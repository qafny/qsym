from antlr4 import InputStream, CommonTokenStream
import sys
import os

current_dir = os.path.dirname(os.path.realpath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.insert(0,parent_dir)
import numpy as np
from AST_Scripts.XMLExpLexer import XMLExpLexer
from AST_Scripts.XMLExpParser import XMLExpParser
from AST_Scripts.ProgramTransformer import ProgramTransformer
from AST_Scripts.ValidatorProgramVisitors import SimulatorValidator
from AST_Scripts.Retrievers import MatchCounterRetriever
from AST_Scripts.simulator import CoqNVal, CoqQVal, CoqYVal, Simulator, bit_array_to_int, to_binary_arr
import math
import qiskit
sys.path.append(parent_dir+'/qiskit-to-xmlprogrammer')
from qiskit_to_xmlprogrammer import QCtoXMLProgrammer
from qiskit import transpile
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit.converters import circuit_to_dag
from qiskit.dagcircuit import DAGInNode, DAGOpNode, DAGNode, DAGOutNode
from qiskit.visualization import dag_drawer
import graphviz
import os
import sys
from qiskit.circuit.library.arithmetic import FullAdderGate
from qiskit.circuit.library import OrGate

from AST_Scripts.XMLProgrammer import QXProgram, QXQID, QXCU, QXX, QXH, QXRZ, QXRY, QXRoot, QXNum

# Ensure graphviz is in the PATH (for dag drawing)
os.environ["PATH"] += os.pathsep + r"C:\Program Files\Graphviz\bin"

# ----- 3: 3-Qubit GHZ

qc = QuantumCircuit(3, 3)
qc.h(0)
qc.cx(0, 1)
qc.cx(1, 2)
qc.measure([0,1,2], [0,1,2])
qcEx3 = qc.copy()

# -------------------------- COMPILE TO XMLPROGRAMMER --------------------------

visitor = QCtoXMLProgrammer()

# NOTE:: test how to run the code.

def get_tree():
    #new_tree = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/mutants/mutant_38.xml")
    new_tree = visitor.startVisit(qcEx3, circuitName="Example Circuit 1", optimiseCircuit=True, showDecomposedCircuit=True)

    return new_tree

parsetree = get_tree()

from hypothesis import given, strategies as st, assume, settings, HealthCheck

def simulate_circuit(num_qubits, parse_tree, first_qubit):
    val = []
    val += [CoqNVal(first_qubit, phase=0)]
    for i in range(num_qubits-1):
        val += [CoqNVal(False,phase=0)]
    state = {"test": val}
    environment = {"test": num_qubits}

    simulator = Simulator(state, environment)
    simulator.visitProgram(parse_tree)
    new_state = simulator.state
    return new_state

@given(first_qubit = st.sampled_from([True, False]))
def test_bitwise_test_cases(first_qubit):
    indicesOfQHX = [ind for ind, item in enumerate(parsetree._exps) if type(item) == QXH]
    for index in indicesOfQHX:
        parsetree._exps[index] = QXNum(0)
    new_state = simulate_circuit(4,parsetree, first_qubit)
    vals = new_state['test']
    for val in vals:
        if isinstance(val, CoqNVal):
            print(val.getBit())
        elif isinstance(val, CoqYVal):
            print(val.getZero())
            print(val.getOne())
    # if (new_state['test'][0].getBits()[0] == new_state['test'][0].getBits()[1] == new_state['test'][0].getBits()[2]):
    #     assert True
    # else:
    #     assert False
test_bitwise_test_cases()