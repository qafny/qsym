import LocusCollector
import Programmer
from ProgramVisitor import ProgramVisitor
from CollectKind import *
from SimpAExp import SimpAExp
from SubstAExp import SubstAExp
from copy import deepcopy
from PrettyPrinter import PrettyPrinter

BIND = ['k', 'j', 'i', 'h', 'g']

def envPrint(env:tuple):
    printer = PrettyPrinter()
    lines = []
    for (loci, ty, st, num) in env:
        loci_str = " ".join(loc.accept(printer) for loc in loci)
        ty_str = ty.accept(printer)
        if st:
            if isinstance(st, list):
                st_str =" ".join(elem.accept(printer) for elem in st)
            else:
                st_str = st.accept(printer)
        lines.append(f"Env ⊢ {num} : {loci_str}: {ty_str} ↦ {st_str}")
    return "\n".join(line for line in lines)


def compareQRange(q1: QXQRange, q2: QXQRange):
    return (q1.ID() == q2.ID()
            and compareAExp(q1.crange().left(),q2.crange().left())
            and compareAExp(q1.crange().right(),q2.crange().right()))

#vs = qs/q1
def compareRangeLocus(q1: QXQRange, qs: list[QXQRange]):
    vs = []
    for i in range(len(qs)):
        if compareQRange(q1,qs[i]):
            return (vs + (qs[i+1:len(qs)]))
        vs = vs + [qs[i]]
    return None
#vs = q2/q1
def compareLocus(q1: list[QXQRange], q2: list[QXQRange]):
    vs = q2
    for elem in q1:
        vs = compareRangeLocus(elem, vs)
        if vs is None:
            return None
    return vs
#vs = loc-type from env
def compareSubLocus(q1: list[QXQRange], q2: list[(list[QXQRange], QXQTy, QXQSpec, int)]):
    vs = []
    for i in q1:
        for loc, qty, st, num in q2:
            tmpres = compareLocus([i], loc)
            if tmpres == [] or tmpres:
                if equalLocusEnv(loc, vs) is None:
                    vs.append((loc, qty, st, num)) #wouldn't it duplicate? say [p, q] and [(p, q, r)]
                break
    return vs

def equalLocusEnv(q1: list[QXQRange], qs: list[(list[QXQRange], QXQTy, QXQSpec, int)]):
    vs = None
    for elem, ty, st, num in qs:
        vs = compareLocus(q1, elem)
        if vs is not None:
            return vs
    return vs

def equalEnv(qs1: list[(list[QXQRange], QXQTy, QXQSpec, int)], qs2: list[(list[QXQRange], QXQTy, QXQSpec, int)]):
    vs = None
    for elem, ty, st, num in qs1:
        vs = equalLocusEnv(elem, qs2)
        if vs is not None:
            return vs
    return vs


def compareType(ty: QXQTy, ty1: QXQTy):
    if ty1 is None:
        return ty

    if isinstance(ty, TyEn) and isinstance(ty1, TyEn):
        if ty.flag().num() < ty1.flag().num():
            return ty1
        else:
            return ty

    if isinstance(ty, TyEn) and isinstance(ty1, TyNor):
        return ty

    if isinstance(ty, TyNor) and isinstance(ty1, TyEn):
        return ty1

    if isinstance(ty, TyHad) and isinstance(ty1, TyEn):
        return ty1

    if isinstance(ty, TyEn) and isinstance(ty1, TyHad):
        return ty

    if isinstance(ty, TyNor) and isinstance(ty1, TyHad):
        return TyEn(QXNum(1))

    if isinstance(ty, TyHad) and isinstance(ty1, TyNor):
        return TyEn(QXNum(1))

    if isinstance(ty, TyHad) and isinstance(ty1, TyHad):
        return TyEn(QXNum(1))

    if isinstance(ty, TyNor) and isinstance(ty1, TyNor):
        return ty

#
def compareSingle(qs: list[QXQRange], qv: list[QXQRange]):
    if len(qv) != 1:
        return None

    elem = qv[0]
    vs = []
    for i in range(len(qs)):
        v = qs[i]
        if elem.ID() == v.ID():
            if compareAExp(elem.crange().left(), v.crange().left()):
                if compareAExp(elem.crange().right(), v.crange().right()): #(exactmatch, vs, [])
                    qv = []
                    vs += (qs[i+1:len(qs)])
                    return (QXQRange(elem.ID(), QXCRange(v.crange().left(), v.crange().right())), vs, qv)
                else: #(matched_qxrange, vs, [remaining_qxrange])
                    qv = [QXQRange(elem.ID(), QXCRange(v.crange().right(), elem.crange().right()))] 
                    vs += (qs[i+1:len(qs)])
                    return (QXQRange(elem.ID(), QXCRange(v.crange().left(), v.crange().right())), vs, qv)
        vs += [v]


    return None


