from qiskit import QuantumCircuit
from qiskit.circuit.library import UGate
import numpy as np

def main():
    qc = QuantumCircuit(5)

    theta, phi, lam = np.pi/2, 0, np.pi
    u_gate = UGate(theta, phi, lam)

    c4u = u_gate.control(4)
    c4u.name = "cccc_u"

    c4u.definition = None

    qc.append(c4u, [0, 1, 2, 3, 4])

    decomposed_qc = qc.decompose()
    
    return decomposed_qc

final_circuit = main()