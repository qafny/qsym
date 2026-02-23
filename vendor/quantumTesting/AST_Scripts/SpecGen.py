# Generated from SpecExp.g4 by ANTLR 4.7.2
from antlr4 import *
from SpecExpParser import *
from SpecExpVisitor import *

class SpecGen(SpecExpVisitor):

    def __init__(self, st: dict):
        self.st = st
        self.result = []

    def getResult(self):
        return self.result

    def visitProgram(self, ctx: SpecExpParser.ProgramContext):
        ctx.aexp(1).accept(self)

    # Visit a parse tree produced by SpecExpParser#aexp.
    def visitAexp(self, ctx: SpecExpParser.AexpContext):
        i = 0
        while ctx.vexp(i) is not None:
            v = ctx.vexp(i).accept(self)
            self.getResult().append(v)
            i += 1

    # Visit a parse tree produced by SpecExpParser#vexp.
    def visitVexp(self, ctx: SpecExpParser.VexpContext):
        i = 0
        if ctx.Plus() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return v1 + v2
        if ctx.Minus() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return v1 - v2
        if ctx.Mult() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return v1 * v2
        if ctx.Div() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return v1 // v2
        if ctx.Mod() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return v1 % v2
        if ctx.Less() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return int(v1 < v2)
        if ctx.Equal() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return int(v1 == v2)
        if ctx.Greater() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return int(v1 > v2)

    # Visit a parse tree produced by SpecExpParser#numexp.
    def visitNumexp(self, ctx: SpecExpParser.NumexpContext):
        v = int(ctx.Number())
        if ctx.Minus() is not None:
            return - v
        return v