def subLocusGen(q: list[QXQRange], qs: list[(list[QXQRange], QXQTy, QXQSpec, int)]):
    rev = []
    floc = []
    state = None
    type = None
    for i in range(len(qs)):
        elem, qty, st, num = qs[i]
        if isinstance(qty, TyEn):
            vs = compareLocus(elem, q) #vs=q[i, i+1), q[0, i)
            if vs is None:
                rev += [(elem, qty, st, num)]
            elif vs == []:
                floc += elem
                type = compareType(qty, type)
                state = st
                rev += (qs[i+1:len(qs)])
                return (floc, type, state, rev, num)
            else:
                q = vs #q is updated to the unmatched sub-locus in env?
                floc += elem
                type = compareType(qty, type)

        if isinstance(qty, TyNor) or isinstance(qty, TyHad): 
            re = compareSingle(q, elem) 
            if re is not None:
                qxv, vs, qv = re
                if vs == []:
                    floc += [qxv]
                    type = compareType(qty, type)
                    state = st
                    if qv:
                        rev += [(qv, qty, st, -1)] 
                    rev += (qs[i+1:len(qs)])
                    return (floc, type, state, rev, num)
                else:
                    floc += [qxv]
                    type = compareType(qty, type)
                    state = st
                    rev += qv #probably need to fix here as well
            else:
                rev += [qs[i]]

    

    sl = compareSubLocus(q, qs) 
    
    if len(sl)>0:
        floc = []
        for loc,ty,st,num in sl:
            type = compareType(ty, type)
            floc.extend(loc)
            state = st

        
        slrev = []
        for loc,qty,st,num in qs:
            vs = compareRangeLocus(loc[0], floc)
            if vs == None:
                slrev.append((loc,qty,st,num))
         
            # if loc not in floc:
            #     slrev.append((loc,qty,st,num))

        return (floc, type, state, slrev, -1) 
    
    if floc is not None:
        return floc, type, state, rev, -1
    
    return None


def mergeLocus(q: list[QXQRange]):
    if not q:
        return []

    merged = []
    current = q[0]

    for i in range(1, len(q)):
        next_range = q[i]
        if current.ID() == next_range.ID() and compareAExp(current.crange().right(), next_range.crange().left()):
            current = QXQRange(current.ID(), QXCRange(current.crange().left(), next_range.crange().right()))
        else:
            merged.append(current)
            current = next_range

    merged.append(current)
    return merged
def sameLocus(q: list[QXQRange], qs : list[(list[QXQRange], QXQTy, QXQSpec, int)]):
    for i in range(len(qs)):
        elem, qty, num = qs[i]
        vs = compareLocus(q, elem)
        if vs == []:
            vs += (qs[i+1:len(qs)])
            return vs
        elif vs is None:
            vs += [qs[i]]
        else:
            return None

def subRangeLocus(elem: QXQRange, qs: list[QXQRange]):
    vs = []
    for i in range(len(qs)):
        v = qs[i]
        if elem.ID() == v.ID():
            if compareAExp(elem.crange().left(), v.crange().left()):
                if compareAExp(elem.crange().right(), v.crange().right()):
                    vs += (qs[i + 1:len(qs)])
                    return vs
                else:
                    vs += [QXQRange(elem.ID(), QXCRange(v.crange().right(), elem.crange().right()))] + (qs[i + 1:len(qs)])
                    return vs
        vs = vs + [qs[i]]
    return None

def subRangeLoci(q: list[QXQRange], qs: list[QXQRange]):
    for elem in q:
        qs = subRangeLocus(elem, qs)
        if qs is None:
            return None
    return qs

def subLocus(q: list[QXQRange] , qs: list[(list[QXQRange], QXQTy, QXQSpec, int)]):
    qsf = []
    rty = None
    rstate = None
    for i in range(len(qs)):
        elem, ty, st, num = qs[i]
        vs = subRangeLoci(q, elem)
        if vs is None:
            qsf = qsf + [qs[i]]
        elif vs == []:
            qsf = qsf + qs[i+1:len(qs)]
            if isinstance(ty, TyHad):
                rty = TyEn(QXNum(1))
            else:
                rty = ty
            return (rty, st, num, qsf)
        else:
            qsf += [(vs, ty, st, num)] + qs[i+1:len(qs)]
            if isinstance(ty, TyHad):
                rty = TyEn(QXNum(1))
            else:
                rty = ty
            rstate = st
            return (rty, rstate, num, qsf)

    return None

def addOneType(ty : QXQTy):
    if isinstance(ty, TyEn):
        return TyEn(QXNum(ty.flag().num()+1))
    if isinstance(ty, TyNor):
        return TyHad()
    return None

def addOneEn():
    pass

