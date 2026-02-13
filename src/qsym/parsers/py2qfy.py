import ast
from qsym.ast.Programmer import *
from qsym.sp_utils import _mk_num, _mk_bind,_mk_crange,_mk_call
import sys
from pathlib import Path
import rich

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
        op_map = {ast.Add: "+", ast.Sub: "-", ast.Mult: "*", ast.Div: "/"}
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

    def visit_FunctionDef(self, node: ast.FunctionDef):
        """
        Translates: def circuit(n: int)
        Note: The hook MUST be named visit_FunctionDef
        """
        method_id = node.name
        bindings = []
        
        # 1. Parse Arguments (e.g., n: int)
        for arg in node.args.args:
            arg_name = arg.arg
            bindings.append(QXBind(arg_name, TySingle("nat")))
            self.registers['n_size'] = arg_name 

        # 2. Pre-scan body for QuantumRegister declarations
        body_stmts = []
        for stmt in node.body:
            # Handle Assignments like: q = QuantumRegister(n, 'q')
            if isinstance(stmt, ast.Assign) and isinstance(stmt.value, ast.Call):
                func_id = getattr(stmt.value.func, 'id', '')
                if func_id == 'QuantumRegister':
                    reg_name = stmt.targets[0].id
                    # Get size (e.g., 'n' from QuantumRegister(n, ...))
                    size_arg = stmt.value.args[0]
                    size_id = size_arg.id if isinstance(size_arg, ast.Name) else str(size_arg.value)
                    
                    self.registers[reg_name] = size_id
                    
                    # Add to bindings: q: Q[n]
                    q_type = TyQ(flag=QXBind(size_id))
                    bindings.append(QXBind(reg_name, q_type))
                    continue # Skip adding the Qiskit assignment to Qafny body
            
            # Visit other statements normally
            res = self.visit(stmt)
            if res:
                if isinstance(res, list):
                    body_stmts.extend(res)
                else:
                    body_stmts.append(res)
        
        # 3. Construct QXMethod
        q_method = QXMethod(
            id=method_id,
            axiom=False,
            bindings=bindings,
            returns=[], 
            conds=[], 
            stmts=body_stmts
        )
        self.methods.append(q_method)

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
            return self._handle_circuit_call(node.value)
        return None

    def _handle_circuit_call(self, call):
        if not isinstance(call.func, ast.Attribute):
            return None

        op = call.func.attr # 'h', 'append', 'measure'
        
        # Case: circuit.h(q)
        if op == 'h':
            reg_name = call.args[0].id
            size = self.registers.get(reg_name, 'n')
            
            # QXQAssign(location=[QXQRange], exp=QXSingle('H'))
            # location is a list of QXQRange
            loc = _mk_qrange(reg_name, 0, size)
            
            return QXQAssign(
                location=[loc], 
                exp=QXSingle(op="H")
            )
        
        elif op == 'x':
            # target[0] -> QXQIndex(id='target', index=0)
            target = _resolve_exp(call.args[0])
            return QXQAssign(location=[target], exp=QXSingle("X"))

        #need to translate to qxif
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
            
            # In your AST, QXMeasure takes ids (LHS variables) and locus (RHS qubits)
            # We assume implicit return variable 'v' or 'res'
            return QXMeasure(
                ids=[QXBind("v")], 
                locus=[loc]
            )

        # Case: circuit.append(c_inc, ...) -> Transformed to If + Gate
        elif op == 'append':
            # Logic for: circuit.append(c_inc_gate, [q[i]] + list(p))
            # Heuristic: Detect 'controlled' in name
            gate_name = call.args[0].id
            
            if "inc" in gate_name or "control" in gate_name:
                # We need to extract the loop variable 'i' from arguments
                # args[1] is the list of qubits. In Python AST this is complex.
                # We will simplify and assume we are inside the 'for i' loop known context
                # or just hardcode the transformation for this example.
                
                # Construct: if (q[i])
                # QXQIndex(id='q', index=QXBind('i'))
                condition = QXQIndex(id="q", index=QXBind("i"))
                
                # Construct Body: p *= INC
                # Target p[0, n)
                p_loc = _mk_qrange("p", 0, "n")
                
                # Operation: We map 'inc_gate' to a QXSingle op named "INC"
                # (Since AST doesn't have a dedicated Lambda expression in QXExp yet)
                inc_stmt = QXQAssign(
                    location=[p_loc],
                    exp=QXSingle(op="INC") 
                )
                
                # Return QXIf
                return QXIf(
                    bexp=condition,
                    stmts=[inc_stmt],
                    else_branch=[]
                )
                
        return None
    
def main():
    import argparse
    parser = argparse.ArgumentParser(description="Transpile Qiskit/Python to Qafny AST.")
    parser.add_argument("filename", help="Filename in examples/qiskit/ or full path to .py file")
    args = parser.parse_args()

    # 1. Resolve Path
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

    # 2. Parse and Transpile
    rich.print(f"[bold blue]Transpiling:[/] [white]{target_path}[/]")
    try:
        source = target_path.read_text()
        py_ast = ast.parse(source)

        transpiler = PythonToQafny()
        transpiler.visit(py_ast)

        # 3. Output
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
        
