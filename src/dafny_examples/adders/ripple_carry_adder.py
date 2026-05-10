from qiskit import QuantumCircuit, qasm3, transpile
from qiskit.circuit.library import QFTGate
import openqasm3
from openqasm3 import ast
from openqasm3 import printer
from qiskit_qir import to_qir_module
from qiskit.qasm3 import dumps
import math
import numpy as np

from qiskit.circuit.library import VBERippleCarryAdder

num_bits = 4
adder = VBERippleCarryAdder(num_bits, kind="fixed")
qc = QuantumCircuit(adder.num_qubits)
qc.x(1) 
qc.x(2) 

qc.append(adder, range(adder.num_qubits))

transpiled_qc = transpile(qc, basis_gates=['rx', 'ry', 'rz', 'cx', 'ccx'], optimization_level=0)
qasm_string = qasm3.dumps(transpiled_qc)

print(qasm_string)

qc0 = transpile(qc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'], optimization_level=0)
print("\n Hardware depth_0:", qc0.depth())
print("Hardware gates_0:", qc0.count_ops())

with open("vbe_ripple_opt0.qasm", "w") as f:
    qasm3.dump(qc0, f)

