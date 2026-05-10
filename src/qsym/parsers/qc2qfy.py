"""
This file contains a visitor which traverses a Qiskit Quantum Circuit and 
converts it into the format required for "XMLProgrammer.py".
"""
import rich
import math
import qiskit
import runpy
from qiskit import transpile
from qiskit import QuantumCircuit
from qiskit.converters import circuit_to_dag
from qiskit.dagcircuit import DAGInNode, DAGOpNode, DAGNode, DAGOutNode
from qiskit.visualization import dag_drawer
from antlr4 import *
from qsym.parsers.qafny_parser.ProgramTransformer import ProgramTransformer
from qsym.parsers.qafny_parser.ExpLexer import ExpLexer
from qsym.parsers.qafny_parser.ExpParser import ExpParser
from qsym.qafny_ast.PrettyPrinter import PrettyPrinter
import graphviz
import os
import sys
from qiskit.circuit.library.arithmetic import FullAdderGate

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
# current_dir = os.path.dirname(os.path.abspath(__file__))
# sys.path.append(os.path.join(current_dir, "PQASM"))

from qsym.qafny_ast.Programmer import QXProgram, QXMethod, QXCU, QXSingle, QXNum, QXQAssign, QXQRange, QXCRange, QXAssert, QXBind, QXQTy, QXType, QXCall, QXBin, QXFor

# Ensure graphviz is in the PATH (for dag drawing)
os.environ["PATH"] += os.pathsep + r"C:\Program Files\Graphviz\bin"

# ------------------------- DAG TO QXPROGRAMMER -------------------------------

supportedGates = ['h','x','y','z','s','sdg','t','tdg','ry','rz','u','cx','cz']
ignoredGates = ['measure']
qafny_gates = ['x', 'h', 'qft', 'u', 'state_assertion'] #u in cu has to be explict for now

def decomposeToGates(qc, optimiseCircuit, gateSetToUse):
    # Unoptimised circuits are more readable.
    if optimiseCircuit:
        return transpile(qc, basis_gates=gateSetToUse + ignoredGates)
    return transpile(qc, basis_gates=gateSetToUse + ignoredGates, optimization_level=0)



def should_unroll(op):
    if op.definition is None:
        return False
    return any(instr.operation.name == "state_assertion" for instr in op.definition.data)


