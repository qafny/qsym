from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister, transpile
from qiskit.visualization import plot_histogram
from qiskit_aer import Aer
import sys
from qsym.parsers.qiskit_parser import transpile_qiskit_to_qafny_ast
from qsym.ast.ProgramVisitor import ProgramVisitor



def make_inc_gate(n: int):
    """
    Gate INC_n: |x> -> |x+1 mod 2^n> on n qubits.
    Convention: p[0] is LSB.
    """
    target = QuantumRegister(n, 'targ')
    qc = QuantumCircuit(target, name="inc")

    # Increment logic (Rippling carries from MSB down to 1)
    for j in range(n - 1, 0, -1):
        # Flip target[j] if all lower bits target[0]...target[j-1] are 1
        controls = [target[k] for k in range(j)]
        qc.mcx(controls, target[j])
            
    # The LSB always flips (toggle)
    qc.x(target[0])
    
    return qc

def hamming_weight_circuit(n: int):
    """
    Structure-preserving version for transpilation:
    - Keep H layer as one instruction (circuit.h(q))
    - Represent λ(x=>|x+1>) as a named gate INC_n
    - Use controlled INC_n per i, as a single instruction append each iteration
    """
    q = QuantumRegister(n, 'q')
    p = QuantumRegister(n, 'p')
    c = ClassicalRegister(n, 'v')
    circuit = QuantumCircuit(q, p, c)

    # q[0,n) *= H;
    circuit.h(q)
    circuit.barrier()

    # Build lambda gate once
    inc_gate = make_inc_gate(n)
    c_inc_gate = inc_gate.control(1)  # controlled on one qubit
    try:
        c_inc_gate.name = f"CINC_{n}"
    except Exception:
        pass

    # for i in [0,n): if (q[i]) { p *= INC }
    for i in range(n):
        # single append per i (structure-preserving boundary)
        circuit.append(c_inc_gate, [q[i]] + list(p))
        circuit.barrier()

    # measure(p) -> v
    circuit.measure(p, c)

    return circuit

# --- Example Execution ---
# n = 3
# qc = hamming_weight_circuit(n)

# # Use the Aer simulator
# simulator = Aer.get_backend('aer_simulator')
# transpiled_qc = transpile(qc, simulator)
# result = simulator.run(transpiled_qc).result()
# counts = result.get_counts()

# print(f"Circuit for n={n}")
# # qc.draw('mpl') # Uncomment to view graphical circuit
# print("\nMeasurement Results (Hamming Weights found):")
# print(counts)
# print(f"\n{qc.data}")
