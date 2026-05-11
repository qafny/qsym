# Source: https://quantumcomputinguk.org/tutorials/introduction-to-bell-states
# Creates circuits for all 4 Bell states

from qiskit import QuantumCircuit, transpile, ClassicalRegister, QuantumRegister
from qiskit_aer import AerSimulator
from qiskit.circuit.library import QFTGate

backend = AerSimulator() # Using local Aer simulator 

q = QuantumRegister(2,'q')
c = ClassicalRegister(2,'c')

def firstBellState():
    circuit = QuantumCircuit(q,c)

    circuit.h(q[0]) # Hadamard gate 
    circuit.cx(q[0],q[1]) # CNOT gate
    circuit.measure(q,c) # Qubit Measurment

    print(circuit)

    circuit = transpile(circuit, backend) # Rewrites the circuit to match the backend's basis gates and coupling map
    result = backend.run(circuit,shots=1024).result()
    counts = result.get_counts(circuit)

    print(counts)

def secondBellState():
    circuit = QuantumCircuit(q,c)

    circuit.x(q[0]) # Pauli-X gate 
    circuit.h(q[0]) # Hadamard gate 
    circuit.cx(q[0],q[1]) # CNOT gate
    circuit.measure(q,c) # Qubit Measurment

    print(circuit)

    circuit = transpile(circuit, backend) # Rewrites the circuit to match the backend's basis gates and coupling map
    result = backend.run(circuit,shots=1024).result()
    counts = result.get_counts(circuit)

    print(counts)

def thirdBellState():
    circuit = QuantumCircuit(q,c)

    circuit.x(q[1]) # Pauli-X gate 
    circuit.h(q[0]) # Hadamard gate 
    circuit.cx(q[0],q[1]) # CNOT gate
    circuit.measure(q,c) # Qubit Measurment

    print(circuit)

    circuit = transpile(circuit, backend) # Rewrites the circuit to match the backend's basis gates and coupling map
    result = backend.run(circuit,shots=1024).result()
    counts = result.get_counts(circuit)

    print(counts)

def fourthBellState():
    circuit = QuantumCircuit(q,c)

    circuit.x(q[1]) # Pauli-X gate 
    circuit.h(q[0]) # Hadamard gate
    circuit.z(q[0]) # Pauli-Z gate
    circuit.z(q[1]) # Pauli-Z  gate 
    circuit.cx(q[0],q[1]) # CNOT gate
    circuit.measure(q,c) # Qubit Measurment

    print(circuit)

    circuit = transpile(circuit, backend) # Rewrites the circuit to match the backend's basis gates and coupling map
    result = backend.run(circuit,shots=1024).result()
    counts = result.get_counts(circuit)

    print(counts)

print("Creating first Bell State:\n")
firstBellState()
print("\nCreating second Bell State:\n")
secondBellState()
print("\nCreating third Bell State:\n")
thirdBellState()
print("\nCreating fourth Bell State:\n")
fourthBellState()