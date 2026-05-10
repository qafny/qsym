import ast
import sys
import rich
from pathlib import Path
from antlr4 import InputStream, CommonTokenStream  
from qsym.parsers.qafny_parser.ExpLexer import ExpLexer  
from qsym.parsers.qafny_parser.ExpParser import ExpParser 
from qsym.parsers.qafny_parser.ProgramTransformer import ProgramTransformer 
from qsym.qafny_ast.Programmer import *
from qsym.sp_utils import _mk_num, _mk_bind,_mk_crange,_mk_call

# Helper to create a Qafny Quantum Range: q[0, n)
def _mk_qrange(q_name, start_val, end_var_name):
    return QXQRange(
        location=q_name,
        crange=_mk_crange(start_val, end_var_name)
    )

def _resolve_exp(node):
    """
    Recursively resolves Python AST nodes into strings for Qafny.
    Handles: n, 10, n-1, q[i]
    """
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Constant):
        return str(node.value)
    if isinstance(node, ast.BinOp):
        left = _resolve_exp(node.left)
        right = _resolve_exp(node.right)
        op_map = {ast.Add: "+", ast.Sub: "-", ast.Mult: "*", ast.Div: "/", ast.FloorDiv: "//"}
        return f"({left}{op_map[type(node.op)]}{right})"
    if isinstance(node, ast.Subscript):
        # Handle q[i]
        val = _resolve_exp(node.value)
        idx = _resolve_exp(node.slice)
        return f"{val}[{idx}]"
    return "???"

