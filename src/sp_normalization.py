from __future__ import annotations
from typing import Any, List

from sp_rewrite import rewrite_term, canon_sum  # single source of truth
from sp_simplify import deep_simplify
from sp_pretty import pp

def _call_list(obj: Any, name: str, default=None) -> list:
    f = getattr(obj, name, None)
    if callable(f):
        try:
            return list(f() or [])
        except Exception:
            return list(default or [])
    return list(getattr(obj, name, default or []) or [])

def normalize_qspec(spec: Any, st: Any) -> Any:
    """
    Normalize only the state terms (and canonicalize alpha binders).
    Keep locus/qty as-is.
    """
    locus = _call_list(spec, "locus")
    qty   = getattr(spec, "qty", None)
    if callable(getattr(spec, "qty", None)):
        try: qty = spec.qty()
        except Exception: pass

    states = _call_list(spec, "states")

    new_states: List[Any] = []
    for t in states:
        # 1) semantic rewrite
        t1 = rewrite_term(t, st)

        # 2) expression simplification
        t2 = deep_simplify(t1)

        # 3) alpha-canon on any exposed sums
        if getattr(t2, "__class__", type(t2)).__name__ == "QXSum":
            t2 = canon_sum(t2)

        new_states.append(t2)

#    new_states = [rewrite_term(t, st) for t in states]
    print(f"\n new_states {pp(new_states[0])}")

    from Programmer import QXQSpec
    try:
        return QXQSpec(locus=locus, qty=qty, states=new_states)
    except TypeError:
        return QXQSpec(locus=locus, qty=qty, states=new_states)
