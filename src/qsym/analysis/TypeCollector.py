import Programmer
from ProgramVisitor import ProgramVisitor
from CollectKind import *

from TypeChecker import *

#from antlr4.tree.Tree import TerminalNodeImpl

def compareComp(t1: QXComp, t2: QXComp):
    return t1.op() == t2.op() and compareAExp(t1.left(),t2.left()) and compareAExp(t1.right(),t2.right())


def addElem(a: QXComp, l: list[QXComp]):
    for elem in l:
        if compareComp(a, elem):
            return l  # already present
    l.append(a)
    return l


def isARange(env: list[(list[QXQRange], QXQTy)], se:list[str]):
    tmp = []
    for elem,ty in env:
        for v in elem:
            if not v.ID() in se:
                tmp += [v.ID()]
    return tmp

def merge_two_dicts(x, y):
    z = x.copy()   # start with keys and values of x
    z.update(y)    # modifies z with keys and values of y
    return z

def findQAVars(v: QXAExp, vars: list[str]):
    if isinstance(v, QXUni):
        return findQAVars(v.next(), vars)
    if isinstance(v, QXBin):
        return findQAVars(v.left(), vars) + findQAVars(v.right(), vars)
    if isinstance(v, QXNum):
        return []
    if isinstance(v, QXBind):
        return [v.ID()] if v.ID() in vars else []
    return []


def findQVars(v: QXBool, vars: list[str]):

    if isinstance(v, QXLogic):
        return (findQVars(v.left(),vars) + findQVars(v.right(),vars))

    if isinstance(v, QXCNot):
        return findQVars(v.next(), vars)

    if isinstance(v, QXComp):
        return (findQAVars(v.left(),vars) + findQAVars(v.right(),vars))
    
    return []

def subStrs(a: list[str], b:list[str]):
    for elem in a:
        if not elem in b:
            return False
    return True

