from qiskit.circuit.library.boolean_logic import InnerProductGate
from qiskit.circuit import Gate

gate1 = InnerProductGate(2)
gate2 = InnerProductGate(2)
gate2.params = [3]
print(gate2.__eq__(gate1))
print(gate1.num_qubits)
print(gate2.num_qubits)
print(gate1.to_matrix)
print(gate2.to_matrix)