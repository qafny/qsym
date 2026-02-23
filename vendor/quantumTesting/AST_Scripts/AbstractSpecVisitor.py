from abc import ABC, abstractmethod

from antlr4 import ParseTreeVisitor



class AbstractSpecVisitor(ABC):


    @abstractmethod
    def visit(self, ctx):
        pass

    @abstractmethod
    def visitProgram(self, ctx):
        pass

    @abstractmethod
    def visitArrow(self, ctx):
        pass

    @abstractmethod
    def visitAlways(self, ctx):
        pass

    @abstractmethod
    def visitExists(self, ctx):
        pass

    @abstractmethod
    def visitType(self, ctx):
        pass

    @abstractmethod
    def visitABool(self, ctx):
        pass

    @abstractmethod
    def visitBool(self, ctx):
        pass

    @abstractmethod
    def visitNot(self, ctx):
        pass

    @abstractmethod
    def visitBin(self, ctx):
        pass

    @abstractmethod
    def visitIDExp(self, ctx):
        pass

    @abstractmethod
    def visitNum(self, ctx):
        pass

    @abstractmethod
    def visitQty(self, ctx):
        pass

    @abstractmethod
    def visitNat(self, ctx):
        pass

    @abstractmethod
    def visitNor(self, ctx):
        pass

    @abstractmethod
    def visitPhi(self, ctx):
        pass