from __future__ import annotations

from dataclasses import dataclass, replace
from typing import Any, Dict, List, Optional, Tuple

from sp_state import VC, ExecState
from sp_normalization import normalize_qspec  # your normalizer that rewrites terms
from sp_utils import _cn, _call0
# -----------------------------
# Result type
# -----------------------------

@dataclass(frozen=True)
class DischargeResult:
    vc: VC
    ok: bool
    reason: str
    tier: int
    norm_vc: Optional[VC] = None
    evidence: Optional[Any] = None  # e.g., Z3 model, PBT counterexample, lemma trace

@dataclass(frozen=True)
class DischargeConfig:
    enable_tier1_z3: bool = True
    enable_tier2_pbt: bool = True
    enable_tier3_smalln: bool = False

    # PBT knobs (Tier-2)
    pbt_samples: int = 64
    pbt_seed: Optional[int] = None

    # Small-n knobs (Tier-3)
    smalln_max: int = 8   


# -----------------------------
# Small utilities
# -----------------------------

def _locus_list(spec: Any) -> List[Any]:
    try:
        return list(spec.locus())
    except Exception:
        return list(getattr(spec, "locus", []) or [])

def _states_list(spec: Any) -> List[Any]:
    try:
        return list(spec.states())
    except Exception:
        return list(getattr(spec, "states", []) or [])

def _qty_of(spec: Any) -> Any:
    try:
        return spec.qty()
    except Exception:
        return getattr(spec, "qty", None)

def _same_locus(L1: List[Any], L2: List[Any]) -> bool:
    # You can strengthen this later (structural QXQRange equality).
    if len(L1) != len(L2):
        return False
    return all(repr(a) == repr(b) for a, b in zip(L1, L2))

def _find_spec_by_locus(qstore: Dict[Any, Any], locus: List[Any]) -> Optional[Any]:
    for _, spec in qstore.items():
        if _same_locus(_locus_list(spec), locus):
            return spec
    return None


# -----------------------------
# PC entailment (Tier-0)
# -----------------------------

def _pc_contains(pc: Tuple[Any, ...], goal: Any) -> bool:
    return any(repr(c) == repr(goal) for c in pc)

def entails_pc_tier0(pc: Tuple[Any, ...], goal: Any) -> Tuple[bool, str]:
    """
    purely syntactic containment + your common interval pattern.
    """
    if _pc_contains(pc, goal):
        return True, "goal is literally in PC"

    # Handle chained goal of the form: ((0 <= v) <= n) which your pretty-printer emits.
    if _cn(goal) == "QXComp" and _cn(_call0(goal, "left")) == "QXComp":
        inner = _call0(goal, "left")
        outer_right = _call0(goal, "right")

        # Want inner=(0<=v) and also (v<=outer_right)
        # We accept if PC contains both conjuncts syntactically.
        from Programmer import QXComp, QXNum, QXBind

        def is_0_le_v(x: Any) -> bool:
            return (
                _cn(x) == "QXComp"
                and _call0(x, "op") == "<="
                and _cn(_call0(x, "left")) == "QXNum"
                and int(_call0(_call0(x, "left"), "num", -1)) == 0
                and _cn(_call0(x, "right")) == "QXBind"
                and str(_call0(_call0(x, "right"), "ID")) == "v"
            )

        def is_v_le_hi(x: Any, hi: Any) -> bool:
            return (
                _cn(x) == "QXComp"
                and _call0(x, "op") == "<="
                and _cn(_call0(x, "left")) == "QXBind"
                and str(_call0(_call0(x, "left"), "ID")) == "v"
                and repr(_call0(x, "right")) == repr(hi)
            )

        has_lo = any(is_0_le_v(c) for c in pc)
        has_hi = any(is_v_le_hi(c, outer_right) for c in pc)
        if has_lo and has_hi:
            return True, "interval facts (0<=v) and (v<=hi) found in PC"

    return False, "PC entailment failed at Tier-0"


# -----------------------------
# QSpec entailment
# -----------------------------

def entails_qspec_tier0(st: ExecState, ant_qstore: Dict[Any, Any], goal_spec: Any) -> Tuple[bool, str]:
    """
      - find exact-locus match in antecedent qstore
      - normalize both specs
      - check single-term equality by repr
    """
    goal_locus = _locus_list(goal_spec)
    ant_spec = _find_spec_by_locus(ant_qstore, goal_locus)
    if ant_spec is None:
        return False, f"no antecedent component with locus={goal_locus}"

    # Normalize both sides. This is where everything fire.
    antN = normalize_qspec(ant_spec, st)