class PythonToQafny(ast.NodeVisitor):
    def __init__(self):
        self.methods = [] # List[QXMethod]
        self.registers = {} # Map[name -> size_str]

        #symbol tables for semantics
        self.known_functions = {} #maps function_name -> lambda string
        self.gate_vars = {} #maps variable_name -> {"type": "base" |"ctrl", "lambda": str}

    def visit_FunctionDef(self, node: ast.FunctionDef):
        """
        Translates: def circuit(n: int)
        """
        method_id = node.name
        bindings = []

        # check for @qlambda decorators
        for dec in node.decorator_list:
            if isinstance(dec, ast.Call) and getattr(dec.func, 'id', '') == 'qlambda':
                if dec.args:
                    lambda_str = self._extract_string_from_ast(dec.args[0])
                    self.known_functions[node.name] = lambda_str
                return
        
        # parse args
        for arg in node.args.args:
            arg_name = arg.arg
            bindings.append(QXBind(arg_name, TySingle("nat")))
            self.registers['n_size'] = arg_name 

        # pre-scan body for QuantumRegister declarations
        body_stmts = []
        for stmt in node.body:
            # handle assignments like: q = QuantumRegister(n, 'q')
            if isinstance(stmt, ast.Assign) and isinstance(stmt.value, ast.Call):
                func_id = getattr(stmt.value.func, 'id', '')
                if func_id == 'QuantumRegister':
                    reg_name = stmt.targets[0].id
                    
                    # get size of quantum register
                    size_arg = stmt.value.args[0]
                    size_id = size_arg.id if isinstance(size_arg, ast.Name) else str(size_arg.value)
                    
                    self.registers[reg_name] = size_id
                    
                    # add to bindings: q: Q[n]
                    q_type = TyQ(flag=QXBind(size_id))
                    bindings.append(QXBind(reg_name, q_type))
                    continue # skip adding the Qiskit assignment to Qafny body
            
            # visit other stmts
            res = self.visit(stmt)
            if res:
                if isinstance(res, list):
                    body_stmts.extend(res)
                else:
                    body_stmts.append(res)
        
        # construct QXMethod
        q_method = QXMethod(
            id=method_id,
            axiom=False,
            bindings=bindings,
            returns=[], 
            conds=[], 
            stmts=body_stmts
        )
        self.methods.append(q_method)

    
    def visit_Assign(self, node):
        """Track which variables hold our semantic gates."""
        if not isinstance(node.value, ast.Call):
            return

        # Case A: pure arith, e.g.inc_gate = make_inc_gate(n)
        func_name = getattr(node.value.func, 'id', '')
        if func_name in self.known_functions:
            lambda_str = self.known_functions[func_name]
            for target in node.targets:
                if isinstance(target, ast.Name):
                    self.gate_vars[target.id] = {"type": "base", "lambda": lambda_str}

        # Case B: with control, e.g. c_inc_gate = inc_gate.control(1)
        elif isinstance(node.value.func, ast.Attribute):
            method_name = node.value.func.attr
            base_var = getattr(node.value.func.value, 'id', '')
            
            if method_name == 'control' and base_var in self.gate_vars:
                base_lambda = self.gate_vars[base_var]["lambda"]
                for target in node.targets:
                    if isinstance(target, ast.Name):
                        self.gate_vars[target.id] = {"type": "ctrl", "lambda": base_lambda}
    
    def visit_For(self, node: ast.For):
        """
        Translates: for i in range(n) -> QXFor
        """
        # Target: i
        iter_name = node.target.id
        
        if isinstance(node.iter, ast.Call) and getattr(node.iter.func, 'id', '') == 'range':
            args = node.iter.args
            if len(args) == 1:
                start, stop = "0", _resolve_exp(args[0])
            else:
                start, stop = _resolve_exp(args[0]), _resolve_exp(args[1])
            
            q_crange = _mk_crange(start, stop)
            
            # Body
            body_stmts = []
            for stmt in node.body:
                res = self.visit(stmt)
                if res:
                    if isinstance(res, list):
                        body_stmts.extend(res)
                    else:
                        body_stmts.append(res)

            return QXFor(
                id=iter_name,
                crange=q_crange,
                conds=[], # Invariants go here
                stmts=body_stmts
            )
        return None

    def visit_Expr(self, node: ast.Expr):
        """
        Translates expression statements like circuit.h(q)
        """
        if isinstance(node.value, ast.Call):
            res = self._handle_qspec(node.value)
            if res: return res 
            return self._handle_circuit_call(node.value)
        return None
    
    def _handle_qspec(self, call):
        """
        Translates: qspec("assert { ... }") -> QXAssert Node
        """

        func_name = getattr(call.func, 'id', '')
            
        if func_name != 'qspec':
            return None

        if not call.args: return None
        arg = call.args[0]
        
        spec_str = self._extract_string_from_ast(arg)
        
        if spec_str is None:
            print(f"Warning: qspec argument must be a string or f-string at line {call.lineno}")
            return None
        
        try:
            return self._parse_qafny_stmt(spec_str)
        except Exception as e:
            print(f"Error parsing Qafny spec at line {call.lineno}: {e}")
            return None
    

    def _extract_string_from_ast(self, node):
        """
        Reconstructs a string from Constant, Str, or JoinedStr (f-string).
        """
        # Case 1: string literal ("foo")
        if isinstance(node, ast.Constant) and isinstance(node.value, str):
            return node.value 

        # Case 2: f-string (f"foo {x}") -> JoinedStr
        elif isinstance(node, ast.JoinedStr):
            full_string = ""
            for part in node.values:
                if isinstance(part, ast.Constant):
                    full_string += part.value
                elif isinstance(part, ast.FormattedValue):
                    if isinstance(part.value, ast.Name):
                        full_string += part.value.id
                    elif isinstance(part.value, ast.Constant):
                        full_string += str(part.value.value)
                    else:
                        return None 
            return full_string
            
        return None

    def _parse_qafny_stmt(self, code: str):
        """
        Invokes the ANTLR parser on a string fragment.
        """
        input_stream = InputStream(code)
        lexer = ExpLexer(input_stream)
        stream = CommonTokenStream(lexer)
        parser = ExpParser(stream)
        
        tree = parser.stmt()    
        
        if parser.getNumberOfSyntaxErrors() > 0:
            raise ValueError(f"Syntax Error in qspec string: '{code}'")
        
        ast_builder = ProgramTransformer()
        qx_node = ast_builder.visit(tree)
        rich.print(f"\n check generated node: {qx_node}")
        return qx_node
    
    def _parse_qafny_exp(self, code: str):
        """Parses a Qafny expression string into a QXExp node (like QXOracle)."""
        input_stream = InputStream(code)
        lexer = ExpLexer(input_stream)
        stream = CommonTokenStream(lexer)
        parser = ExpParser(stream)
        
        tree = parser.expr() 
        ast_builder = ProgramTransformer()
        
        if parser.getNumberOfSyntaxErrors() > 0:
            raise ValueError(f"Syntax Error parsing oracle lambda: '{code}'")

        return ast_builder.visit(tree)

    def _handle_circuit_call(self, call):
        if not isinstance(call.func, ast.Attribute):
            return None

        op = call.func.attr # 'h', 'append', 'measure'
        
        # Case: circuit.h(q)
        if op == 'h':
            reg_name = call.args[0].id
            size = self.registers.get(reg_name, 'n')
            
            # QXQAssign(location=[QXQRange], exp=QXSingle('H'))
            loc = _mk_qrange(reg_name, 0, size)
            
            return QXQAssign(
                location=[loc], 
                exp=QXSingle(op="H")
            )
        
        elif op == 'x':
            # target[0] -> QXQIndex(id='target', index=0)
            target = _resolve_exp(call.args[0])
            return QXQAssign(location=[target], exp=QXSingle("X"))

        #translate to qxif, then we need to symbolic interpret the arithmetic at the low-level. 
        #or we can simulate the whole block/function to test the property. we chose this now.
        elif op == 'mcx':
            ctrls = _resolve_exp(call.args[0]) # e.g. "controls"
            targ = _resolve_exp(call.args[1])  # e.g. "target[j]"
        
            return QXQAssign(location=[targ], exp=QXSingle(f"MCX({ctrls})"))
        
        elif op == 'barrier':
            return None
        
        # Case: circuit.measure(p, v)
        elif op == 'measure':
            q_reg = call.args[0].id
            # c_reg = call.args[1].id # Qafny usually returns the value: v := measure(q)
            size = self.registers.get(q_reg, 'n')

            loc = _mk_qrange(q_reg, 0, size)
            
            # QXMeasure takes ids (LHS variables) and locus (RHS qubits)
            # return variable 'v' or 'res'
            return QXMeasure(
                ids=[QXBind("v")], 
                locus=[loc]
            )

        # circuit.append(c_inc_gate/c_xxx_gate, [q[i]] + list(p))
        elif op == 'append':
            gate_var_name = getattr(call.args[0], 'id', '')
            qubit_arg_node = call.args[1]
            all_qubits = self._parse_append_args(qubit_arg_node)
            
            if not all_qubits: return None
            
            # Look up the gate in our Symbol Table Memory
            if gate_var_name in getattr(self, 'gate_vars', {}):
                gate_info = self.gate_vars[gate_var_name]
                
                # Extract the math
                lambda_str = gate_info["lambda"]
                is_controlled = (gate_info["type"] == "ctrl")
                
                # Create the Qafny lambda expression dynamically
                try:
                    qafny_oracle_node = self._parse_qafny_exp(f"λ({lambda_str})")
                except Exception as e:
                    print(f"Error parsing oracle at line {call.lineno}: {e}")
                    return None

                if is_controlled:
                    # It's a controlled gate (e.g., c_inc_gate)
                    tgt_node = all_qubits[-1]    # Assume last is target
                    ctrl_nodes = all_qubits[:-1] # Everything else is control
                    condition = ctrl_nodes[0] if len(ctrl_nodes) == 1 else QXBoolLiteral(True)

                    inc_stmt = QXQAssign(
                        location=[tgt_node],
                        exp=qafny_oracle_node
                    )
                    
                    return QXIf(
                        bexp=condition,
                        stmts=[inc_stmt],
                        else_branch=[]
                    )
                else:
                    return QXQAssign(
                        location=all_qubits,
                        exp=qafny_oracle_node
                    )

            # --- FALLBACK: Standard Heuristics ---
            elif "inc" in gate_var_name or "control" in gate_var_name:
                tgt_node = all_qubits[-1]    
                ctrl_nodes = all_qubits[:-1] 
                
                if len(ctrl_nodes) == 1:
                    condition = ctrl_nodes[0]
                else:
                    condition = QXBoolLiteral(True)

                inc_stmt = QXQAssign(
                    location=[tgt_node],
                    exp=QXSingle(op="INC") # Hardcoded fallback
                )
                
                return QXIf(
                    bexp=condition,
                    stmts=[inc_stmt],
                    else_branch=[]
                )
                
        return None
    
    def _parse_append_args(self, arg_node):
        
        """
        Parses the qubit argument of circuit.append().
        Handles patterns like:
          - [q[i]] + list(p)
          - [q[0], p[1]]
          - list(target)
        
        Returns a flat list of Qafny AST nodes (QXQIndex or QXQRange).
        """
        # Case 1: Concatenation (e.g., [q[i]] + list(p))
        if isinstance(arg_node, ast.BinOp) and isinstance(arg_node.op, ast.Add):
            left_qubits = self._parse_append_args(arg_node.left)
            right_qubits = self._parse_append_args(arg_node.right)
            return left_qubits + right_qubits

        # Case 2: List Literal (e.g., [q[i]])
        if isinstance(arg_node, ast.List):
            qubits = []
            for elt in arg_node.elts:
                # elt is likely a Subscript (q[i]) or Name (q)
                qubits.extend(self._parse_locus(elt)) # Reuse your existing _parse_locus
            return qubits

        # Case 3: 'list(p)' Call
        if isinstance(arg_node, ast.Call) and getattr(arg_node.func, 'id', '') == 'list':
            # Argument is the register name 'p'
            reg_node = arg_node.args[0]
            return self._parse_locus(reg_node)

        # Case 4: Direct Register Reference (e.g. just 'p')
        if isinstance(arg_node, ast.Name):
             return self._parse_locus(arg_node)

        return []


    def _parse_locus(self, node):
        """
        Converts Python AST node (Name, Subscript, List) into a list of Qafny QXQRange.
        
        Handles:
          - q        -> [QXQRange('q', crange=[0, size))]
          - q[0]     -> [QXQRange('q', crange=[0, 1))]  (Single qubit range)
          - q[i]     -> [QXQIndex('q', index=i)]        (Symbolic index)
          - [q, p]   -> [QXQRange('q'...), QXQRange('p'...)]
        """
        
        # Case A: Whole Register (e.g., 'q')
        if isinstance(node, ast.Name):
            name = node.id
            # We look up the size from our symbol table, or default to 'n'
            size = self.registers.get(name, "n") 
            
            # Return QXQRange for the whole register: q[0, size)
            # QXCRange(left=0, right=size)
            return [QXQRange(
                location=name,
                crange=QXCRange(left=QXNum(0), right=QXBind(size))
            )]

        # Case B: Single Qubit or Slice (e.g., 'q[0]', 'q[i]', 'q[0:2]')
        elif isinstance(node, ast.Subscript):
            if isinstance(node.value, ast.Name):
                name = node.value.id
                slice_node = node.slice
                
                # 1. Handle Slice: q[0:2] -> q[0, 2)
                if isinstance(slice_node, ast.Slice):
                    lower = self._extract_index_expr(slice_node.lower)
                    upper = self._extract_index_expr(slice_node.upper)
                    
                    return [QXQRange(
                        location=name,
                        crange=QXCRange(left=lower, right=upper)
                    )]
                
                # 2. Handle Index: q[i] or q[0]
                # In Qafny, if we use it as a control (if q[i]), we want QXQIndex.
                # If we use it as a target (q[i] *= X), we might want QXQRange of len 1.
                
                idx_expr = self._extract_index_expr(slice_node)
                
                # let's return a QXQIndex if it's symbolic 'i'
                # or a Range [0, 1) if it's literal '0'.
                # Actually, Qafny often treats q[i] as a range [i, i+1) for operations.
                
                # Let's return QXQIndex, which is valid for controls (Boolean).
                # If used in an assignment, your visitor might need to wrap it in a range.
                return [QXQIndex(id=name, index=idx_expr)]

        # Case C: List Literal (e.g., [q, p])
        elif isinstance(node, ast.List):
            ranges = []
            for item in node.elts:
                ranges.extend(self._parse_locus(item))
            return ranges

        # Case D: Call to 'list(p)'
        elif isinstance(node, ast.Call) and getattr(node.func, 'id', '') == 'list':
             if node.args:
                 return self._parse_locus(node.args[0])

        return []

    def _extract_index_expr(self, node):
        """Helper to turn AST index/slice nodes into QX expressions (Num or Bind)."""
        if node is None: 
            return None # e.g. q[:n] -> lower is None
            
        # Literal Number: 0
        if isinstance(node, ast.Constant): 
            return QXNum(node.value)
        # Variable: i
        elif isinstance(node, ast.Name):
            return QXBind(node.id)
        # Binary Op: n - 1, i + 1 etc. 
        elif isinstance(node, ast.BinOp):
            # Recursively build QXBin expression
            left = self._extract_index_expr(node.left)
            right = self._extract_index_expr(node.right)
            # Map Python ast.Add/Sub to string "+"/"-"
            op_map = {ast.Add: "+", ast.Sub: "-", ast.Mult: "*", ast.Div: "/", ast.FloorDiv: "//"}
            op_str = op_map.get(type(node.op), "?")
            return QXBin(op=op_str, left=left, right=right)
            
        return QXNum(0) # Fallback

