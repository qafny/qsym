from AST_Scripts import XMLProgrammer
from AST_Scripts.ProgramVisitor import ProgramVisitor
from AST_Scripts.XMLProgrammer import QXMatch, QXApp, QXIf


class RPFRetriever(ProgramVisitor):

    def __init__(self):
        self.app_args: list = []
        self.rpf_idx: int = -1
        self.rps_var_id: str = ""

    def visitLet(self, ctx: XMLProgrammer.QXLet):
        i = 0
        while ctx.idexp(i) is not None:
            self.app_args.append(ctx.idexp(i))
            i += 1

        ctx.program().accept(self)

    def visitMatch(self, ctx: XMLProgrammer.QXMatch):
        self.rpf_idx = [arg.ID() for arg in self.app_args].index(ctx.ID())
        ctx.multi().accept(self)

    def visitPair(self, ctx: XMLProgrammer.QXPair):
        self.rps_var_id = ctx.elem().ID()

    def visitIDExp(self, ctx: XMLProgrammer.QXIDExp):
        return

    def visitQID(self, ctx: XMLProgrammer.QXQID):
        return

    def visitApp(self, ctx: XMLProgrammer.QXApp):
        return

    def get_rpf_index(self):
        return self.rpf_idx

    def get_rps_var_id(self):
        return self.rps_var_id


class MatchCounterRetriever(ProgramVisitor):

    def __init__(self):
        self.app_counter: int = 0
        self.if_counter: int = 0

    def visitLet(self, ctx: XMLProgrammer.QXLet):
        ctx.program().accept(self)

    def visitMatch(self, ctx: XMLProgrammer.QXMatch):
        ctx.zero().program().accept(self)
        ctx.multi().program().accept(self)

        i = 0
        while ctx.multi().program().exp(i) is not None:
            if isinstance(ctx.multi().program().exp(i), QXApp):
                self.app_counter += 1
            elif isinstance(ctx.multi().program().exp(i), QXIf):
                self.if_counter += 1

            i += 1

    def visitIDExp(self, ctx: XMLProgrammer.QXIDExp):
        return

    def visitQID(self, ctx: XMLProgrammer.QXQID):
        return

    def visitApp(self, ctx: XMLProgrammer.QXApp):
        return

    def get_app_counter(self):
        return self.app_counter

    def get_if_counter(self):
        return self.if_counter
