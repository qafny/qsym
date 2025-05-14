from Programmer import *
from ProgramVisitor import ProgramVisitor
from StateManager import StateManager
from QOperator import QOperator
from ExprTransformer import ExprTransformer
from typing import List, Optional


class SymbolicExecutor(ProgramVisitor):
    def __init__(self):
        super().__init__()
        self.state_manager = StateManager()
        self.operator = QOperator(self.state_manager)

    def visitMethod(self, ctx: QXMethod):
        """Entry point for symbolic execution"""
        # Process specifications
        for bind in ctx.bindings():
            if isinstance(bind.type(), TySingle):
                self.state_manager.set_pre_bind(bind)

        for cond in ctx.conds():
            if isinstance(cond, QXRequires):
                if isinstance(cond.spec(), QXQSpec):
                    self.state_manager.set_precond_q(cond.spec())
                elif isinstance(cond.spec(), QXComp):
                    self.state_manager.set_precond_c(cond.spec())

            elif isinstance(cond.spec(), QXEnsures):
                self.state_manager.set_postcond(cond.spec())
        self.state_manager.init_snapshot()
#        print(self.state_manager.show_history())

        # Process statements
        for stmt in ctx.stmts():
            self.visit(stmt)
        print(self.state_manager.show_history())
    
    
    def visitAssert(self, ctx: QXAssert):
        """Handle quantum assertion"""
        spec = ctx.spec()
        if not self.state_manager.verify_state(spec):
            raise AssertionError(
                f"Assertion failed:\n"
                f"Expected: {spec.state()}\n"
                f"Got: {self.state_manager.get_curr_bind().state}"
            )
        print("Assertion passed")

    def visitQAssign(self, ctx: QXQAssign):
        """Handle quantum assignment q *= qexp"""
        regs = [loc.ID() for loc in ctx.locus()]
        qexp = ctx.exp()
        print(f"Visiting quantum assignment: {regs} *= {qexp}")
        
        if isinstance(qexp, QXOracle):
            self.operator.apply_lambda(regs, qexp)
        elif isinstance(qexp, QXSingle):
            if qexp.op() == 'H':
                self.operator.apply_hadamard(regs, qexp)
            elif qexp.op() == 'QFT':
                self.operator.apply_qft(regs, qexp)
            elif qexp.op() == 'RQFT':
                self.operator.apply_rqft(regs, qexp)
        else:
            self.operator.apply_mea(regs, qexp)

    def visitCast(self, ctx: QXCast):
        
        """Handle quantum cast"""
        # Process quantum type
        print(f"Visiting cast: {ctx.qty()}")
        regs = [loc.ID() for loc in ctx.locus()]
        self.operator.apply_cast(regs, ctx.qty())
          

    #think visitIf as a Control-U
    def visitIf(self, ctx: QXIf):
        #need to consider the variable binding,
        #because the conditional operation eat variables

        """Handle if statement"""
        # Add path condition
        self.state_manager.add_path_cond(ctx.bexp())
       
        # Process then branch
        for stmt in ctx.stmts():
     #       print(f"symex: {self.state_manager.path_conds}")
            self.visit(stmt)
            
        # Pop path condition after processing
        self.state_manager.remove_path_cond()