def main():
    import argparse
    import importlib.util
    import sys
    import ast
    from pathlib import Path
    import rich

    parser = argparse.ArgumentParser(description="Transpile Qiskit/Python to Qafny AST.")
    parser.add_argument("filename", help="Filename in examples/qiskit/ or full path to .py file")
    args = parser.parse_args()

    # Resolve Path
    target_path = Path(args.filename)
    
    if not target_path.exists():
        script_dir = Path(__file__).resolve().parent
        project_root = script_dir.parent.parent.parent
        qiskit_dir = project_root / "src" / "examples" / "qiskit"
        
        # Try variations
        candidates = [
            qiskit_dir / args.filename,
            qiskit_dir / f"{args.filename}.py"
        ]
        
        for cand in candidates:
            if cand.exists():
                target_path = cand
                break

    if not target_path.exists():
        rich.print(f"[bold red]Error:[/] File not found: {args.filename}")
        sys.exit(1)

    # Parse and Transpile
    rich.print(f"[bold blue]Transpiling:[/] [white]{target_path}[/]")

    #trigger PBT if @qlambda is used.
    try:
        module_name = target_path.stem
        spec = importlib.util.spec_from_file_location(module_name, target_path)
        module = importlib.util.module_from_spec(spec)
        sys.modules[module_name] = module
        
        # This executes the file. If @qlambda fails Hypothesis PBT
        spec.loader.exec_module(module)
        rich.print("[bold green]pbt Passed! No contract violations.[/]\n")
        
    except Exception as e:
        rich.print(f"[bold red]pbt Failed: Circuit violates @qlambda contract.[/]")
        import traceback
        traceback.print_exc()
        sys.exit(1) 
    
    #Transpilation
    try:
        source = target_path.read_text()
        py_ast = ast.parse(source)

        transpiler = PythonToQafny()
        transpiler.visit(py_ast)

        # Output
        if not transpiler.methods:
            rich.print("[yellow]No methods were generated. Check your visitor hooks.[/]")
        else:
            rich.print("-" * 30)
            for method in transpiler.methods:
                rich.print(method)
            rich.print("-" * 30)

    except Exception as e:
        rich.print(f"[bold red]Transpilation Failed:[/]")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
        
