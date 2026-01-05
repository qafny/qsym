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
