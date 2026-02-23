# Generated from PQASM.g4 by ANTLR 4.13.1
# encoding: utf-8
from antlr4 import *
from io import StringIO
import sys
if sys.version_info[1] > 5:
	from typing import TextIO
else:
	from typing.io import TextIO

def serializedATN():
    return [
        4,1,32,157,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,2,6,7,
        6,2,7,7,7,2,8,7,8,2,9,7,9,2,10,7,10,1,0,1,0,1,0,1,0,1,0,1,0,1,0,
        1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,
        1,0,1,0,1,0,3,0,49,8,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,70,8,1,1,2,1,2,1,2,1,2,1,2,
        1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,
        1,2,1,2,1,2,1,2,1,2,1,2,3,2,99,8,2,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,
        3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,3,3,118,8,3,1,4,1,4,1,4,1,
        4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,3,4,132,8,4,1,5,1,5,1,5,1,5,1,
        6,1,6,1,7,1,7,1,8,1,8,3,8,144,8,8,1,9,1,9,1,10,1,10,1,10,1,10,1,
        10,1,10,1,10,3,10,155,8,10,1,10,0,0,11,0,2,4,6,8,10,12,14,16,18,
        20,0,1,1,0,30,31,173,0,48,1,0,0,0,2,69,1,0,0,0,4,98,1,0,0,0,6,117,
        1,0,0,0,8,131,1,0,0,0,10,133,1,0,0,0,12,137,1,0,0,0,14,139,1,0,0,
        0,16,143,1,0,0,0,18,145,1,0,0,0,20,154,1,0,0,0,22,49,5,1,0,0,23,
        24,5,2,0,0,24,49,3,2,1,0,25,26,5,3,0,0,26,49,3,10,5,0,27,28,5,4,
        0,0,28,49,3,10,5,0,29,30,5,5,0,0,30,31,3,0,0,0,31,32,3,0,0,0,32,
        49,1,0,0,0,33,34,5,6,0,0,34,35,3,16,8,0,35,36,3,10,5,0,36,37,3,0,
        0,0,37,49,1,0,0,0,38,39,5,7,0,0,39,40,3,8,4,0,40,41,3,0,0,0,41,42,
        3,0,0,0,42,49,1,0,0,0,43,49,3,2,1,0,44,45,5,8,0,0,45,46,3,0,0,0,
        46,47,5,9,0,0,47,49,1,0,0,0,48,22,1,0,0,0,48,23,1,0,0,0,48,25,1,
        0,0,0,48,27,1,0,0,0,48,29,1,0,0,0,48,33,1,0,0,0,48,38,1,0,0,0,48,
        43,1,0,0,0,48,44,1,0,0,0,49,1,1,0,0,0,50,51,5,10,0,0,51,52,3,2,1,
        0,52,53,3,2,1,0,53,70,1,0,0,0,54,55,5,11,0,0,55,56,3,12,6,0,56,57,
        3,2,1,0,57,70,1,0,0,0,58,59,5,12,0,0,59,70,3,4,2,0,60,61,5,13,0,
        0,61,62,3,12,6,0,62,63,3,14,7,0,63,70,1,0,0,0,64,70,3,4,2,0,65,66,
        5,8,0,0,66,67,3,2,1,0,67,68,5,9,0,0,68,70,1,0,0,0,69,50,1,0,0,0,
        69,54,1,0,0,0,69,58,1,0,0,0,69,60,1,0,0,0,69,64,1,0,0,0,69,65,1,
        0,0,0,70,3,1,0,0,0,71,72,5,14,0,0,72,73,3,10,5,0,73,74,3,16,8,0,
        74,99,1,0,0,0,75,76,5,15,0,0,76,77,3,10,5,0,77,78,3,16,8,0,78,79,
        3,12,6,0,79,99,1,0,0,0,80,81,5,16,0,0,81,82,3,10,5,0,82,83,3,16,
        8,0,83,84,3,12,6,0,84,99,1,0,0,0,85,86,5,17,0,0,86,87,3,10,5,0,87,
        88,3,16,8,0,88,89,3,16,8,0,89,99,1,0,0,0,90,91,5,18,0,0,91,92,3,
        10,5,0,92,93,3,12,6,0,93,99,1,0,0,0,94,95,5,8,0,0,95,96,3,4,2,0,
        96,97,5,9,0,0,97,99,1,0,0,0,98,71,1,0,0,0,98,75,1,0,0,0,98,80,1,
        0,0,0,98,85,1,0,0,0,98,90,1,0,0,0,98,94,1,0,0,0,99,5,1,0,0,0,100,
        101,5,19,0,0,101,118,5,31,0,0,102,103,5,20,0,0,103,118,3,20,10,0,
        104,105,5,21,0,0,105,106,3,6,3,0,106,107,3,6,3,0,107,118,1,0,0,0,
        108,109,5,22,0,0,109,110,3,6,3,0,110,111,3,6,3,0,111,118,1,0,0,0,
        112,118,3,16,8,0,113,114,5,8,0,0,114,115,3,6,3,0,115,116,5,9,0,0,
        116,118,1,0,0,0,117,100,1,0,0,0,117,102,1,0,0,0,117,104,1,0,0,0,
        117,108,1,0,0,0,117,112,1,0,0,0,117,113,1,0,0,0,118,7,1,0,0,0,119,
        120,5,23,0,0,120,121,3,6,3,0,121,122,3,6,3,0,122,132,1,0,0,0,123,
        124,5,24,0,0,124,125,3,6,3,0,125,126,3,6,3,0,126,132,1,0,0,0,127,
        128,5,8,0,0,128,129,3,8,4,0,129,130,5,9,0,0,130,132,1,0,0,0,131,
        119,1,0,0,0,131,123,1,0,0,0,131,127,1,0,0,0,132,9,1,0,0,0,133,134,
        5,25,0,0,134,135,5,31,0,0,135,136,5,26,0,0,136,11,1,0,0,0,137,138,
        3,16,8,0,138,13,1,0,0,0,139,140,3,16,8,0,140,15,1,0,0,0,141,144,
        3,20,10,0,142,144,5,31,0,0,143,141,1,0,0,0,143,142,1,0,0,0,144,17,
        1,0,0,0,145,146,7,0,0,0,146,19,1,0,0,0,147,155,5,29,0,0,148,149,
        5,27,0,0,149,155,5,29,0,0,150,151,5,8,0,0,151,152,3,20,10,0,152,
        153,5,9,0,0,153,155,1,0,0,0,154,147,1,0,0,0,154,148,1,0,0,0,154,
        150,1,0,0,0,155,21,1,0,0,0,7,48,69,98,117,131,143,154
    ]