class QCtoQXProgrammer:
    def __init__(self):
        self.dag = None
        self.h_buffer = []
        self.expList = []

        self.methods = []

    def flush_h_buffer(self):
        if not self.h_buffer:
                return
                
        start, end = self.h_buffer
        if end - start >= 1:
            locus = QXQRange("q", crange=QXCRange(QXNum(start), QXNum(end)))
   
        self.expList.append(QXQAssign(location=[locus], exp=QXSingle("H")))
        self.h_buffer = []

    def visit(
        self,
        qc,
        circuitName=None,
        optimiseCircuit=False,
        showDecomposedCircuit=False,
        showInputCircuit=True,
        emit_qx=True,
        gateSetToUse = supportedGates
    ):
        print()
        if circuitName is not None:
            print("------------------- COMPILING CIRCUIT: " + str(circuitName) + " -------------------")
        else:
            print("------------------- COMPILING CIRCUIT: " + "[Name Unknown]" + " -------------------")

        
        # if showInputCircuit:
        #     print("Input Circuit:")
        #     print(qc.draw())
        #     print()


        # qc = decomposeToGates(qc, optimiseCircuit, gateSetToUse)
        # if showDecomposedCircuit:
        #     print("Decomposed Circuit:")
        #     print(qc.draw())

        self.dag = circuit_to_dag(qc)

        
        # Dictionary mapping Qiskit qubits to XMLProgrammer qubits
        self.QXQubits = dict()
        for i, qubit in enumerate(self.dag.qubits):
            self.QXQubits[qubit] = QXNum(i)
        self.visitedNodes = set()
        self.expList = []

        bindings = [QXBind(id=qreg.name) for qreg in qc.qregs]
        
        for node in self.dag.topological_op_nodes():
            self.dag_to_qx(node)


        vectorized_stmts = self.vectorize_gates(self.expList)    
        optimized_stmts = self.roll_loop(vectorized_stmts)

        method = QXMethod(
            id="main",
            axiom=False,
            bindings=bindings,
            returns=[],
            conds=[],
            stmts=optimized_stmts  
        )
        self.methods.append(method)

        self.program = QXProgram(self.methods)
        print("Extracted QXProgram (AST):")
        print(self.program)

        if emit_qx:
            qafny = PrettyPrinter()
            qafny.visitProgram(self.program)
            print(f"\n Qafny Representation: \n {qafny.visitProgram(self.program)}")
        else:
            print("Qafny emission skipped; AST is available via return value.")

        print("------------------------------------------------------------")
        return self.program


    def dag_to_qx(self, node, qubit_map=None):
        
        if hasattr(node, 'operation'):
            # CircuitInstruction from recursive op.definition.data
            op = node.operation
            node_qubits = node.qubits
        else:
            # DAGOpNode from the top-level DAG
            op = node.op
            node_qubits = node.qargs 
        
        indices = [qubit_map[q] if qubit_map else self.dag.find_bit(q).index 
                   for q in node_qubits]
           
        #virtual nodes for assertions 
        if node.name == "state_assertion":
            spec_str = op.metadata.get("assertion_str", 'true')
            locus = self.indices_to_qranges(indices)
            # Wrap the string in the AST node
            q_spec = self.parse_string_to_qspec(locus, spec_str)
            self.expList.append(QXAssert(q_spec))
            return 
        
  #     primitives = ['x', 'h', 's', 'cx', 'ccx','qft']
  #     base gates
  #     if op.name in primitives:

        num_ctrls = getattr(op, 'num_ctrl_qubits', 0)

        if num_ctrls > 0:
            ctrl_locus = self.indices_to_qranges(indices[:num_ctrls])
            targ_locus = self.indices_to_qranges(indices[num_ctrls:])
            
            full_locus = ctrl_locus + targ_locus           
        else:
            full_locus = self.indices_to_qranges(indices)


        if hasattr(op, 'params') and len(op.params) > 0:
            new_method_name = op.name.replace('-', '_').replace(' ', '_')
            qx_params = []
            for p in op.params:
                try:
                    qx_params.append(QXNum(int(float(p))))
                except (ValueError, TypeError):
                    qx_params.append(QXSingle(str(p)))
            
            self.expList.append(QXQAssign(
                location=full_locus, 
                exp=QXCall(id=new_method_name, exps=qx_params)
            ))
            return
  
        self.expList.append(QXQAssign(full_locus, QXSingle(op.name.upper())))
        return

        #recursive call for opaque U, let's not dive in, will need to later
        if op.definition is not None:           
            #prepare callee map
            outer_exp_list = self.expList
            self.expList = []
            in_map = dict(zip(op.definition.qubits, indices))

            #recurse
            for sub_instr in op.definition.data:
                self.dag_to_qx(sub_instr, qubit_map=in_map)

            #another method
            method_node=QXMethod(
                id=node.name,
                axiom=False,
                bindings=[], #QXBind list for targets
                returns=[],
                conds=[], #precondition
                stmts=self.expList 
            )
            self.expList = outer_exp_list
            self.expList.append(method_node)
            
            return
    
    def parse_string_to_qspec(self, locus, spec_str):
        """
        Takes the user's assertion string and runs it through 
        the Qafny parser to get a QXSpec AST node.
        """
        # Example spec_str: "∑ v ∈ [0, 2^j) . 1/sqrt(2^j) |v⟩"
        
        # Reconstruct a valid Qafny assertion string
        # e.g. "q[0, 8) : ... "
    #    locus_str = ", ".join([str(l) for l in locus])
    #    full_qafny_str = f"{{ {locus_str} : {spec_str} }}"
        print(f"\n full_qafny_str: {spec_str}")

        lexer = ExpLexer(InputStream(spec_str))
        stream = CommonTokenStream(lexer)
        parser = ExpParser(stream)
        tree = parser.spec()

        transformer = ProgramTransformer()
        parsed_assert = transformer.visit(tree)
        if not parsed_assert:
            rich.print(f"[bold red]ANTLR Parse Error:[/] The string did not match the stmts grammar.")
            return None
         
        return parsed_assert
    
    def indices_to_qranges(self, indices):
        """
        Converts a list of indices into contiguous QXQRange objects.
        e.g., -> QXQRange(q[8, 9))
        """
        if not indices:
            return []

        indices = sorted(indices)
        ranges = []
        start = indices[0]
        prev = start

        for i in indices[1:]:
            if i == prev + 1:
                prev = i
            else:
                # Emit the contiguous block
                ranges.append(
                    QXQRange("q", crange=QXCRange(QXNum(start), QXNum(prev + 1)))
                )
                start = i
                prev = i
                
        # Emit the final block
        ranges.append(
            QXQRange("q", crange=QXCRange(QXNum(start), QXNum(prev + 1)))
        )
        return ranges          

    def infer_parameter_math(self, val_list, iterator_id):
        
        first_val = val_list[0]
        
        # constant Progression (e.g., the base '7' never changes)
        is_constant = True
        for v in val_list:
            if v != first_val:
                is_constant = False
                break
                
        if is_constant:
            # pass the single value
            return QXNum(num=first_val) 
            
        # geometric progression 
        if first_val != 0:
            ratio = val_list[1] // first_val
            is_geometric = True
            
            # verify the ratio holds true for the entire sequence
            for i in range(1, len(val_list)):
                if val_list[i] != val_list[i-1] * ratio:
                    is_geometric = False
                    break
                    
            if is_geometric:
                # build: ratio ^ k (e.g., 2^k)
                ratio_expr = QXBin(op='^', left=QXNum(num=ratio), right=QXBind(id=iterator_id))
                
                if first_val == 1:
                    return ratio_expr
                else:
                    # build: first_val * (ratio ^ k)
                    return QXBin(op='*', left=QXNum(num=first_val), right=ratio_expr)

        # If it doesn't fit a known pattern, return None
        return None
    
    def vectorize_gates(self, expList):
        optimized = []
        i = 0
        
        while i < len(expList):
            stmt = expList[i]
            
            # look for a single-qubit gate assignment
            if (isinstance(stmt, QXQAssign) and 
                isinstance(stmt.exp(), QXSingle) and 
                len(stmt.location()) == 1):
                
                gate_name = stmt.exp().op() if hasattr(stmt.exp(), 'id') else stmt.exp().op() 
                locus = stmt.location()[0]

                print(f"locus: {locus}")
                
                # ensure we have a readable integer index
                if not hasattr(locus.crange().left(), 'num'):
                    optimized.append(stmt)
                    i += 1
                    continue
                    
                start_idx = locus.crange().left().num()
                expected_next = start_idx + 1
                seq_length = 1
                
                # ─── THE LOOKAHEAD ───
                while (i + seq_length) < len(expList):
                    next_stmt = expList[i + seq_length]
                    
                    # must be an assignment of a QXSingle to 1 location
                    if not (isinstance(next_stmt, QXQAssign) and 
                            isinstance(next_stmt.exp(), QXSingle) and 
                            len(next_stmt.location()) == 1):
                        break
                        
                    # must be the exact same gate (e.g., another 'H')
                    next_gate_name = next_stmt.exp().op() if hasattr(next_stmt.exp(), 'id') else next_stmt.exp().op()
                    if next_gate_name != gate_name:
                        break
                        
                    # must act on the immediate next contiguous qubit
                    next_locus = next_stmt.location()[0]
                    if not hasattr(next_locus.crange().left(), 'num'):
                        break
                    if next_locus.crange().left().num() != expected_next:
                        break
                        
                    # must be a width of 1 (e.g., q[1, 2) )
                    if next_locus.crange().right().num() != expected_next + 1:
                        break
                        
                    expected_next += 1
                    seq_length += 1
                
                # ─── COMPRESS THE SEQUENCE ───
                if seq_length > 1:
                    # build the merged boundary: e.g., 0 to 15
                    merged_crange = QXCRange(
                        left=QXNum(num=start_idx), 
                        right=QXNum(num=start_idx + seq_length)
                    )
                    
                    # create the unified memory location
                    merged_locus = QXQRange(
                        location=locus.location(), # This keeps 'q'
                        crange=merged_crange
                    )
                    
                    # build the broadcasted assignment
                    merged_stmt = QXQAssign(
                        location=[merged_locus],
                        exp=QXSingle(gate_name) 
                    )
                    
                    optimized.append(merged_stmt)
                    i += seq_length
                    continue

            # if it's not a single gate or doesn't repeat, leave it alone
            optimized.append(stmt)
            i += 1
            
        return optimized

    def roll_loop(self, expList):
            optimized = []
            i = 0
            loop_counter = 1
            
            while i < len(expList):
                stmt = expList[i]
                
                ##Debug
                # if isinstance(stmt, QXQAssign) and isinstance(stmt.exp(), QXCall):
                #     print(f"DEBUG [Index {i}]: Found QXCall '{stmt.exp().ID()}'")
                    
                #     loci = stmt.location() 
                #     print(f"  - Location len: {len(loci)}")
                
                    # if len(loci) > 0:
                    #     ctrl_locus = loci[0]
                    #     print(f"  - Control Left Type: {type(ctrl_locus.crange().left())}")
                    #     try:
                    #         print(f"  - Control Left Value: {ctrl_locus.crange().left().num()}")
                    #         print(f"  - First Param Value: {stmt.exp().exps()}")
                    #     except Exception as e:
                    #         print(f"  - ATTRIBUTE ERROR: {e}")

                #TODO single case            
                
                # control-circuit case
                if (isinstance(stmt, QXQAssign) and 
                    isinstance(stmt.exp(), QXCall) and 
                    len(stmt.location()) == 2):
                    
                    ctrl_locus = stmt.location()[0]
                    target_locus = stmt.location()[1]
                    num_params = len(stmt.exp().exps())
                    
                    # Ensure the control locus has a readable integer starting point
                    if not hasattr(ctrl_locus.crange().left(), 'num'):
                        optimized.append(stmt)
                        i += 1
                        continue
                        
                    ctrl_start = ctrl_locus.crange().left().num()
                    
                    # Extract initial parameters to start the sequence history
                    try:
                        param_history = [[p.num() for p in stmt.exp().exps()]] 
                    except AttributeError:
                        # If a parameter is a string/symbolic instead of a number, abort rolling
                        optimized.append(stmt)
                        i += 1
                        continue
                    
                    loop_length = 1
                    
                    # ─── THE LOOKAHEAD ───
                    while (i + loop_length) < len(expList):
                        next_stmt = expList[i + loop_length]
                        
                        # must be an assignment calling a Method
                        if not (isinstance(next_stmt, QXQAssign) and isinstance(next_stmt.exp(), QXCall)):
                            break
                            
                        # structural equivalence: Must have the exact same number of parameters
                        if len(next_stmt.exp().exps()) != num_params:
                            break
                            
                        # must have exactly 2 memory locations (control, target)
                        if len(next_stmt.location()) != 2:
                            break
                            
                        # target equivalence: target register boundaries must perfectly match
                        next_target = next_stmt.location()[1]
        #                print(f"\nnext_target: {next_target}")
                        if (next_target.crange().left().num() != target_locus.crange().left().num() or
                            next_target.crange().right().num() != target_locus.crange().right().num()):
                            break
                            
                        # topology: control qubit index must increment exactly by 1
                        expected_ctrl = ctrl_start + loop_length
                        next_ctrl = next_stmt.location()[0]
                        if not hasattr(next_ctrl.crange().left(), 'num') or next_ctrl.crange().left().num() != expected_ctrl:
                            break
                            
                        # extract parameters safely
                        try:
                            param_history.append([p.num() for p in next_stmt.exp().exps()])
                        except AttributeError:
                            break
                            
                        loop_length += 1
                    
                    print(f"\n loop_length {loop_length}")
                    # only roll if we found a sequence of 3 or more
                    if loop_length > 2: 
                        dynamic_params = []
                        
                        #DEBUG READ
                        print(f"\n--- DEBUG MATH DEDUCTION (Loop Length: {loop_length}) ---")
                        for p_idx in range(num_params):
                            column_vals = [history[p_idx] for history in param_history]
                            
                            print(f"  Col {p_idx} Values: {column_vals}")
                            print(f"  Col {p_idx} Types:  {[type(v) for v in column_vals]}")
                            
                            dyn_ast_node = self.infer_parameter_math(column_vals, 'k')
                            print(f"  Col {p_idx} Inferred Node: {dyn_ast_node}")
                            
                            dynamic_params.append(dyn_ast_node)
                        print(f"--------------------------------------------------\n")
                        
                        # If the math deduction failed for ANY parameter, abort and leave unrolled
                        if None in dynamic_params:
                            optimized.append(stmt)
                            i += 1
                            continue

                        # abstract the repeating sequence under a single unified name
                        unified_method_name = f"ctrl_gate_{loop_counter}"
                        loop_counter += 1
                        
                        # build the dynamic bounds (normalized so 'k' always starts at 0)
                        range_start_ast = QXNum(0)
                        range_end_ast = QXNum(loop_length)
                        
                        # calculate physical address: q[ctrl_start + k, ctrl_start + k + 1)
                        if ctrl_start == 0:
                            left_idx = QXBind(id='k')
                        else:
                            left_idx = QXBin(op='+', left=QXNum(ctrl_start), right=QXBind('k'))
                        right_idx = QXBin(op='+', left=left_idx, right=QXNum(num=1))
                        dyn_ctrl = QXQRange('q', crange=QXCRange(left=left_idx, right=right_idx))
                        
                        # construct the loop body
                        print(f"\n dynamic_params: {dynamic_params}")
                        loop_body = QXQAssign(
                            location=[dyn_ctrl, target_locus],
                            exp=QXCall(id=unified_method_name, exps=dynamic_params) 
                        )

                        loop_crange = QXCRange(left=range_start_ast, right=range_end_ast)
                        
                        # append the final QXFor object
                        optimized.append(QXFor(
                            id='k',
                            crange=loop_crange,
                            conds=[],
                            stmts=[loop_body]
                        ))
                        
                        # jump the cursor past the flat statements we just consumed
                        i += loop_length
                        continue
                        
                # if it doesn't match the rolling criteria, append the original flat statement
                optimized.append(stmt)
                i += 1
                
            return optimized

def main():
    import argparse
    import importlib.util
    import sys
    import ast
    from pathlib import Path


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

    
    file_vars = runpy.run_path(str(target_path))

    circuits = [obj for obj in file_vars.values() if isinstance(obj, QuantumCircuit)]

    if not circuits:
        print("Error: No QuantumCircuit found in the target file.")
        sys.exit(1)

    # Grab the decomposed circuit
    target_qc = circuits[0]

    
    #Transpilation
    try:
        transpiler = QCtoQXProgrammer()
        transpiler.visit(target_qc, circuitName=target_path.name)

        # Output
        # if not transpiler.methods():
        #     rich.print("[yellow]No methods were generated. Check your visitor hooks.[/]")
        # else:
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

