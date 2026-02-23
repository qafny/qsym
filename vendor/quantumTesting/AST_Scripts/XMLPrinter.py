#from collections import ChainMap
from types import NoneType
from AST_Scripts.XMLProgrammer import *
from AST_Scripts.ProgramVisitor import *

class XMLPrinter(ProgramVisitor):

    def __init__(self):
        #self.type_environment = type_environment
        self.xml_output = ''
        #self.indentation = 0

    # Visit a parse tree produced by XMLExpParser#program.
    def visitProgram(self, ctx: XMLProgrammer.QXProgram):
        i = 0
        while ctx.exp(i) is not None:
            ctx.exp(i).accept(self)
            self.xml_output += "\n"
            i += 1

    def visitLet(self, ctx: XMLProgrammer.QXLet):
        self.xml_output += "let " + ctx.ID() + " = "
        i = 0
        while ctx.idexp(i) is not None:
            self.xml_output += "("
            ctx.idexp(i).accept(self)
            self.xml_output += ")"
            i += 1
        self.xml_output += " in\n  "
        ctx.program().accept(self)

    def visitMatch(self, ctx: XMLProgrammer.QXMatch):
        self.xml_output += "match "+ ctx.ID()
        self.xml_output += " with "
        ctx._zero.accept(self)
        ctx._multi.accept(self)
        self.xml_output += "\n end \n"

    def visitPair(self, ctx: XMLProgrammer.QXPair):
        ctx.elem().accept(self)
        self.xml_output += " => "
        ctx._program.accept(self)

    def visitApp(self, ctx: XMLProgrammer.QXApp):
        self.xml_output += " " + ctx.ID()
        self.xml_output += "("
        i = 0
        while ctx.vexp(i) is not None:
            ctx.vexp(i).accept(self)
            self.xml_output += ", "
            #print("var",ctxa.idexp(i+1).ID())
            i += 1
        self.xml_output += ")"

    def visitIf(self, ctx: XMLProgrammer.QXIf):
        self.xml_output += "if "
        ctx.vexp().accept(self)
        self.xml_output += " then {"
        ctx.left().accept(self)
        self.xml_output += "} else {"
        ctx.right().accept(self)
        self.xml_output += "}"

    def visitSKIP(self, ctx: XMLProgrammer.QXSKIP):
        self.xml_output += "  SKIP (" + ctx.ID()
        self.xml_output += ", "
        ctx.vexp().accept(self)
        self.xml_output += ")"

    # X posi, changed the following for an example
    def visitX(self, ctx: XMLProgrammer.QXX):
        self.xml_output += "  X (" + ctx.ID()
        self.xml_output += ", "
        ctx.vexp().accept(self)
        self.xml_output += ")"


    # we will first get the position in st and check if the state is 0 or 1,
    # then decide if we go to recucively call ctx.exp
    def visitCU(self, ctx: XMLProgrammer.QXCU):
        self.xml_output += "  CU (" + ctx.ID()
        self.xml_output += ", "
        ctx.vexp().accept(self)
        self.xml_output += ")"
        ctx.program().accept(self)

    # SR n x, now variables are all string, are this OK?
    def visitSR(self, ctx: XMLProgrammer.QXSR):
        self.xml_output += "  SR (" + ctx.ID()
        self.xml_output += ", "
        ctx.vexp().accept(self)
        self.xml_output += ")"

    def visitLshift(self, ctx: XMLProgrammer.QXLshift):
        self.xml_output += "  Lshift " + ctx.ID()

    def visitRshift(self, ctx: XMLProgrammer.QXRshift):
        self.xml_output += "  Rshift " + ctx.ID()

    def visitRev(self, ctx: XMLProgrammer.QXRev):
        self.xml_output += "  Rev " + ctx.ID()

    # actually, we need to change the QFT function
    # the following QFT is only for full QFT, we did not have the case for AQFT
    def visitQFT(self, ctx: XMLProgrammer.QXQFT):
        self.xml_output += "  QFT (" + ctx.ID()
        self.xml_output += ", "
        ctx.vexp().accept(self)
        self.xml_output += ")"

    def visitRQFT(self, ctx: XMLProgrammer.QXRQFT):
        self.xml_output += "  RQFT " + ctx.ID()

    def visitIDExp(self, ctx: XMLProgrammer.QXIDExp):
        self.xml_output += ctx.ID()
        if ctx.type() is not None:
            self.xml_output += " : "
            ctx.type().accept(self)

    def visitQTy(self, ctx: XMLProgrammer.Qty):
        if ctx.type() is None:
            self.xml_output += "Q("
            ctx.get_num().accept(self)
            self.xml_output += ")"
        elif ctx.type() == "Nor":
            self.xml_output += "Nor("
            ctx.get_num().accept(self)
            self.xml_output += ")"
        else:
            self.xml_output += "Phi("
            ctx.get_num().accept(self)
            self.xml_output += ", "
            self.xml_output += str(ctx.get_anum())
            self.xml_output += ")"

    def visitNat(self, ctx: XMLProgrammer.Nat):
        self.xml_output += "nat"

    def visitBin(self, ctx: XMLProgrammer.QXBin):
        self.left().accept(self)
        if ctx.op() == "Plus":
            self.xml_output += " + "
        elif ctx.op() == "Minus":
            self.xml_output += " - "
        elif ctx.op() == "Times":
            self.xml_output += " * "
        elif ctx.op() == "Div":
            self.xml_output += " / "
        elif ctx.op() == "Exp":
            self.xml_output += " ^ "
        elif ctx.op() == "Mod":
            self.xml_output += " % "
        elif ctx.op() == "GNum":
            self.xml_output += " @ "
        self.right().accept(self)

    def visitNum(self, ctx: XMLProgrammer.QXNum):
        self.xml_output += str(ctx.num())

    # def visit(self, ctx):
    #    if ctx.getChildCount() > 0:
    #        self.visitChildren(ctx)
    #    else:
    #        self.visitTerminal(ctx)

    def getXML(self):
        return self.xml_output
