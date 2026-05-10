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
from AST_Scripts.simulator import CoqNVal, CoqQVal, Simulator, bit_array_to_int, to_binary_arr
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
from qiskit.circuit.library.arithmetic import FullAdderGate, ExactReciprocalGate
from qiskit.circuit.library import OrGate

from AST_Scripts.XMLProgrammer import QXProgram, QXQID, QXCU, QXX, QXH, QXRZ, QXRY, QXRoot, QXNum

# Ensure graphviz is in the PATH (for dag drawing)
os.environ["PATH"] += os.pathsep + r"C:\Program Files\Graphviz\bin"

qc = QuantumCircuit(5,5)
linAmplitudeGate = ExactReciprocalGate(num_state_qubits=3, scaling=4.0)
qc.append(linAmplitudeGate, [0,1,2,3])
qcEx1 = qc.copy()
# -------------------------- COMPILE TO XMLPROGRAMMER --------------------------

visitor = QCtoXMLProgrammer()


def get_tree():
    new_tree = visitor.startVisit(qcEx1, circuitName="Example Circuit 1", optimiseCircuit=True, showDecomposedCircuit=True)
    valid_tree = True
    return new_tree, valid_tree

parsetree = get_tree()[0]

from hypothesis import given, strategies as st, assume, settings, HealthCheck

def simulate_circuit(num_qubits, parse_tree):
    state = dict(
        {"test": [CoqNVal([False]+([False] * (num_qubits-1)), phase=0)]
         })
    environment = dict(
        {"xa": num_qubits
         })

    simulator = Simulator(state, environment)
    simulator.visitProgram(parse_tree)
    new_state = simulator.state
    return new_state

def process_bitwise_test_cases():
    indicesOfQHX = [ind for ind, item in enumerate(parsetree._exps) if type(item) == QXH]
    for index in indicesOfQHX:
        parsetree._exps[index] = QXNum(0)
    new_state = simulate_circuit(5,parsetree)

    return new_state
print(process_bitwise_test_cases()['test'][0].getBits())