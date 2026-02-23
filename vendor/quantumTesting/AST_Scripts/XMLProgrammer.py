from types import NoneType

from AST_Scripts.AbstractProgramVisitor import AbstractProgramVisitor

class QXTop:

    def accept(self, visitor):
        pass

class QXExp(QXTop):

    def accept(self, visitor : AbstractProgramVisitor):
        pass

class QXProgram(QXTop):
    def __init__(self, exps: [QXExp]):
        self._exps = exps

    def accept(self, visitor : AbstractProgramVisitor):
        return visitor.visitProgram(self)

    def exp(self, i:int=None):
        return self._exps[i] if len(self._exps) > i else None

    def __str__(self):
        s = "["
        for e in self._exps:
            s += str(e) + ", "
        s = s[:-2]
        s += "]"
        return s


class QXType(QXTop):

    def accept(self, visitor : AbstractProgramVisitor):
        pass

class QXRoot(QXTop):
    def __init__(self, _prog: QXProgram):
        self._prog = _prog

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitRoot(self)

    def program(self):
        return self._prog



class QXNext(QXTop):
    def __init__(self, _prog: QXProgram):
        self._prog = _prog

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitNext(self)

    def program(self):
        return self._prog

class QXVexp(QXTop):

    def accept(self, visitor : AbstractProgramVisitor):
        pass

class QXElem(QXTop):

    def accept(self, visitor : AbstractProgramVisitor):
        pass

class QXIDExp(QXElem, QXVexp):
    def __init__(self, id: str, ty: QXType = None, block:str = None, rec: str = None):
        self._id = id
        self._type = ty
        self._block = block
        self._rec = rec

    def accept(self, visitor : AbstractProgramVisitor):
        return visitor.visitIDExp(self)

    def ID(self):
        return self._id if self._id is str else self._id.getText()

    def type(self):
        return self._type

    def block(self):
        return self._block

    def rec(self):
        return self._rec

class QXQID(QXElem, QXVexp):
    def __init__(self, id: str, ty: QXType = None, block:str = None, rpf_for: str = None):
        self._id = id
        self._type = ty
        self._block = block
        self._rpf_for = rpf_for

    def accept(self, visitor : AbstractProgramVisitor):
        return visitor.visitIDExp(self)

    def ID(self):
        return self._id if self._id is str else str(self._id)

    def type(self):
        return self._type

    def block(self):
        return self._block

    def rpf_for(self):
        return self._rpf_for

    def __str__(self):
        return f"QXQID(id={self._id})"


