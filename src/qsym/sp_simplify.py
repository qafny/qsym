
from __future__ import annotations

"""
sp_simplify.py

Purpose
-------
Centralize **expression-level** simplification so that:
- sp_rewrite focuses on **semantic rewrite rules** (H expansion/cancel, oracle rules, loop-summary rules, etc.)
- sp_normalization can enforce a consistent "final form" for amplitudes and arithmetic
  (e.g., (1/sqrt(M))*(1/sqrt(M))  ==>  1/M).

Design notes
------------
- Works on your existing QX AST nodes (QXBin, QXUni, QXNum, QXBind, QXCall, QXSum, QXTensor, QXSKet, etc.)
  via the same `.accept(visitor)` mechanism.
- Also provides a `deep_simplify` helper that traverses internal operational IR nodes
  (IApply/IIter/ITensorProd/IPostSelect) and simplifies any embedded QX expressions.
- Intentionally conservative: we do local algebraic normalization and constant folding,
  but we do *not* attempt heavy arithmetic reasoning (leave that to Z3 / lemma library later).
"""

from dataclasses import dataclass
from typing import Any, Optional, Tuple
from .sp_utils import _cn, _call0, _mk_num, _mk_bin, _mk_uni, _mk_call

# Internal operational nodes
from .sp_terms import IApply, IIter, ILoopSummary, IStep, ICtrlGate, ITensorProd, IPostSelect

def _is_num(x: Any) -> bool:
    return _cn(x) == "QXNum"

def _as_int(x: Any) -> Optional[int]:
    if _cn(x) != "QXNum":
        return None
    try:
        n = _call0(x, "num")
        if isinstance(n, bool):
            return None
        if isinstance(n, int):
            return int(n)
        if isinstance(n, float) and float(n).is_integer():
            return int(n)
    except Exception:
        return None
    return None

def _same_repr(a: Any, b: Any) -> bool:
    return repr(a) == repr(b)

def _is_one(x: Any) -> bool:
    v = _as_int(x)
    return v == 1

def _is_zero(x: Any) -> bool:
    v = _as_int(x)
    return v == 0

def _is_unisqrt(x: Any) -> bool:
    return _cn(x) == "QXUni" and str(_call0(x, "op")) == "sqrt"

def _sqrt_arg(x: Any) -> Any:
    return _call0(x, "next")

def _is_one_over_sqrt(x: Any) -> bool:
    # 1 / sqrt(E)
    if _cn(x) != "QXBin" or str(_call0(x, "op")) != "/":
        return False
    l = _call0(x, "left")
    r = _call0(x, "right")
    return _is_one(l) and _is_unisqrt(r)

def _one_over_sqrt_arg(x: Any) -> Any:
    # assumes _is_one_over_sqrt(x)
    return _sqrt_arg(_call0(x, "right"))

# ----------------------------------------------------------------------
# SimplifyVisitor
# ----------------------------------------------------------------------

