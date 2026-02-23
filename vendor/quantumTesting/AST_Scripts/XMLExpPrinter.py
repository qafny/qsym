#from collections import ChainMap
from types import NoneType

from Source.quantumCode.AST_Scripts.XMLExpVisitor import XMLExpVisitor
#from Source.quantumCode.AST_Scripts.ExpParser import *
#from Source.quantumCode.AST_Scripts.XMLExpVisitor import XMLExpVisitor
#from Source.quantumCode.AST_Scripts.XMLExpParser import XMLExpParser
from Source.quantumCode.AST_Scripts.XMLProgrammer import *

class XMLExpPrinter(XMLExpVisitor):

    def __init__(self, type_environment:dict):
        self.type_environment = type_environment
        #self.type_environment = type_environment
        self.xml_output = ''
        #self.indentation = 0

    def visitRoot(self, ctx: QXRoot):
        self.xml_output += "<root>"
        ctx.program().accept(self)
        self.xml_output += "</root>"

    # Visit a parse tree produced by XMLExpParser#nextexp.
    def visitNext(self, ctx: QXNext):
        self.xml_output += "<next>"
        ctx.program().accept(self)
        self.xml_output += "</next>"

    # Visit a parse tree produced by XMLExpParser#program.
    def visitProgram(self, ctx: QXProgram):
        i = 0
        while ctx.exp(i) is not None:
            ctx.exp(i).accept(self)
            self.xml_output += "\n"
            i += 1

    def visitLet(self, ctx: QXLet):
        self.xml_output += "<let id = '" + ctx.ID() + "' >"
        i = 0
        while ctx.idexp(i) is not None:
            #self.xml_output += "("
            ctx.idexp(i).accept(self)
            #self.xml_output += ")"
            i += 1
        #self.xml_output += " in\n  "
        ctx.program().accept(self)
        self.xml_output += "</let>"

    def visitMatch(self, ctx: QXMatch):
        self.xml_output += "<match id = '"
        self.xml_output += ctx.ID()
        self.xml_output += "'>"
        i = 0
        ctx.zero().accept(self)
        ctx.multi().accept(self)
        #self.xml_output += "\n end \n"

    def visitPair(self, ctx: QXPair):
        self.xml_output += "<pair case ='"
        ctx.elem().accept(self)
        self.xml_output += "'> "
        ctx.program().accept(self)
        self.xml_output += "</pair>"

    def visitApp(self, ctx: QXApp):
        self.xml_output += "<app id = '"
        self.xml_output += ctx.ID()
        self.xml_output += "' >"
        i = 0
        while ctx.vexp(i) is not None:
            ctx.vexp(i).accept(self)
            self.xml_output += " "
            #print("var",ctxa.idexp(i+1).Identifier())
            i += 1
        self.xml_output += "</app>"

    def visitIf(self, ctx: QXIf):
        self.xml_output += "<if>"
        ctx.vexp().accept(self)
        self.xml_output += "\n"
        ctx.left().accept(self)
        self.xml_output += "\n"
        ctx.right().accept(self)
        self.xml_output += "</if>"

    def visitSKIP(self, ctx: QXSKIP):
        self.xml_output += "<pexp gate = 'SKIP' id ='"
        self.xml_output += ctx.ID()
        self.xml_output += "' >"
        ctx.vexp().accept(self)
        self.xml_output += "</pexp>"

    # X posi, changed the following for an example
    def visitX(self, ctx: QXX):
        self.xml_output += "<pexp gate = 'X' id ='"
        self.xml_output += ctx.ID()
        self.xml_output += "' >"
        ctx.vexp().accept(self)
        self.xml_output += "</pexp>"


    # we will first get the position in st and check if the state is 0 or 1,
    # then decide if we go to recucively call ctx.exp
    def visitCU(self, ctx: QXCU):
        self.xml_output += "<pexp gate = 'CU' id ='"
        self.xml_output += ctx.ID()
        self.xml_output += "' >"
        ctx.vexp().accept(self)
        self.xml_output += "\n"
        ctx.program().accept(self)
        self.xml_output += "</pexp>"


    # SR n x, now variables are all string, are this OK?
    def visitSR(self, ctx: QXSR):
        self.xml_output += "<pexp gate = 'SR' id ='"
        self.xml_output += ctx.ID()
        self.xml_output += "' >"
        ctx.vexp().accept(self)
        self.xml_output += "</pexp>"

    def visitLshift(self, ctx: QXLshift):
        self.xml_output += "<pexp gate = 'Lshift' id ='"
        self.xml_output += ctx.ID()
        self.xml_output += "' >"
        self.xml_output += "</pexp>"

    def visitRshift(self, ctx: QXRshift):
        self.xml_output += "<pexp gate = 'Rshift' id ='"
        self.xml_output += ctx.ID()
        self.xml_output += "' >"
        self.xml_output += "</pexp>"

    def visitRev(self, ctx: QXRev):
        self.xml_output += "<pexp gate = 'Rev' id ='"
        self.xml_output += ctx.ID()
        self.xml_output += "' >"
        self.xml_output += "</pexp>"

    # actually, we need to change the QFT function
    # the following QFT is only for full QFT, we did not have the case for AQFT
    def visitQFT(self, ctx: QXQFT):
        self.xml_output += "<pexp gate = 'QFT' id ='"
        self.xml_output += ctx.ID()
        self.xml_output += "' >"
        ctx.vexp().accept(self)
        self.xml_output += "</pexp>"

    def visitRQFT(self, ctx: QXRQFT):
        self.xml_output += "<pexp gate = 'RQFT' id ='"
        self.xml_output += ctx.ID()
        self.xml_output += "' >"
        self.xml_output += "</pexp>"

    def visitIDExp(self, ctx: QXIDExp):
        self.xml_output += "<vexp op = 'id' "
        if ctx.type() is not None:
            ctx.type().accept(self)
        self.xml_output += ">"
        self.xml_output += ctx.ID()
        self.xml_output += "</vexp>"

    def visitQTy(self, ctx: Qty):
        if ctx.type() is not None:
            if ctx.type() == "Nor":
                self.xml_output += "Nor("
                ctx.get_num().accept(self)
                self.xml_output += ")"
            elif ctx.type() == "Phi":
                self.xml_output += "Phi("
                ctx.get_num().accept(self)
                self.xml_output += ", "
                ctx.get_anum().accept(self)
                self.xml_output += ")"
        else:
            self.xml_output += "Q("
            ctx.get_num().accept(self)
            self.xml_output += ")"

    def visitNat(self, ctx: Nat):
        self.xml_output += "Nat"

    def visitNum(self, ctx: QXNum):
        self.xml_output += "<vexp op = 'num' >"
        self.xml_output += str(ctx.num()) + "</vexp>"

    def visitBin(self, ctx: QXBin):
        self.xml_output += "<vexp op = '" + ctx.OP() + "' >"
        ctx.left().accept(self)
        ctx.right().accept(self)
        self.xml_output += "</vexp>"

    def visitTerminal(self, node):
        # For leaf nodes
        if node.getSymbol().type == XMLExpParser.Identifier:
            self.xml_output += ""f'{node.getText()}\n'""
        if node.getSymbol().type == XMLExpParser.Number:
            self.xml_output += ""f'{node.getText()}\n'""
        self.xml_output += ""

    # def visit(self, ctx):
    #    if ctx.getChildCount() > 0:
    #        self.visitChildren(ctx)
    #    else:
    #        self.visitTerminal(ctx)

    def getXML(self):
        return self.xml_output
