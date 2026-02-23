# Generated from SpecExp.g4 by ANTLR 4.9.2
from antlr4 import *
if __name__ is not None and "." in __name__:
    from .SpecExpParser import SpecExpParser
else:
    from SpecExpParser import SpecExpParser

# This class defines a complete generic visitor for a parse tree produced by SpecExpParser.

class SpecExpVisitor(ParseTreeVisitor):

    # Visit a parse tree produced by SpecExpParser#program.
    def visitProgram(self, ctx:SpecExpParser.ProgramContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SpecExpParser#atype.
    def visitAtype(self, ctx:SpecExpParser.AtypeContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SpecExpParser#arrow.
    def visitArrow(self, ctx:SpecExpParser.ArrowContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SpecExpParser#always.
    def visitAlways(self, ctx:SpecExpParser.AlwaysContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SpecExpParser#exists.
    def visitExists(self, ctx:SpecExpParser.ExistsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SpecExpParser#qexp.
    def visitQexp(self, ctx:SpecExpParser.QexpContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SpecExpParser#qexps.
    def visitQexps(self, ctx:SpecExpParser.QexpsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SpecExpParser#vexp.
    def visitVexp(self, ctx:SpecExpParser.VexpContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SpecExpParser#bexp.
    def visitBexp(self, ctx:SpecExpParser.BexpContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SpecExpParser#numexp.
    def visitNumexp(self, ctx:SpecExpParser.NumexpContext):
        return self.visitChildren(ctx)



del SpecExpParser