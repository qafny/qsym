"""
This file contains a visitor which traverses a Qiskit Quantum Circuit and 
converts it into the format required for "XMLProgrammer.py".
"""

import math
import qiskit
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

from qsym.qafny_ast.Programmer import QXProgram, QXMethod, QXCU, QXSingle, QXNum, QXQAssign, QXQRange, QXCRange, QXAssert

# Ensure graphviz is in the PATH (for dag drawing)
os.environ["PATH"] += os.pathsep + r"C:\Program Files\Graphviz\bin"

# ------------------------- DAG TO XMLPROGRAMMER -------------------------------

supportedGates = ['h','x','y','z','s','sdg','t','tdg','ry','rz','u','cx','cz']
ignoredGates = ['measure']
qafny_basis = ['x', 'h', 'cx', 'ccx', 'cu', 'state_assertion'] #u in cu has to be explict for now

def decomposeToGates(qc, optimiseCircuit, gateSetToUse):
    # Unoptimised circuits are more readable.
    if optimiseCircuit:
        return transpile(qc, basis_gates=gateSetToUse + ignoredGates)
    return transpile(qc, basis_gates=gateSetToUse + ignoredGates, optimization_level=0)



def should_unroll(op):
    if op.definition is None:
        return False
    return any(instr.operation.name == "state_assertion" for instr in op.definition.data)


class QCtoXMLProgrammer:
    def __init__(self):
        self.dag = None
        self.h_buffer = []
        self.expList = []

    def flush_h_buffer(self):
        if not self.h_buffer:
                return
                
        start, end = self.h_buffer
        if end - start >= 1:
            locus = QXQRange("q", crange=QXCRange(QXNum(start), QXNum(end)))
   
        self.expList.append(QXQAssign(location=[locus], exp=QXSingle("H")))
        self.h_buffer = []

    def startVisit(
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

        
        if showInputCircuit:
            print("Input Circuit:")
            print(qc.draw())
            print()


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
        
        for node in self.dag.topological_op_nodes():
            self.dag_to_qx(node)

        self.program = QXProgram(self.expList)
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

    # def visitNode(self, node):
    #     if node in self.visitedNodes:
    #         return
    #     else:
    #         self.visitedNodes.add(node)
    #         self.dag_to_qx(node)
    #         for successor in self.dag.successors(node): # type: ignore
    #             self.visitNode(successor)


    def dag_to_qx(self, node, qubit_map=None):
        
        op = node.op    
        indices = [qubit_map[q] if qubit_map else self.dag.find_bit(q).index 
                   for q in node.qargs]
        
        #base gates
        if op.name in ["x", "qft", "h"]:
            locus = self.indices_to_qranges(indices)
            self.expList.append(QXQAssign(locus, QXSingle(op.name.upper())))
            return

       
        #virtual nodes for assertions 
        if node.name == "state_assertion":
            spec_str = op.metadata.get("assertion_str", 'true')
            locus = self.indices_to_qranges(indices)
            # Wrap the string in the AST node
            q_spec = self.parse_string_to_qspec(locus, spec_str)
            self.expList.append(QXAssert(q_spec))
            return 

        #recursive call for opaque U
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
        locus_str = ", ".join([str(l) for l in locus])
        full_qafny_str = f"{{ {locus_str} : {spec_str} }}"

        lexer = ExpLexer(InputStream(full_qafny_str))
        stream = CommonTokenStream(lexer)
        parser = ExpParser(stream)
        tree = parser.stmts()

        transformer = ProgramTransformer()
        parsed_assert = transformer.visitProgram(tree)
         
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
        start = indices
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


            

