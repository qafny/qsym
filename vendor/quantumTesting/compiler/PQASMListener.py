# Generated from PQASM.g4 by ANTLR 4.13.1
from antlr4 import *
if "." in __name__:
    from .PQASMParser import PQASMParser
else:
    from PQASMParser import PQASMParser

# This class defines a complete listener for a parse tree produced by PQASMParser.
class PQASMListener(ParseTreeListener):

    # Enter a parse tree produced by PQASMParser#program.
    def enterProgram(self, ctx:PQASMParser.ProgramContext):
        pass

    # Exit a parse tree produced by PQASMParser#program.
    def exitProgram(self, ctx:PQASMParser.ProgramContext):
        pass


    # Enter a parse tree produced by PQASMParser#instr.
    def enterInstr(self, ctx:PQASMParser.InstrContext):
        pass

    # Exit a parse tree produced by PQASMParser#instr.
    def exitInstr(self, ctx:PQASMParser.InstrContext):
        pass


    # Enter a parse tree produced by PQASMParser#mu.
    def enterMu(self, ctx:PQASMParser.MuContext):
        pass

    # Exit a parse tree produced by PQASMParser#mu.
    def exitMu(self, ctx:PQASMParser.MuContext):
        pass


    # Enter a parse tree produced by PQASMParser#arithExp.
    def enterArithExp(self, ctx:PQASMParser.ArithExpContext):
        pass

    # Exit a parse tree produced by PQASMParser#arithExp.
    def exitArithExp(self, ctx:PQASMParser.ArithExpContext):
        pass


    # Enter a parse tree produced by PQASMParser#cBoolExp.
    def enterCBoolExp(self, ctx:PQASMParser.CBoolExpContext):
        pass

    # Exit a parse tree produced by PQASMParser#cBoolExp.
    def exitCBoolExp(self, ctx:PQASMParser.CBoolExpContext):
        pass


    # Enter a parse tree produced by PQASMParser#list.
    def enterList(self, ctx:PQASMParser.ListContext):
        pass

    # Exit a parse tree produced by PQASMParser#list.
    def exitList(self, ctx:PQASMParser.ListContext):
        pass


    # Enter a parse tree produced by PQASMParser#pos.
    def enterPos(self, ctx:PQASMParser.PosContext):
        pass

    # Exit a parse tree produced by PQASMParser#pos.
    def exitPos(self, ctx:PQASMParser.PosContext):
        pass


    # Enter a parse tree produced by PQASMParser#rot.
    def enterRot(self, ctx:PQASMParser.RotContext):
        pass

    # Exit a parse tree produced by PQASMParser#rot.
    def exitRot(self, ctx:PQASMParser.RotContext):
        pass


    # Enter a parse tree produced by PQASMParser#natOrVarname.
    def enterNatOrVarname(self, ctx:PQASMParser.NatOrVarnameContext):
        pass

    # Exit a parse tree produced by PQASMParser#natOrVarname.
    def exitNatOrVarname(self, ctx:PQASMParser.NatOrVarnameContext):
        pass


    # Enter a parse tree produced by PQASMParser#boolOrVarName.
    def enterBoolOrVarName(self, ctx:PQASMParser.BoolOrVarNameContext):
        pass

    # Exit a parse tree produced by PQASMParser#boolOrVarName.
    def exitBoolOrVarName(self, ctx:PQASMParser.BoolOrVarNameContext):
        pass


    # Enter a parse tree produced by PQASMParser#natOrNatMaker.
    def enterNatOrNatMaker(self, ctx:PQASMParser.NatOrNatMakerContext):
        pass

    # Exit a parse tree produced by PQASMParser#natOrNatMaker.
    def exitNatOrNatMaker(self, ctx:PQASMParser.NatOrNatMakerContext):
        pass



del PQASMParser