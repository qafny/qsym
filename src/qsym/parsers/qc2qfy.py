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

        optimized_stmts = self.roll_loop(self.expList)

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
            print("Qafny Representation:")
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
        """
        Deduces the mathematical pattern of parameters for a normalized loop index.
        val_list: A list of integers extracted from sequential gates (e.g.,)
        """
        # 1. Constant Progression (e.g., the base '7' never changes)
        if all(v == val_list for v in val_list):
            return QXNum(val_list)
            
        # 2. Geometric Progression (e.g., the power scaling: 1, 2, 4, 8)
        is_geometric = True
        ratio = None
        if len(val_list) > 1 and val_list != 0:
            ratio = val_list // val_list
            # Verify the ratio holds true for the entire sequence
            for i in range(1, len(val_list)):
                if val_list[i] != val_list[i-1] * ratio:
                    is_geometric = False
                    break
                    
        if is_geometric and ratio is not None:
            # Formula: start_val * (ratio ^ k)
            ratio_expr = QXBin('^', QXNum(ratio), QXBind(iterator_id))
            if val_list == 1:
                return ratio_expr
            else:
                return QXBin('*', QXNum(val_list), ratio_expr)

        # If it doesn't fit a known pattern, return None so the roller aborts
        return None

    def roll_loop(self, expList):
            optimized = []
            i = 0
            loop_counter = 1
            
            while i < len(expList):
                stmt = expList[i]

                if isinstance(stmt, QXQAssign) and isinstance(stmt.exp(), QXCall):
                    print(f"DEBUG [Index {i}]: Found QXCall '{stmt.exp().ID()}'")
                    
                    loci = stmt.location() 
                    print(f"  - Location len: {len(loci)}")
                
                    if len(loci) > 0:
                        ctrl_locus = loci[0]
                        print(f"  - Control Left Type: {type(ctrl_locus.crange().left())}")
                        try:
                            print(f"  - Control Left Value: {ctrl_locus.crange().left().num()}")
                            print(f"  - First Param Value: {stmt.exp().exps().num()}")
                        except Exception as e:
                            print(f"  - ATTRIBUTE ERROR: {e}")

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
                        next_target = next_stmt.location()
                        if (next_target.crange().left().num() != target_locus.crange().left().num() or
                            next_target.crange().right().num() != target_locus.crange().right().num()):
                            break
                            
                        # topology: control qubit index must increment exactly by 1
                        expected_ctrl = ctrl_start + loop_length
                        next_ctrl = next_stmt.location()
                        if not hasattr(next_ctrl.crange().left(), 'num') or next_ctrl.crange().left().num() != expected_ctrl:
                            break
                            
                        # extract parameters safely
                        try:
                            param_history.append([p.num for p in next_stmt.exp.exps])
                        except AttributeError:
                            break
                            
                        loop_length += 1
                    
                    
                    # only roll if we found a sequence of 3 or more
                    if loop_length > 2: 
                        dynamic_params = []
                        
                        # analyze each parameter's column mathematically
                        for p_idx in range(num_params):
                            column_vals = [history[p_idx] for history in param_history]
                            dyn_ast_node = self.infer_parameter_math(column_vals, 'k')
                            dynamic_params.append(dyn_ast_node)
                        
                        # if the math deduction failed for any parameter, abort and leave unrolled
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
                        left_idx = QXBin('+', QXNum(ctrl_start), QXBind('k'))
                        right_idx = QXBin('+', left_idx, QXNum(1))
                        dyn_ctrl = QXQRange('q', crange=QXCRange(left_idx, right_idx))
                        
                        # construct the loop body
                        loop_body = QXQAssign(
                            location=[dyn_ctrl, target_locus],
                            exp=QXCall(id=unified_method_name, exps=dynamic_params) 
                        )
                        
                        # append the final QXFor object
                        optimized.append(QXFor(
                            iterator_id='k',
                            range_start=range_start_ast,
                            range_end=range_end_ast,
                            body_stmts=[loop_body]
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

