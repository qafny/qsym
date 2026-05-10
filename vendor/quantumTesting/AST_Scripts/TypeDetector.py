# type checker
import copy
from enum import Enum
from collections import ChainMap
from types import NoneType

from antlr4 import ParserRuleContext

from Source.quantumCode.AST_Scripts import XMLProgrammer
from Source.quantumCode.AST_Scripts.BlockContain import BlockContain
from Source.quantumCode.AST_Scripts.ProgramVisitor import ProgramVisitor
from Source.quantumCode.AST_Scripts.XMLExpParser import XMLExpParser
from Source.quantumCode.AST_Scripts.XMLExpVisitor import XMLExpVisitor
from Source.quantumCode.AST_Scripts.XMLProgrammer import *


class TypeDetector(ProgramVisitor):

    # x, y, z, env : ChainMap{ x: n, y : m, z : v} , n m v are nat numbers 100, 100, 100, eg {x : 128}
    # st state map, {x : v1, y : v2 , z : v3}, eg {x : v1}: v1,
    # st {x : v1} --> Coq_nval case: v1 is a ChainMap of Coq_nval
    # v1 --> 128 length array v1: {0 : Coq_nval, 1 : Coq_nval, 2 : Coq_nval, ...., 127 : Coq_nval}, 2^128
    # x --> v1 --> cal(v1) --> integer
    # Coq_nval(b,r) b == |0> | |1>, r == e^(2 pi i * 1 / n), r = 0 Coq_nval(b, 0)
    # x -> v1 ----> run simulator -----> v2 ---> calInt(v2,128) == (x + 2^10) % 2^128
    def __init__(self, type_environment: dict):
        self.type_environment = type_environment
        # self.rmax = rmax rmax is M_find(x,env), a map from var to int

    def visitProgram(self, ctx: XMLProgrammer.QXProgram):
        i = 0
        bl = BlockContain()
        while ctx.exp(i) is not None:
            ctx.exp(i).accept(self)
            if bl.visit(ctx.exp(i)):
                return
            i += 1

    def get_type_env(self):
        return self.type_environment

    def visitIDExp(self, ctx:XMLProgrammer.QXIDExp):
        tv = ctx.ID()
        return self.type_environment.get(tv) == Nat

    def visitQID(self, ctx:XMLProgrammer.QXQID):
        tv = ctx.ID()
        return isinstance(self.type_environment.get(ctx.ID()), Qty)

    def visitNum(self, ctx:XMLProgrammer.QXNum):
        return True

    def visitBin(self, ctx:XMLProgrammer.QXBin):
        return ctx.left().accept(self) and ctx.right().accept(self)
    # the only thing that matters will be 48 and 47

    def visitQTy(self, ctx: XMLProgrammer.Qty):
        return ctx

    def visitNat(self, ctx: XMLProgrammer.Nat):
        return ctx

    def visitLet(self, ctx:XMLProgrammer.QXLet):
        bl = BlockContain()
        if bl.visitProgram(ctx.program()):
            i = 0
            #f = ctx.ID()
            #tml = []
            #tmv = copy.deepcopy(self.type_environment)
            while ctx.idexp(i) is not None:
                x = ctx.idexp(i).ID()
                #tml.append(x)
                v = ctx.idexp(i).type().accept(self)
                self.type_environment.update({x: v})
                i += 1
            ctx.program().accept(self)
            #tmv.update({f: Fun(tml, tx.type_environment, self.type_environment)})

    def visitApp(self, ctx: XMLProgrammer.QXApp):
        identifier_text = ctx.ID()
        qty = self.type_environment.get(identifier_text)
        tml = qty.args()
        tmv = qty.pre()
        rmv = qty.out()
        for i in range(len(tml)):
            if isinstance(ctx.vexp(i), QXIDExp):
                na = ctx.vexp(i).ID()
                tmpty = self.type_environment.get(na)
                tx = joinType(tmv.get(tml[i]), tmpty)
                if tx is None:
                    return
                self.type_environment.update({na: rmv.get(tml[i])})

    def visitMatch(self, ctx:XMLProgrammer.QXMatch):
        bl = BlockContain()
        if bl.visitProgram(ctx.zero().program()):
            ctx.zero().program().accept(self)
        elif bl.visitProgram(ctx.multi().program()):
            va = ctx.multi().elem().ID()
            self.type_environment.update({va: Nat()})
            ctx.multi().program().accept(self)
            self.type_environment.pop(va)

    # should do nothing
    def visitSKIP(self, ctx: XMLProgrammer.QXSKIP):
        return

    # X posi, changed the following for an example
    def visitX(self, ctx: XMLProgrammer.QXX):
        x = ctx.ID()
        ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x:Qty(self.type_environment.get(x).get_num(),"Nor")})
                return
        #return p < self.env.get(x) and str(self.type_environment.get(x)) == "Nor"
        # print(M_find(x, self.st))

    # we will first get the position in st and check if the state is 0 or 1,
    # then decide if we go to recucively call ctx.exp
    def visitCU(self, ctx: XMLProgrammer.QXCU):
        x = ctx.ID()
        ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x:Qty(self.type_environment.get(x).get_num(),"Nor")})
                ctx.program().accept(self)
            else:
                ctx.program().accept(self)

    # SR n x, now variables are all string, are this OK?
    def visitSR(self, ctx:XMLProgrammer.QXSR):
        x = ctx.ID()
        ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x:Qty(self.type_environment.get(x).get_num(),"Phi")})

    def visitLshift(self, ctx: XMLProgrammer.QXLshift):
        x = ctx.ID()
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x:Qty(self.type_environment.get(x).get_num(),"Nor")})

    def visitRshift(self, ctx: XMLProgrammer.QXRshift):
        x = ctx.ID()
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x:Qty(self.type_environment.get(x).get_num(),"Nor")})

    def visitRev(self, ctx: XMLProgrammer.QXRev):
        x = ctx.ID()
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x:Qty(self.type_environment.get(x).get_num(),"Nor")})

    # actually, we need to change the QFT function
    # the following QFT is only for full QFT, we did not have the case for AQFT
    def visitQFT(self, ctx: XMLProgrammer.QXQFT):
        x = ctx.ID()
        ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x), Qty):
            temp = (self.type_environment.get(x))
            print(temp)
            if temp.type is None:
                self.type_environment.update({x:Qty(self.type_environment.get(x).get_num(),"Phi")})
            elif self.type_environment.get(x).type() == "Nor":
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Phi")})


    def visitRQFT(self, ctx: XMLProgrammer.QXRQFT):
        x = ctx.ID()
        #ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x).type, Qty):
            if self.type_environment.get(x).type is None:
                self.type_environment.update({x:Qty(self.type_environment.get(x).get_num(),"Nor")})
            elif self.type_environment.get(x).type() == "Phi":
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Nor")})


