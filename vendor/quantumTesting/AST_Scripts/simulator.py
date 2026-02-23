import math
import traceback
from collections import ChainMap
# from types import NoneType

from AST_Scripts.XMLProgrammer import *
from AST_Scripts.ProgramVisitor import *

NoneType = type(None)


class CoqVal:
    pass  # TODO


class CoqNVal(CoqVal):

    def __init__(self, boolean_binary_array: bool, phase: int):
        self.boolean_binary = boolean_binary_array
        self.phase = phase

    def getBit(self):
        return self.boolean_binary

    def setBit(self, b:bool):
        self.boolean_binary = b

    def getPhase(self):
        return self.phase

    def setPhase(self, i:int):
        self.phase += i


class CoqQVal(CoqVal):

    def __init__(self, r1: int, r2: int, b: [bool] = None, n: int = None):
        self.r1 = r1
        self.r2 = r2
        self.n = n
        self.b = b

    def getPhase(self):
        return self.r1

    def getLocal(self):
        return self.r2

    def getRest(self):
        return self.b

    def getNum(self):
        return self.n



#first flow is the amplitude, and the second flow is the phase int ==> exp(i * pi/int)
class CoqYVal(CoqVal):

    def __init__(self, r1: list[tuple[float, int]], r2: list[tuple[float, int]]):
        self.r1 = r1
        self.r2 = r2

    def getZero(self):
        return self.r1

    def getOne(self):
        return self.r2

    def addY(self, r):
        if len(self.r1) == 1 and len(self.r2) == 1 and self.r1[0][1] == 0 and self.r2[0][1] == 0:
                self.r1 = [(math.cos(math.pi*r/90)*self.r1[0][0]-math.sin(math.pi*r/90)*self.r2[0][0],0)]
                self.r2 = [(math.sin(math.pi*r/90)*self.r1[0][0]+math.cos(math.pi*r/90)*self.r2[0][0],0)]

    def addH(self):
        if len(self.r1) == 1 and len(self.r2) == 1 and self.r1[0][1] == 0 and self.r2[0][1] == 0:
            self.r1 = [((self.r1[0][0]+self.r2[0][0]) / math.sqrt(2),0)]
            self.r2 = [((self.r1[0][0]-self.r2[0][0]) / math.sqrt(2),0)]
        else:
            self.r1 = simpRyPoint(divSqrt(self.r1) + divSqrt(self.r2))
            self.r2 = simpRyPoint(divSqrt(self.r1) + applyNeg(divSqrt(self.r2)))

    def applyMult(self, r):
        newr = []
        for e in self.r2:
            newr += [(e[0], e[1] + r)]
        self.r2 = newr

    def flip(self):
        v = self.r2
        self.r2 = self.r1
        self.r1 = v

"""
Helper Functions
"""
def divSqrt(r:list[tuple[float, int]]):
    newr = []
    for e in r:
        newr += [(e[0] / math.sqrt(2),e[1])]
    return newr

def applyNeg(r:list[tuple[float, int]]):
    newr = []
    for e in r:
        newr += [(-e[0],e[1])]
    return newr

def simpRyPoint(r:list[tuple[float, int]]):
    newr = []
    for e in r:
        if e[0] != 0:
            newr += [(e[0],e[1])]
    return newr

def simpRy(a:CoqYVal):
    if not a.getZero():
        return CoqNVal([0],0)
    elif len(a.getZero()) == 1 and a.getZero()[0][0] == 0:
        return CoqNVal([0],0)
    elif not a.getOne():
        return CoqNVal([0],0)
    elif len(a.getOne()) == 1 and a.getOne()[0][0] == 0:
        return CoqNVal([0],0)
    else:
        return a

def exchange(coq_val: CoqVal):
    if isinstance(coq_val, CoqNVal):
        coq_val.setBit(not coq_val.getBit())
    if isinstance(coq_val, CoqYVal):
        coq_val.flip()
'''
def times_rotate(v, q, rmax):
    if isinstance(v, CoqNVal):
        if v.boolean_binary:
            return CoqNVal(v.getBits(), rotate(v.getPhase(), q, rmax))
        else:
            return CoqNVal(v.getBits(), v.getPhase())
    else:
        return CoqQVal(v.r1, rotate(v.r2, q, rmax))
'''