def subVec(opvec, id, vec):
    """
    Recursively replace all QXBind(id=id) in opvec with vec.
    Works for QXBind, QXBin, QXNum, QXUni, etc.
    """
    if isinstance(opvec, QXBind):
        if opvec.ID() == id[0]:
            return vec
        else:
            return opvec
    elif isinstance(opvec, QXBin):
        return QXBin(
            op=opvec.op(),
            left=subVec(opvec.left(), id, vec),
            right=subVec(opvec.right(), id, vec)
        )
    elif isinstance(opvec, QXUni):
        return QXUni(
            op=opvec.op(),
            next=subVec(opvec.next(), id, vec)
        )
    # Add more cases as needed for your QXAExp subclasses
    elif isinstance(opvec, QXNum):
        return opvec  # QXNum, etc., are returned as is
    
    elif isinstance(opvec, QXComp):
        return QXComp(
            opvec.op(),
            left=subVec(opvec.left(), id, vec),
            right=subVec(opvec.right(), id, vec)
        )
    else:
        return opvec
   
def findStates(q:list[QXQRange], qs: list[(list[QXQRange], QXQTy, QXQSpec, int)]):
    states = []
    print(f"\n q:{q}\nqs:{envPrint(qs)}")
    locstate = compareSubLocus(q, qs)
    print(f"\nfindStates: {envPrint(locstate)}")

    for elem in locstate:
        print(elem[2].__dict__, type(elem[2]))
        if elem[2] not in states:
            states.append(elem[2])     
    print(f"final states{states}")

def addEn(idx: int, qxsum: QXSum=None, con: QXCon=None, amp: QXAExp=None, ctrl: bool=False):
    if qxsum:
        flag = len(qxsum.sums())
        nsums = list(qxsum.sums())
#        print(f"\n{nsums} {con}")
        nsums.insert(idx, con) if con else []
#        print(f"\n{nsums} and amp{amp} ctrl{ctrl}")
        if idx == 0:
            namp = QXBin('*', amp, qxsum.amp()) if amp else qxsum.amp()
        else:
            namp = QXBin('*', qxsum.amp(), amp) if amp else qxsum.amp()
        nkets = list(qxsum.kets())
        if ctrl: 
            nkets[idx] = QXSKet(QXBin('*', 
                                        QXBind(BIND[flag]), #the control ket
                                        qxsum.kets()[idx].vector()))
        else:
            nkets[idx] = QXSKet(QXBind(BIND[flag]))
        
    else:
        nsums = [con]
        namp = amp
        nkets = [QXSKet(vector=QXBind(id='k'))]
    return QXSum(sums=nsums, amp=namp, kets=nkets)


def findPos(q1: list[QXQRange], q2:list[QXQRange]):
    idxs = []
    if len(q2) != 2:
        ValueError(f"Loci{q2} from LocusCollector have two locus!")
    
    for elem in q2:
        for i in range(len(q1)):
            if compareQRange(elem, q1[i]):
                idxs.append(i)
    assert(idxs[0] != idxs[1], AssertionError(f"Loci{q2} controlling itself!"))
    idxs = tuple(idxs)
    return idxs

def createHadBranch(base:QXQState, qv: int, amp=None):
    if isinstance(base, QXSum):
        sums = list(base.sums())
        amps = list(base.amps())
        kets = list(base.kets())
        kets.insert(0, QXSKet(QXNum(qv)))
        if amp:
            amps.append(amp) # Add a ket for the predicate
    elif isinstance(base, QXTensor):
        sums = None
        amps = [amp] if amp else []
        kets = list(base.kets())
        kets.insert(0, QXSKet(QXNum(qv)))
    return QXSum(sums=sums, amps=amps, kets=kets)

def applyHadBranch(state:QXQState):
    hamp = QXBin('/', QXNum(1), QXUni('sqrt', QXNum(2)))
    branch0 = createHadBranch(state, 0, hamp)
    branch1 = createHadBranch(state, 1, hamp)
    return [branch0, branch1]

def createArithBranch(cst: QXQState, tst: QXQState, bv:int, pred=None):
    if isinstance(cst, QXSum):
        sums = list(cst.sums())
        amps = list(cst.amps())
        kets = list(cst.kets())
        if cst != tst:
            if isinstance(tst, QXSum):
                sums.extend(tst.sums())
                amps.extend(tst.amps())
                kets.extend(tst.kets())
            else: 
                if pred:
                    kets.append(QXSKet(QXNum(bv)))
                else:
                    kets.extend(tst.kets())
        if pred:    
            amps.append(QXComp('==', left=pred, right=QXNum(bv)))

        return QXSum(sums=sums, amps=amps, kets=kets)
    else:
        ValueError(f"createBranch: cst {cst} is not a QXSum!")
  
def applyArithBranch(states:list[QXQState], idxs:tuple[int, int], amp=None):
    if len(states) > 1: idxs = idxs[0], idxs[1]-len(states[0].kets())
    if amp: 
        pred = amp
    else: 
        pred = states[0].kets()[idxs[0]].vector()
        if isinstance(pred, QXNum): #already split
            pred = None

    branch0 = createArithBranch(states[0], states[1], 0, pred)
    branch1 = createArithBranch(states[0], states[1], 1, pred)

    return [branch0, branch1] if branch0 != branch1 else [branch0]
 

