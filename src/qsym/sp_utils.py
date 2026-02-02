from __future__ import annotations

"""
sp_utils.py

Shared, *low-level* helpers used across the pipeline.

Design constraints
------------------
- Must remain import-cycle-free: do not import sp_rewrite/sp_simplify/sp_normalization.
- Keep these helpers "dumb": duck-typing, small constructors, and tiny utilities only.
- Prefer local imports of Programmer AST classes inside constructors to avoid import-time coupling.
"""

from typing import Any, Optional


# -------------------------
# Tiny duck-typing helpers
# -------------------------

def _cn(x: Any) -> str:
    return getattr(x, "__class__", type(x)).__name__


def _call0(obj: Any, name: str, default=None):
    """
    Call a zero-arg getter method if present (e.g., node.left()),
    else treat as field access (e.g., node.left).
    """
    f = getattr(obj, name, None)
    if callable(f):
        try:
            return f()
        except Exception:
            return default
    return getattr(obj, name, default)


# -------------------------
# AST constructors (Programmer.py nodes)
# -------------------------

def _mk_bind(name: str):
    from Programmer import QXBind
    return QXBind(id=name)


def _mk_num(i: int):
    from Programmer import QXNum
    return QXNum(num=i)


def _mk_bin(op: str, left: Any, right: Any):
    from Programmer import QXBin
    return QXBin(op=op, left=left, right=right)


def _mk_uni(op: str, nxt: Any):
    from Programmer import QXUni
    return QXUni(op=op, next=nxt)


def _mk_call(fid: str, exps: list[Any], inverse: bool = False):
    from Programmer import QXCall
    return QXCall(id=fid, exps=exps, inverse=inverse)


def _mk_crange(lo: Any, hi: Any):
    from Programmer import QXCRange
    return QXCRange(left=lo, right=hi)


def _mk_con(id_: str, cr: Any, cond: Any = None):
    from Programmer import QXCon
    try:
        return QXCon(id=id_, crange=cr, condtion=cond)
    except TypeError:
        return QXCon(id=id_, crange=cr, condition=cond)


def _mk_sket(v: Any):
    from Programmer import QXSKet
    return QXSKet(vector=v)


def _mk_tensor(kets: list[Any]):
    from Programmer import QXTensor
    return QXTensor(kets=kets, id='None', crange=None)


def _mk_sum(cons: list[Any], amp: Any, tensor: Any):
    from Programmer import QXSum
    return QXSum(sums=cons, amp=amp, tensor=tensor)


def _mk_had(s: str):
    from Programmer import QXHad
    return QXHad(s)

class FreeVarCollector:
    def __init__(self):
        self.free = set()
        self.bound = set()

    def visit(self, node: Any):
        if node is None: return
        cn = _cn(node)

        # 1. QXSum (Quantum State Sums)
        if cn == "QXSum":
            # Visit bounds first (e.g. 0..N) - N is free
            cons = list(_call0(node, "sums", []) or [])
            for c in cons:
                self.visit(_call0(c, "crange"))
            
            # Bind indices (k) - k is bound
            new_binds = []
            for c in cons:
                bid = str(_call0(c, "ID"))
                if bid not in self.bound:
                    self.bound.add(bid)
                    new_binds.append(bid)
            
            # Visit body with k bound
            self.visit(_call0(node, "amp"))
            self.visit(_call0(node, "tensor"))
            self.visit(_call0(node, "kets"))

            # Unbind
            for bid in new_binds: self.bound.remove(bid)
            return

        # defensive check
        if cn == "IIter":
            # Visit loop bounds (0..N) - N is free
            self.visit(_call0(node, "lo"))
            self.visit(_call0(node, "hi"))
            
            # Bind loop var (i) - i is bound
            bid = str(_call0(node, "binder"))
            is_new = False
            if bid not in self.bound:
                self.bound.add(bid)
                is_new = True
            
            # Visit the summarized body
            self.visit(_call0(node, "body_summary"))
            self.visit(_call0(node, "term"))
            
            if is_new: self.bound.remove(bid)
            return

        # 3. Variable Usage
        if cn == "QXBind":
            name = str(_call0(node, "ID"))
            if name not in self.bound:
                self.free.add(name)
            return

        # 4. Standard Recursion (Gates, Ops, Expressions)

        children_attrs = [
            "left", "right", "op", "exps", "target", "phase", 
            "condtion", "factors", "pre_term", "meas_value", "crange",
            "steps", "controls", "targets", "guard" # 
        ]
        
        for attr in children_attrs:
            child = _call0(node, attr)
            if isinstance(child, (list, tuple)):
                for c in child: self.visit(c)
            else:
                self.visit(child)

def get_real_free_vars(node: Any) -> Set[str]:
    c = FreeVarCollector()
    c.visit(node)
    return c.free
