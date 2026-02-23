# type checker
import copy
from enum import Enum
from collections import ChainMap
from types import NoneType

from antlr4 import ParserRuleContext

from Source.quantumCode.AST_Scripts.SpecExpLexer import *
from Source.quantumCode.AST_Scripts.SpecExpVisitor import *
from Source.quantumCode.AST_Scripts.SpecLang import *

class SpecTransformer(SpecExpVisitor):

    def visitProgram(self, ctx:SpecExpParser.ProgramContext):
        if ctx.arrow() is not None:
            return ctx.arrow().accept(self)
        elif ctx.always() is not None:
            return ctx.always().accept(self)
        elif ctx.exists() is not None:
            return ctx.exists().accept(self)

    def visitAtype(self, ctx:SpecExpParser.AtypeContext):
        if ctx.Nat() is not None:
             return Nat()
        elif ctx.Qt() is not None:
            v = ctx.vexp().accept(self)
            return Qty(v)


    # Visit a parse tree produced by SpecExpParser#arrow.
    def visitArrow(self, ctx:SpecExpParser.ArrowContext):
        v1 = ctx.qexps(0).accept(self)
        v2 = ctx.qexps(1).accept(self)
        return SPArrow(v1, v2)


    # Visit a parse tree produced by SpecExpParser#always.
    def visitAlways(self, ctx:SpecExpParser.AlwaysContext):
        v = ctx.vexp().accept(self)
        p = ctx.program().accept(self)
        return SPAlways(v, p)

    # Visit a parse tree produced by SpecExpParser#exists.
    def visitExists(self, ctx:SpecExpParser.ExistsContext):
        id = ctx.Identifier()
        t = ctx.atype().accept(self)
        p = ctx.program().accept(self)
        b = None
        if ctx.bexp() is not None:
            b = ctx.bexp().accept(self)
        return SPExists(id, t, p, b)


    def visitQexp(self, ctx:SpecExpParser.QexpContext):
        id = ctx.Identifier()
        v1 = ctx.vexp(0).accept(self)
        v2 = ctx.vexp(1).accept(self)
        if ctx.Nor() is not None:
            return SPNor(id, v1, v2)
        elif ctx.Phi() is not None:
            return SPPhi(id, v1, v2)


    # Visit a parse tree produced by SpecExpParser#qexps.
    def visitQexps(self, ctx:SpecExpParser.QexpsContext):
        tmp = []
        i = 0
        while ctx.qexp(i) is not None:
            v = ctx.qexp(i).accept(self)
            tmp.append(v)
            i=i+1
        return tmp

    # Visit a parse tree produced by SpecExpParser#vexp.
    def visitVexp(self, ctx:SpecExpParser.VexpContext):
        if ctx.Identifier() is not None:
            return SPIDExp(ctx.Identifier())
        if ctx.numexp() is not None:
            return ctx.numexp().accept(self)
        v1 = ctx.vexp(0).accept(self)
        v2 = ctx.vexp(1).accept(self)
        if ctx.Plus() is not None:
            return SPBin("Plus", v1, v2)
        if ctx.Minus() is not None:
            return SPBin("Minus", v1, v2)
        if ctx.Mult() is not None:
            return SPBin("Mult", v1, v2)
        if ctx.Div() is not None:
            return SPBin("Div", v1, v2)
        if ctx.Mod() is not None:
            return SPBin("Mod", v1, v2)


    # Visit a parse tree produced by SpecExpParser#bexp.
    def visitBexp(self, ctx:SpecExpParser.BexpContext):
        if ctx.Not() is not None:
            b = ctx.bexp(0).accept(self)
            return SPNot(b)
        if ctx.Equal() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return SPABool("Equal", v1, v2)
        if ctx.Less() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return SPABool("Less", v1, v2)
        if ctx.Greater() is not None:
            v1 = ctx.vexp(0).accept(self)
            v2 = ctx.vexp(1).accept(self)
            return SPABool("Greater", v1, v2)
        if ctx.And() is not None:
            v1 = ctx.bexp(0).accept(self)
            v2 = ctx.bexp(1).accept(self)
            return SPBool("And", v1, v2)
        if ctx.Or() is not None:
            v1 = ctx.bexp(0).accept(self)
            v2 = ctx.bexp(1).accept(self)
            return SPBool("Or", v1, v2)


    # Visit a parse tree produced by SpecExpParser#numexp.
    def visitNumexp(self, ctx:SpecExpParser.NumexpContext):
        return SPNum(int(ctx.getText()))
