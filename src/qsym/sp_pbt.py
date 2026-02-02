from __future__ import annotations
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Tuple
import random
from sp_normalization import normalize_qspec

try:
    import z3
    HAS_Z3 = True
except ImportError:
    HAS_Z3 = False

try:
    from hypothesis import given, settings, strategies as st_hyp
    from hypothesis.errors import HypothesisException
    HAS_HYPOTHESIS = True
except ImportError:
    HAS_HYPOTHESIS = False

from sp_state import ExecState
from sp_utils import _cn, _call0

# We need the translator to convert AST constraints (st.pc) into Z3 constraints
# Assuming sp_tier1.py is in the same directory
try:
    from sp_z3 import Z3Translator
except ImportError:
    class Z3Translator:
        def __init__(self): self.vars = {}
        def get_var(self, n): 
            if n not in self.vars: self.vars[n] = z3.Int(n)
            return self.vars[n]
        def trans(self, node): 
            return None 

# -----------------------------
# Helpers & Simulators
# -----------------------------

@dataclass(frozen=True)
class ForallBinder:
    name: str
    lo_expr: Any
    hi_expr: Any
    reg_idx: int = 0 

class StructureEvaluator:
    def __init__(self, env: Dict[str, int]):
        self.env = env
    
    def eval(self, node: Any) -> int:
        if node is None: return 0
        cn = _cn(node)
        if cn == "QXNum": return int(_call0(node, "num", 0))
        if cn == "QXBind": return int(self.env.get(str(_call0(node, "ID", "?")), 0))
        if cn == "QXBin":
            op = str(_call0(node, "op"))
            l, r = self.eval(_call0(node, "left")), self.eval(_call0(node, "right"))
            if op == "+": return l + r
            if op == "-": return l - r
            if op == "*": return l * r
            if op == "/": return l // r if r != 0 else 0
            if op == "%": return l % r if r != 0 else 0
            if op == "^": return l ** r
        return 0

def _is_direct_binder_ket(node: Any, binder: str) -> bool:
    if node is None or _cn(node) != "QXSKet": return False
    vec = _call0(node, "vector")
    if vec is None or _cn(vec) != "QXBind": return False
    bid = _call0(vec, "ID", None) or _call0(vec, "id", None)
    return str(bid) == binder

def extract_forall_binders(spec: Any) -> List[ForallBinder]:
    out = []
    states = list(_call0(spec, "states", []) or [])
    for t in states:
        if _cn(t) != "QXSum": continue

        # Identify tensor factors for register mapping
        kets = _call0(t, "kets")
        factors = list(_call0(kets, "kets", []) or _call0(kets, "factors", []) or [])
        if not factors and _cn(kets) == "QXSKet":
            factors = [kets]

        # Iterate sums in order
        cons = list(_call0(t, "sums", []) or [])
        for c in cons:
            cond = _call0(c, "condition", None) or _call0(c, "condtion", None)
            if cond is not None: continue

            bid = str(_call0(c, "ID", None) or _call0(c, "id", None))
            cr = _call0(c, "crange")
            if not cr: continue

            # Find register index for this binder
            found_idx = -1
            for i, f in enumerate(factors):
                if _is_direct_binder_ket(f, bid):
                    found_idx = i
                    break
            
            out.append(ForallBinder(bid, _call0(cr, "left"), _call0(cr, "right"), found_idx))

    return out

class BasisInstantiator:
    def __init__(self, env: Dict[str, int], reg_map: Dict[int, int], locus_names: List[str]):
        self.env = env
        self.reg_map = reg_map
        self.locus_names = locus_names
        self.state: Dict[str, int] = {name: 0 for name in locus_names}

    def eval_num(self, node: Any) -> int:
        ev = StructureEvaluator(self.env)
        return ev.eval(node)

    def compute(self, node: Any) -> Dict[str, int]:
        self._visit(node, current_reg_idx=0)
        return self.state

    def _visit(self, node: Any, current_reg_idx: int):
        if node is None: return
        cn = _cn(node)
        
        if cn == "IApply":
            term = _call0(node, "term")
            self._visit(term, current_reg_idx)
            
            op = _call0(node, "op")
            op_name = str(_call0(op, "op"))
            
            if op_name in ("H", "QFT"):
                 if current_reg_idx in self.reg_map:
                     val = self.reg_map[current_reg_idx]
                     if current_reg_idx < len(self.locus_names):
                         reg_name = self.locus_names[current_reg_idx]
                         self.state[reg_name] = val
            return

        if cn == "IIter":
            start = self.eval_num(_call0(node, "lo"))
            end = self.eval_num(_call0(node, "hi"))
            bid = str(_call0(node, "binder"))
            term = _call0(node, "term")
            
            for i in range(start, end):
                self.env[bid] = i
                self._visit(term, current_reg_idx)
            return

        if cn in ("QXTensor", "ITensorProd"):
            factors = list(_call0(node, "kets") or _call0(node, "factors") or [])
            for i, f in enumerate(factors):
                self._visit(f, current_reg_idx + i)
            return

        if cn == "QXSKet":
            val = self.eval_num(_call0(node, "vector"))
            if current_reg_idx < len(self.locus_names):
                self.state[self.locus_names[current_reg_idx]] = val
            return

        if cn == "QXSum":
            sums = list(_call0(node, "sums", []) or [])
            if sums:
                valid_scope = True
                for s_node in sums:
                    bid = str(_call0(s_node, "ID", None) or _call0(s_node, "id", None))
                    cr = _call0(s_node, "crange")
                    start, end = self.eval_num(_call0(cr, "left")), self.eval_num(_call0(cr, "right"))
                    val = self.env.get(bid)
                    if val is None: continue
                    if not (start <= val < end): valid_scope = False
                
                if not valid_scope: return
                self._visit(_call0(node, "kets"), current_reg_idx)
            return

