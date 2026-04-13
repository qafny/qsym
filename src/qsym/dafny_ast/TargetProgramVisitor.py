#import TargetProgrammer
#import AbstractTargetVisitor
from .TargetProgrammer import *
from .AbstractTargetVisitor import *

#from .AbstractProgramVisitor import AbstractProgramVisitor


class TargetProgramVisitor(AbstractTargetVisitor):

    def visit(self, ctx):
        match ctx:
            case DXMethod():
                return self.visitMethod(ctx)
            case DXProgram():
                return self.visitProgram(ctx)
            case DXAssert():
                return self.visitAssert(ctx)
            case DXInit():
                return self.visitInit(ctx)
            case DXBind():
                return self.visitBind(ctx)
            case DXAssign():
                return self.visitAssign(ctx)
            case DXIf():
                return self.visitIf(ctx)
            case DXWhile():
                return self.visitWhile(ctx)
            case DXCall():
                return self.visitCall(ctx)
            case SType():
                return self.visitSType(ctx)
            case SeqType():
                return self.visitSeqType(ctx)
            case FunType():
                return self.visitFunType(ctx)
            case DXNot():
                return self.visitNot(ctx)
            case DXComp():
                return self.visitComp(ctx)
            case DXLogic():
                return self.visitLogic(ctx)
            case DXIndex():
                return self.visitIndex(ctx)
            case DXAll():
                return self.visitAll(ctx)
            case DXIfExp():
                return self.visitIfExp(ctx)
            case DXBin():
                return self.visitBin(ctx)
            case DXUni():
                return self.visitUni(ctx)
            case DXNum():
                return self.visitNum(ctx)
            case DXReal():
                return self.visitReal(ctx)
            case DXCast():
                return self.visitCast(ctx)
            case DXInRange():
                return self.visitInRange(ctx)
            case DXAssert():
                return self.visitAssert(ctx)
            case DXRequires():
                return self.visitRequires(ctx)
            case DXEnsures():
                return self.visitEnsures(ctx)
            case DXSeqComp():
                return self.visitSeqComp(ctx)
            case DXWitness():
                return self.visitWitness(ctx)
            case _:
                raise NotImplementedError(f"No visit method defined for {type(ctx)}")

    def visitMethod(self, ctx: DXMethod):
        for bindelem in ctx.bindings():
            bindelem.accept(self)

        for reelem in ctx.returns():
            reelem.accept(self)

        for condelem in ctx.conds():
            condelem.accept(self)

        for stmtelem in ctx.stmts():
            stmtelem.accept(self)

    def visitProgram(self, ctx: DXProgram):
        for elem in ctx.method():
            elem.accept(self)

    def visitAssert(self, ctx: DXAssert):
        return ctx.spec().accept(self)

    def visitRequires(self, ctx: DXRequires):
        return ctx.spec().accept(self)

    def visitEnsures(self, ctx: DXEnsures):
        return ctx.spec().accept(self)

    def visitInit(self, ctx: DXInit):
        return ctx.binding().accept(self)

    def visitInRange(self, ctx: DXInRange):
        ctx.bind().accept(self)
        ctx.left().accept(self)
        ctx.right().accept(self)

    def visitBind(self, ctx: DXBind):
        if ctx.type() is not None:
            ctx.type().accept(self)
        return ctx.ID()

    def visitAssign(self, ctx: DXAssign):
        return ctx.exp().accept(self)

    def visitIf(self, ctx: DXIf):
        ctx.cond().accept(self)
        ctx.left().accept(self)
        ctx.right().accept(self)

    def visitWhile(self, ctx: DXWhile):
        ctx.cond().accept(self)
        for elem in ctx.stmts():
            elem.accept(self)

    def visitCall(self, ctx: DXCall):
        for elem in ctx.exps():
            elem.accept(self)
        return ctx.ID()

    def visitSType(self, ctx: SType):
        return ctx.type()

    def visitSeqType(self, ctx: SeqType):
        return ctx.type().accept(self)

    def visitFunType(self, ctx: FunType):
        ctx.left().accept(self)
        ctx.right().accept(self)

    def visitNot(self, ctx: DXNot):
        return ctx.next().accept(self)

    def visitComp(self, ctx: DXComp):
#        print('\nvisitComp', ctx)
        ctx.left().accept(self)
        ctx.right().accept(self)

    def visitLogic(self, ctx: DXLogic):
        ctx.left().accept(self)
        ctx.right().accept(self)

    def visitIndex(self, ctx: DXIndex):
        ctx.bind().accept(self)
        ctx.index().accept(self)

    def visitAll(self, ctx: DXAll):
        ctx.bind().accept(self)
        ctx.next().accept(self)

    def visitBin(self, ctx: DXBin):
        ctx.left().accept(self)
        ctx.right().accept(self)
        return ctx.op()

    def visitIfExp(self, ctx: DXIfExp):
        ctx.bexp().accept(self)
        ctx.left().accept(self)
        ctx.right().accept(self)
        return True

    def visitUni(self, ctx: DXUni):
        ctx.next().accept(self)
        return ctx.op()

    def visitNum(self, ctx: DXNum):
        return ctx.val()

    def visitReal(self, ctx: DXReal):
        return ctx.real()

    def visitCast(self, ctx: DXCast):
        ctx.type().accept(self)
        ctx.next().accept(self)
    
    def visitLength(self, ctx: DXLength):
        ctx.var().accept(self)

    def visitSeqComp(self, ctx: DXSeqComp):
#        print('\n okay, lets see TPV', ctx)
        ctx.size().accept(self)
        ctx.idx().accept(self)
        ctx.spec().accept(self) if ctx.spec() is not None else None
        ctx.lambd().accept(self)

    def visitWitness(self, ctx: DXWitness):
        ctx.bind().accept(self)
        ctx.constrs().accept(self)
        return ctx

