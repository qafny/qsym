# type checker
import copy
from enum import Enum
from collections import ChainMap
from types import NoneType

from antlr4 import ParserRuleContext

from .XMLExpLexer import *
from .XMLExpVisitor import *
from .XMLTypeSearch import *
from .XMLProgrammer import *
from .XMLExpParser import *

class ProgramTransformer(XMLExpVisitor):

    def visitRoot(self, ctx: XMLExpParser.RootContext):
        program = self.visitProgram(ctx.program())
        return QXRoot(program)

    def visitProgram(self, ctx: XMLExpParser.ProgramContext):
        i = 0
        tmp = []
        while ctx.exp(i) is not None:
            v = self.visitExp(ctx.exp(i))
            tmp.append(v)
            i += 1
        return QXProgram(tmp)

    def visitNextexp(self, ctx: XMLExpParser.NextexpContext):
        v = self.visitProgram(ctx.program())
        return QXNext(v)

    def visitExp(self, ctx: XMLExpParser.ExpContext):
        if ctx.letexp() is not None:
            return self.visitLetexp(ctx.letexp())
        elif ctx.appexp() is not None:
            return self.visitAppexp(ctx.appexp())
        elif ctx.ifexp() is not None:
            return self.visitIfexp(ctx.ifexp())
        elif ctx.matchexp() is not None:
            return self.visitMatchexp(ctx.matchexp())
        elif ctx.cuexp() is not None:
            return self.visitCUexp(ctx.cuexp())
        elif ctx.skipexp() is not None:
            return self.visitSkipexp(ctx.skipexp())
        elif ctx.xexp() is not None:
            return self.visitXexp(ctx.xexp())
        elif ctx.srexp() is not None:
            return self.visitSrexp(ctx.srexp())
        elif ctx.qftexp() is not None:
            return self.visitQftexp(ctx.qftexp())
        elif ctx.lshiftexp() is not None:
            return self.visitLshiftexp(ctx.lshiftexp())
        elif ctx.rshiftexp() is not None:
            return self.visitRshiftexp(ctx.rshiftexp())
        elif ctx.revexp() is not None:
            return self.visitRevexp(ctx.revexp())
        elif ctx.rqftexp() is not None:
            return self.visitRqftexp(ctx.rqftexp())

    def visitElement(self, ctx: XMLExpParser.ElementContext):
        if ctx.numexp() is not None:
            v = self.visitNumexp(ctx.numexp())
            return QXNum(v)
        else:
            return QXIDExp(ctx.Identifier(), None)

    def visitAtype(self, ctx: XMLExpParser.AtypeContext):
        if ctx.Nat() is not None:
            return Nat()
        elif ctx.Qt() is not None:
            v = self.visitElement(ctx.element(0))
            return Qty(v)
        elif ctx.Nor() is not None:
            v = self.visitElement(ctx.element(0))
            return Qty(v, "Nor")
        elif ctx.Phi() is not None:
            v = self.visitElement(ctx.element(0))
            v1 = v = self.visitElement(ctx.element(1))
            return Qty(v, "Phi", v1)
        return Nat()

    def visitLetexp(self, ctx: XMLExpParser.LetexpContext):
        i = 0
        f = ctx.Identifier()
        tml = []
        while ctx.idexp(i) is not None:
            x = self.visitIdexp(ctx.idexp(i))
            tml.append(x)
            i += 1
        fv = self.visitProgram(ctx.program())
        return QXLet(f, tml, fv)

    def visitIfexp(self, ctx: XMLExpParser.IfexpContext):
        f = self.visitVexp(ctx.vexp())
        ab = self.visitNextexp(ctx.nextexp(0))
        cd = self.visitNextexp(ctx.nextexp(1))
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXIf(f,ab,cd, tmpb)

    def visitAppexp(self, ctx: XMLExpParser.AppexpContext):
        vx = ctx.Identifier()
        i = 0
        tmp = []
        while ctx.vexp(i) is not None:
            v = self.visitVexp(ctx.vexp(i))
            tmp.append(v)
            i = i + 1
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXApp(vx,tmp, tmpb)

    def visitMatchexp(self, ctx: XMLExpParser.MatchexpContext):
        x = ctx.Identifier()
        left = self.visitExppair(ctx.exppair(0))
        right = self.visitExppair(ctx.exppair(1))
        return QXMatch(x,left, right)

    def visitExppair(self, ctx:XMLExpParser.ExppairContext):
        elem = self.visitElement(ctx.element())
        prog = self.visitProgram(ctx.program())
        return QXPair(elem, prog)

    # should do nothing
    def visitSkipexp(self, ctx: XMLExpParser.SkipexpContext):
        x = ctx.Identifier()
        v = self.visitVexp(ctx.vexp())
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXSKIP(x, v, tmpb)

    # X posi, changed the following for an example
    def visitXexp(self, ctx: XMLExpParser.XexpContext):
        x = ctx.Identifier()
        v = self.visitVexp(ctx.vexp())
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXX(x, v, tmpb)

    # we will first get the position in st and check if the state is 0 or 1,
    # then decide if we go to recucively call ctx.exp
    def visitCUexp(self, ctx: XMLExpParser.CuexpContext):
        x = ctx.Identifier()
        v = self.visitVexp(ctx.vexp())
        p = self.visitProgram(ctx.program())
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXCU(x, v, p, tmpb)

    # SR n x, now variables are all string, are this OK?
    def visitSrexp(self, ctx: XMLExpParser.SrexpContext):
        x = ctx.Identifier()
        v = self.visitVexp(ctx.vexp())
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXSR(x, v, tmpb)

    def visitLshiftexp(self, ctx: XMLExpParser.LshiftexpContext):
        x = ctx.Identifier()
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXLshift(x, tmpb)

    def visitRshiftexp(self, ctx: XMLExpParser.RshiftexpContext):
        x = ctx.Identifier()
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXRshift(x, tmpb)

    def visitRevexp(self, ctx: XMLExpParser.RevexpContext):
        x = ctx.Identifier()
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXRev(x, tmpb)

    # actually, we need to change the QFT function
    # the following QFT is only for full QFT, we did not have the case for AQFT
    def visitQftexp(self, ctx: XMLExpParser.QftexpContext):
        x = ctx.Identifier()
        v = self.visitVexp(ctx.vexp())
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXQFT(x,v, tmpb)


    def visitRqftexp(self, ctx: XMLExpParser.RqftexpContext):
        x = ctx.Identifier()
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        return QXRQFT(x, tmpb)

    def visit(self, ctx: ParserRuleContext):
        if isinstance(ctx, XMLExpParser.RootContext):
            return self.visitRoot(ctx)
        elif isinstance(ctx, XMLExpParser.ProgramContext):
            return self.visitProgram(ctx)
        elif isinstance(ctx, XMLExpParser.ExpContext):
            return self.visitExp(ctx)
        elif isinstance(ctx, XMLExpParser.ExppairContext):
            return self.visitExppair(ctx)
        elif isinstance(ctx, XMLExpParser.ElementContext):
            return self.visitElement(ctx)
        elif isinstance(ctx, XMLExpParser.AtypeContext):
            return self.visitAtype(ctx)
        elif isinstance(ctx, XMLExpParser.VexpContext):
            return self.visitVexp(ctx)
        elif isinstance(ctx, XMLExpParser.OpContext):
            return self.visitOp(ctx)
        else:
            return super().visit(ctx)

    def visitIdexp(self, ctx: XMLExpParser.IdexpContext):
        if ctx.Identifier(1) is not None:
            x = ctx.Identifier(1)
            rec = ctx.Identifier(0)
        else:
            x = ctx.Identifier(0)
            rec = None
        tmpb = None
        if ctx.BLOCK() is not None:
            tmpb = "block"
        t = None
        if ctx.atype() is not None:
            t = self.visitAtype(ctx.atype())
        if ctx.VEXP(0) is not None:
            return QXIDExp(x, t, tmpb, rec)
        else:
            return QXQID(x, t, tmpb)

    # Visit a parse tree produced by XMLExpParser#vexp.
    def visitVexp(self, ctx: XMLExpParser.VexpContext):
        if ctx.idexp() is not None:
            return self.visitIdexp(ctx.idexp())
        if ctx.NUM() is not None:
            v = self.visitNumexp(ctx.numexp())
            if ctx.Identifier() is not None:
                rec = ctx.Identifier()
            else:
                rec = None
            tmpb = None
            if ctx.BLOCK() is not None:
                tmpb = "block"
            return QXNum(v, tmpb, rec)
        else:
            tmpb = None
            if ctx.BLOCK() is not None:
                tmpb = "block"
            x = self.visitOp(ctx.op())
            v1 = self.visitVexp(ctx.vexp(0))
            v2 = self.visitVexp(ctx.vexp(1))
            rec = ctx.Identifier()
            return QXBin(x, v1, v2, tmpb, rec)
    # the only thing that matters will be 48 and 47

    def visitOp(self, ctx:XMLExpParser.OpContext):
        if ctx.Plus() is not None:
            return "+"
        elif ctx.Minus() is not None:
            return "-"
        elif ctx.Times() is not None:
            return "*"
        elif ctx.Div() is not None:
            return "/"
        elif ctx.Exp() is not None:
            return "^"
        elif ctx.GNum() is not None:
            return "$"
        elif ctx.Mod() is not None:
            return "%"

    def visitAtype(self, ctx:XMLExpParser.AtypeContext):
        if ctx.Nat() is not None:
            return Nat()
        if ctx.Qt() is not None:
            v = self.visitElement(ctx.element(0))
            return Qty(v)
        if ctx.Nor() is not None:
            v = self.visitElement(ctx.element(0))
            return Qty(v, "Nor")
        if ctx.Phi() is not None:
            v = self.visitElement(ctx.element(0))
            v1 = self.visitElement(ctx.element(1))
            return Qty(v, "Phi", v1)

    def visitNumexp(self, ctx:XMLExpParser.NumexpContext):
        return int(ctx.getText())