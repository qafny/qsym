import random

from AST_Scripts import XMLProgrammer
from AST_Scripts import ProgramVisitor
# from AST_Scripts import RPFRetriever
from AST_Scripts.XMLProgrammer import QXApp, QXMatch, QXNum, QXIf
from AST_Scripts.simulator import Simulator


def calBinNoLength(v):
    val = []
    while v != 0:
        b = v % 2
        v = v // 2
        val.append(b)
    return val


class SimulatorValidator(ProgramVisitor.ProgramVisitor):

    def visitLet(self, ctx: XMLProgrammer.QXLet):
        ctx.program().accept(self)

    def visitMatch(self, ctx: XMLProgrammer.QXMatch):
        counter = 0
        i = 0
        while ctx.multi().program().exp(i) is not None:
            if isinstance(ctx.multi().program().exp(i), QXApp):
                # Disallow more than 1 App inside pair
                if counter > 0:
                    raise Exception("Found more than one app in pair")
                else:
                    ctx.multi().program().exp(i).accept(self)
                    counter += 1
            else:
                ctx.multi().program().exp(i).accept(self)
            i += 1

        if counter == 0:
            raise Exception("Found no app in pair")

    def visitApp(self, ctx: XMLProgrammer.QXApp):
        return

    def visitIf(self, ctx: XMLProgrammer.QXIf):
        return

    def visitIDExp(self, ctx: XMLProgrammer.QXIDExp):
        return 1

    def visitQID(self, ctx: XMLProgrammer.QXQID):
        return 1

    def visitNum(self, ctx: XMLProgrammer.QXNum):
        return 1