def addto(r, n, rmax):
    return (r + 2 ** max_helper(rmax, n)) % 2 ** rmax


def max_helper(x, y):
    return max(x - y, 0)


def rotate(r, n, rmax):
    return addto(r, n, rmax)


def addto_n(r, n, rmax):
    return max_helper(r + 2 ** rmax, 2 ** max_helper(rmax, n)) % 2 ** rmax


def r_rotate(r, n, rmax):
    return addto_n(r, n, rmax)

'''
def times_r_rotate(v, q, rmax):
    if isinstance(v, CoqNVal):
        if v.boolean_binary:
            return CoqNVal(v.getBits(), r_rotate(v.getPhase(), q, rmax))
        else:
            return CoqNVal(v.getBits(), v.getPhase())
    else:
        return CoqQVal(v.r1, r_rotate(v.r2, q, rmax))
'''

def up_h(v, rmax):
    if isinstance(v, CoqNVal):
        b = v.boolean_binary
        r = v.phase
        if b:
            return CoqQVal(
                r,
                rotate(0, 1, rmax)
            )
        else:
            return CoqQVal(r, 0)
    else:
        r = v.r1
        f = v.r2
        return CoqNVal(
            2 ** max_helper(rmax, 1) <= f,
            r
        )


def natminusmod(x, v, a):
    if x - v < 0:
        return x - v + a
    else:
        return x - v


def bit_array_to_int(bit_array, num_qubits):
    val = 0
    for i in range(min(len(bit_array), num_qubits)):
        val += pow(2, i) * int(bit_array[i])
    return val


def to_binary_arr(value, array_length):
    binary_arr = [False] * array_length
    for i in range(array_length):
        b = value % 2
        value = value // 2
        binary_arr[i] = bool(b)
    return binary_arr

def calBin(val, num):
    return to_binary_arr(val, num)


def calBinNoLength(v):
    val = []
    while v != 0:
        b = v % 2
        v = v // 2
        val.append(b)
    return val