#    goalN = goal_spec
    goalN = normalize_qspec(goal_spec, st)

    from sp_pretty import pp
    print(f"\n entails: {pp(antN)} ==> {pp(goalN)}")

    # Debug-friendly normalized qstore snapshot
    norm_qstore = None
    try:
        norm_qstore = dict(ant_qstore)
        for cid, spec in ant_qstore.items():
            if spec is ant_spec:
                norm_qstore[cid] = antN
                break
    except Exception:
        norm_qstore = None

    # qty match (optional but recommended)
    # if repr(_qty_of(antN)) != repr(_qty_of(goalN)):
    #     return False, "qty mismatch after normalization", norm_qstore

    ant_states = _states_list(antN)
    goal_states = _states_list(goalN)

    if len(ant_states) != len(goal_states):
        return False, f"state arity mismatch (ant={len(ant_states)}, goal={len(goal_states)})", norm_qstore

    # strict repr equality for now
    for a, g in zip(ant_states, goal_states):
        if repr(a) != repr(g):
            print(f"\n DEBUG MISMATCH:")
            print(f"LHS Repr: {repr(ant_states[0])}")
            print(f"RHS Repr: {repr(goal_states[0])}")
            return False, "state mismatch after normalization", norm_qstore

    return True, "matched after normalization (Tier-0)", norm_qstore


# -----------------------------------------------------------------------------
# Tier-1: Z3 entailment (classical + extracted constraints)
# -----------------------------------------------------------------------------

def entails_pc_tier1_z3(st: ExecState, pc: Tuple[Any, ...], goal: Any) -> Tuple[bool, str, Optional[Any]]:
    """
    Tier-1 Z3 entailment:
      PC |= goal

    Implementation strategy in your codebase:
      - use your existing eval_to_z3(...) from sp_eval on each PC clause and on goal
      - check UNSAT of PC ∧ ¬goal
      - if SAT, return a counterexample model

    This file provides a safe adapter; if sp_eval is unavailable, Tier-1 is skipped.
    """
    try:
        import z3
        from sp_eval import eval_to_z3  # your existing translator
    except Exception as e:
        return False, f"Tier-1 skipped (missing z3/sp_eval): {e}", None

    z3_pc = []
    for c in pc:
        z = eval_to_z3(c, st.cstore)
        if z is not None:
            z3_pc.append(z)

    z_goal = eval_to_z3(goal, st.cstore)
    if z_goal is None:
        return False, "Tier-1: goal could not be translated to Z3", None

    s = z3.Solver()
    s.add(z3_pc)
    s.add(z3.Not(z_goal))

    if s.check() == z3.unsat:
        return True, "PC entails goal (Z3 UNSAT of PC ∧ ¬goal)", None

    m = s.model()
    return False, "Z3 found counterexample (PC ∧ ¬goal is SAT)", m

# Placeholder: extracted constraints from QXQSpec patterns -> Z3
def entails_qspec_tier1_extracted(st: ExecState, ant_specN: Any, goal_specN: Any) -> Tuple[bool, str, Optional[Any]]:
    """
    Tier-1 for QSpecs is *not* full amplitude equality.
    Instead, extract classical constraints implied by common patterns, e.g.:

      Σ k∈[0,2^n) . |k> |f(k)>
        => k bounds, domain/range bounds for f, modular arithmetic well-formedness, etc.

    This is intentionally left as a stub hook; you will plug in your extractor here.
    """
    return False, "Tier-1 QSpec extraction not implemented", None

# -----------------------------------------------------------------------------
# Tier-2: PBT validation for uniform-superposition transitions
# -----------------------------------------------------------------------------

def entails_qspec_tier2_pbt(st: ExecState, ant_specN: Any, goal_specN: Any, cfg: DischargeConfig) -> Tuple[bool, str, Optional[Any]]:
    """
    Tier-2 uses sampling to validate the *per-basis transition* relationship between
    antecedent and goal patterns, rather than full statevector equality.

    Expected use cases:
      - H-prepared uniform superpositions
      - oracle-style mappings |k> |0> -> |k> |f(k)>
      - modular exponentiation (Shor) style mappings, *as long as the state is uniform in k*

    This is provided as a stub:
      - It returns "skipped" unless you implement an evaluator for the ket expressions.
    """
    return False, "Tier-2 PBT validator not implemented (hook only)", None