#handle LocusCombined cases, ensuring #kets = #locus && preds is added to amps
#assuming one control loci and one target loci.
#they might come from different loci or the same one 
def mergeStates(q: list[QXQRange], qs: list[(list[QXQRange], QXQTy, QXQSpec, int)], conds:tuple[bool, tuple[int, int]]=None, comp:QXComp=None):
    vs = compareSubLocus(q, qs) #return the loc-type-states from renv
    print(f"\nmerge States{vs} \nidxs: {conds[1]}")
    preds = []
    if comp: 
        print(f"\nconds: {comp}")     
        for elem in vs[0][2].qxsums():
            pred = subVec(comp, [vs[0][0][conds[1][0]].ID()], elem.kets()[conds[1][0]].vector())
            preds.append(pred)
    #suppose to have k < N  
    print(f"\npreds: {preds if preds else None}")


    if len(vs) > 1:        
        if isinstance(vs[0][1], TyHad):
            if isinstance(vs[1][1], TyNor):
                qxsum = applyHadBranch(vs[1][2])
            elif isinstance(vs[1][1], TyEn):
                qxsum = [branch for state in vs[1][2].qxsums() for branch in applyHadBranch(state)]
            return QXSums(qxsum)
                                                                    
        elif isinstance(vs[0][1], TyEn):
            #amp and kets
            qxsums = []
            states = [item[2] for item in vs]
            if isinstance(vs[1][1], TyNor):
                for i, state in enumerate(states[0].qxsums()):
                    branch = applyArithBranch([state, states[1]], conds[1], preds[i] if preds else None)#remove duplicates
                    qxsums.extend(branch)
            elif isinstance(vs[1][1], TyHad):
                pass
            elif isinstance(vs[1][1], TyEn):
                for i, state in enumerate(states[0].qxsums()):
                    for j, elem in enumerate(states[1].qxsums()):
                            branch = applyArithBranch([state, elem], conds[1], preds[i] if preds else None)
                            qxsums.extend(branch)

            return QXSums(qxsums)

    elif len(vs) == 1:
        #only en-control is here.
        qxsums = []
        states = [item[2] for item in vs]
        for i, state in enumerate(states[0].qxsums()):
            branch = applyArithBranch([state, state], conds[1], preds[i] if preds else None)
            qxsums.extend(branch)
        return QXSums(qxsums)
    
    else:
        ValueError(f"mergeStates: no states found for {q} in {qs}")
        
#consider ketwise
def hadGate(q: QXQRange, ket: QXSKet, char: str):

    sums = QXCon(char, QXCRange(QXNum(0), QXNum(2)))
    amp = QXBin('/', QXNum(1), QXUni('sqrt', QXNum(2)))
    kets = [QXNum(0), QXNum(1)]
    phase = QXCall(id='omega', exps=[QXBin('*', ket, QXBind(id=char)),
                                QXUni(op ='abs',next=QXNum(2))])
    return sums, amp, phase, kets

def qftGate(q: QXQRange, ket: QXSKet, char: str):
    #find the locus to operate
    left = q.crange().left()
    right = q.crange().right()
    print(f"\n{left}, {right}")

    if isinstance(left, QXNum) and isinstance(right, QXBind):  
        ran = QXBind(id=right.ID())                 
    elif isinstance(left, QXNum) and isinstance(right, QXNum):
        ran = QXNum(num=(right.num() - left.num()))
    sums = QXCon(char, QXCRange(QXNum(0), QXBin('^', QXNum(2), ran)))
    amp = QXBin('/', QXNum(1), QXUni('sqrt', QXNum(2)))
    kets = [QXNum(0), QXNum(1)]
    phase = QXCall(id='omega', exps=[QXBin('*', ket, QXBind(id=char)),
                                QXUni(op ='abs',next=QXNum(2))])
    return sums, amp, phase, kets

def createEn(idx: int, ran: QXNum | QXBind, vec: QXNum | QXBind=None):
    sum=QXCon(id=BIND[idx], 
                crange=QXCRange(left=QXNum(0), 
                                right=QXBin(op='^',
                                            left=QXNum(2), 
                                            right=ran)))
    amp=QXBin(op='/',
            left=QXNum(1), 
            right=QXUni(op='sqrt', 
                        next=QXBin(op='^', 
                                    left=QXNum(2), 
                                    right=ran)))
    ket=QXSKet(vector=QXBind(id=BIND[idx]))
    
    if vec:
        phase_exp = [QXBin('*', 
                    left = vec,
                    right = QXBind(id=BIND[idx])),
                QXUni(op='abs',
                    next=QXBin(op='^',
                                left=QXNum(num=2), 
                                right=ran))]
    else: phase_exp = None
    return sum, amp, phase_exp, ket

