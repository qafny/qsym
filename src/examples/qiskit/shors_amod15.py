from qiskit import QuantumCircuit, transpile
from qiskit.transpiler.passes.synthesis.high_level_synthesis import HLSConfig
from qiskit.converters import circuit_to_dag, dag_to_circuit
from qiskit.circuit.library import QFT
from qiskit.visualization import dag_drawer
from qsym.spec_api import qlambda
from qsym.spec_api import qspec
from qsym.types import qidx, qnum
import numpy as np
from hypothesis import assume
from assertion import StateAssertion


#Assumptions: user understands the Qafny syntax. 
#User needs to write their intented functionality for each function with Qafny syntax. 

def c_amod15(a, power):
    #need postcondition provided by user.
    """Controlled multiplication by a mod 15"""
    if a not in [2,4,7,8,11,13]:
        raise ValueError("'a' must be 2,4,7,8,11 or 13")
    U = QuantumCircuit(4)
    for _iteration in range(power):
        if a in [2,13]:
            U.swap(2,3)
            U.swap(1,2)
            U.swap(0,1)
        if a in [7,8]:
            U.swap(0,1)
            U.swap(1,2)
            U.swap(2,3)
        if a in [4, 11]:
            U.swap(1,3)
            U.swap(0,2)
        if a in [7,11,13]:
            for q in range(4):
                U.x(q)

    my_assert = StateAssertion("aux == (aux * 7) % 15", num_qubits=4)
    U.append(my_assert, range(4))
    U = U.to_gate()
    U.name = f"{a}^{power} mod 15"
    
    c_U = U.control()
    return c_U

def qft_dagger(n):
    """n-qubit QFTdagger the first n qubits in circ"""
    qc = QuantumCircuit(n)
    # Don't forget the Swaps!
    for qubit in range(n//2):
        qc.swap(qubit, n-qubit-1)
    for j in range(n):
        for m in range(j):
            qc.cp(-np.pi/float(2**(j-m)), m, j)
        qc.h(j)
    qc.name = "QFT†"
    return qc

def shors_circuit(a: int, N_COUNT: int):
    qc = QuantumCircuit(N_COUNT + 4, N_COUNT)

    # Initialize counting qubits
    # in state |+>
    for q in range(N_COUNT):
        qc.h(q)

    # And auxiliary register in state |1>
    qc.x(N_COUNT)

    # Do controlled-U operations
    for q in range(N_COUNT):
        qc.append(c_amod15(a, 2**q),[q] + [i+N_COUNT for i in range(4)])
        # if (q[i]) { p[0, n) *= λ (x => |base ^ (2 ^ i) * x % N⟩); 
    assertion_str = "q[0, N_COUNT) : en ↦ ∑ j ∈ [0, 2) . 1/sqrt(2) . |j⟩**n"
    qc.append(StateAssertion(assertion_str, N_COUNT), range(N_COUNT))

    # Do inverse-QFT
    qc.append(qft_dagger(N_COUNT), range(N_COUNT))

    # Measure circuit
#    qc.measure(range(N_COUNT), range(N_COUNT))'
#    qc.draw(fold=-1)  # -1 means 'do not fold'
    return qc

def main():

    qc = shors_circuit(7, 15)

    #TODO need to distinguish built-in gates and custom gates
    cc = qc.decompose(gates_to_decompose=[g.operation for g in qc.data if "mod 15" in g.operation.name])
    print(cc.draw())
    dag = circuit_to_dag(cc)
    #dag_drawer(dag)
    for node in dag.topological_op_nodes():
        num_ctrl = getattr(node.op, 'num_ctrl_qubits', 0)
        print(node.qargs, node.num_clbits, node.num_qubits, num_ctrl)
        print(node.name, node.label, node.params)

#    oc = qc.decompose()
#    print(oc.draw())
    

    #transpile can't do custom gates
    #real_qc0 = transpile(cc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h', 'state_assertion'], optimization_level=3)
    real_qc0 = transpile(cc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'], optimization_level=1)
    print("\n Hardware depth_0:", real_qc0.depth())
    print("Hardware gates_0:", real_qc0.count_ops())
    #for inst, qargs, cargs in real_qc0.data:
    #    print(f"Name: {inst.name}, Label: {inst.label}, Params: {inst.params}")

if __name__ == '__main__':
    main()

    