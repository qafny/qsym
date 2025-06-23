import Programmer
from ProgramVisitor import ProgramVisitor
from Programmer import *
from TypeChecker import *


class SubstAExp(ProgramVisitor):

    def __init__(self, id: str, e : QXAExp):
        # need st --> state we are deling with
        # kind map from fun vars to kind maps
        #self.kenv = kenv
        # the checked type env at index
        self.id = id
        self.exp = e


    def visitQSpec(self, ctx: Programmer.QXQSpec):
        loc = []
        for elem in ctx.locus():
            loc += [elem.accept(self)]
        v = ctx.state().accept(self)
        return QXQSpec(loc, ctx.qty(), v)


    def visitHad(self, ctx: Programmer.QXHad):
        return ctx


    def visitSKet(self, ctx: Programmer.QXSKet):
        return QXSKet(ctx.vector().accept(self))


    def visitVKet(self, ctx: Programmer.QXVKet):
        return QXVKet(ctx.vector().accept(self))


    def visitQRange(self, ctx: Programmer.QXQRange):
        v = ctx.crange().accept(self)
        return QXQRange(ctx.ID(), v)


    def visitCRange(self, ctx: Programmer.QXCRange):
        l = ctx.left().accept(self)
        r = ctx.right().accept(self)
        return QXCRange(l, r)


    def visitTensor(self, ctx: Programmer.QXTensor):
        ks = []
        for elem in ctx.kets():
            ks += [elem.accept(self)]
        ran = None
        if ctx.range() is not None:
            ran = ctx.range().accept(self)
        amp = None
        if ctx.amp() is not None:
            amp = ctx.amp().accept(self)
        return QXTensor(ks, ctx.ID(), ran, amp)


    def visitSum(self, ctx: Programmer.QXSum):
        sums = []
        for elem in ctx.sums():
            sums += [elem.accept(self)]

        ks = []
        for kelem in ctx.kets():
            ks += [kelem.accept(self)]

        return QXSum(sums, ctx.amp().accept(self), ks)


    def visitPart(self, ctx: Programmer.QXPart):
        qnum = ctx.qnum().accept(self)
        fname = ctx.fname().accept(self)
        tamp = ctx.trueAmp().accept(self)
        famp = ctx.falseAmp().accept(self)
        return QXPart(qnum, fname, tamp, famp)


    def visitCon(self, ctx: Programmer.QXCon):
        v = ctx.range().accept(self)
        return QXCon(ctx.ID(), v)


    def visitBind(self, ctx: Programmer.QXBind):
        if ctx.ID() == self.id:
            return self.exp
        return ctx


    def visitNum(self, ctx: Programmer.QXNum):
        return ctx


    def visitBin(self, ctx: Programmer.QXBin):
        return QXBin(ctx.op(), ctx.left().accept(self), ctx.right().accept(self))


    def visitUni(self, ctx: Programmer.QXUni):
        return QXUni(ctx.op(), ctx.next().accept(self))


    def visitQIndex(self, ctx: Programmer.QXQIndex):
        return QXQIndex(ctx.ID(), ctx.index().accept(self))