def castEn(q:list[QXQRange]):
    #find the locus to operate
    left = q[0].crange().left()
    right = q[0].crange().right()

    if isinstance(left, QXNum) and isinstance(right, QXBind):  
        ran = QXBind(id=right.ID())                 
    elif isinstance(left, QXNum) and isinstance(right, QXNum):
        ran = QXNum(num=(right.num() - left.num()))
    else:
        raise ValueError(f"castEn: cannot cast {q[0]} to En")
    
    sum, amp, phase_exp, ket = createEn(0, ran)
    return QXSums([QXSum(sums=[sum], amps=[amp], kets=[ket])])
#handle QAssign, if control happens, st has to be a QXSum
def updateEn(q:list[QXQRange], st:QXQState, op:QXQAssign, conds:tuple[bool, tuple[int, int]]):
  
    #find the locus to operate
    for i in range(len(q)):
        if q[i] == op.locus()[0]: 
            #find the locus to operate
            left = q[i].crange().left()
            right = q[i].crange().right()
            pos = i
            print(f"\n{left}, {right}")
            break   

    #find the range 
    if isinstance(left, QXNum) and isinstance(right, QXBind):  
        ran = QXBind(id=right.ID())                 
    elif isinstance(left, QXNum) and isinstance(right, QXNum):
        ran = QXNum(num=(right.num() - left.num()))

    if isinstance(st, QXTensor):
        vec = st.kets()[pos].vector()
        if isinstance (vec, QXHad):
                match op.exp().op():
                    case 'H' | 'QFT' | 'RQFT':
                        match vec.state():
                            case '+':
                                vector = QXNum(0)
                            case '-':
                                vector = QXNum(1)
                            case _:
                                return False
                    case _:
                        return False
                return QXTensor(kets=[vector])
        elif isinstance(vec, (QXNum, QXBind)):                           
                    match op.exp().op():
                        case 'H':
                            print(f"\nvector: {vec}")
                            match vec:                              
                                case QXNum() if vec.num() == 0:
                                    vector = QXHad('+')
                                case QXNum() if vec.num() == 1:
                                    vector = QXHad('-')
                                case QXNum():
                                    raise ValueError(f"QXNum must be 0 or 1 under Hadamard, got {vec.num()}")
                                case _:
                                    return None 
                            return QXTensor(kets=[vector])
                        case 'QFT':
                            const = QXNum(1)
                        case 'RQFT':
                            const = QXNum(-1)
                        case _:
                            return False
                    return createEn(idx=0, ran=ran, vec=vec)
                        
    elif isinstance(st, QXSums):
        qxsums = []
        for elem in st.qxsums():
            # Skip if conditional and vector doesn't match
            if conds[0]:
                print(f"\nelem{elem}")
                cond_vec = elem.kets()[conds[1][0]].vector()
                if not (isinstance(cond_vec, QXNum) and cond_vec.num() == 1):
                    qxsums.append(elem)  # Keep original if condition not met
                    continue
            
            # Prepare new components
            idx = len(elem.sums()) if elem.sums() else 0
            vec = elem.kets()[pos].vector()
            sum, amp, phase_exp, ket = createEn(idx, ran, vec)
            
            # Build updated components
            sums = list(elem.sums()) if elem.sums() else []
            amps = list(elem.amps())
            kets = list(elem.kets())
            
            # Handle phase based on operation
            if op.exp().op() == 'H':
                phase = QXCall(id='omega', exps=[phase_exp[0], QXNum(2)])
            elif op.exp().op() == 'RQFT':
                phase = QXCall(id='omega', exps=[
                    QXBin('*', QXNum(-1), phase_exp[0]), 
                    phase_exp[1]
                ])
            else:
                phase = QXCall(id='omega', exps=phase_exp)
            
            # Update collections
            sums.append(sum)
            amps.extend([amp, phase])
            kets[pos] = ket
            
            qxsums.append(QXSum(sums, amps, kets))
        
        return QXSums(qxsums)
            
                          
