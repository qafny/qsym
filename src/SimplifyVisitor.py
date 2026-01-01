
from Programmer import QXCall, QXNum, QXBin
from SubstAExp import SubstAExp


class SimplifyVisitor(SubstAExp):
    def __init__(self):

        super().__init__("DUMMY", None)

    def _is_val(self, node, val):
        """Helper to check if a node is a specific integer literal."""
        if isinstance(node, QXNum):
            return int(node.num()) == val
        return False

    def visitBind(self, ctx):
        return ctx

    def visitNum(self, ctx):
        return ctx

    def visitCall(self, ctx):
        new_exps = [e.accept(self) for e in ctx.exps()]
        return QXCall(ctx.ID(), new_exps, ctx.inverse(), ctx.line_number())

    def visitBin(self, ctx):
        l = ctx.left().accept(self)
        r = ctx.right().accept(self)
        op = str(ctx.op())

        # Arithmetic Simplifications
        if op == "+":
            if self._is_val(l, 0): return r
            if self._is_val(r, 0): return l

        elif op == "*":
            if self._is_val(l, 1): return r
            if self._is_val(r, 1): return l
            if self._is_val(l, 0): return QXNum(0)
            if self._is_val(r, 0): return QXNum(0)

        elif op == "^":
            if self._is_val(r, 1): return l
            if self._is_val(r, 0): return QXNum(1)
            if self._is_val(l, 1): return QXNum(1)

        elif op == "%":
            mod_N = r
            
            # Ensure left side is a multiplication
            if isinstance(l, QXBin) and str(l.op()) == "*":
                l_inner = l.left()
                r_inner = l.right()

                # (A * (B % N)) % N -> (A * B) % N
                if isinstance(r_inner, QXBin) and str(r_inner.op()) == "%":
                    if repr(mod_N) == repr(r_inner.right()):
                        new_prod = QXBin("*", l_inner, r_inner.left())
                        return QXBin("%", new_prod, mod_N)

                # ((A % N) * B) % N -> (A * B) % N
                if isinstance(l_inner, QXBin) and str(l_inner.op()) == "%":
                    if repr(mod_N) == repr(l_inner.right()):
                        new_prod = QXBin("*", l_inner.left(), r_inner)
                        return QXBin("%", new_prod, mod_N)

        return QXBin(op, l, r)