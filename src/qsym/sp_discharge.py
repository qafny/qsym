from __future__ import annotations

from dataclasses import dataclass
from typing import Any, List, Optional, Tuple, Dict

from .sp_state import VC, ExecState
from .sp_normalization import normalize_qspec
from .sp_utils import _cn, _call0
import random

try:
    import z3
    HAS_Z3 = True
except ImportError:
    HAS_Z3 = False

# Import the logic
from .sp_z3 import entails_pc_tier1_z3
from .sp_pbt import entails_qspec_tier2_pbt, entails_pred_tier2_pbt

# -----------------------------
# Configuration & Result
# -----------------------------

@dataclass(frozen=True)
class DischargeResult:
    vc: VC
    ok: bool
    reason: str
    tier: int
    norm_vc: Optional[VC] = None
    evidence: Optional[Any] = None

@dataclass(frozen=True)
class DischargeConfig:
    enable_tier1_z3: bool = True
    enable_tier2_pbt: bool = True
    enable_tier2_hypothesis: bool = True   
    pbt_samples: int = 5                  # number of env models or outer repeats
    hyp_k_examples: int = 200              # number of k samples per env
    pbt_max_int: int = 8
    pbt_seed: int = 42


# -----------------------------
# Tier-0 Helper: Strict Match (Ignore En Flag) For internal debug purpose
# -----------------------------

def strict_eq_ignore_en(s1: Any, s2: Any) -> bool:
    """
    Tier-0 Check:
    1. Locus must match exactly (repr).
    2. States must match exactly (repr).
    3. Qty must match class name, but we IGNORE the flag inside TyEn.
    """
    if s1 is s2: return True
    if s1 is None or s2 is None: return False

    # 1. Compare Locus
    l1 = list(_call0(s1, "locus", []) or [])
    l2 = list(_call0(s2, "locus", []) or [])
    if repr(l1) != repr(l2): 
        return False

    # 2. Compare States (Strict Term Equality)
    st1 = list(_call0(s1, "states", []) or [])
    st2 = list(_call0(s2, "states", []) or [])
    if repr(st1) != repr(st2): 
        return False

    # 3. Compare Qty (Blind Flag Check)
    q1 = _call0(s1, "qty")
    q2 = _call0(s2, "qty")
    cn1 = _cn(q1)
    cn2 = _cn(q2)

    if cn1 != cn2: 
        return False # Mismatch (e.g. TyNor vs TyEn)
    
    if cn1 == "TyEn": 
        return True # Both are En; ignore the flag content!
        
    # For TyNor, TyHad, etc., exact match is fine
    return repr(q1) == repr(q2)


# -----------------------------
# Main API
# -----------------------------



def entails_pc_tier0(pc, goal) -> Tuple[bool, str]:
    if any(repr(c) == repr(goal) for c in pc): return True, "Tier-0: Literal Match"
    return False, "Tier-0 Failed"

def discharge_vc(st: ExecState, vc: VC, cfg: Optional[DischargeConfig] = None) -> DischargeResult:
    cfg = cfg or DischargeConfig()
    cons = vc.consequent
    if not cons: return DischargeResult(vc, False, "No consequent", 0)

    # Tier 1 (Classical)
    if _cn(cons) in ("QXComp", "QXLogic"):
        if cfg.enable_tier1_z3:
            ok, why, ev = entails_pc_tier1_z3(vc.antecedent_pc, cons)
            if ok: return DischargeResult(vc, True, why, 1)
            return DischargeResult(vc, False, why, 1, evidence=ev)
        return DischargeResult(vc, False, "Tier-1 Disabled", 0)

        # 3. Try Tier-2 (Quantum Amplitude Check)
        #    If the predicate depends on a quantum measurement 'y', check if
        #    all violating 'y' values have 0 amplitude.
        if cfg.enable_tier2_pbt:
            # We need to pass the antecedent QUANTUM PROGRAM, not just PC
            ok, why, ev = entails_pred_tier2_pbt(st, vc, cfg)
            if ok: return DischargeResult(vc, True, why, 2)
            
            # If Tier 2 also fails, return the Tier 1 Z3 evidence as the main reason
            return DischargeResult(vc, False, "Tier-1 & Tier-2 Failed", 1, evidence=ev)
        
        return DischargeResult(vc, False, "Tier-1 Counterexample", 1)

    # === B. Quantum Obligations (QSpec) ===
    if _cn(cons) == "QXQSpec":
        
        # 1. Find matching component
        goal_locus = list(_call0(cons, "locus", []) or [])
        ant_spec = None
        for cid, spec in vc.antecedent_qstore.items():
            l2 = list(_call0(spec, "locus", []) or [])
            if len(l2) == len(goal_locus) and all(repr(a)==repr(b) for a,b in zip(l2, goal_locus)):
                ant_spec = spec
                break
        
        if not ant_spec:
            return DischargeResult(vc, False, "No matching component", 0)

        # 2. Normalize
        antN = normalize_qspec(ant_spec, st)
        goalN = normalize_qspec(cons, st)

        from .sp_pretty import pp
        print(f"verifying: {pp(antN)} ==> {pp(goalN)}")
        
        # Tier 0: Strict Equality, skip for now to work on pbt 
        # if strict_eq_ignore_en(antN, goalN):
        #     return DischargeResult(vc, True, "Tier-0: Exact Match", 0)

        # Tier 2: PBT Structure Check
        if cfg.enable_tier2_pbt:
            ok, why, ev = entails_qspec_tier2_pbt(st, antN, goalN, cfg)
            if ok:
                return DischargeResult(vc, True, why, 2)
            return DischargeResult(vc, False, why, 2, evidence=ev)

        return DischargeResult(vc, False, "Tier-0 Mismatch", 0)

    return DischargeResult(vc, False, "Unsupported VC", 0)

def discharge_all(final_states: List[ExecState], cfg: Optional[DischargeConfig] = None) -> Tuple[List, List]:
    cfg = cfg or DischargeConfig()
    ok, bad = [], []
    for st in final_states:
        for vc in st.vcs:
            r = discharge_vc(st, vc, cfg)
            (ok if r.ok else bad).append(r)
    return ok, bad