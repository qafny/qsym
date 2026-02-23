"""
This file contains library circuits from Qiskit to be compiled into
XMLProgrammer format. Run this file to compile them.

"""

# --------------------------------- IMPORTS ------------------------------------
import math
import numpy as np
import qiskit
import os
import sys
import graphviz
from qiskit_to_xmlprogrammer import QCtoXMLProgrammer

# Qiskit imports for circuit creation
from qiskit import QuantumCircuit
from qiskit.circuit.library import QFT, EfficientSU2, GroverOperator, InnerProduct, FourierChecking, LinearAmplitudeFunction, PhaseOracle, GraphState
from qiskit.circuit.library.arithmetic import FullAdderGate

# The below lines were used to ensure PATH in windows has the necessary file path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
# current_dir = os.path.dirname(os.path.abspath(__file__))
# sys.path.append(os.path.join(current_dir, "PQASM"))

# Ensure graphviz is in the PATH (for dag drawing)
os.environ["PATH"] += os.pathsep + r"C:\Program Files\Graphviz\bin"

# -------------------------- QISKIT LIBRARY CIRCUITS ---------------------------

# 1: Half Adder

# Create a quantum circuit with 4 qubits:
# 1, 2 are inputs qubits, 3 is carry-in, 4 is the output (a+b+carry-in)
qc = QuantumCircuit(4)  # 4 qubits for a single 1-bit full adder
qc.append(FullAdderGate(num_state_qubits=1), [0, 1, 2, 3])  # no argument, just 1-bit adder
qcEx1 = qc.copy()

# 2: linear pauli rotations
# based on https://github.com/Qiskit/qiskit/blob/main/qiskit/circuit/library/arithmetic/linear_pauli_rotations.py
num_qubits = 6
circuit = QuantumCircuit(num_qubits)

# build the circuit
qr_state = circuit.qubits[:num_qubits - 1]
qr_target = circuit.qubits[-1]
circuit.rx(0, qr_target)
for i, q_i in enumerate(qr_state):
    circuit.crx(1 * pow(2, i), q_i, qr_target)
# if self.basis == "x":
#     circuit.rx(self.offset, qr_target)
# elif self.basis == "y":
#     circuit.ry(self.offset, qr_target)
# else:  # 'Z':
#     circuit.rz(self.offset, qr_target)

# for i, q_i in enumerate(qr_state):
#     if self.basis == "x":
#         circuit.crx(self.slope * pow(2, i), q_i, qr_target)
#     elif self.basis == "y":
#         circuit.cry(self.slope * pow(2, i), q_i, qr_target)
#     else:  # 'Z'
#         circuit.crz(self.slope * pow(2, i), q_i, qr_target)
qcEx2 = circuit.copy()


# 3: QFT Circuit (and inverse)
qcEx3a = QFT(5, approximation_degree=0, inverse=False)
qcEx3b = QFT(3, inverse=True, do_swaps=True) 

# 4: Grover
oracle = QuantumCircuit(2)
oracle.z(0)
qcEx4 = GroverOperator(oracle, insert_barriers=True)

# 5: Inner Product
# Computers the inner product of two binary vectors of size n
qcEx5 = InnerProduct(3)

# 6: EfficientSU2
# Note: This circuit is parameterised - ie, it contains parameters that come from
# Outside the circuit itself, but are set externally. We set random values here.
qcEx6 = EfficientSU2(3, reps=1)
params = np.random.rand(qcEx6.num_parameters)
param_dict = {paramKey: paramVal for paramKey, paramVal in zip(qcEx6.parameters, params)}
qcEx6 = qcEx6.assign_parameters(param_dict)



# 7: Fourier Checking
qcEx7 = FourierChecking([1,1,1,-1], [1,-1,1,-1])

# 8: Linear Amplitude Function
qcEx8 = LinearAmplitudeFunction(3, slope=2, offset=4, domain=(0,3), image=(0,10))

# 9: Phase Oracle
qcEx9 = PhaseOracle("(a | (a & b) | (c | d))")

# 10: Graph
adjacency_matrix = np.array([[0, 1, 0, 0],
                           [1, 0, 1, 1],
                           [0, 1, 0, 1],
                           [0, 1, 1, 0]])
qcEx10 = GraphState(adjacency_matrix)


# -------------------------- COMPILE TO XMLPROGRAMMER --------------------------

visitor = QCtoXMLProgrammer()
visitor.startVisit(qcEx1, circuitName="Example 1: Half Adder")
visitor.startVisit(qcEx2, circuitName="Example 2: Linear Pauli Rotations")
visitor.startVisit(qcEx3a, circuitName="Example 3a: QFT")
visitor.startVisit(qcEx3b, circuitName="Example 3b: QFT Inverse")
visitor.startVisit(qcEx4, circuitName="Example 4: Grover Operator")
visitor.startVisit(qcEx5, circuitName="Example 5: Inner Product")
visitor.startVisit(qcEx6, circuitName="Example 6: EfficientSU2")
visitor.startVisit(qcEx7, circuitName="Example 7: Fourier Checking")
visitor.startVisit(qcEx8, circuitName="Example 8: Linear Amplitude Function")
visitor.startVisit(qcEx9, circuitName="Example 9: Phase Oracle")
visitor.startVisit(qcEx10, circuitName="Example 10: Graph State")