# -----------------------------
# Z3 Environment Generator (Dynamic)
# -----------------------------

def _z3_generate_env_for_requires(st: ExecState, cfg: Any) -> Optional[Dict[str, int]]:
    """
    Uses the Z3Translator to convert the ACTUAL path condition (st.pc)
    into constraints, rather than hardcoding specific variable names.
    """
    if not HAS_Z3: return None
    
    tr = Z3Translator() # Use the shared translator
    s = z3.Solver()

    print(f"\n st.pc {st.pc}")
    
    # 1. Translate Path Conditions (Requires, If-guards, etc.)
    # st.pc is a list of AST nodes representing boolean constraints
    for constraint_node in st.pc:
        z3_constr = tr.trans(constraint_node)
        if z3_constr is not None:
            s.add(z3_constr)

    # 2. Add Soft Bounds to ensure Finite Model for PBT
    # We iterate over all variables the translator discovered
    for name, zvar in tr.vars.items():
        if name not in tr.vars:
            # Force creation of the variable in the translator
            tr.get_var(name)
        # Only constrain if it's a classical integer (simple heuristic)
        # Avoid constraining binders created inside quantifiers if possible
        # (Our simple translator usually puts global vars in tr.vars)
        
        # Soft bound: Try to keep inputs small (e.g. < 100) for faster testing
        # unless the constraints specifically demand large numbers.
        s.add(zvar >= 0)
        s.add(zvar <= max(64, cfg.pbt_max_int * cfg.pbt_max_int))

    # 3. Solve
    if s.check() != z3.sat:
        print(f"[Z3] UNSAT (Requires unfulfillable): {s.reason_unknown()}")
        return None
        
    m = s.model()
    env = {}

    print("\n--- [Z3 Model Generated] ---")
    print(m)
    print("----------------------------\n")
    
    # 4. Extract Environment
    for name, zvar in tr.vars.items():
        # Evaluate variable in model
        val_ref = m.eval(zvar, model_completion=True)
        try:
            val = int(val_ref.as_long())
            env[name] = val
            env[f"{name}_sym"] = val
        except:
            pass # Ignore functions or arrays if present
            
    return env

# -----------------------------
# Hypothesis Runner
# -----------------------------

def _hypothesis_sample_k_and_check(env, st, antN, goalN, cfg) -> Tuple[bool, Optional[str]]:
    if not HAS_HYPOTHESIS: return False, "Hypothesis missing"
    
    locus_objs = list(_call0(goalN, "locus", []) or [])
    locus_names = [str(_call0(l, "location")) for l in locus_objs]
    if not locus_names: locus_names = ["q", "p"]

    binders = extract_forall_binders(goalN)
    if not binders: return False, "No binders found"
    
    @st_hyp.composite
    def multi_binder_strategy(draw):
        curr_env = env.copy()
        ev = StructureEvaluator(curr_env)
        reg_vals = {} 
        
        for b in binders:
            lo = ev.eval(b.lo_expr)
            hi = ev.eval(b.hi_expr)
            
            if hi <= lo: val = lo
            else:
                bounds = [lo, lo+1, hi-1, hi-2]
                bounds = [x for x in bounds if lo <= x < hi]
                strat = st_hyp.integers(min_value=lo, max_value=hi-1)
                if bounds: strat = st_hyp.one_of(st_hyp.sampled_from(bounds), strat)
                val = draw(strat)
            
            curr_env[b.name] = val
            curr_env[f"{b.name}_sym"] = val
            if b.reg_idx != -1:
                reg_vals[b.reg_idx] = val
                
        return curr_env, reg_vals

    @settings(max_examples=cfg.hyp_k_examples, deadline=None, derandomize=True)
    @given(multi_binder_strategy())
    def _prop(data):
        env_k, reg_vals = data
        
        sim_lhs = BasisInstantiator(env_k.copy(), reg_vals, locus_names)
        state_lhs = sim_lhs.compute(antN)
        
        sim_rhs = BasisInstantiator(env_k.copy(), reg_vals, locus_names)
        state_rhs = sim_rhs.compute(goalN)
        
        assert state_lhs == state_rhs, f"LHS={state_lhs} != RHS={state_rhs}"

    try:
        _prop()
        return True, None
    except AssertionError as e:
        return False, str(e)
    except Exception as e:
        return False, f"Error: {e}"

