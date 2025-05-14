
from ProgramVisitor import ProgramVisitor
from Programmer import *
from PrettyPrinter import PrettyPrinter
from typing import Dict, List, Optional, Tuple

class QEnv:
    """Environment for quantum variables with loci"""
    def __init__(self):
        # Map: variable name -> (loci, type, state)
        self.env: Dict[str, Tuple[List[QXQRange], QXQTy, QXQState]] = {}
        self.counter = 0

    def extend(self, loci: List[QXQRange], type_info: QXQTy, state: QXQState) -> str:
        """Create fresh variable in environment"""
        var_name = f"u{self.counter}"
        self.counter += 1
        self.env[var_name] = (loci, type_info, state)
        return var_name
        
    def lookup(self, var: str) -> Optional[Tuple[List[QXQRange], QXQTy, QXQState]]:
        """Look up variable binding in environment"""
        return self.env.get(var)

    def current_var(self) -> str:
        """Get most recent variable name"""
        return f"u{self.counter-1}"
    
    def __repr__(self) -> str:
        """Pretty print environment in derivation format"""
        printer = PrettyPrinter()
        result = []
        
        for var, (loci, type_info, state) in self.env.items():
            # Format loci using visitor
            loci_str = " ".join(loc.accept(printer) for loc in loci)
            
            # Format type and state using visitor
            type_str = type_info.accept(printer)
            state_str = state.accept(printer)
            
            # Build full entry
            entry = f"Env ⊢ {var} : {loci_str} : {type_str} ↦ {state_str}"
            result.append(entry)
            
        return "\n".join(result)

class SymbolicState:
    """Maintains symbolic execution state"""
    def __init__(self):
        self.q_env = QEnv()  # Quantum environment
        self.path_conds: List[QXBExp] = []  # Path conditions
        self.precond: Optional[QXQSpec] = None
        self.postcond: Optional[QXQSpec] = None

class SymbolicExecutor(ProgramVisitor):
    def __init__(self):
        super().__init__()
        self.state = SymbolicState()

    def visitMethod(self, ctx: QXMethod):
        """Entry point for symbolic execution"""
        # Process specifications
        for cond in ctx.conds():
            if isinstance(cond, QXRequires):
                self.state.precond = cond.spec()
                self._create_initial_var(cond.spec())
        #        print(f"Precondition: {self.state.precond}")
            elif isinstance(cond, QXEnsures):
                self.state.postcond = cond.spec()
         #       print(f"Postcondition: {self.state.postcond}")

        # Process statements
        for stmt in ctx.stmts():
            self.visit(stmt)
        print(repr(self.state.q_env))

        # Verify postcondition
   #     if self.state.postcond:
   #         self._verify_postcondition()

    def _create_initial_var(self, spec: QXQSpec):
        """Initialize quantum state from specification"""
        # Create initial variable in environment with all loci
        self.state.q_env.extend(
            spec.locus(),  # All register ranges
            spec.qty(),    # Type info 
            spec.state()   # Initial state
        )

    def visitAssert(self, ctx: QXAssert):
        """Handle quantum assertion: assert { ... }"""
        # 1. Extract expected spec from the assertion
        spec = ctx.spec()
        expected_loci = spec.locus()
        expected_type = spec.qty()
        expected_state = spec.state()
        print(f"Assertion: {expected_loci}, {expected_type}, {expected_state}") 

        # 2. Get current state from environment
        curr_var = self.state.q_env.current_var()
        curr_binding = self.state.q_env.lookup(curr_var)
        if not curr_binding:
            raise AssertionError("No current quantum state for assertion.")
        curr_loci, curr_type, curr_state = curr_binding

        # 3. Compare loci, type, and state
        loci_match = all(str(l1) == str(l2) for l1, l2 in zip(expected_loci, curr_loci))
        type_match = type(expected_type) == type(curr_type)
        state_match = self._states_equivalent(curr_state, expected_state)

        if not (loci_match and type_match and state_match):
            raise AssertionError(
                f"Quantum assertion failed:\n"
                f"Expected: {expected_state}\n"
                f"Got:      {curr_state}"
            )
        print("Quantum assertion passed.")

    def visitQAssign(self, ctx: QXQAssign):
        """Handle quantum assignment q *= qexp"""
        regs = [loc.ID() for loc in ctx.locus()]
        qexp = ctx.exp()
        print(ctx)
