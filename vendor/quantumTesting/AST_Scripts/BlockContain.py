# type checker
import copy
from enum import Enum
from collections import ChainMap
from types import NoneType

from antlr4 import ParserRuleContext

from Source.quantumCode.AST_Scripts import XMLProgrammer
from Source.quantumCode.AST_Scripts.ProgramVisitor import ProgramVisitor
from Source.quantumCode.AST_Scripts.XMLExpParser import XMLExpParser
from Source.quantumCode.AST_Scripts.XMLExpVisitor import XMLExpVisitor

class BlockContain(ProgramVisitor):

    # x, y, z, env : ChainMap{ x: n, y : m, z : v} , n m v are nat numbers 100, 100, 100, eg {x : 128}
    # st state map, {x : v1, y : v2 , z : v3}, eg {x : v1}: v1,
    # st {x : v1} --> Coq_nval case: v1 is a ChainMap of Coq_nval
    # v1 --> 128 length array v1: {0 : Coq_nval, 1 : Coq_nval, 2 : Coq_nval, ...., 127 : Coq_nval}, 2^128
    # x --> v1 --> cal(v1) --> integer
    # Coq_nval(b,r) b == |0> | |1>, r == e^(2 pi i * 1 / n), r = 0 Coq_nval(b, 0)
    # x -> v1 ----> run simulator -----> v2 ---> calInt(v2,128) == (x + 2^10) % 2^128
    def __init__(self):
        pass
        # self.rmax = rmax rmax is M_find(x,env), a map from var to int

    def visitProgram(self, ctx: XMLProgrammer.QXProgram):
        i = 0
        tmp = False
        while ctx.exp(i) is not None:
            tmp = tmp or ctx.exp(i).accept(self)
            i += 1
        return tmp

    def visitLet(self, ctx: XMLProgrammer.QXLet):
        return ctx.program().accept(self)

    def visitMatch(self, ctx:XMLProgrammer.QXMatch):
        return ctx.zero().program().accept(self) or ctx.multi().program().accept(self)

    def visitIf(self, ctx:XMLProgrammer.QXIf):
        return (ctx.block() is not None) or ctx.vexp().accept(self) or ctx.left().accept(self) or ctx.right().accept(self)

    def visitApp(self, ctx:XMLProgrammer.QXApp):
        i = 0
        tmp = False
        while(ctx.vexp(i) is not None):
            tmp = tmp or ctx.vexp(i).accept(self)
            i = i + 1
        return tmp or (ctx.block() is not None)

    def visitPair(self, ctx: XMLProgrammer.QXPair):
        return ctx.program().accept(self)

    # should do nothing
    def visitSKIP(self, ctx:XMLProgrammer.QXSKIP):
        return (ctx.block() is not None) or ctx.vexp().accept(self)

    # X posi, changed the following for an example
    def visitX(self, ctx:XMLProgrammer.QXX):
        return (ctx.block() is not None) or ctx.vexp().accept(self)

        #return p < self.env.get(x) and str(self.type_environment.get(x)) == "Nor"
        # print(M_find(x, self.st))

    # we will first get the position in st and check if the state is 0 or 1,
    # then decide if we go to recucively call ctx.exp
    def visitCU(self, ctx:XMLProgrammer.QXCU):
        return (ctx.block() is not None) or ctx.program().accept(self) or ctx.vexp().accept(self)

    # SR n x, now variables are all string, are this OK?
    def visitSR(self, ctx:XMLProgrammer.QXSR):
        return (ctx.block() is not None) or ctx.vexp().accept(self)

    def visitLshift(self, ctx:XMLProgrammer.QXLshift):
        return ctx.block is not None

    def visitRshift(self, ctx:XMLProgrammer.QXRshift):
        return ctx.block is not None

    def visitRev(self, ctx:XMLProgrammer.QXRev):
        return ctx.block is not None

    # actually, we need to change the QFT function
    # the following QFT is only for full QFT, we did not have the case for AQFT
    def visitQFT(self, ctx:XMLProgrammer.QXQFT):
        return (ctx.block() is not None) or ctx.vexp().accept(self)

    def visitRQFT(self, ctx:XMLProgrammer.QXRQFT):
        return ctx.block is not None

    def visitIDExp(self, ctx: XMLProgrammer.QXIDExp):
        # print("idexp var",ctx.Identifier().accept(self))
        # print("idexp val",self.get_state().get(ctx.Identifier().accept(self)))
        return (ctx.block() is not None)

    def visitQID(self, ctx: XMLProgrammer.QXQID):
            # print("idexp var",ctx.Identifier().accept(self))
            # print("idexp val",self.get_state().get(ctx.Identifier().accept(self)))
        return (ctx.block() is not None)
        # Visit a parse tree produced by XMLExpParser#vexp.

    def visitBin(self, ctx: XMLProgrammer.QXBin):
        return (ctx.block() is not None)
    # def visitIDExp(self, ctx: XMLProgrammer.QXIDExp):
    #     ctx.type().accept(self)

    def visitNum(self, ctx: XMLProgrammer.QXNum):
        return (ctx.block() is not None)