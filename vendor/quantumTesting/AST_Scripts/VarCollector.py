# Generated from SpecExp.g4 by ANTLR 4.7.2
from antlr4 import *
from SpecExpParser import *
from SpecExpVisitor import *


# This class defines a complete generic visitor for a parse tree produced by SpecExpParser.

class VarCollector(SpecExpVisitor):

    def __init__(self):
        self.st = dict()

    def getNumEnv(self):
        return self.st

    def visitProgram(self, ctx: SpecExpParser.ProgramContext):
        ctx.aexp(0).accept(self)

    # Visit a parse tree produced by SpecExpParser#aexp.
    def visitAexp(self, ctx: SpecExpParser.AexpContext):
        i = 0
        while ctx.vexp(i) is not None:
            ctx.vexp(i).accept(self)
            i += 1

    # Visit a parse tree produced by SpecExpParser#vexp.
    def visitVexp(self, ctx: SpecExpParser.VexpContext):
        i = 0
        while ctx.vexp(i) is not None:
            ctx.vexp(i).accept(self)
            i += 1
        if ctx.Identifier() is not None:
            self.getNumEnv().update({ctx.Identifier(), 0})

    # Visit a parse tree produced by SpecExpParser#numexp.
    def visitNumexp(self, ctx: SpecExpParser.NumexpContext):
        return self.visitChildren(ctx)
