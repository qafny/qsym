from types import NoneType

from Source.quantumCode.AST_Scripts import AbstractSpecVisitor


class SPTop:

    def accept(self, visitor):
        pass


class SPProgram(SPTop):

    def accept(self, visitor: AbstractSpecVisitor):
        pass

class SPArrow(SPProgram):

    def __init__(self, ex1: [SPExp], ex2 : [SPExp]):
        self.ex1 = ex1
        self.ex2 = ex2

    def accept(self, visitor: AbstractSpecVisitor):
        pass

    def left(self):
        return self.ex1

    def right(self):
        return self.ex2


class SPAlways(SPProgram):

    def __init__(self, v: SPVExp, p: SPProgram):
        self.v = v
        self.p = p

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitProgram(self)

    def vexp(self):
        return self.v

    def program(self):
        return self.p


class SPExists(SPProgram):

    def __init__(self, s: str, t: SPType, p: SPProgram, b: SPBExp=None):
        self.id = s
        self.type = t
        self.prog = p
        self.bexp = b

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitProgram(self)

    def ID(self):
        return self.id

    def type(self):
        return self.type

    def program(self):
        return self.prog

    def bexp(self):
        return self.bexp


class SPType(SPTop):

    def accept(self, visitor: AbstractSpecVisitor):
        pass

class SPBExp(SPTop):

    def accept(self, visitor: AbstractSpecVisitor):
        pass

class SPABool(SPBExp):

    def accept(self, visitor: AbstractSpecVisitor):
        pass

    def __init__(self, op: str, v1: SPVExp, v2: SPVExp):
        self.op = op
        self.v1 = v1
        self.v2 = v2

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitABool(self)

    def OP(self):
        return self.op

    def left(self):
        return self.v1

    def right(self):
        return self.v2

class SPBool(SPBExp):

    def accept(self, visitor: AbstractSpecVisitor):
        pass

    def __init__(self, op: str, v1: SPBExp, v2: SPBExp):
        self.op = op
        self.v1 = v1
        self.v2 = v2

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitBool(self)

    def OP(self):
        return self.op

    def left(self):
        return self.v1

    def right(self):
        return self.v2


class SPNot(SPBExp):

    def accept(self, visitor: AbstractSpecVisitor):
        pass

    def __init__(self, v1: SPBExp):
        self.v1 = v1

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitNot(self)

    def next(self):
        return self.v1


class SPVExp(SPTop):

    def accept(self, visitor: AbstractSpecVisitor):
        pass


class SPIDExp(SPVExp):
    def __init__(self, id: str):
        self.id = id

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitIDExp(self)

    def ID(self):
        return self.id if self.id is str else self.id.getText()


class SPBin(SPVExp):
    def __init__(self, op: str, v1: SPVexp, v2: SPVexp):
        self.op = op
        self.v1 = v1
        self.v2 = v2

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitBin(self)

    def OP(self):
        return self.op

    def left(self):
        return self.v1

    def right(self):
        return self.v2


class SPNum(SPVExp):
    def __init__(self, v: int):
        self.v = v

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitNum(self)

    def num(self):
        return self.v

class Qty(SPType):

    def __init__(self, qubit_array_size: SPVExp):
        self.qubit_array_size = qubit_array_size

    def __str__(self):
        return f"Qty(qubit_array_size={self.qubit_array_size})"

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitQty(self)


class Nat(SPType):
    type = "Nat"

    def type(self):
        return "Nat"

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitNat(self)

class SPQExp(SPTop):

    def accept(self, visitor: AbstractSpecVisitor):
        pass

class SPNor(SPQExp):
    def __init__(self, id: str, b: SPVExp, l:SPVExp):
        self.id = id
        self.b = b
        self.l = l

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitSKIP(self)

    def ID(self):
        return self.id if isinstance(self.id, str) else self.id.getText()

    def vexp(self):
        return self.b

    def length(self):
        return self.l

class SPPhi(SPQExp):
    def __init__(self, id: str, b: SPVExp, l:SPVExp):
        self.id = id
        self.b = b
        self.l = l

    def accept(self, visitor: AbstractSpecVisitor):
        visitor.visitSKIP(self)

    def ID(self):
        return self.id if isinstance(self.id, str) else self.id.getText()

    def vexp(self):
        return self.b

    def length(self):
        return self.l