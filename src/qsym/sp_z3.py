from typing import Any, Tuple, Optional
from .sp_utils import _cn, _call0

try:
    import z3
    HAS_Z3 = True
except ImportError:
    HAS_Z3 = False
# -----------------------------
# Tier-1: Z3 Translator (Classical Logic)
# -----------------------------

class Z3Translator:
    def __init__(self):
        self.vars = {}

    def get_var(self, name: str):
        if name not in self.vars:
            self.vars[name] = z3.Int(name)
        return self.vars[name]

    def mk_pow2(self, base, exp, limit=256):
        """
        Generates a linear If-Then-Else chain for base^exp.
        Avoids Z3's non-linear logic (which fails on unbound vars).
        """
        # Start with the fallback (if exp > limit) -> just return 0 or unconstrained
        chain = z3.IntVal(0) 
        
        # Build the chain backwards: If(e==3, b^3, If(e==2, b^2, ...))
        for i in range(limit, -1, -1):
            
            # Calculate the concrete value of base^i
            if hasattr(base, "as_long"): # Base is concrete (e.g. 2)
                val = base.as_long() ** i
                term = z3.IntVal(val)
            else:
                # Base is symbolic. We unroll multiplication: b*b*...*b
                # (Rare in your constraints, usually base is concrete 2)
                term = z3.IntVal(1)
                if i > 0:
                    term = base
                    for _ in range(i - 1): term = term * base
            
            chain = z3.If(exp == i, term, chain)
        
        return chain

    def trans(self, node: Any) -> Any:
        if node is None: return None
        cn = _cn(node)
        
        if cn == "QXNum": return z3.IntVal(int(_call0(node, "num", 0)))
        if cn == "QXBind": return self.get_var(str(_call0(node, "ID", "?")))
            
        if cn == "QXBin":
            op = str(_call0(node, "op"))
            l = self.trans(_call0(node, "left"))
            r = self.trans(_call0(node, "right"))
            if l is None or r is None: return None
            
            if op == "+": return l + r
            if op == "-": return l - r
            if op == "*": return l * r
            if op == "/": return l / r 
            if op == "%": 
                if hasattr(l, "is_int") and not l.is_int(): l = z3.ToInt(l)
                if hasattr(r, "is_int") and not r.is_int(): r = z3.ToInt(r)
                return l % r
            
            # Use the helper
            if op == "^": return self.mk_pow2(l, r)

            return None

        # Logic & Comparisons (Chained handling included)
        if cn == "QXComp":
            op = str(_call0(node, "op"))
            left_node = _call0(node, "left")
            right_node = _call0(node, "right")

            # Handle Chained Comparison: (1 < base) < N
            if _cn(left_node) == "QXComp":
                middle_node = _call0(left_node, "right")
                c1 = self.trans(left_node)
                mid = self.trans(middle_node)
                r = self.trans(right_node)
                if mid is None or r is None: return None
                
                c2 = None
                if op == "<": c2 = mid < r
                elif op == "<=": c2 = mid <= r
                elif op == ">": c2 = mid > r
                elif op == ">=": c2 = mid >= r
                elif op == "==": c2 = mid == r
                
                if c1 is None or c2 is None: return None
                return z3.And(c1, c2)

            # Normal Case
            l, r = self.trans(left_node), self.trans(right_node)
            if l is None or r is None: return None
            if op == "==": return l == r
            if op == "!=": return l != r
            if op == "<":  return l < r
            if op == "<=": return l <= r
            if op == ">":  return l > r
            if op == ">=": return l >= r
            return None

        if cn == "QXLogic":
            op = str(_call0(node, "op")).lower()
            if op in ("not", "!"):
                return z3.Not(self.trans(_call0(node, "left")))
            l, r = self.trans(_call0(node, "left")), self.trans(_call0(node, "right"))
            if l is None or r is None: return None
            if op in ("&&", "and"): return z3.And(l, r)
            if op in ("||", "or"):  return z3.Or(l, r)
            if op == "==>": return z3.Implies(l, r)

        return None

def entails_pc_tier1_z3(pc, goal) -> Tuple[bool, str, Optional[Any]]:
    if not HAS_Z3: return False, "Tier-1 Skipped (No Z3)", None
    
    tr = Z3Translator()
    s = z3.Solver()
    
    # 1. Assert PC
    for p in pc:
        c = tr.trans(p)
        if c is not None: 
            s.add(c)
        
    # 2. Assert Negated Goal
    g = tr.trans(goal)
    if g is None: 
        return False, "Tier-1: Goal trans failed", None
    
    s.add(z3.Not(g))
    
    # 3. Check
    res = s.check()
    if res == z3.unsat: return True, "Tier-1: Z3 Proved Valid", None
    if res == z3.sat:   return False, "Tier-1: Counterexample", s.model()
    return False, "Tier-1: Unknown", None