class PQASMParser ( Parser ):

    grammarFileName = "PQASM.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "'ESKIP'", "'Next'", "'Had'", "'New'", 
                     "'ESeq'", "'Meas'", "'IFa'", "'('", "')'", "'ISeq'", 
                     "'ICU'", "'Ora'", "'Ry'", "'Add'", "'Less'", "'Equal'", 
                     "'ModMult'", "'Equal_posi_list'", "'BA'", "'Num'", 
                     "'APlus'", "'AMult'", "'CEq'", "'CLt'", "'['", "']'", 
                     "'nat2fb'", "'eskip'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "ESKIP", "NAT", "BOOL", "VARNAME", "WS" ]

    RULE_program = 0
    RULE_instr = 1
    RULE_mu = 2
    RULE_arithExp = 3
    RULE_cBoolExp = 4
    RULE_list = 5
    RULE_pos = 6
    RULE_rot = 7
    RULE_natOrVarname = 8
    RULE_boolOrVarName = 9
    RULE_natOrNatMaker = 10

    ruleNames =  [ "program", "instr", "mu", "arithExp", "cBoolExp", "list", 
                   "pos", "rot", "natOrVarname", "boolOrVarName", "natOrNatMaker" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    T__4=5
    T__5=6
    T__6=7
    T__7=8
    T__8=9
    T__9=10
    T__10=11
    T__11=12
    T__12=13
    T__13=14
    T__14=15
    T__15=16
    T__16=17
    T__17=18
    T__18=19
    T__19=20
    T__20=21
    T__21=22
    T__22=23
    T__23=24
    T__24=25
    T__25=26
    T__26=27
    ESKIP=28
    NAT=29
    BOOL=30
    VARNAME=31
    WS=32

    def __init__(self, input:TokenStream, output:TextIO = sys.stdout):
        super().__init__(input, output)
        self.checkVersion("4.13.1")
        self._interp = ParserATNSimulator(self, self.atn, self.decisionsToDFA, self.sharedContextCache)
        self._predicates = None




    class ProgramContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def instr(self):
            return self.getTypedRuleContext(PQASMParser.InstrContext,0)


        def list_(self):
            return self.getTypedRuleContext(PQASMParser.ListContext,0)


        def program(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(PQASMParser.ProgramContext)
            else:
                return self.getTypedRuleContext(PQASMParser.ProgramContext,i)


        def natOrVarname(self):
            return self.getTypedRuleContext(PQASMParser.NatOrVarnameContext,0)


        def cBoolExp(self):
            return self.getTypedRuleContext(PQASMParser.CBoolExpContext,0)


        def getRuleIndex(self):
            return PQASMParser.RULE_program

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterProgram" ):
                listener.enterProgram(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitProgram" ):
                listener.exitProgram(self)




    def program(self):

        localctx = PQASMParser.ProgramContext(self, self._ctx, self.state)
        self.enterRule(localctx, 0, self.RULE_program)
        try:
            self.state = 48
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,0,self._ctx)
            if la_ == 1:
                self.enterOuterAlt(localctx, 1)
                self.state = 22
                self.match(PQASMParser.T__0)
                pass

            elif la_ == 2:
                self.enterOuterAlt(localctx, 2)
                self.state = 23
                self.match(PQASMParser.T__1)
                self.state = 24
                self.instr()
                pass

            elif la_ == 3:
                self.enterOuterAlt(localctx, 3)
                self.state = 25
                self.match(PQASMParser.T__2)
                self.state = 26
                self.list_()
                pass

            elif la_ == 4:
                self.enterOuterAlt(localctx, 4)
                self.state = 27
                self.match(PQASMParser.T__3)
                self.state = 28
                self.list_()
                pass

            elif la_ == 5:
                self.enterOuterAlt(localctx, 5)
                self.state = 29
                self.match(PQASMParser.T__4)
                self.state = 30
                self.program()
                self.state = 31
                self.program()
                pass

            elif la_ == 6:
                self.enterOuterAlt(localctx, 6)
                self.state = 33
                self.match(PQASMParser.T__5)
                self.state = 34
                self.natOrVarname()
                self.state = 35
                self.list_()
                self.state = 36
                self.program()
                pass

            elif la_ == 7:
                self.enterOuterAlt(localctx, 7)
                self.state = 38
                self.match(PQASMParser.T__6)
                self.state = 39
                self.cBoolExp()
                self.state = 40
                self.program()
                self.state = 41
                self.program()
                pass

            elif la_ == 8:
                self.enterOuterAlt(localctx, 8)
                self.state = 43
                self.instr()
                pass

            elif la_ == 9:
                self.enterOuterAlt(localctx, 9)
                self.state = 44
                self.match(PQASMParser.T__7)
                self.state = 45
                self.program()
                self.state = 46
                self.match(PQASMParser.T__8)
                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class InstrContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def instr(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(PQASMParser.InstrContext)
            else:
                return self.getTypedRuleContext(PQASMParser.InstrContext,i)


        def pos(self):
            return self.getTypedRuleContext(PQASMParser.PosContext,0)


        def mu(self):
            return self.getTypedRuleContext(PQASMParser.MuContext,0)


        def rot(self):
            return self.getTypedRuleContext(PQASMParser.RotContext,0)


        def getRuleIndex(self):
            return PQASMParser.RULE_instr

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterInstr" ):
                listener.enterInstr(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitInstr" ):
                listener.exitInstr(self)




    def instr(self):

        localctx = PQASMParser.InstrContext(self, self._ctx, self.state)
        self.enterRule(localctx, 2, self.RULE_instr)
        try:
            self.state = 69
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,1,self._ctx)
            if la_ == 1:
                self.enterOuterAlt(localctx, 1)
                self.state = 50
                self.match(PQASMParser.T__9)
                self.state = 51
                self.instr()
                self.state = 52
                self.instr()
                pass

            elif la_ == 2:
                self.enterOuterAlt(localctx, 2)
                self.state = 54
                self.match(PQASMParser.T__10)
                self.state = 55
                self.pos()
                self.state = 56
                self.instr()
                pass

            elif la_ == 3:
                self.enterOuterAlt(localctx, 3)
                self.state = 58
                self.match(PQASMParser.T__11)
                self.state = 59
                self.mu()
                pass

            elif la_ == 4:
                self.enterOuterAlt(localctx, 4)
                self.state = 60
                self.match(PQASMParser.T__12)
                self.state = 61
                self.pos()
                self.state = 62
                self.rot()
                pass

            elif la_ == 5:
                self.enterOuterAlt(localctx, 5)
                self.state = 64
                self.mu()
                pass

            elif la_ == 6:
                self.enterOuterAlt(localctx, 6)
                self.state = 65
                self.match(PQASMParser.T__7)
                self.state = 66
                self.instr()
                self.state = 67
                self.match(PQASMParser.T__8)
                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class MuContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def list_(self):
            return self.getTypedRuleContext(PQASMParser.ListContext,0)


        def natOrVarname(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(PQASMParser.NatOrVarnameContext)
            else:
                return self.getTypedRuleContext(PQASMParser.NatOrVarnameContext,i)


        def pos(self):
            return self.getTypedRuleContext(PQASMParser.PosContext,0)


        def mu(self):
            return self.getTypedRuleContext(PQASMParser.MuContext,0)


        def getRuleIndex(self):
            return PQASMParser.RULE_mu

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterMu" ):
                listener.enterMu(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitMu" ):
                listener.exitMu(self)




    def mu(self):

        localctx = PQASMParser.MuContext(self, self._ctx, self.state)
        self.enterRule(localctx, 4, self.RULE_mu)
        try:
            self.state = 98
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [14]:
                self.enterOuterAlt(localctx, 1)
                self.state = 71
                self.match(PQASMParser.T__13)
                self.state = 72
                self.list_()
                self.state = 73
                self.natOrVarname()
                pass
            elif token in [15]:
                self.enterOuterAlt(localctx, 2)
                self.state = 75
                self.match(PQASMParser.T__14)
                self.state = 76
                self.list_()
                self.state = 77
                self.natOrVarname()
                self.state = 78
                self.pos()
                pass
            elif token in [16]:
                self.enterOuterAlt(localctx, 3)
                self.state = 80
                self.match(PQASMParser.T__15)
                self.state = 81
                self.list_()
                self.state = 82
                self.natOrVarname()
                self.state = 83
                self.pos()
                pass
            elif token in [17]:
                self.enterOuterAlt(localctx, 4)
                self.state = 85
                self.match(PQASMParser.T__16)
                self.state = 86
                self.list_()
                self.state = 87
                self.natOrVarname()
                self.state = 88
                self.natOrVarname()
                pass
            elif token in [18]:
                self.enterOuterAlt(localctx, 5)
                self.state = 90
                self.match(PQASMParser.T__17)
                self.state = 91
                self.list_()
                self.state = 92
                self.pos()
                pass
            elif token in [8]:
                self.enterOuterAlt(localctx, 6)
                self.state = 94
                self.match(PQASMParser.T__7)
                self.state = 95
                self.mu()
                self.state = 96
                self.match(PQASMParser.T__8)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class ArithExpContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def VARNAME(self):
            return self.getToken(PQASMParser.VARNAME, 0)

        def natOrNatMaker(self):
            return self.getTypedRuleContext(PQASMParser.NatOrNatMakerContext,0)


        def arithExp(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(PQASMParser.ArithExpContext)
            else:
                return self.getTypedRuleContext(PQASMParser.ArithExpContext,i)


        def natOrVarname(self):
            return self.getTypedRuleContext(PQASMParser.NatOrVarnameContext,0)


        def getRuleIndex(self):
            return PQASMParser.RULE_arithExp

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterArithExp" ):
                listener.enterArithExp(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitArithExp" ):
                listener.exitArithExp(self)




    def arithExp(self):

        localctx = PQASMParser.ArithExpContext(self, self._ctx, self.state)
        self.enterRule(localctx, 6, self.RULE_arithExp)
        try:
            self.state = 117
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,3,self._ctx)
            if la_ == 1:
                self.enterOuterAlt(localctx, 1)
                self.state = 100
                self.match(PQASMParser.T__18)
                self.state = 101
                self.match(PQASMParser.VARNAME)
                pass

            elif la_ == 2:
                self.enterOuterAlt(localctx, 2)
                self.state = 102
                self.match(PQASMParser.T__19)
                self.state = 103
                self.natOrNatMaker()
                pass

            elif la_ == 3:
                self.enterOuterAlt(localctx, 3)
                self.state = 104
                self.match(PQASMParser.T__20)
                self.state = 105
                self.arithExp()
                self.state = 106
                self.arithExp()
                pass

            elif la_ == 4:
                self.enterOuterAlt(localctx, 4)
                self.state = 108
                self.match(PQASMParser.T__21)
                self.state = 109
                self.arithExp()
                self.state = 110
                self.arithExp()
                pass

            elif la_ == 5:
                self.enterOuterAlt(localctx, 5)
                self.state = 112
                self.natOrVarname()
                pass

            elif la_ == 6:
                self.enterOuterAlt(localctx, 6)
                self.state = 113
                self.match(PQASMParser.T__7)
                self.state = 114
                self.arithExp()
                self.state = 115
                self.match(PQASMParser.T__8)
                pass


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class CBoolExpContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def arithExp(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(PQASMParser.ArithExpContext)
            else:
                return self.getTypedRuleContext(PQASMParser.ArithExpContext,i)


        def cBoolExp(self):
            return self.getTypedRuleContext(PQASMParser.CBoolExpContext,0)


        def getRuleIndex(self):
            return PQASMParser.RULE_cBoolExp

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterCBoolExp" ):
                listener.enterCBoolExp(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitCBoolExp" ):
                listener.exitCBoolExp(self)




    def cBoolExp(self):

        localctx = PQASMParser.CBoolExpContext(self, self._ctx, self.state)
        self.enterRule(localctx, 8, self.RULE_cBoolExp)
        try:
            self.state = 131
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [23]:
                self.enterOuterAlt(localctx, 1)
                self.state = 119
                self.match(PQASMParser.T__22)
                self.state = 120
                self.arithExp()
                self.state = 121
                self.arithExp()
                pass
            elif token in [24]:
                self.enterOuterAlt(localctx, 2)
                self.state = 123
                self.match(PQASMParser.T__23)
                self.state = 124
                self.arithExp()
                self.state = 125
                self.arithExp()
                pass
            elif token in [8]:
                self.enterOuterAlt(localctx, 3)
                self.state = 127
                self.match(PQASMParser.T__7)
                self.state = 128
                self.cBoolExp()
                self.state = 129
                self.match(PQASMParser.T__8)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class ListContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def VARNAME(self):
            return self.getToken(PQASMParser.VARNAME, 0)

        def getRuleIndex(self):
            return PQASMParser.RULE_list

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterList" ):
                listener.enterList(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitList" ):
                listener.exitList(self)




    def list_(self):

        localctx = PQASMParser.ListContext(self, self._ctx, self.state)
        self.enterRule(localctx, 10, self.RULE_list)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 133
            self.match(PQASMParser.T__24)
            self.state = 134
            self.match(PQASMParser.VARNAME)
            self.state = 135
            self.match(PQASMParser.T__25)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class PosContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def natOrVarname(self):
            return self.getTypedRuleContext(PQASMParser.NatOrVarnameContext,0)


        def getRuleIndex(self):
            return PQASMParser.RULE_pos

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterPos" ):
                listener.enterPos(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitPos" ):
                listener.exitPos(self)




    def pos(self):

        localctx = PQASMParser.PosContext(self, self._ctx, self.state)
        self.enterRule(localctx, 12, self.RULE_pos)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 137
            self.natOrVarname()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class RotContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def natOrVarname(self):
            return self.getTypedRuleContext(PQASMParser.NatOrVarnameContext,0)


        def getRuleIndex(self):
            return PQASMParser.RULE_rot

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterRot" ):
                listener.enterRot(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitRot" ):
                listener.exitRot(self)




    def rot(self):

        localctx = PQASMParser.RotContext(self, self._ctx, self.state)
        self.enterRule(localctx, 14, self.RULE_rot)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 139
            self.natOrVarname()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class NatOrVarnameContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def natOrNatMaker(self):
            return self.getTypedRuleContext(PQASMParser.NatOrNatMakerContext,0)


        def VARNAME(self):
            return self.getToken(PQASMParser.VARNAME, 0)

        def getRuleIndex(self):
            return PQASMParser.RULE_natOrVarname

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterNatOrVarname" ):
                listener.enterNatOrVarname(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitNatOrVarname" ):
                listener.exitNatOrVarname(self)




    def natOrVarname(self):

        localctx = PQASMParser.NatOrVarnameContext(self, self._ctx, self.state)
        self.enterRule(localctx, 16, self.RULE_natOrVarname)
        try:
            self.state = 143
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [8, 27, 29]:
                self.enterOuterAlt(localctx, 1)
                self.state = 141
                self.natOrNatMaker()
                pass
            elif token in [31]:
                self.enterOuterAlt(localctx, 2)
                self.state = 142
                self.match(PQASMParser.VARNAME)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class BoolOrVarNameContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def BOOL(self):
            return self.getToken(PQASMParser.BOOL, 0)

        def VARNAME(self):
            return self.getToken(PQASMParser.VARNAME, 0)

        def getRuleIndex(self):
            return PQASMParser.RULE_boolOrVarName

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterBoolOrVarName" ):
                listener.enterBoolOrVarName(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitBoolOrVarName" ):
                listener.exitBoolOrVarName(self)




    def boolOrVarName(self):

        localctx = PQASMParser.BoolOrVarNameContext(self, self._ctx, self.state)
        self.enterRule(localctx, 18, self.RULE_boolOrVarName)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 145
            _la = self._input.LA(1)
            if not(_la==30 or _la==31):
                self._errHandler.recoverInline(self)
            else:
                self._errHandler.reportMatch(self)
                self.consume()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class NatOrNatMakerContext(ParserRuleContext):
        __slots__ = 'parser'

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def NAT(self):
            return self.getToken(PQASMParser.NAT, 0)

        def natOrNatMaker(self):
            return self.getTypedRuleContext(PQASMParser.NatOrNatMakerContext,0)


        def getRuleIndex(self):
            return PQASMParser.RULE_natOrNatMaker

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterNatOrNatMaker" ):
                listener.enterNatOrNatMaker(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitNatOrNatMaker" ):
                listener.exitNatOrNatMaker(self)




    def natOrNatMaker(self):

        localctx = PQASMParser.NatOrNatMakerContext(self, self._ctx, self.state)
        self.enterRule(localctx, 20, self.RULE_natOrNatMaker)
        try:
            self.state = 154
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [29]:
                self.enterOuterAlt(localctx, 1)
                self.state = 147
                self.match(PQASMParser.NAT)
                pass
            elif token in [27]:
                self.enterOuterAlt(localctx, 2)
                self.state = 148
                self.match(PQASMParser.T__26)
                self.state = 149
                self.match(PQASMParser.NAT)
                pass
            elif token in [8]:
                self.enterOuterAlt(localctx, 3)
                self.state = 150
                self.match(PQASMParser.T__7)
                self.state = 151
                self.natOrNatMaker()
                self.state = 152
                self.match(PQASMParser.T__8)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx





