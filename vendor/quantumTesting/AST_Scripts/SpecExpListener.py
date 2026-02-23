# Generated from SpecExp.g4 by ANTLR 4.9.2
from antlr4 import *
if __name__ is not None and "." in __name__:
    from .SpecExpParser import SpecExpParser
else:
    from SpecExpParser import SpecExpParser

# This class defines a complete listener for a parse tree produced by SpecExpParser.
class SpecExpListener(ParseTreeListener):

    # Enter a parse tree produced by SpecExpParser#program.
    def enterProgram(self, ctx:SpecExpParser.ProgramContext):
        pass

    # Exit a parse tree produced by SpecExpParser#program.
    def exitProgram(self, ctx:SpecExpParser.ProgramContext):
        pass


    # Enter a parse tree produced by SpecExpParser#atype.
    def enterAtype(self, ctx:SpecExpParser.AtypeContext):
        pass

    # Exit a parse tree produced by SpecExpParser#atype.
    def exitAtype(self, ctx:SpecExpParser.AtypeContext):
        pass


    # Enter a parse tree produced by SpecExpParser#arrow.
    def enterArrow(self, ctx:SpecExpParser.ArrowContext):
        pass

    # Exit a parse tree produced by SpecExpParser#arrow.
    def exitArrow(self, ctx:SpecExpParser.ArrowContext):
        pass


    # Enter a parse tree produced by SpecExpParser#always.
    def enterAlways(self, ctx:SpecExpParser.AlwaysContext):
        pass

    # Exit a parse tree produced by SpecExpParser#always.
    def exitAlways(self, ctx:SpecExpParser.AlwaysContext):
        pass


    # Enter a parse tree produced by SpecExpParser#exists.
    def enterExists(self, ctx:SpecExpParser.ExistsContext):
        pass

    # Exit a parse tree produced by SpecExpParser#exists.
    def exitExists(self, ctx:SpecExpParser.ExistsContext):
        pass


    # Enter a parse tree produced by SpecExpParser#qexp.
    def enterQexp(self, ctx:SpecExpParser.QexpContext):
        pass

    # Exit a parse tree produced by SpecExpParser#qexp.
    def exitQexp(self, ctx:SpecExpParser.QexpContext):
        pass


    # Enter a parse tree produced by SpecExpParser#qexps.
    def enterQexps(self, ctx:SpecExpParser.QexpsContext):
        pass

    # Exit a parse tree produced by SpecExpParser#qexps.
    def exitQexps(self, ctx:SpecExpParser.QexpsContext):
        pass


    # Enter a parse tree produced by SpecExpParser#vexp.
    def enterVexp(self, ctx:SpecExpParser.VexpContext):
        pass

    # Exit a parse tree produced by SpecExpParser#vexp.
    def exitVexp(self, ctx:SpecExpParser.VexpContext):
        pass


    # Enter a parse tree produced by SpecExpParser#bexp.
    def enterBexp(self, ctx:SpecExpParser.BexpContext):
        pass

    # Exit a parse tree produced by SpecExpParser#bexp.
    def exitBexp(self, ctx:SpecExpParser.BexpContext):
        pass


    # Enter a parse tree produced by SpecExpParser#numexp.
    def enterNumexp(self, ctx:SpecExpParser.NumexpContext):
        pass

    # Exit a parse tree produced by SpecExpParser#numexp.
    def exitNumexp(self, ctx:SpecExpParser.NumexpContext):
        pass



del SpecExpParser