#handle oracle
def updateState(q: list[QXQRange], st: QXQState, op: QXQAssign, conds:tuple[bool, tuple[int, int]]=None):
    #QXCall 3 cases: another function, (Arithmetic and Omega) - > QXOracle 
    #operation on one register at a time. 
    #find the locus to operate
    for i in range(len(q)):
        if q[i] == op.locus()[0]: 
            #find the locus to operate
            left = q[i].crange().left()
            right = q[i].crange().right()
            pos = i
            print(f"\n{left}, {right}")
            break  
    
    if isinstance(op.exp(), QXOracle):
        if op.exp().phase().ID() == 'arith':  
            if isinstance(st, QXTensor):   
                vec = st.kets()[pos].vector() 
                ket = QXSKet(vector=subVec(op.exp().vectors()[0].vector(), op.exp().ids(), vec)) 
                if isinstance(vec, QXHad):                       
                    raise ValueError(f"updateState: cannot apply arithmetic oracle on Hadamard state {st}")
    #                print(f"\n{op.exp().vectors()[0].vector()}{op.exp().ids()}{vec}")
                elif isinstance(vec, (QXNum, QXBind)): #nor type
                    kets = list(st.kets())
                    kets[pos] = ket
                    return QXTensor(kets)                      
            elif isinstance(st, QXSums):
                qxsums = []
                for elem in st.qxsums():
                    if conds and conds[0]:  # Check if conditions are provided
                        cond_vec = elem.kets()[conds[1][0]].vector()
                        if not (isinstance(cond_vec, QXNum) and cond_vec.num() == 1):
                            qxsums.append(elem)
                            continue  # Skip if condition not met
                    vec = elem.kets()[pos].vector()
                    ket = QXSKet(vector=subVec(op.exp().vectors()[0].vector(), op.exp().ids(), vec))
                    sums = list(elem.sums())
                    amps = list(elem.amps())
                    kets = list(elem.kets())
                    qxsums.append(QXSum(sums, amps, kets[:pos] + [ket] + kets[pos+1:]))

                return QXSums(qxsums) 
        
        elif op.exp().phase().ID() == 'omega': #only for en type
            qxsums = []
            for elem in st.qxsums():
                if conds and conds[0]:
                    cond_vec = elem.kets()[conds[1][0]].vector()
                    if not (isinstance(cond_vec, QXNum) and cond_vec.num() == 1):
                        qxsums.append(elem)
                        continue  
                vec = elem.kets()[pos].vector()
                phase = QXCall(id='omega', 
                           exps=[subVec(elem, op.exp().ids(), vec) for elem in op.exp().phase().exps()])
                sums = list(elem.sums())
                amps = list(elem.amps())
                amps.append(phase)
                kets = list(elem.kets())
                qxsums.append(QXSum(sums, amps, kets))
            return QXSums(qxsums)
        
        else:
            pass 
   

def replaceLocus(t: list[QXQRange], r1: QXQRange, r2: QXQRange):
    tmp = []
    for elem in t:
        if compareQRange(elem, r1):
            tmp += [r2]
        else:
            tmp += [elem]
    return tmp

def replaceLoci(t: list[QXQRange], r1: list[QXQRange], r2: list[QXQRange]):
    vs = zip(r1, r2)
    for v1,v2 in vs:
        t = replaceLocus(t, v1, v2)
    return t

def replaceEnvLoci(tenv: list[(list[QXQRange],QXQTy, QXQSpec, int)], l1: list[QXQRange], l2: list[QXQRange]):
    tmp = []
    for elem,ty,st,num in tenv:
        vs = compareLocus(elem, l1)
        if vs is None:
            tmp += [(elem,ty,st,num)]
        else:
            tmp += [replaceLoci(elem, l1, l2)]
    return tmp

def substQVar(l:list[(str,QXAExp)], v:str):

    for name, elem in l:
        if name == v and isinstance(elem, QXBind):
            return elem.ID()
    return v

def substAllVars(l:list[SubstAExp], v:QXAExp):

    for st in l:
        v = st.visit(v)

    return v

# check the types of the quantum array (nor, Had, EN types)
# for a given index in a function name f, we check the type information at location index in the function
# the type env, is the initial type env getting from TypeCollector, no ending type env is needed.
class StateChecker(ProgramVisitor):

    def __init__(self, kenv: dict, tenv: dict, senv: dict, renv:list[(list[QXQRange], QXQTy, QXQSpec, int)], counter: int):
        # need st --> state we are deling with
        #kind map from fun vars to kind maps
        #generated from CollectKind
        #self.kenv = kenv
        #type env
        #this is the type env mapping from function names to input and output envs,
        #as well as predicates. These predicates deal with the relations among loci.
        #for example, if we have a locus x[i,j), y[m,n), Obviously, we should have
        #predicates to show that i < j, and m < n. Otherwise, the locus will not make sense.
        #recall that type env is not a map, but a list of pairs
        # first in a pair is a locus (a list of ranges), the second is a quantum type
        #we assume that this is also an input, because the input/output type envs can be generated
        #in TypeCollector
        #self.tenv = tenv
        #current fun name, where we want
        #self.name = f
        #the index for a function name to check
        #self.ind = ind
        #kind env, this is the step kind env inside a function f
        self.kinds = kenv
        # this is the type env generated from TypeCollector
        self.tenv = tenv
        # this is the state evn generated from StateCollector
        self.senv = senv

        #QXCall(f,...)
        #the checked state env at index
        #the generated state environment.
        self.renv = renv
        self.counter = counter
        self.conds = False, None

    def kenv(self):
        return self.kinds

    def renv(self):
        return self.renv
    

    #Need to deal with assertion
    #assertion might modify locus types
    def visitAssert(self, ctx: Programmer.QXAssert):
        return ctx.spec().accept(self)

    #It is correct here
    #since KindCollections might only collect
    #variables in the beginning, and in the return clause
    #it will not recall variables inside a function.
    def visitInit(self, ctx: Programmer.QXInit):
        y = ctx.binding().ID()
        kv = ctx.binding().type()
        self.kinds.update({y: kv})
        return True

    def visitCast(self, ctx: Programmer.QXCast):
        ty = ctx.qty()
        if isinstance(ty, TyAA):
            vs = sameLocus(ctx.locus(), self.renv)
            if vs is None:
                return False
            else:
                self.renv = [(ctx.locus(), TyAA(), self.counter)] + vs
                self.counter += 1
                return True

        re = subLocusGen(ctx.locus(), self.renv)
        if re is None:
            return False
        newLoc, newTy, st, vs, num = re
        if isinstance(newTy, TyHad):
            st = castEn(newLoc)
        print(f"newLoc: {newLoc}\n newTy: {newTy}\n st: {st}\n vs: {vs}\n num: {num}")
        self.renv = vs + [(newLoc, ty, st, num)]
        return True

    def visitBind(self, ctx: Programmer.QXBind):
        if ctx.type() is not None:
            ctx.type().accept(self)
        return ctx.ID()

    def visitQAssign(self, ctx: Programmer.QXQAssign):
        # print("\nrenv in sc before", self.renv)
        # envPrint(self.renv)

        print(f"QAssign begin: {ctx.locus()}{self.renv}")
        loc, ty, st, nenv, num = subLocusGen(ctx.locus(), self.renv)
