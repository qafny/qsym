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
from qiskit.circuit.library.arithmetic import FullAdderGate
from qiskit.circuit.library import OrGate

from AST_Scripts.XMLProgrammer import QXProgram, QXQID, QXCU, QXX, QXH, QXRZ, QXRY, QXRoot, QXNum

# Ensure graphviz is in the PATH (for dag drawing)
os.environ["PATH"] += os.pathsep + r"C:\Program Files\Graphviz\bin"

# --------------------------- EXAMPLE CIRCUITS ---------------------------------

# ----- 1: Common gates

qc = QuantumCircuit(2, 2)
qc.h(0)
qc.cx(0, 1)
qc.h(1)
qc.x(1)
qc.measure([0,1], [0,1])
qcEx1 = qc.copy()

# dag_img = dag_drawer(dagEx1, style="color")
# dag_img.save('dagEx1.png')

# ----- 2: All qiskit gates

qc = QuantumCircuit(3, 1)
qc.h(0)
qc.cx(0, 1)
qc.x(2)
qc.z(2)
qc.s(1)
qc.t(0)
qc.cz(1, 2)
qc.sdg(1)
qc.tdg(0)
qc.y(0)
qcEx2 = qc.copy()

# ----- 3: 3-Qubit GHZ

qc = QuantumCircuit(3, 3)
qc.h(0)
qc.cx(0, 1)
qc.cx(1, 2)
qc.measure([0,1,2], [0,1,2])
qcEx3 = qc.copy()

# ---- 4: inner product gates
# gate1 = InnerProductGate(4)
# gate2 = InnerProductGate(4)
# gate2 = gate2.power(4.0)

# 5: OrGate test
testGate = OrGate(3)
qc = QuantumCircuit(QuantumRegister(4), ClassicalRegister(2))
qc.h(0)
qc.ry(np.pi,1)
qc.append(testGate, [0,1,2,3])
qc.measure(3, 0)
qc.measure(1,1)
qcEx4 = qc.copy()
# -------------------------- COMPILE TO XMLPROGRAMMER --------------------------

visitor = QCtoXMLProgrammer()

# NOTE:: test how to run the code.

def get_tree():
    #new_tree = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/mutants/mutant_38.xml")
    new_tree = visitor.startVisit(qcEx3, circuitName="Example Circuit 1", optimiseCircuit=True, showDecomposedCircuit=True)
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

def simulate_circuit(num_qubits, parse_tree, first_qubit):
    state = dict(
        {"test": [CoqNVal([first_qubit]+([False] * (num_qubits-1)), phase=0)]
         })
    environment = dict(
        {"xa": num_qubits
         })

    simulator = Simulator(state, environment)
    simulator.visitProgram(parse_tree)
    new_state = simulator.state
    return new_state

@given(first_qubit = st.sampled_from([True, False]))
def test_bitwise_test_cases(first_qubit):
    # pt_output = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/cl_adder_good.xml")
    # print('pt_output', pt_output)
    # print('pt_output type', type(pt_output))
    indicesOfQHX = [ind for ind, item in enumerate(parsetree._exps) if type(item) == QXH]
    for index in indicesOfQHX:
        parsetree._exps[index] = QXNum(0)
    new_state = simulate_circuit(4,parsetree, first_qubit)
    # calculated = bit_array_to_int(new_state.get('ya')[0].getBits(), na)
    # insts.append((na, expected, calculated))
    print(new_state['test'][0].getBits())
    if (new_state['test'][0].getBits()[0] == new_state['test'][0].getBits()[1] == new_state['test'][0].getBits()[2]):
        assert True
    else:
        assert False
test_bitwise_test_cases()