# collect the types of the quantum array (EN types)
# For each method, we have a map from the function name to three things
# We first have a initial type env, grouping loci together
# This is based on analysis of requires
# Then, we will have a endinng type env, grouping another possible loci
# This is to analyze the ensures
# The third field is a predicate. Each predicate collect the implicit
# rules in the locus type
# for example, if we have a range x[i,j) in a locus, obviously, i <= j
class TypeCollector(ProgramVisitor):

    def __init__(self, kenv: dict):
        # need st --> state we are dealing with
        self.kenv = kenv # mapping from function names -> two items,
        #the two items are both maps from variables to kinds
        self.env = dict()
        # mapping from function names -> three items, types
        # the first two items mapping from loci -> types
        # the third item is a list of predicates
        self.tenv = [] # temp pre-env for a method
        self.mkenv = [] # temp post-env for a method
        self.pred = [] # temp predicates
        self.fkenv = None
        self.fvar = ""
        self.errors = []

    
    def _create_spec_vars(self, conds: list[QXCond], cond_class):
        """Unified method to generate default unconstrained variables."""
        tmp = [var for var, kty in self.fkenv.items() if isinstance(kty, TyQ)]
        vars = tmp.copy()

        for elem in conds:
            if isinstance(elem, cond_class):
                if isinstance(elem.spec(), QXQSpec):
                    for ran in elem.spec().locus():
                        if ran.ID() in tmp:
                            tmp.remove(ran.ID())
                        else:
                            return []  
                elif isinstance(elem.spec(), QXBool):
                    tmvars = findQVars(elem.spec(), vars)
                    # Safely handle if findQVars returned None
                    if tmvars and not subStrs(tmvars, tmp):
                        for tmpelem in tmvars:
                            if tmpelem in tmp:
                                tmp.remove(tmpelem)

        result = []
        for var in tmp:
            v = self.fkenv.get(var).flag()
            locus = [QXQRange(var, QXCRange(QXNum(0), v))]
            ty = TyEn(QXNum(0))  # defaulting to en(0)
            result.append((locus, ty))

        return result

    def findLocus(self, locus: list[QXQRange], target_env):

        for elem, qty in target_env:
            vs = compareLocus(locus, elem)
            if vs == []:
                return qty
        return None

    def visitMethod(self, ctx: QXMethod):
        self.fvar = str(ctx.ID())
        self.tenv = []
        self.mkenv = []
        self.pred = []
        self.fkenv = self.kenv.get(self.fvar)

        self.tenv += self._create_default_vars(ctx.conds(), QXRequires)
        self.mkenv += self._create_default_vars(ctx.conds(), QXEnsures)

        for condelem in ctx.conds():
            v = condelem.accept(self)
            if not v:
                return False

        self.env.update({self.fvar:(self.tenv,self.mkenv,self.pred)})

        return True

    def visitProgram(self, ctx: QXProgram):
        for elem in ctx.method():
            v = elem.accept(self)
            if not v:
                return False

        return True
    
    def _extract_bounds(self, node):
        """Extracts the base ID and bounds from either a full register or a slice."""
        if hasattr(node, 'crange'): # It's a slice like q[i, j)
            return node.ID(), node.crange().left(), node.crange().right()
        else: # It's a whole register like q1
            ty = self.fkenv.get(node.ID())
            # Default bounds are 0 to the register's full flag length
            return node.ID(), QXNum(0), ty.flag()
    
    def _process_spec(self, spec, target_env):
        """Unified method to process Hoare logic specifications."""
        if isinstance(spec, QXQSpec):
            for elem in spec.locus():
                x = str(elem.ID())
                kty = self.fkenv.get(x)
                if not isinstance(kty, TyQ):
                    self.errors.append(f"TypeCollector Error: '{x}' is not a quantum type.")
                    return False

                left = elem.crange().left()
                right = elem.crange().right()

                if not left.accept(self) or not right.accept(self):
                    return False

                if not compareAExp(left, QXNum(0)):
                    addElem((QXComp("<=", QXNum(0), left)), self.pred)
                if not compareAExp(right, kty.flag()):
                    addElem((QXComp("<=", right, kty.flag())), self.pred)
                if not compareAExp(left, right):
                    addElem((QXComp("<=", left, right)), self.pred)

            target_env.append((spec.locus(), spec.qty()))

        if isinstance(spec, QXComp):
            left_id, left_start, left_end = self._extract_bounds(spec.left())
            right_id, right_start, right_end = self._extract_bounds(spec.right())

            tyx = self.fkenv.get(left)
            tyy = self.fkenv.get(right)

            if isinstance(tyx, TyQ) and isinstance(tyy, TyQ):
                # Pass the specific environment to findLocus!
                xT = self.findLocus([QXQRange(left_id, QXCRange(left_start, left_end))], target_env)
                yT = self.findLocus([QXQRange(right_id, QXCRange(right_start, right_end))], target_env) 

                if xT is None and yT is None:
                    self.errors.append(f"TypeCollector Error: Neither {left} nor {right} found in environment.")
                    return False
                elif xT is None:
                    target_env.append( ([QXQRange(left, QXCRange(QXNum(0), tyx.flag()))], yT) ) # Tuples fixed
                elif yT is None:
                    target_env.append( ([QXQRange(left, QXCRange(QXNum(0), tyx.flag()))], xT) ) # Tuples fixed
                else:
                    re = compareType(xT, yT)
                    if re is None:
                        self.errors.append(f"TypeCollector Error: Type mismatch between {left} and {right}.")
                        return False
        return True
    
    def visitRequires(self, ctx: QXRequires):
        return self._process_spec(ctx.spec(), self.tenv)

    def visitEnsures(self, ctx: QXEnsures):
        return self._process_spec(ctx.spec(), self.mkenv)

    def visitUni(self, ctx: QXUni):
        return ctx.next().accept(self)

    def visitBin(self, ctx: QXBin):
        return ctx.left().accept(self) and ctx.right().accept(self)

    def visitBind(self, ctx: QXBind):
        ty = self.fkenv[0].get(ctx.ID())
        if isinstance(ty, TySingle):
            return ty.type() == "nat"

    def visitNum(self, ctx: QXNum):
        return True

    def get_env(self):
        return self.env

    def get_tenv(self, meth_name: str) -> list[(list[QXQRange], QXQTy, int)]:
        """Returns the requires type environment associated with a particular method name (either str or antlr4.tree.Tree.TerminalNodeImpl)"""
        # if isinstance(meth_name, TerminalNodeImpl):
        #     meth_name = str(meth_name)

        return self.env[meth_name][0]

    def get_mkenv(self, meth_name: str) -> list[(list[QXQRange], QXQTy, int)]:
        """Returns the ensures type environment associated with a particular method name (either str or antlr4.tree.Tree.TerminalNodeImpl)"""
        # if isinstance(method_name, TerminalNodeImpl):
        #     method_name = str(method_name)

        return self.env[meth_name][1]
    
    def get_preds(self, meth_name: str) -> list[QXComp]:
        return self.env[meth_name][2]
    


    # def createRequireVars(self, l:list[QXCond]):

    #     tmp = []
    #     for var , kty in self.fkenv[0].items():
    #         if isinstance(kty, TyQ):
    #             tmp += [var]

    #     vars = tmp.copy()

    #     for elem in l:
    #         if isinstance(elem, QXRequires):
    #             if isinstance(elem.spec(), QXQSpec):
    #                 for ran in elem.spec().locus():
    #                     if ran.ID() in tmp:
    #                         tmp.remove(ran.ID())
    #                     else:
    #                         return []  
    #             elif isinstance(elem.spec(), QXBool):
    #                 tmvars = findQVars(elem.spec(), vars)
    #                 if not subStrs(tmvars, tmp):
    #                     for tmpelem in tmvars:
    #                         tmp.remove(tmpelem)

    #     result = []

    #     for var in tmp:
    #         v = self.fkenv[0].get(var).flag()
    #         locus = [QXQRange(var, QXCRange(QXNum(0), v))]
    #         ty = TyEn(QXNum(1))
    #         result += [(locus, ty)]

    #     return result

    # def createEnsureVars(self, l:list[QXCond]):

    #     tmp = []
    #     for var , kty in self.fkenv[0].items():
    #         if isinstance(kty, TyQ):
    #             tmp += [var]

    #     vars = tmp.copy()

    #     for elem in l:
    #         if isinstance(elem, QXEnsures):
    #             if isinstance(elem.spec(), QXQSpec):
    #                 for ran in elem.spec().locus():
    #                     if ran.ID() in tmp:
    #                         tmp.remove(ran.ID())
    #                     else:
    #                         return []  # instead of None
    #             elif isinstance(elem.spec(), QXBool):
    #                 tmvars = findQVars(elem.spec(), vars)
    #                 if not subStrs(tmvars, tmp):
    #                     for tmpelem in tmvars:
    #                         tmp.remove(tmpelem)

    #     result = []

    #     for var in tmp:
    #         v = self.fkenv[0].get(var).flag()
    #         locus = [QXQRange(var, QXCRange(QXNum(0), v))]
    #         ty = TyEn(QXNum(1))
    #         result += [(locus, ty)]

    #     return result
    


 #   def visitRequires(self, ctx: QXRequires):
        # if isinstance(ctx.spec(), QXQSpec):
        #     for elem in ctx.spec().locus():
        #         x = str(elem.ID())
        #         kty = self.fkenv[0].get(x)
        #         if not isinstance(kty, TyQ):
        #             self.errors.append(f"TypeCollector Error: '{x}' in Requires is not a quantum type.")
        #             return False

        #         left = elem.crange().left()
        #         right = elem.crange().right()

        #         if not left.accept(self) or not right.accept(self):
        #             return False
        #         #Requires { x[i,j) : en(1) -> .... }
        #         # i <= j, if i == j, then x[i,j) == {}
        #         if not compareAExp(left, QXNum(0)):
        #             addElem((QXComp("<=",QXNum(0),left)), self.pred)
        #         if not compareAExp(right, kty.flag()):
        #             addElem((QXComp("<=",right,kty.flag())), self.pred)

        #     self.tenv.append((ctx.spec().locus(), ctx.spec().qty()))

        # if isinstance(ctx.spec(), QXComp):
        #     print('\nleft right', ctx.spec().left(), ctx.spec().right()) #QXSingle "nat"
        #     left = ctx.spec().left().ID()
        #     right = ctx.spec().right().ID()

        #     tyx = self.fkenv[0].get(left)
        #     tyy = self.fkenv[0].get(right)

        #     if isinstance(tyx, TyQ) and isinstance(tyy, TyQ):
        #         xT = self.findLocus([QXQRange(left, QXCRange(QXNum(0),tyx.flag()))])
        #         yT = self.findLocus([QXQRange(right, QXCRange(QXNum(0),tyy.flag()))])

        #         if xT is None and yT is None:
        #             return False
        #         elif xT is None:
        #             self.tenv.append([QXQRange(left, QXCRange(QXNum(0),tyx.flag()))], yT)
        #         elif yT is None:
        #             self.tenv.append([QXQRange(left, QXCRange(QXNum(0), tyx.flag()))], xT)
        #         else:
        #             re = compareType(xT, yT)
        #             if re is None:
        #                 return False
        # return True


 #   def visitEnsures(self, ctx: QXEnsures):
        # if isinstance(ctx.spec(), QXQSpec):
        #     for elem in ctx.spec().locus():
        #         x = str(elem.ID())
        #         kty = self.fkenv[0].get(x)
        #         if not isinstance(kty, TyQ):
        #             return False

        #         left = elem.crange().left()
        #         right = elem.crange().right()

        #         if not left.accept(self) or not right.accept(self):
        #             return False

        #         if not compareAExp(left, QXNum(0)):
        #             addElem((QXComp("<=",QXNum(0),left)), self.pred)
        #         if not compareAExp(right, kty.flag()):
        #             addElem((QXComp("<=",right,kty.flag())), self.pred)

        #     self.mkenv.append((ctx.spec().locus(), ctx.spec().qty()))

        # if isinstance(ctx.spec(), QXComp):
        #     left = ctx.spec().left().ID()
        #     right = ctx.spec().right().ID()

        #     tyx = self.fkenv[0].get(left)
        #     tyy = self.fkenv[0].get(right)

        #     if isinstance(tyx, TyQ) and isinstance(tyy, TyQ):
        #         xT = self.findLocus([QXQRange(left, QXCRange(QXNum(0),tyx.flag()))])
        #         yT = self.findLocus([QXQRange(right, QXCRange(QXNum(0),tyy.flag()))])

        #         if xT is None and yT is None:
        #             return False
        #         elif xT is None:
        #             self.mkenv.append([QXQRange(left, QXCRange(QXNum(0),tyx.flag()))], yT)
        #         elif yT is None:
        #             self.mkenv.append([QXQRange(left, QXCRange(QXNum(0), tyx.flag()))], xT)
        #         else:
        #             re = compareType(xT, yT)
        #             if re is None:
        #                 return False
        # return True