class Simulator(ProgramVisitor):
    # x, y, z, env : ChainMap{ x: n, y : m, z : v} , n m v are nat numbers 100, 100, 100, eg {x : 128}
    # st state map, {x : v1, y : v2 , z : v3}, eg {x : v1}: v1,
    # st {x : v1} --> Coq_nval case: v1 is a ChainMap of Coq_nval
    # v1 --> 128 length array v1: {0 : Coq_nval, 1 : Coq_nval, 2 : Coq_nval, ...., 127 : Coq_nval}, 2^128
    # x --> v1 --> cal(v1) --> integer
    # Coq_nval(b,r) b == |0> | |1>, r == e^(2 pi i * 1 / n), r = 0 Coq_nval(b, 0)
    # x -> v1 ----> run simulator -----> v2 ---> calInt(v2,128) == (x + 2^10) % 2^128
    def __init__(self, state: dict, env: dict):
        self.state = state
        self.env = env
        # self.rmax = rmax rmax is M_find(x,env), a map from var to int

    def visitLet(self, ctx: XMLProgrammer.QXLet):
        f = ctx.ID()
        self.state.update({f: ctx})

    def visitMatch(self, ctx: XMLProgrammer.QXMatch):
        x = ctx.ID()
        value = self.state.get(x)
        if value <= 0:
            ctx.zero().program().accept(self)
        else:
            va = ctx.multi().elem().ID()
            tmpv = self.state.get(va)
            self.state.update({va: int(value) - 1})
            ctx.multi().program().accept(self)
            self.state.update({va:tmpv})

    def visitApp(self, ctx: XMLProgrammer.QXApp):
        vx = ctx.ID()
        ctxa = self.state.get(vx)
        i = 0
        tmpv = dict()
        tmpa = dict()
        while ctxa.idexp(i) is not None:
            x = ctxa.idexp(i).ID()
            v = ctx.vexp(i).accept(self)
            tmpv.update({x:self.state.get(x)})
            tmpa.update({x:v})
            i += 1

        while len(tmpa) != 0:
            xv,re = tmpa.popitem()
            self.state.update({xv: re})

        ctxa.program().accept(self)
        while len(tmpv) != 0:
            xv,re = tmpv.popitem()
            if re is not None:
                self.state.update({xv:re})
            else:
                self.state.pop(xv, None)

    def visitIf(self, ctx: XMLProgrammer.QXIf):
        v = ctx.vexp().accept(self)
        if v == 1:
            ctx.left().accept(self)
        else:
            ctx.right().accept(self)

    def get_state(self):
        return self.state

    def sr_rotate(self, x, n):
        val = self.state.get(x)[0]
        if isinstance(val, CoqQVal):
            self.state.get(x)[0] = CoqQVal(val.r1, (val.r2 + pow(2, val.getNum() - n)) % pow(2, val.getNum()), val.getRest(), val.getNum())

    def srr_rotate(self, x, n):
        val = self.state.get(x)[0]
        if isinstance(val, CoqQVal):
            self.state.get(x)[0] = CoqQVal(val.r1, ((val.r2 +
                                                     pow(2, val.getNum()) - pow(2, val.getNum() - n)) % pow(2, val.getNum())), val.getRest(), val.getNum())

    # should do nothing
    def visitSKIP(self, ctx: XMLProgrammer.QXSKIP):
        return

    # X posi, changed the following for an example
    def visitX(self, ctx: XMLProgrammer.QXX):
        vx = ctx.ID()
        p = ctx.vexp().accept(self)  # this will pass the visitor to the child of ctx
        x = self.state.get(vx)[p]
        exchange(x)

    def visitRZ(self, ctx: XMLProgrammer.QXRZ):
        vx = ctx.ID()
        index = ctx.vexp().accept(self)
        val = self.state.get(vx)[index]
        p = ctx.num().accept(self)  # this will pass the visitor to the child of ctx
        # CoqNVal uses len(bits), CoqQVal uses getNum()
        if isinstance(val, CoqNVal):
            val.setPhase(p)

        if isinstance(val, CoqYVal):
            val.applyMult(p)

    def visitRY(self, ctx: XMLProgrammer.QXRY):
        vx = ctx.ID()
        val = ctx.vexp().accept(self)
        p = ctx.num().accept(self)  # this will pass the visitor to the child of ctx
        x = self.state.get(vx)
        if isinstance(x[val], CoqNVal):
            v = x[val].getBit()
            if v == True:
                x[val] = CoqYVal([(-math.sin(math.pi * p / 90),0)],[(math.cos(math.pi * p / 90),0)])
            else:
                x[val] = CoqYVal([(math.cos(math.pi * p / 90),0)],[(math.sin(math.pi * p / 90),0)])
        elif isinstance(x[val], CoqYVal):
            x[val].addY(p)
        newv = simpRy(x[val])
        x[val] = newv


    def visitH(self, ctx: XMLProgrammer.QXH):
        vx = ctx.ID()
        val = ctx.vexp().accept(self)
        x = self.state.get(vx)
        if isinstance(x[val], CoqNVal):
            v = x[val].getBit()
            if v == True:
                x[val] = CoqYVal([(math.sqrt(2)/2,0)],[(-math.sqrt(2)/2,0)])
            else:
                x[val] = CoqYVal([(math.sqrt(2)/2,0)],[(math.sqrt(2)/2,0)])
        elif isinstance(x[val], CoqYVal):
            x[val].addH()

        newv = simpRy(x[val])
        x[val] = newv

    # we will first get the position in st and check if the state is 0 or 1,
    # then decide if we go to recursively call ctx.exp
    def visitCU(self, ctx: XMLProgrammer.QXCU):
        vx = ctx.ID()
        x = self.state.get(vx)
        p = ctx.vexp().accept(self)  # this will pass the visitor to the child of ctx
        if x[p].getBit() == True:
            ctx.program().accept(self)
        else:
            return  # do nothing

    # my previous rz parsing is wrong
    # it should be RZ q posi
    # def visitRzexp(self, ctx: XMLExpParser.RzexpContext):
    #     q = int(ctx.vexp(0).accept(self))  # I guess then you need to define vexp
    #     # we can first define the var and integer case
    # I guess Identifier and int are all terminal
    # does it means that we do not need to define anything?
    #     x = ctx.idexp().accept(self)
    #    p = ctx.vexp(1).accept(self)  # this will pass the visitor to the child of ctx
    #   if q >= 0:
    #      self.st.update({x: times_rotate(self.st.get(x), q, self.env.get(x))})
    #  else:
    #     self.st.update({x: times_r_rotate(self.st.get(x), abs(q), self.env.get(x))})

    # SR n x, now variables are all string, are this OK?
    def visitSR(self, ctx: XMLProgrammer.QXSR):
        n = int(ctx.vexp().accept(self))
        x = ctx.ID()
        if n >= 0:
            self.sr_rotate(x, n)
        else:
            self.srr_rotate(x, abs(n))

    def lshift(self, x, n):
        if n == 0:
            return

        tmp = self.state.get(x)[0].getBits()
        tmpv = tmp[0]
        for i in range(n - 1):
            tmp[i] = tmp[i + 1]
        tmp[n - 1] = tmpv
        self.state.get(x)[0] = CoqNVal(tmp, self.state.get(x)[0].getPhase())

    def visitLshift(self, ctx: XMLProgrammer.QXLshift):
        x = ctx.ID()
        self.lshift(x, self.env.get(x))

    def rshift(self, x, n):
        if n == 0:
            return

        tmp = self.state.get(x)[0].getBits()
        tmpv = tmp[n - 1]
        for i in range(n - 1, -1, -1):
            tmp[i] = tmp[i - 1]

        tmp[0] = tmpv
        self.state.get(x)[0] = CoqNVal(tmp, self.state.get(x)[0].getPhase())

    def visitRshift(self, ctx: XMLProgrammer.QXRshift):
        x = ctx.ID()
        self.rshift(x, self.env.get(x))

    def reverse(self, x, n):
        if n == 0:
            return

        size = n
        tmp = self.state.get(x)[0].getBits()
        tmpa = []
        for i in range(n):
            tmpa.append(tmp[size - i])
        self.state.get(x)[0] = CoqNVal(tmp, self.state.get(x)[0].getPhase())

    def visitRev(self, ctx: XMLProgrammer.QXRev):
        x = ctx.ID()
        self.reverse(x, self.env.get(x))

    def turn_qft(self, x, n):
        val = self.state.get(x)[0]
        r1 = val.getPhase()
        r2 = 0
        if isinstance(val, CoqNVal):
            for i in range(n):
                r2 = (r2 + pow(2, i) * int(val[i].getBit())) % pow(2, n)
        result = val[n:]
        self.state.get(x)[0] = CoqQVal(r1, r2, result, n)

        # actually, we need to change the QFT function
        # the following QFT is only for full QFT, we did not have the case for AQFT

    def visitQFT(self, ctx: XMLProgrammer.QXQFT):
        x = ctx.ID()
        v = ctx.vexp().accept(self)
        b = int(v)
        self.turn_qft(x, self.env.get(x) - b)
        # TODO implement

    def turn_rqft(self, x):
        val = self.state.get(x)[0]
        n = val.getNum()
        if isinstance(val, CoqQVal):
            tmp = val.getLocal()
            tov = [False] * n
            for i in range(n):
                b = tmp % 2
                tmp = tmp // 2
                tov[i] = bool(b)
            result = tov
            for i in range(n):
                self.state.get(x)[i] = CoqNVal(result[i], val.getPhase())
            self.state[x] += val.getRest()
            #self.state.get(x)[0] = CoqNVal(result, val.getPhase())

    def visitRQFT(self, ctx: XMLProgrammer.QXRQFT):
        x = ctx.ID()
        self.turn_rqft(x)

    def visitIDExp(self, ctx: XMLProgrammer.QXIDExp):
        return self.get_state().get(ctx.ID())

    def visitQID(self, ctx: XMLProgrammer.QXQID):
        return self.get_state().get(ctx.ID())
        # Visit a parse tree produced by XMLExpParser#vexp.

    def visitBin(self, ctx: XMLProgrammer.QXBin):
        x = ctx.left().accept(self)
        y = ctx.right().accept(self)
        if ctx.OP() == "+":
            return x + y
        elif ctx.OP() == "-":
            return x - y
        elif ctx.OP() == "*":
            return x * y
        elif ctx.OP() == "/":
            if y == 0:
                return 0
            return x // y
        elif ctx.OP() == "^":
            return x ** y
        elif ctx.OP() == "%":
            if y == 0:
                return 0
            return x % y
        elif ctx.OP() == "$":
            tmp = (calBinNoLength(x))
            if y < len(tmp):
                return int(tmp[y])
        return 0

    def visitNum(self, ctx: XMLProgrammer.QXNum):
        return ctx.num()