#        print(self.state.q_env)

        if isinstance(qexp, QXOracle):
            # Handle lambda operation
            self._handle_lambda(regs, qexp)
        elif isinstance(qexp, QXSingle):
            if qexp.op() == 'H':
                self._handle_had(regs, qexp)
            elif qexp.op() == 'QFT':
                self._handle_QFT(regs, qexp)
            elif qexp.op() == 'RQFT':
                self._handle_RQFT(regs, qexp)
        else:
            #measurement
            self._handle_mea(regs, qexp)

    def _handle_lambda(self, regs: List[str], oracle: QXOracle):
        """Transform state for lambda operation based on quantum type"""
        vectors = oracle.vectors()
        param = oracle.ids()
        fn = oracle.phase()
        
        curr_var = self.state.q_env.current_var()
        curr_binding = self.state.q_env.lookup(curr_var)
        
        if curr_binding:
            loci, type_info, state = curr_binding
            
            # Handle different quantum types
            if isinstance(type_info, TyEn):
                # For entangled type: transform preserving entanglement
                self._handle_lambda_en(loci, type_info, state, regs, vectors, param, fn)
            elif isinstance(type_info, TyHad):
                # For Hadamard type: transform basis states
                self._handle_lambda_had(loci, type_info, state, regs, vectors, param, fn)
            elif isinstance(type_info, TyNor):
                # For normal type: direct transformation
                self._handle_lambda_nor(loci, type_info, state, regs, vectors, param, fn)

    def _handle_had(self, regs: List[str], qexp: QXSingle):
        """Handle Hadamard operation for different quantum types"""
        curr_var = self.state.q_env.current_var()
        curr_binding = self.state.q_env.lookup(curr_var)
        if not curr_binding:
            raise AssertionError("No current quantum state for Hadamard operation.")
        loci, type_info, state = curr_binding
        print(f"loci: {loci}", f"type_info: {type_info}", f"state: {state}")

        if isinstance(type_info, TyEn):
            self._handle_had_en(loci, type_info, state, regs, qexp)
        elif isinstance(type_info, TyHad):
            self._handle_had_had(loci, type_info, state, regs, qexp)
        elif isinstance(type_info, TyNor):
            self._handle_had_nor(loci, type_info, state, regs, qexp)
    
    def _handle_had_en(self, loci, type_info, state, regs, qexp):
        """Handle Hadamard operation for entangled quantum state"""
        if isinstance(state, QXSum):
            new_kets = state.kets().copy()
            new_sums = state.sums().copy()
            
            for i, reg in enumerate(regs):
                reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
                
                # Create new summation variable j
                sum_var = 'j'
                new_sum = QXCon(sum_var, QXCRange(QXNum(0), 
                            QXBin('^', QXNum(2), QXBind('n'))))
                new_sums.append(new_sum)
                
                # Transform ket using vector helper
                curr_ket = state.kets()[reg_idx].vector()
                new_vector = self._transform_vector(curr_ket, sum_var, reg_idx, 'hadamard')
                new_kets[reg_idx] = QXSKet(new_vector)
            
            # Transform amplitude using amplitude helper
            new_amp = self._transform_amp(state, 'hadamard', sum_var='j')
            
            new_state = QXSum(sums=new_sums, amp=new_amp, kets=new_kets)
            self.state.q_env.extend(loci, type_info, new_state)
    
    def _handle_had_had(self, loci, type_info, state, regs, qexp):
        """Handle Hadamard operation for Hadamard basis state"""
        if isinstance(state, QXTensor):
            new_kets = state.kets().copy()
            
            # Transform in Hadamard basis
            for i, reg in enumerate(regs):
                reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
                
                # Transform vector using helper
                curr_ket = state.kets()[reg_idx].vector()
                new_vector = self._transform_vector(
                    curr_ket,
                    None,  # No parameter needed for Hadamard
                    reg_idx,
                    'hadamard'
                )
                new_kets[reg_idx] = QXSKet(new_vector)

            new_state = QXTensor(new_kets)
            self.state.q_env.extend(loci, type_info, new_state)

    def _handle_had_nor(self, loci, type_info, state, regs, qexp):
        """Handle Hadamard operation for normal (non-entangled) quantum state"""
        if isinstance(state, QXTensor):
            new_kets = state.kets().copy()
            
            # Transform each affected register
            for i, reg in enumerate(regs):
                reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
                
                # Transform vector using helper
                curr_ket = state.kets()[reg_idx].vector()
                new_vector = self._transform_vector(
                    curr_ket,
                    None,  # No parameter needed for Hadamard
                    reg_idx, 
                    'hadamard'
                )
                new_kets[reg_idx] = QXSKet(new_vector)

            new_state = QXTensor(new_kets)
            self.state.q_env.extend(loci, type_info, new_state)

  
              
    def _handle_lambda_en(self, loci, type_info, state, regs, vectors, params, fn):
        """Handle lambda for entangled quantum state"""
        if isinstance(state, QXSum):
            new_kets = state.kets().copy()
            
            # Transform while preserving entanglement
            for i, reg in enumerate(regs):
                if i >= len(vectors):
                    break
                reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
                # Get the lambda parameter for this vector
                param = params[i] if isinstance(params, list) else params
                new_vector = self._substitute_expr(
                    vectors[i].vector(),
                    param,
                    reg_idx,
                    'lambda'
                )
                new_kets[reg_idx] = QXSKet(new_vector)

            # Transform amplitude using amplitude helper
            new_amp = self._transform_amp(state, 'lambda', fn=fn, params=params)
            
            new_state = QXSum(sums=state.sums(), amp=new_amp, kets=new_kets)
            self.state.q_env.extend(loci, type_info, new_state)

    def _handle_lambda_had(self, loci, type_info, state, regs, vectors, params, fn):
        """Handle lambda for Hadamard basis state"""
        if isinstance(state, QXTensor):
            new_kets = state.kets().copy()
            
            # Transform in Hadamard basis
            for i, reg in enumerate(regs):
                if i >= len(vectors):
                    break
                reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
                # Transform vector in Hadamard basis
                param = params[i] if isinstance(params, list) else params
                new_vector = QXBin(
                    'H',
                    self._substitute_expr(
                        vectors[i].vector(),
                        param,
                        reg_idx,
                        'lambda'
                    ),
                    None
                )
                new_kets[reg_idx] = QXSKet(new_vector)
                
            new_state = QXTensor(new_kets)
            self.state.q_env.extend(loci, type_info, new_state)

    def _handle_lambda_nor(self, loci, type_info, state, regs, vectors, params, fn):
        """Handle lambda for normal (non-entangled) quantum state"""
        if isinstance(state, QXTensor):
            new_kets = state.kets().copy()
            
            # Transform each affected register
            for i, reg in enumerate(regs):
                if i >= len(vectors):
                    break
                reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
                # Get the lambda parameter for this vector
                param = params[i] if isinstance(params, list) else params
                new_vector = self._substitute_expr(
                    vectors[i].vector(),
                    param,
                    reg_idx,
                    'lambda'
                )
                new_kets[reg_idx] = QXSKet(new_vector)
            
            new_state = QXTensor(new_kets)
            self.state.q_env.extend(loci, type_info, new_state)




    def _transform_vector(self, vector, param: str, reg_idx: int, transform_type: str = 'lambda'):
        """
        Transform vector expressions for both lambda and hadamard operations.
        Args:
            vector: Vector expression to transform
            param: Parameter (lambda param or new sum variable)
            reg_idx: Register index
            transform_type: Type of transformation ('lambda' or 'hadamard')
        """
        curr_var = self.state.q_env.current_var()
        curr_binding = self.state.q_env.lookup(curr_var)
        if not curr_binding:
            return vector
                
        _, type_info, state = curr_binding
        
        if isinstance(vector, QXBind):
            if isinstance(type_info, TyEn) and isinstance(state, QXSum):
                curr_ket = state.kets()[reg_idx].vector()
                if transform_type == 'lambda' and param == vector.ID():
                    return QXBind(curr_ket.ID())
                elif transform_type == 'hadamard' and vector.ID() == curr_ket.ID():
                    return QXBind(param)
            return vector
                        
        elif isinstance(vector, QXBin):
            left = self._transform_vector(vector.left(), param, reg_idx, transform_type)
            right = self._transform_vector(vector.right(), param, reg_idx, transform_type)
            return QXBin(vector.op(), left, right)
        
        return vector

    def _transform_amp(self, state: QXSum, transform_type: str, **kwargs):
        """
        Transform amplitude for both lambda and hadamard operations.
        Args:
            state: Current quantum state
            transform_type: Type of transformation ('lambda' or 'hadamard')
            **kwargs: Additional arguments (fn for lambda, sum_var for hadamard)
        """
        if transform_type == 'lambda':
            fn = kwargs.get('fn')
            params = kwargs.get('params', [])
            if isinstance(fn, QXCall) and fn.ID() == 'omega':
                new_args = [self._transform_vector(exp, params[0], 0, 'lambda') 
                        for exp in fn.exps()]
                return QXBin('*', state.amp(), QXCall('ω', new_args))
            return state.amp()
        
        elif transform_type == 'hadamard':
            sum_var = kwargs.get('sum_var', 'j')
            return QXBin(
                '*',
                QXBin(
                    '*',
                    state.amp(),
                    QXBin('/', QXNum(1), 
                        QXUni('sqrt',  
                        QXBin('^', QXNum(2), 
                            QXBind('n'))))
                        ),
                QXCall('ω', [QXBin('*', QXBind(sum_var), QXBind('k')), QXNum(2)])
            )
        
        return state.amp()
    
    def _substitute_expr(self, expr, param: str = None, reg_idx: int = 0, transform_type: str = 'lambda'):
        """
        Substitute/transform expressions in quantum state context.
        Args:
            expr: Expression to transform
            param: Lambda parameter or new summation variable
            reg_idx: Index of register being transformed
            transform_type: Type of transformation ('lambda' or 'hadamard')
        """
        curr_var = self.state.q_env.current_var()
        curr_binding = self.state.q_env.lookup(curr_var)
        if not curr_binding:
            return expr
                
        _, type_info, state = curr_binding
        
        if isinstance(expr, QXBind):
            if isinstance(type_info, TyEn) and isinstance(state, QXSum):
                curr_ket = state.kets()[reg_idx].vector()
                if transform_type == 'lambda':
                    # Lambda substitution
                    if param is not None and expr.ID() == param:
                        if hasattr(curr_ket, "ID"):
                            return QXBind(curr_ket.ID())
                elif transform_type == 'hadamard':
                    # Hadamard transformation
                    if isinstance(curr_ket, QXBind) and expr.ID() == curr_ket.ID():
                        return QXBind(param)  # param is the new sum variable (e.g., 'j')
            elif isinstance(state, QXTensor):
                return state.kets()[reg_idx].vector()
            return expr
                        
        elif isinstance(expr, QXBin):
            left = self._substitute_expr(expr.left(), param, reg_idx, transform_type)
            right = self._substitute_expr(expr.right(), param, reg_idx, transform_type)
            return QXBin(expr.op(), left, right)
                    
        elif isinstance(expr, QXUni):
            next_expr = self._substitute_expr(expr.next(), param, reg_idx, transform_type)
            return QXUni(expr.op(), next_expr)
        
        elif isinstance(expr, QXCall):
            new_args = [self._substitute_expr(arg, param, reg_idx, transform_type) 
                    for arg in expr.exps()]
            return QXCall(expr.ID(), new_args)
            
        return expr
    
                

    def visitIf(self, ctx: QXIf):
        """Handle if statement"""
        # Add path condition
        self.state.path_conds.append(ctx.bexp())
        
        # Process then branch
        for stmt in ctx.stmts():
            self.visit(stmt)
            
        # Pop path condition after processing
        self.state.path_conds.pop()

    def _verify_postcondition(self):
        """Verify current state satisfies postcondition"""
        post_spec = self.state.postcond
        
        # Check quantum state matches
        for qrange in post_spec.locus():
            reg = qrange.ID()
            if reg in self.state.q_env:
                curr_state = self.state.q_env[reg]
                # Verify type matches
                if not isinstance(curr_state.type, type(post_spec.qty())):
                    raise AssertionError(f"Type mismatch for register {reg}")
                # Verify state matches
                if not self._states_equivalent(
                    curr_state.state, post_spec.state()):
                    raise AssertionError(f"State mismatch for register {reg}")

    def _states_equivalent(self, s1: QXSum, s2: QXSum) -> bool:
        """Check if two quantum states are equivalent"""
        if isinstance(s1, QXSum) and isinstance(s2, QXSum):
            # Check summation structure matches
            if len(s1.sums()) != len(s2.sums()):
                return False
            # Check amplitudes match    
            if str(s1.amp()) != str(s2.amp()):
                return False
            # Check kets match
            return all(self._kets_equivalent(k1, k2) 
                    for k1, k2 in zip(s1.kets(), s2.kets()))
        elif isinstance(s1, QXTensor) and isinstance(s2, QXTensor):
            # Check kets match for tensor states
            return all(self._kets_equivalent(k1, k2)
                    for k1, k2 in zip(s1.kets(), s2.kets()))
        return False

    def _kets_equivalent(self, k1: QXSKet, k2: QXSKet) -> bool:
        """Check if two kets are equivalent"""
        return str(k1.vector()) == str(k2.vector())