#        st = findStates(loc, self.renv)
        print(f"QAssign: \nloc: {loc}\n ty: {ty} \n st: {st}\n {nenv}\n num: {num}")
        
        

        if isinstance(ctx.exp(), QXOracle):
            st = updateState(loc, st, ctx, self.conds)
        elif isinstance(ctx.exp(), QXSingle):
    #        flag = ty.flag().num() if isinstance(ty, TyEn) else 0
            st = updateEn(loc, st, ctx, self.conds)
            ty = addOneType(ty)


        self.renv = nenv
        self.renv += [(loc, ty, st, num)]
 #       print("\nrenv in sc after", envPrint(self.renv))
        # envPrint(self.renv)

        return True

    def visitMeasure(self, ctx: Programmer.QXMeasure):
        re = subLocus(ctx.locus(), self.renv)
        if re is None:
            return False
        nty, num, nenv = re

        for id in ctx.ids():
            self.kinds.update({id:TySingle("nat")})

        self.renv = [(ctx.locus(), nty, num)]+nenv
        return True

    def visitCAssign(self, ctx: Programmer.QXCAssign):
        return True

    def visitIf(self, ctx: Programmer.QXIf):
    #    self.conds = True
        if isinstance(ctx.bexp(), QXBool):
            oldenv = self.renv
            for elem in ctx.stmts():
                elem.accept(self)
            if equalEnv(oldenv, self.renv):
                return True
            else:
                return False


        if isinstance(ctx.bexp(), QXQBool):
    #        if isinstance(ctx.bexp(), QXQComp):
            findLocus = LocusCollector.LocusCollector(self.renv)
            cond = findLocus.visit(ctx.bexp())

    #        print(f"\n locusRenv and renv after conds: {findLocus.renv} \n{self.renv}") 
            floc, ty, st, nenv, num = subLocusGen(findLocus.renv, self.renv)
    #        print(f"\n locusRenv, nenv, renv after conds: {findLocus.renv} \n{nenv} \n{self.renv} {envPrint(self.renv)}")         
            print(f"\n IF: findLocus.renv: {findLocus.renv} \nloc: {floc}\n ty: {ty} \n st: {st}\n nenv: {nenv}\n num: {num} \n renv: {self.renv} ")
            if isinstance(cond, QXComp):
                condidx = findPos(floc, findLocus.renv)
                self.conds = True, condidx
                st = mergeStates(floc, self.renv, self.conds, cond)
                self.renv = [(floc, ty, st, num)] + nenv
                findLocus.renv = [findLocus.renv[-1]]
                print(f"\n{findLocus.renv}")
                print(f"\n IF cond bool: loc: {floc}\n ty: {ty} \n st: {st}\n nenv: {nenv}\n num: {num} \n renv: {self.renv} {envPrint(self.renv)}")
 #           castEn(floc, ctrl=bool)
            else: 
                self.renv = [(floc, ty, st, num)] + nenv
            if isinstance(ty, TyNor):
                for elem in ctx.stmts():
                    elem.accept(self)
                return True

            for elem in ctx.stmts():
                cond = findLocus.visit(elem)
            print(f"\n locusRenv and renv: {findLocus.renv} \n{self.renv} {envPrint(self.renv)}")
            floc, ty, st, nenv, num = subLocusGen(findLocus.renv, self.renv)
            print(f"\n IF: before QAssign merger: {floc}\n ty: {ty} \n st: {st}\n nenv: {nenv}\n num: {num} \n renv: {self.renv})")
            
            condidx = findPos(floc, findLocus.renv)
            print(f"\n condidx: {condidx}")
            self.conds = True, condidx
            
            st = mergeStates(floc, self.renv, self.conds)
            print(f"\n Again IF: loc: {floc}\n ty: {ty} \n st: {st}\n nenv: {nenv}\n num: {num} \nrenv: {self.renv} ")
            self.renv = [(floc, ty, st, num)] + nenv
            print(f"{envPrint(self.renv)}")
            for elem in ctx.stmts():
                elem.accept(self)
            self.conds = False, None
            return True

    def visitFor(self, ctx: Programmer.QXFor):
        lbound = ctx.crange().left()
        rbound = ctx.crange().right()

        tmpv = self.renv
        self.kinds.update({ctx.ID():TySingle("nat")})
        self.renv = []
        for ielem in ctx.inv():
            if isinstance(ielem, QXQSpec):
                self.renv += [(ielem.locus(),ielem.qty(), self.counter)]
                self.counter += 1

        for elem in ctx.stmts():
            re = elem.accept(self)
            if not re:
                return re

        tmp1 = deepcopy(self.renv)
        simpler = SimpAExp()
        subst1 = SubstAExp(ctx.ID(), lbound)
        subst2 = SubstAExp(ctx.ID(), rbound)
        for elem, ty in tmp1:
            elem1 = subst1.visit(elem)
            elem1a = simpler.visit(elem1)
            elem2 = subst2.visit(elem)
            elem2a = simpler.visit(elem2)
            replaceEnvLoci(tmpv, elem1a, elem2a)

        self.renv = tmpv

        return True

    def visitCall(self, ctx: Programmer.QXCall):
        x = ctx.ID()
        kenv = self.kinds.get(x)
        tmpQVars = []
        tmpVars = []
        for i in range(len(kenv.items())):
            var, ty = kenv.items()[i]
            elem = ctx.exps()[i]
            if isinstance(ty, TyQ):
                tmpQVars += [(var,elem)]
            else:
                tmpVars += [(var,elem)]

        substs = []
        for var,elem in tmpVars:
            st = SubstAExp(var, elem)
            substs += [st]

        endEnv = self.tenv.get(x)[1]

        tmpNewEnv = []

        for loc, ty in endEnv:
            for ran in loc:
                id = substQVar(tmpQVars, ran.ID())
                left = substAllVars(substs, ran.crange().left())
                right = substAllVars(substs, ran.crange().right())
                v = QXQRange(id, QXCRange(left, right))
                tmpNewEnv += [(v,ty)]

        modEnv = self.renv

        for loc, ty in tmpNewEnv:
            vs = subLocusGen(loc, modEnv)
            if vs is None:
                return False

            floc, qty, ret, num = vs
            modEnv = [(floc, ty, self.counter)] + ret
            self.counter += 1

        self.renv = modEnv
        return True

    def visitCNot(self, ctx: Programmer.QXCNot):
        return ctx.next().accept(self)

    def visitEn(self, ctx: Programmer.TyEn):
        return ctx.flag().accept(self)

    def visitQSpec(self, ctx: Programmer.QXQSpec):
        ctx.qty().accept(self)
        for elem in ctx.locus():
            elem.accept(self)
        return ctx.state().accept(self)

    def visitTensor(self, ctx: Programmer.QXTensor):
        for elem in ctx.kets():
            elem.accept(self)

    def visitSKet(self, ctx: Programmer.QXSKet):
        return ctx.vector().accept(self)

    def visitVKet(self, ctx: Programmer.QXVKet):
        return ctx.vector().accept(self)

    def visitSum(self, ctx: Programmer.QXSum):
        for elem in ctx.kets():
            elem.accept(self)
        ctx.amp().accept(self)
        for elem in ctx.sums():
            elem.accept(self)

    def visitLogic(self, ctx: Programmer.QXLogic):
        ctx.left().accept(self)
        ctx.right().accept(self)

    def visitBool(self, ctx: Programmer.QXComp):
        ctx.left().accept(self)
        ctx.right().accept(self)
        return ctx.op()

    def visitCon(self, ctx: Programmer.QXCon):
        ctx.range().accept(self)
        return ctx.ID()

    def visitQIndex(self, ctx: Programmer.QXQIndex):
        ctx.index().accept(self)
        return ctx.ID()

    def visitQNot(self, ctx: Programmer.QXQNot):
        return ctx.next().accept(self)

    def visitQComp(self, ctx: Programmer.QXQComp):
        ctx.left().accept(self)
        ctx.right().accept(self)
        ctx.index().accept(self)

    def visitAll(self, ctx: Programmer.QXAll):
        ctx.bind().accept(self)
        ctx.next().accept(self)

    def visitBin(self, ctx: Programmer.QXBin):
        ctx.left().accept(self)
        ctx.right().accept(self)
        return ctx.op()

    def visitUni(self, ctx: Programmer.QXUni):
        ctx.next().accept(self)
        return ctx.op()
