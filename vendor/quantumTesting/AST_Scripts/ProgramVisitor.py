from AST_Scripts import XMLProgrammer

from AST_Scripts.AbstractProgramVisitor import AbstractProgramVisitor


class ProgramVisitor(AbstractProgramVisitor):

    def visit(self, ctx):
        match ctx:
            case QXRoot():
                return self.visitRoot(ctx)
            case QXNext():
                return self.visitNext(ctx)
            case QXProgram():
                return self.visitProgram(ctx)
            case QXLet():
                return self.visitLet(ctx)
            case QXApp():
                return self.visitApp(ctx)
            case QXCU():
                return self.visitCU(ctx)
            case QXIf():
                return self.visitIf(ctx)
            case QXMatch():
                return self.visitMatch(ctx)
            case QXPair():
                return self.visitPair(ctx)
            case QXBin():
                return self.visitBin(ctx)
            case QXIDExp():
                return self.visitIDExp(ctx)
            case QXNum():
                return self.visitNum(ctx)
            case Qty():
                return self.visitQTy(ctx)
            case Nat():
                return self.visitNat(ctx)
            case Fun():
                return self.visitFun(ctx)
            case QXSKIP():
                return self.visitSKIP(ctx)
            case QXX():
                return self.visitX(ctx)
            case QXH():
                return self.visitH(ctx)
            case QXRY():
                return self.visitRY(ctx)
            case QXRZ():
                return self.visitRZ(ctx)
            case QXRY():
                return self.visitRY(ctx)
            case QXSR():
                return self.visitSR(ctx)
            case QXQFT():
                return self.visitQFT(ctx)
            case QXRQFT():
                return self.visitRQFT(ctx)
            case QXLshift():
                return self.visitLshift(ctx)
            case QXRshift():
                return self.visitRshift(ctx)
            case QXRev():
                return self.visitRev(ctx)
            case _:
                raise NotImplementedError(f"No visit method defined for {type(ctx)}")

    # Visit a parse tree produced by XMLExpParser#root.
    def visitRoot(self, ctx: XMLProgrammer.QXRoot):
        # print(ctx)
        return ctx.program().accept(self)

    # Visit a parse tree produced by XMLExpParser#nextexp.
    def visitNext(self, ctx: XMLProgrammer.QXNext):
        return ctx.program().accept(self)

    # Visit a parse tree produced by XMLExpParser#program.
    def visitProgram(self, ctx: XMLProgrammer.QXProgram):
        i = 0
        while ctx.exp(i) is not None:
            ctx.exp(i).accept(self)
            i = i + 1

    # Visit a parse tree produced by XMLExpParser#exp.

    def visitLet(self, ctx: XMLProgrammer.QXLet):
        return ctx.program().accept(self)

    def visitApp(self, ctx: XMLProgrammer.QXApp):
        i = 0
        while ctx.vexp(i) is not None:
            ctx.vexp(i).accept(self)

    def visitCU(self, ctx: XMLProgrammer.QXCU):
        return ctx.program().accept(self)

    def visitIf(self, ctx: XMLProgrammer.QXIf):
        ctx.vexp().accept(self)
        ctx.left().accept(self)
        ctx.right().accept(self)

    def visitMatch(self, ctx: XMLProgrammer.QXMatch):
        ctx.zero().accept(self)
        ctx.multi().accept(self)

    def visitPair(self, ctx: XMLProgrammer.QXPair):
        ctx.elem().accept(self)
        ctx.program().accept(self)

    def visitBin(self, ctx: XMLProgrammer.QXBin):
        ctx.left().accept(self)
        ctx.right().accept(self)

    def visitIDExp(self, ctx: XMLProgrammer.QXIDExp):
        ctx.type().accept(self)

    def visitQID(self, ctx: XMLProgrammer.QXQID):
        ctx.type().accept(self)


    def visitQTy(self, ctx: XMLProgrammer.Qty):
        ctx.get_num().accept(self)

    def visitNat(self, ctx: XMLProgrammer.Nat):
        pass

    def visitFun(self, ctx: XMLProgrammer.Fun):
        pass

    def visitSKIP(self, ctx: XMLProgrammer.QXSKIP):
        ctx.vexp().accept(self)

    def visitX(self, ctx: XMLProgrammer.QXX):
        ctx.vexp().accept(self)

    def visitH(self, ctx: XMLProgrammer.QXH):
        ctx.vexp().accept(self)

    def visitRZ(self, ctx: XMLProgrammer.QXRZ):
        ctx.vexp().accept(self)
        ctx.num().accept(self)

    def visitRY(self, ctx: XMLProgrammer.QXRY):
        ctx.vexp().accept(self)
        ctx.num().accept(self)

    def visitSR(self, ctx: XMLProgrammer.QXSR):
        ctx.vexp().accept(self)

    def visitQFT(self, ctx: XMLProgrammer.QXQFT):
        ctx.vexp().accept(self)

    def visitRQFT(self, ctx: XMLProgrammer.QXRQFT):
        pass

    def visitLshift(self, ctx: XMLProgrammer.QXLshift):
        pass

    def visitRshift(self, ctx: XMLProgrammer.QXRshift):
        pass

    def visitRev(self, ctx: XMLProgrammer.QXRev):
        pass

    def visitNum(self, ctx: XMLProgrammer.QXNum):
        pass
        # return ctx.num()