class SimplifyVisitor:
    """
    Duck-typed visitor for QX AST nodes.
    """

    # ---- terminals ----
    def visitNum(self, ctx: Any):
        return ctx

    def visitBind(self, ctx: Any):
        return ctx

    # ---- arithmetic ----
    def visitUni(self, ctx: Any):
        op = str(_call0(ctx, "op"))
        nxt = _call0(ctx, "next")
        nxtS = nxt.accept(self) if hasattr(nxt, "accept") else nxt

        # sqrt(sqrt(x)) is not simplified here (too risky for algebraic domains)
        return _mk_uni(op, nxtS) if _cn(ctx) == "QXUni" else ctx

    def visitBin(self, ctx: Any):
        op = str(_call0(ctx, "op"))
        l = _call0(ctx, "left")
        r = _call0(ctx, "right")
        lS = l.accept(self) if hasattr(l, "accept") else l
        rS = r.accept(self) if hasattr(r, "accept") else r

        # Constant folding where safe (ints only)
        li = _as_int(lS)
        ri = _as_int(rS)

        if op == "+":
            if _is_zero(lS): return rS
            if _is_zero(rS): return lS
            if li is not None and ri is not None:
                return _mk_num(li + ri)

        if op == "-":
            if _is_zero(rS): return lS
            if li is not None and ri is not None:
                return _mk_num(li - ri)

        if op == "*":
            if _is_zero(lS) or _is_zero(rS): return _mk_num(0)
            if _is_one(lS): return rS
            if _is_one(rS): return lS
            if li is not None and ri is not None:
                return _mk_num(li * ri)

            # Key normalization for amplitudes:
            # (1/sqrt(E))*(1/sqrt(E))  ==>  1/E
            if _is_one_over_sqrt(lS) and _is_one_over_sqrt(rS):
                a1 = _one_over_sqrt_arg(lS)
                a2 = _one_over_sqrt_arg(rS)
                if _same_repr(a1, a2):
                    return _mk_bin("/", _mk_num(1), a1)

        if op == "/":
            if _is_zero(lS): return _mk_num(0)
            if _is_one(rS): return lS
            if li is not None and ri is not None and ri != 0:
                # Keep rational as division node if not integral
                if (li % ri) == 0:
                    return _mk_num(li // ri)

        if op == "^":
            # Very light folding: 2^0, x^1, x^0
            if _is_zero(rS): return _mk_num(1)
            if _is_one(rS): return lS
            if li is not None and ri is not None and ri >= 0:
                try:
                    return _mk_num(li ** ri)
                except Exception:
                    pass
                
        # Modulo simplifications (for modular arithmetic in Shor-style specs)
        if op == "%":
            # (x % N) % N  ==>  x % N
            if _cn(lS) == "QXBin" and str(_call0(lS, "op")) == "%":
                inner_left = _call0(lS, "left")
                inner_mod  = _call0(lS, "right")
                if _same_repr(inner_mod, rS):
                    return _mk_bin("%", inner_left, rS)

            # (a * (b % N)) % N  ==>  (a*b) % N
            # ((a % N) * b) % N  ==>  (a*b) % N
            # ((a % N) * (b % N)) % N  ==>  (a*b) % N
            if _cn(lS) == "QXBin" and str(_call0(lS, "op")) == "*":
                a = _call0(lS, "left")
                b = _call0(lS, "right")

                if _cn(b) == "QXBin" and str(_call0(b, "op")) == "%" and _same_repr(_call0(b, "right"), rS):
                    return _mk_bin("%", _mk_bin("*", a, _call0(b, "left")), rS)

                if _cn(a) == "QXBin" and str(_call0(a, "op")) == "%" and _same_repr(_call0(a, "right"), rS):
                    return _mk_bin("%", _mk_bin("*", _call0(a, "left"), b), rS)

                if (
                    _cn(a) == "QXBin" and str(_call0(a, "op")) == "%" and _same_repr(_call0(a, "right"), rS)
                    and _cn(b) == "QXBin" and str(_call0(b, "op")) == "%" and _same_repr(_call0(b, "right"), rS)
                ):
                    return _mk_bin("%", _mk_bin("*", _call0(a, "left"), _call0(b, "left")), rS)

            return _mk_bin("%", lS, rS)

        if op == "^":
            # Very light folding: 2^0, x^1, x^0
            if _is_zero(rS): return _mk_num(1)
            if _is_one(rS): return lS
            if li is not None and ri is not None and ri >= 0:
                try:
                    return _mk_num(li ** ri)
                except Exception:
                    pass

        # default
        return _mk_bin(op, lS, rS)

    def visitCall(self, ctx: Any):
        fid = str(_call0(ctx, "ID"))
        exps = list(_call0(ctx, "exps", []) or [])
        expsS = [e.accept(self) if hasattr(e, "accept") else e for e in exps]

        # omega(0, 1) is often used as "1" in your rewriting (phase = 1)
        if fid == "omega" and len(expsS) >= 2:
            if _is_zero(expsS[0]) and _is_one(expsS[1]):
                return _mk_num(1)

        inv = bool(_call0(ctx, "inverse", False))
        return _mk_call(fid, expsS, inverse=inv)

    # ---- quantum-state structure (local simplification only) ----
    def visitSKet(self, ctx: Any):
        v = _call0(ctx, "vector")
        vS = v.accept(self) if hasattr(v, "accept") else v
        from Programmer import QXSKet
        return QXSKet(vector=vS)

    def visitVKet(self, ctx: Any):
        v = _call0(ctx, "vector")
        vS = v.accept(self) if hasattr(v, "accept") else v
        from Programmer import QXVKet
        return QXVKet(vector=vS)

    def visitTensor(self, ctx: Any):
        ks = list(_call0(ctx, "kets", []) or [])
        ksS = [k.accept(self) if hasattr(k, "accept") else k for k in ks]
        from Programmer import QXTensor
        return QXTensor(kets=ksS, id=_call0(ctx, "ID", "None"), crange=_call0(ctx, "range", None))

    def visitCRange(self, ctx: Any):
        l = _call0(ctx, "left")
        r = _call0(ctx, "right")
        lS = l.accept(self) if hasattr(l, "accept") else l
        rS = r.accept(self) if hasattr(r, "accept") else r
        from Programmer import QXCRange
        return QXCRange(left=lS, right=rS)

    def visitCon(self, ctx: Any):
        cr = _call0(ctx, "crange")
        crS = cr.accept(self) if hasattr(cr, "accept") else cr
        # preserve ID; handle both spellings
        cid = str(_call0(ctx, "ID"))
        cond = _call0(ctx, "condtion", None)
        if cond is None:
            cond = _call0(ctx, "condition", None)
        condS = cond.accept(self) if hasattr(cond, "accept") else cond
        from Programmer import QXCon
        try:
            return QXCon(id=cid, crange=crS, condtion=condS)
        except TypeError:
            return QXCon(id=cid, crange=crS, condition=condS)

    def visitSum(self, ctx: Any):
        amp = _call0(ctx, "amp")
        ampS = amp.accept(self) if hasattr(amp, "accept") else amp

        kets = _call0(ctx, "kets")
        ketsS = kets.accept(self) if hasattr(kets, "accept") else kets

        cons = list(_call0(ctx, "sums", []) or [])
        consS = [c.accept(self) if hasattr(c, "accept") else c for c in cons]

        from Programmer import QXSum
        return QXSum(sums=consS, amp=ampS, tensor=ketsS)

    def visitQRange(self, ctx: Any):
        # QXQRange(location=..., crange=...)
        cr = _call0(ctx, "crange")
        crS = cr.accept(self) if hasattr(cr, "accept") else cr
        from Programmer import QXQRange
        return QXQRange(location=_call0(ctx, "location"), crange=crS)


# Single instance is fine (stateless visitor)
_simplifier = SimplifyVisitor()

def sim_expr(expr: Any) -> Any:
    """Simplify a QX arithmetic/state AST node using local algebraic rules."""
    if expr is None:
        return None
    if hasattr(expr, "accept"):
        try:
            return expr.accept(_simplifier)
        except Exception:
            return expr
    return expr

def deep_simplify(node: Any) -> Any:
    """
    Recursively simplify expressions *inside* internal terms (IApply/IIter/ITensorProd/IPostSelect),
    and simplify any embedded QX nodes.
    """
    if node is None:
        return None

    # Internal operational nodes
    if isinstance(node, IApply):
        termS = deep_simplify(node.term)
        # op and target are AST-ish; keep them but simplify any embedded aexp where possible
        return IApply(op=node.op, target=node.target, term=termS)

    if isinstance(node, IIter):
        termS = deep_simplify(node.term)
        # summarize steps: simplify op parameters in-place where possible (not changing structure)
        summ = node.body_summary
        if isinstance(summ, ILoopSummary):
            stepsS = []
            for s in summ.steps:
                if isinstance(s, IStep):
                    stepsS.append(IStep(op=s.op, target=s.target, guard=s.guard))
                else:
                    stepsS.append(s)
            summS = ILoopSummary(tuple(stepsS))
        else:
            summS = summ
        return IIter(binder=node.binder, lo=sim_expr(node.lo), hi=sim_expr(node.hi), body_summary=summS, term=termS)

    if isinstance(node, ITensorProd):
        fsS = tuple(deep_simplify(f) for f in node.factors)
        return ITensorProd(factors=fsS)

    if isinstance(node, IPostSelect):
        preS = deep_simplify(node.pre_term)
        return IPostSelect(
            pre_term=preS,
            meas_locus=node.meas_locus,
            meas_value=sim_expr(node.meas_value),
            prob_sym=sim_expr(node.prob_sym) if node.prob_sym is not None else None
        )

    # Plain QX node
    if hasattr(node, "accept"):
        return sim_expr(node)

    return node
