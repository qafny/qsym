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
from qiskit.circuit.library.arithmetic import FullAdderGate, PiecewiseChebyshevGate
from qiskit.circuit.library import OrGate
from AST_Scripts.XMLProgrammer import QXProgram, QXQID, QXCU, QXX, QXH, QXRZ, QXRY, QXRoot, QXNum

# Ensure graphviz is in the PATH (for dag drawing)
os.environ["PATH"] += os.pathsep + r"C:\Program Files\Graphviz\bin"

qc = QuantumCircuit(8,5)
linAmplitudeGate = PiecewiseChebyshevGate(f_x=3.0, num_state_qubits=6, degree=3,breakpoints=[2], label = 'test')
qc.append(linAmplitudeGate, [0,1,2,3,4,5,6,7])
qcEx1 = qc.copy()
# -------------------------- COMPILE TO XMLPROGRAMMER --------------------------

visitor = QCtoXMLProgrammer()

# NOTE:: test how to run the code.

def get_tree():
    #new_tree = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/mutants/mutant_38.xml")
    new_tree = visitor.startVisit(qcEx1, circuitName="Example Circuit 1", optimiseCircuit=True, showDecomposedCircuit=True)
    valid_tree = True

    # try:
    #     # Validation of the Constraints.
    #     # Added per Dr. Li's suggestion on 11/16 to scoop out the validator behaviour out of the simulator as there can be
    #     # programs which does not always need to follow constraints like only having 1 app tag.
    #     validator = SimulatorValidator()
    #     validator.visitProgram((new_tree))

    #     # Non-Decreasing Recursive Fixed Point Factor Check
    # except Exception as e:
    #     print('\n ==============', e, '==============')
    #     valid_tree = False

    # retriever = MatchCounterRetriever()
    # retriever.visitProgram(new_tree)
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
    # pt_output = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/cl_adder_good.xml")
    # print('pt_output', pt_output)
    # print('pt_output type', type(pt_output))
    indicesOfQHX = [ind for ind, item in enumerate(parsetree._exps) if type(item) == QXH]
    for index in indicesOfQHX:
        parsetree._exps[index] = QXNum(0)
    new_state = simulate_circuit(8,parsetree)
    # calculated = bit_array_to_int(new_state.get('ya')[0].getBits(), na)
    # insts.append((na, expected, calculated))

    return new_state
print(process_bitwise_test_cases()['test'][0].getBits())