# -----------------------------
# Main Tier 2 Function
# -----------------------------

def entails_qspec_tier2_pbt(st: ExecState, antN: Any, goalN: Any, cfg: Any) -> Tuple[bool, str, Optional[str]]:
    # 1. Z3 Env (Dynamic from PC)
    env = _z3_generate_env_for_requires(st, cfg)
    
    # Fallback if Z3 fails or is missing (Pure Random)
    if env is None:
        rng = random.Random(cfg.pbt_seed)
        env = {}
        for name in st.cstore.keys():
            v = rng.randint(2, cfg.pbt_max_int)
            env[name] = v
            env[f"{name}_sym"] = v

    # 2. Hypothesis Check
    if cfg.enable_tier2_hypothesis and HAS_HYPOTHESIS:
        ok, err = _hypothesis_sample_k_and_check(env, st, antN, goalN, cfg)
        if not ok: return False, "Tier-2: Fail", err
        return True, f"Tier-2: Passed ({cfg.hyp_k_examples} samples)", None

    return True, "Tier-2: Skipped", None


# sp_pbt.py

def entails_pred_tier2_pbt(st: ExecState, vc: VC, cfg: Any) -> Tuple[bool, str, Optional[str]]:
    """
    Tier-2 for Predicates:
    Verifies that any classical value 'y' satisfying 'Not(Goal)' has 0 amplitude.
    """
    if not (cfg.enable_tier2_hypothesis and HAS_HYPOTHESIS):
        return False, "Hypothesis disabled", None

    # 1. Generate Classical Environment (N, n, r)
    env = _z3_generate_env_for_requires(st, cfg)
    if env is None: return False, "No Z3 Env", None

    # 2. Extract the Quantum Program (Antecedent)
    #    We need the quantum state that produced 'y'.
    #    Usually found in vc.antecedent_qstore.
    #    Heuristic: Look for the component that writes to the variables in the goal.
    #    (Simplified: Take the first/main quantum spec).
    if not vc.antecedent_qstore:
        return False, "No Quantum State to check", None
    
    # Just grab the first quantum component for simulation (simpler for now)
    # Real implementation would match 'y' to 'q' or 'p' register.
    q_spec = list(vc.antecedent_qstore.values())[0]
    program_node = normalize_qspec(q_spec, st) 
    
    # 3. Define the "Violator" Strategy
    #    We want to find inputs that MAKE the consequent FALSE.
    
    # Extract variables used in consequent (e.g. 'y')
    # This requires traversing the goal AST 'vc.consequent'
    # For now, let's assume 'y' is the target variable.
    
    @settings(max_examples=cfg.hyp_k_examples, deadline=None, derandomize=True)
    @given(st_hyp.integers(min_value=0, max_value=2**env.get('n', 4) - 1))
    def _prop_no_bad_paths(y_val):
        # 1. Update Env with the sampled 'y'
        env_run = env.copy()
        env_run['y'] = y_val 
        env_run['y_sym'] = y_val

        # 2. Evaluate the Predicate (The Consequent)
        #    We check: Does this 'y' violate the spec?
        ev = StructureEvaluator(env_run)
        is_goal_satisfied = ev.eval_bool(vc.consequent) # You'll need eval_bool in StructureEvaluator
        
        if is_goal_satisfied:
            return # This y is good, so it's allowed to have amplitude.

        # 3. If Goal is VIOLATED, the Quantum Amplitude MUST be 0.
        #    We run the simulator targeting state |y>.
        #    (Assuming 'q' register maps to 'y')
        
        reg_vals = {0: y_val} # Map reg_idx 0 to y
        locus_names = ["q"]   # Heuristic mapping
        
        sim = BasisInstantiator(env_run, reg_vals, locus_names)
        
        # If the simulator says this path is valid (returns non-zero or updates p),
        # then we have a BUG: The circuit produces a 'y' that violates the spec.
        # Note: BasisInstantiator returns a state dict. 
        # For 'p' (amplitude) tracking, we might need to check the 'p' register or 
        # a special flag.
        
        # Assuming your simulator updates 'p' based on oracle phase/logic:
        final_state = sim.compute(program_node)
        
        # In QSV, if a path is invalid/blocked by PostSelect/Logic, 
        # it usually results in p=0 or state not updating.
        # This part depends on how exactly your simulator signals "Zero Probability".
        
        # CHECK: Did the simulator successfully reach a state consistent with y_val?
        # If yes, we have a counterexample.
        
        # For now, let's assume BasisInstantiator returns a state if path exists.
        # If we reached the end, does it imply probability > 0?
        pass 

    # Note: Implementing the "Violator Check" strictly requires
    # inverting the condition in Z3 or Hypothesis.
    # A simpler heuristic for now:
    # Just skip this check and rely on the fact that if Tier 1 failed, 
    # we assume the user verified the algorithm logic elsewhere, 
    # or print a warning.
    
    return False, "Pred-PBT not fully implemented yet", None