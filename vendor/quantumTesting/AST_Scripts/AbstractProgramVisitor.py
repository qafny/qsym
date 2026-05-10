from abc import ABC, abstractmethod

from antlr4 import ParseTreeVisitor



class AbstractProgramVisitor(ABC):


    @abstractmethod
    def visit(self, ctx):
        pass

    @abstractmethod
    def visitNext(self, ctx):
        pass

    @abstractmethod
    def visitProgram(self, ctx):
        pass

    @abstractmethod
    def visitLet(self, ctx):
        pass

    @abstractmethod
    def visitApp(self, ctx):
        pass

    @abstractmethod
    def visitCU(self, ctx):
        pass

    @abstractmethod
    def visitIf(self, ctx):
        pass

    @abstractmethod
    def visitMatch(self, ctx):
        pass

    @abstractmethod
    def visitPair(self, ctx):
        pass

    @abstractmethod
    def visitBin(self, ctx):
        pass

    @abstractmethod
    def visitIDExp(self, ctx):
        pass

    @abstractmethod
    def visitQID(self, ctx):
        pass

    @abstractmethod
    def visitNum(self, ctx):
        pass

    @abstractmethod
    def visitQTy(self, ctx):
        pass

    @abstractmethod
    def visitNat(self, ctx):
        pass

    @abstractmethod
    def visitFun(self, ctx):
        pass

    @abstractmethod
    def visitSKIP(self, ctx):
        pass

    @abstractmethod
    def visitX(self, ctx):
        pass

    @abstractmethod
    def visitSR(self, ctx):
        pass

    @abstractmethod
    def visitQFT(self, ctx):
        pass

    @abstractmethod
    def visitRQFT(self, ctx):
        pass

    @abstractmethod
    def visitLshift(self, ctx):
        pass

    @abstractmethod
    def visitRshift(self, ctx):
        pass

    @abstractmethod
    def visitRev(self, ctx):
        pass
