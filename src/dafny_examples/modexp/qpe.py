from qiskit import QuantumCircuit, qasm3, transpile
from qiskit.circuit.library import QFTGate
import openqasm3
from openqasm3 import ast
from openqasm3 import printer
from qiskit_qir import to_qir_module
from qiskit.qasm3 import dumps
import math
import numpy as np


qpe = QuantumCircuit(4, 3)

# Apply H-Gates to counting qubits:
for qubit in range(3):
    qpe.h(qubit)

# Prepare our eigenstate |psi>:
qpe.x(3)
qpe.global_phase = np.pi / 2 

# Do the controlled-U operations:
angle = 2*math.pi/3
repetitions = 1
for counting_qubit in range(3):
    for i in range(repetitions):
        qpe.cp(angle, counting_qubit, 3);
    repetitions *= 2

# Do the inverse QFT:
qpe = qpe.compose(QFTGate(3).inverse(), [0,1,2])

qasm_string = qasm3.dumps(qpe)

print(qasm_string)


qc0 = transpile(qpe, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'], optimization_level=0)
print("\n Hardware depth_0:", qc0.depth())
print("Hardware gates_0:", qc0.count_ops())


with open("qpe_org.qasm", "w") as f:
    qasm3.dump(qpe, f)


with open("qpe_opt0.qasm", "w") as f:
    qasm3.dump(qc0, f)