# -----------------------------------------------------------------------------
# Tier-3: amplitude checks for small n
# -----------------------------------------------------------------------------

def entails_qspec_tier3_smalln(st: ExecState, ant_specN: Any, goal_specN: Any, cfg: DischargeConfig) -> Tuple[bool, str, Optional[Any]]:
    """
    Tier-3 is optional and should be used sparingly:
      - when n is concretized and small
      - or when you have lemma-backed reduction of amplitudes to classical formulas.

    Hook only for now.
    """
    return False, "Tier-3 small-n amplitude check not implemented (hook only)", None
# -----------------------------
# Main API
# -----------------------------

def discharge_vc(st: ExecState, vc: VC, cfg: Optional[DischargeConfig] = None) -> DischargeResult:
    cfg = cfg or DischargeConfig()
    cons = vc.consequent
    if cons is None:
        return DischargeResult(vc=vc, ok=False, reason="VC has no consequent", tier=0)

    # -------------------------
    # Classical obligations
    # -------------------------
    if _cn(cons) in ("QXComp", "QXLogic"):
        ok0, why0 = entails_pc_tier0(vc.antecedent_pc, cons)
        if ok0:
            return DischargeResult(vc=vc, ok=True, reason=why0, tier=0)

        if cfg.enable_tier1_z3:
            ok1, why1, model = entails_pc_tier1_z3(st, vc.antecedent_pc, cons)
            if ok1:
                return DischargeResult(vc=vc, ok=True, reason=why1, tier=1)
            # Tier-1 gives useful evidence even on failure.
            return DischargeResult(vc=vc, ok=False, reason=why1, tier=1, evidence=model)

        return DischargeResult(vc=vc, ok=False, reason=why0, tier=0)

    # -------------------------
    # Quantum obligations (QXQSpec)
    # -------------------------
    if _cn(cons) == "QXQSpec":
        
        ok0, why0, norm_qstore = entails_qspec_tier0(st, vc.antecedent_qstore, cons)
        norm_vc = replace(vc, antecedent_qstore=norm_qstore) if norm_qstore is not None else None
        if ok0:
            return DischargeResult(vc=vc, ok=True, reason=why0, tier=0, norm_vc=norm_vc)

        # Recompute normalized specs for downstream tiers (avoid repeated normalization in each tier)
        goal_locus = _locus_list(cons)
        ant_spec = _find_spec_by_locus(vc.antecedent_qstore, goal_locus)
        antN = normalize_qspec(ant_spec, st) if ant_spec is not None else None
        goalN = normalize_qspec(cons, st)

        if cfg.enable_tier1_z3 and antN is not None:
            ok1, why1, ev1 = entails_qspec_tier1_extracted(st, antN, goalN)
            if ok1:
                return DischargeResult(vc=vc, ok=True, reason=why1, tier=1, norm_vc=norm_vc, evidence=ev1)

        if cfg.enable_tier2_pbt and antN is not None:
            ok2, why2, ev2 = entails_qspec_tier2_pbt(st, antN, goalN, cfg)
            if ok2:
                return DischargeResult(vc=vc, ok=True, reason=why2, tier=2, norm_vc=norm_vc, evidence=ev2)

        #could 
        if cfg.enable_tier3_smalln and antN is not None:
            ok3, why3, ev3 = entails_qspec_tier3_smalln(st, antN, goalN, cfg)
            if ok3:
                return DischargeResult(vc=vc, ok=True, reason=why3, tier=3, norm_vc=norm_vc, evidence=ev3)

        # Fail with the best available explanation (Tier-0 mismatch if nothing else)
        return DischargeResult(vc=vc, ok=False, reason=why0, tier=0, norm_vc=norm_vc)

    return DischargeResult(vc=vc, ok=False, reason=f"unsupported consequent kind: {_cn(cons)}", tier=0)

def discharge_all(final_states: List[ExecState], cfg: Optional[DischargeConfig] = None) -> Tuple[List[DischargeResult], List[DischargeResult]]:
    cfg = cfg or DischargeConfig()
    ok: List[DischargeResult] = []
    bad: List[DischargeResult] = []
    for st in final_states:
        for vc in st.vcs:
            r = discharge_vc(st, vc, cfg)
            (ok if r.ok else bad).append(r)
    return ok, bad