class QXLet(QXExp):
    def __init__(self, id: str, ids: [QXIDExp], p: QXProgram):
        self._id = id
        self._ids = ids
        self._prog = p

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitLet(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def idexp(self, i:int = None):
        return self._ids[i] if i < len(self._ids) else None

    def program(self):
        return self._prog
    

class QXApp(QXExp):
    def __init__(self, id: str, vs: [QXVexp], block:str = None):
        self._id = id
        self._vs = vs
        self._block = block

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitApp(self)

    def ID(self) -> str:
        return self._id if isinstance(self._id, str) else self._id.getText()

    def vexp(self, i : int = None):
        return self._vs[i] if len(self._vs) > i else None

    def block(self):
        return self._block


class QXCU(QXExp):
    def __init__(self, id: str, v: QXVexp, p: QXProgram, block:str = None):
        self._id = id
        self._v = v
        self._prog = p
        self._block = block

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitCU(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def vexp(self):
        return self._v

    def program(self):
        return self._prog

    def block(self):
        return self._block

    def __str__(self):
        return f"QXCU(id={self._id}, control={self._v}, prog={self._prog})"


class QXIf(QXExp):
    def __init__(self, v: QXVexp, lefta, righta, block:str = None):
        self._v = v
        self._lefta = lefta
        self._righta = righta
        self._block = block

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitIf(self)

    def vexp(self):
        return self._v

    def left(self):
        return self._lefta

    def right(self):
        return self._righta

    def block(self):
        return self._block

class QXPair(QXTop):
    def __init__(self, elem: QXElem, p: QXProgram):
        self._elem = elem
        self._program = p

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitPair(self)

    def elem(self):
        return self._elem

    def program(self):
        return self._program

class QXMatch(QXExp):
    def __init__(self, id: str, zero: QXPair, multi: QXPair):
        self._id = id
        self._zero = zero
        self._multi = multi

    def accept(self, visitor : AbstractProgramVisitor):
        return visitor.visitMatch(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def zero(self):
        return self._zero

    def multi(self):
        return self._multi


class QXBin(QXVexp):
    def __init__(self, op: str, v1: QXVexp, v2: QXVexp, block:str = None, rec: str = None):
        self._op = op
        self._v1 = v1
        self._v2 = v2
        self._block = block
        self._rec = rec

    def accept(self, visitor : AbstractProgramVisitor):
        return visitor.visitBin(self)

    def OP(self):
        return self._op

    def left(self):
        return self._v1

    def right(self):
        return self._v2

    def block(self):
        return self._block

    def rec(self):
        return self._rec


class QXNum(QXElem, QXVexp):
    def __init__(self, v: int, block:str = None, rec: str = None):
        self._v = v
        self._block = block
        self._rec = rec

    def accept(self, visitor : AbstractProgramVisitor):
        return visitor.visitNum(self)

    def num(self):
        return self._v

    def block(self):
        return self._block

    def rec(self):
        return self._rec
    
    def __str__(self):
        return f"QXNum({self._v})"



def joinType(a: QXType, b: QXType):
    if isinstance(a, Qty) and isinstance(b, Qty):
        if a.type() is None or b.type() is None:
            if a.type() is None:
                a.set_type(b.type())
            else:
                b.set_type(a.type())
            return a
        elif a.type() == b.type():
            return a
        else:
            return None
    elif isinstance(a, Nat) and isinstance(b, Nat):
        return a
    elif isinstance(a, Fun) and isinstance(b, Fun):
        return a
    else:
        return None


def joinTypes(a: dict, b: dict):
    for key in a.keys():
        if b.get(key) is not None:
            if isinstance(a.get(key), Qty) and isinstance(b.get(key), Qty):
                if a.get(key).type() is None and b.get(key).type() is not None:
                    a.get(key).set_type(b.get(key).type())
    return a


def equalTypes(a: dict, b: type):
    tmp = True
    for key in a.keys():
        if a.get(key) != b:
            tmp = False
    return tmp



class Qty(QXType):

    def __init__(self, qubit_array_size: QXIDExp, type: str = None, m=None):
        self._qubit_array_size = qubit_array_size
        self._type = type
        if m is None:
            self._m = "0"
        else:
            self._m = m

    def get_num(self):
        return self._qubit_array_size

    def get_anum(self):
        return self._m

    def set_type(self, ty: str):
        self._type = ty

    def type(self):
        return self._type

    def fullty(self):
        return (self._type, self._qubit_array_size, self._m)

    def __str__(self):
        return f"Qty(type={self._type}, qubit_array_size={self._qubit_array_size}, m={self._m})"

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitQty(self)

class Nat(QXType):

    type = "Nat"

    def type(self):
        return "Nat"

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitNat(self)

class Fun(QXType):

    def __init__(self, args: [str], pre: dict, out: dict):
        self._args = args
        self._pre = pre
        self._out = out
        # self.r2 = r2

    def type(self):
        return ("Fun", (self._args, self._pre, self._out))

    def args(self):
        return self._args

    def pre(self):
        return self._pre

    def out(self):
        return self._out

    def __str__(self):
        return f"Fun(args={self._args}, pre={self._pre}, out={self._out})"

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitFun(self)


class QXSKIP(QXExp):
    def __init__(self, id: str, v: QXVexp, block:str = None):
        self._id = id
        self._v = v
        self._block = block

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitSKIP(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def vexp(self):
        return self._v

    def block(self):
        return self._block

class QXX(QXExp):
    def __init__(self, id: str, v: QXVexp, block:str = None):
        self._id = id
        self._v = v
        self._block = block

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitX(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def vexp(self):
        return self._v

    def block(self):
        return self._block

    def __str__(self):
        return f"QXX(id={self._id}, v={self._v})"

class QXH(QXExp):
    def __init__(self, id: str, v: QXVexp, block:str = None):
        self._id = id
        self._v = v
        self._block = block

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitH(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def vexp(self):
        return self._v

    def block(self):
        return self._block

    def __str__(self):
        return f"QXH(id={self._id}, v={self._v})"

class QXRZ(QXExp):
    def __init__(self, id: str, v: QXVexp, v1:QXVexp, block:str = None):
        self._id = id
        self._v = v
        self._num = v1
        self._block = block

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitRZ(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def vexp(self):
        return self._v

    def num(self):
        return self._num

    def block(self):
        return self._block

    def __str__(self):
        return f"QXRZ(id={self._id}, v={self._v}, angle={self._num})"


class QXRY(QXExp):
    def __init__(self, id: str, v: QXVexp, v1:QXVexp, block:str = None):
        self._id = id
        self._v = v
        self._num = v1
        self._block = block

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitRY(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def vexp(self):
        return self._v

    def num(self):
        return self._num

    def block(self):
        return self._block

    def __str__(self):
        return f"QXRY(id={self._id}, v={self._v}, angle={self._num})"

class QXSR(QXExp):
    def __init__(self, id: str, v: QXVexp, block:str = None):
        self._id = id
        self._v = v
        self._block = block


    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitSR(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def vexp(self):
        return self._v

    def block(self):
        return self._block

class QXQFT(QXExp):
    def __init__(self, id: str, v: QXVexp, block:str = None):
        self._id = id
        self._v = v
        self._block = block


    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitQFT(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def vexp(self):
        return self._v

    def block(self):
        return self._block


class QXRQFT(QXExp):
    def __init__(self, id: str, block:str = None):
        self._id = id
        self._block = block

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitRQFT(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def block(self):
        return self._block


class QXLshift(QXExp):
    def __init__(self, id: str, block:str = None):
        self._id = id
        self._block = block


    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitLshift(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def block(self):
        return self._block

class QXRshift(QXExp):
    def __init__(self, id: str, block:str = None):
        self._id = id
        self._block = block


    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitRshift(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def block(self):
        return self._block

class QXRev(QXExp):
    def __init__(self, id: str, block:str = None):
        self._id = id
        self._block = block

    def accept(self, visitor : AbstractProgramVisitor):
        visitor.visitRev(self)

    def ID(self):
        return self._id if isinstance(self._id, str) else self._id.getText()

    def block(self):
        return self._block
