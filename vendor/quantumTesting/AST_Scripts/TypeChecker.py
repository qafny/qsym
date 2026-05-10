# type checker
import copy
from enum import Enum
from collections import ChainMap
from types import NoneType

from antlr4 import ParserRuleContext

from XMLProgrammer import *
from ProgramVisitor import *


class TypeChecker(ProgramVisitor):

    # x, y, z, env : ChainMap{ x: n, y : m, z : v} , n m v are nat numbers 100, 100, 100, eg {x : 128}
    # st state map, {x : v1, y : v2 , z : v3}, eg {x : v1}: v1,
    # st {x : v1} --> Coq_nval case: v1 is a ChainMap of Coq_nval
    # v1 --> 128 length array v1: {0 : Coq_nval, 1 : Coq_nval, 2 : Coq_nval, ...., 127 : Coq_nval}, 2^128
    # x --> v1 --> cal(v1) --> integer
    # Coq_nval(b,r) b == |0> | |1>, r == e^(2 pi i * 1 / n), r = 0 Coq_nval(b, 0)
    # x -> v1 ----> run simulator -----> v2 ---> calInt(v2,128) == (x + 2^10) % 2^128
    def __init__(self, type_environment: dict):

        self.type_environment = type_environment

    def visitProgram(self, ctx: XMLProgrammer.QXProgram):
        i = 0
        tmp = True
        while ctx.exp(i) is not None:
            tmp = tmp and ctx.exp(i).accept(self)
            i += 1
        return tmp

    def get_type_env(self):
        return self.type_environment

    def visitQty(self, ctx: XMLProgrammer.Qty):
        return ctx

    def visitNat(self, ctx: XMLProgrammer.Nat):
        return ctx

    def mapcopy(self, kvd: dict):
        new = dict()
        for key, val in kvd.items():
            new.update({key: val})
        return new

    def visitLet(self, ctx: XMLProgrammer.QXLet):
        i = 0
        f = ctx.ID()
        tml = []
        # tmv = self.mapcopy(self.type_environment)
        while ctx.idexp(i) is not None:
            x = ctx.idexp(i).ID()
            tml.append(x)
            if ctx.idexp(i).type() is not None:
                v = ctx.idexp(i).type()
            else:
                v = Nat()
            self.type_environment.update({x: v})
            i += 1
        tmv = self.mapcopy(self.type_environment)
        tfv = self.mapcopy(self.type_environment)
        #tx = TypeSearch(self.type_environment)
        #tx.visitProgram(ctx.program())
        #self.type_environment = self.mapcopy(tx.type_environment)
        self.type_environment.update({f: Fun(tml, tfv, self.type_environment)})
        fv = ctx.program().accept(self)
        tmv.update({f: Fun(tml, tfv, self.type_environment)})
        #for j in range(len(tml)):
        #    tmv.pop(tml[j])
        #    j += 1
        self.type_environment = tmv
        return fv
        #print("f", ctx)
        #ctx.exp().accept(self)

    def visitIf(self, ctx: XMLProgrammer.QXIf):
        if ctx.vexp().accept(self):
            tmv = self.mapcopy(self.type_environment)
            tmp1 = ctx.left().accept(self)
            rmv = self.mapcopy(self.type_environment)
            self.type_environment = tmv
            tmp2 = ctx.right().accept(self)
            return tmp1 and tmp2 and equalTypes(rmv, self.type_environment)
        return False

    def visitApp(self, ctx: XMLProgrammer.QXApp):
        vx = ctx.ID()
        qty = self.type_environment.get(vx)
        tml = qty.args()
        tmv = qty.pre()
        rmv = qty.out()
        tmp = True
        for i in range(len(tml)):
            if isinstance(ctx.vexp(i), QXIDExp):
                na = ctx.vexp(i).ID()
                tmpty = self.type_environment.get(na)
                tx = joinType(tmv.get(tml[i]), tmpty)
                if tx is None:
                    return False
                self.type_environment.update({na: rmv.get(tml[i])})
            else:
                tmp = tmp and ctx.vexp(i).accept(self)
        return tmp

    def visitMatch(self, ctx: XMLProgrammer.QXMatch):
        x = ctx.ID()
        fenv = self.mapcopy(self.type_environment)
        va = ctx.multi().elem().ID()
        senv = self.mapcopy(self.type_environment)
        senv.update({va: Nat()})
        #s1 = TypeSearch(fenv)
        #s1.visitProgram(ctx.zero().program())
        #s2 = TypeSearch(senv)
        #s2.visitProgram(ctx.multi().program())
        #fenv1 = s1.type_environment
        #senv1 = s2.type_environment.pop(va)
        #senv2 = joinTypes(fenv1, senv1)
        #fenv3 = self.mapcopy(senv2)
        self.type_environment = fenv
        ctx.zero().program().accept(self)
        fenv1 = self.type_environment
        self.type_environment = senv
        ctx.multi().program().accept(self)
        senv1 = self.type_environment
        return equalTypes(fenv1, senv1.pop(va))

    # should do nothing
    def visitSKIP(self, ctx: XMLProgrammer.QXSKIP):
        x = ctx.ID()
        ctx.vexp().accept(self)
        return isinstance(self.type_environment.get(x), Qty)

    # X posi, changed the following for an example
    def visitX(self, ctx: XMLProgrammer.QXX):
        x = ctx.ID()
        ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Nor")})
                return True
            else:
                return self.type_environment.get(x).type() == "Nor"
        return False
        #return p < self.env.get(x) and str(self.type_environment.get(x)) == "Nor"
        # print(M_find(x, self.st))

    def visitRZ(self, ctx: XMLProgrammer.QXRZ):
        x = ctx.ID()
        ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Nor")})
                return True
            else:
                return self.type_environment.get(x).type() == "Nor"
        return False
        #return p < self.env.get(x) and str(self.type_environment.get(x)) == "Nor"
        # print(M_find(x, self.st))

    def visitH(self, ctx: XMLProgrammer.QXH):
        x = ctx.ID()
        ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Nor")})
                return True
            else:
                return self.type_environment.get(x).type() == "Nor"
        return False
        #return p < self.env.get(x) and str(self.type_environment.get(x)) == "Nor"
        # print(M_find(x, self.st))


    # we will first get the position in st and check if the state is 0 or 1,
    # then decide if we go to recucively call ctx.exp
    def visitCU(self, ctx: XMLProgrammer.QXCU):
        x = ctx.ID()
        ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Nor")})
                ctx.program().accept(self)
                return True
            else:
                ctx.program().accept(self)
                return self.type_environment.get(x).type() == "Nor"
        return False

    # SR n x, now variables are all string, are this OK?
    def visitSR(self, ctx: XMLProgrammer.QXSR):
        x = ctx.ID()
        ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Phi")})
                return True
            else:
                return self.type_environment.get(x).type() == "Phi"
        return False

    def visitLshift(self, ctx: XMLProgrammer.QXLshift):
        x = ctx.ID()
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Nor")})
                return True
            else:
                return self.type_environment.get(x).type() == "Nor"
        return False

    def visitRshift(self, ctx: XMLProgrammer.QXRshift):
        x = ctx.ID()
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Nor")})
                return True
            else:
                return self.type_environment.get(x).type() == "Nor"
        return False

    def visitRev(self, ctx: XMLProgrammer.QXRev):
        x = ctx.ID()
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Nor")})
                return True
            else:
                return self.type_environment.get(x).type() == "Nor"
        return False

    # actually, we need to change the QFT function
    # the following QFT is only for full QFT, we did not have the case for AQFT
    def visitQFT(self, ctx: XMLProgrammer.QXQFT):
        x = ctx.ID()
        ctx.vexp().accept(self)
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Phi")})
                return True
            elif self.type_environment.get(x).type() == "Nor":
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Phi")})
                return True
        return False

    def visitRQFT(self, ctx: XMLProgrammer.QXRQFT):
        x = ctx.ID()
        if isinstance(self.type_environment.get(x), Qty):
            if self.type_environment.get(x).type() is None:
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Nor")})
                return True
            elif self.type_environment.get(x).type() == "Phi":
                self.type_environment.update({x: Qty(self.type_environment.get(x).get_num(), "Nor")})
                return True
        return False

    def visitIDExp(self, ctx: XMLProgrammer.QXIDExp):
        return isinstance(self.type_environment.get(ctx.ID()), Nat)

    def visitQID(self, ctx: XMLProgrammer.QXQID):
        return isinstance(self.type_environment.get(ctx.ID()), Qty)

    # Visit a parse tree produced by XMLExpParser#vexp.
    def visitBin(self, ctx: XMLProgrammer.QXBin):
        return ctx.left().accept(self) and ctx.left().accept(self)

    # the only thing that matters will be 48 and 47

    def visitNum(self, ctx: XMLProgrammer.QXNum):
        return True

