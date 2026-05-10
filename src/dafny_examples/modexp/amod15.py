from qiskit import QuantumCircuit, qasm3, transpile
from qiskit.circuit.library import QFTGate
import openqasm3
from openqasm3 import ast
from openqasm3 import printer
from qiskit_qir import to_qir_module
from qiskit.qasm3 import dumps
import numpy as np


def c_amod15(a, power):    
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
    U = U.to_gate()
    U.name = f"{a}^{power} mod 15"
    c_U = U.control()
    return c_U


def qft_inverse(n):
    return QFTGate(num_qubits=n).inverse()




def shors(a, N_COUNT):

    qc = QuantumCircuit(N_COUNT + 4, N_COUNT)

    # Initialize counting qubits
    # in state |+>
    qc.h(range(N_COUNT))
    #with qc.for_loop(range(N_COUNT)) as i:
    #    qc.h(i)

    # And auxiliary register in state |1>
    qc.x(N_COUNT)

    # Do controlled-U operations
    #with qc.for_loop(range(N_COUNT)) as q:
    for q in range(N_COUNT):
        qc.append(c_amod15(a, 2**q),
                [q] + [i+N_COUNT for i in range(4)])
    # custom_gate = c_amod15(a, 2**q)
    # custom_gate.name = f"c_amod15_pow_{q}"
    # qc.append(custom_gate, [q] + [i+N_COUNT for i in range(4)])
    

    #inverse-QFT
    qc.append(qft_inverse(N_COUNT), range(N_COUNT))

    ##Measure circuit
    #qc.measure(range(N_COUNT), range(N_COUNT))
    return qc
qc = shors(7, 8)
qasm_str = dumps(qc)
print(qasm_str)



print("\nHardware depth_org:", qc.depth())
print("Hardware gates_org:", qc.count_ops())
print("Hardware gates_org:", qc.decompose().count_ops())

real_qc3 = transpile(qc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'], optimization_level=3)
print("\nHardware depth_3:", real_qc3.depth())
print("Hardware gates_3:", real_qc3.count_ops())

real_qc2 = transpile(qc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'], optimization_level=2)
print("\nHardware depth_2:", real_qc2.depth())
print("Hardware gates_2:", real_qc2.count_ops())

real_qc1 = transpile(qc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'], optimization_level=1)
print("\n Hardware depth_1:", real_qc1.depth())
print("Hardware gates_1:", real_qc1.count_ops())

real_qc0 = transpile(qc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'], optimization_level=0)
print("\n Hardware depth_0:", real_qc0.depth())
print("Hardware gates_0:", real_qc0.count_ops())


module, entry_points = to_qir_module(real_qc0)

# with open("cir_opt0.ll", "w") as f:
#     f.write(str(module))

# with open("cir_opt0.bc", "wb") as f:
#     f.write(module.bitcode)
    

with open("cir_org.qasm", "w") as f:
    qasm3.dump(qc, f)


with open("cir_opt0.qasm", "w") as f:
    qasm3.dump(real_qc0, f)


with open("cir_opt1.qasm", "w") as f:
    qasm3.dump(real_qc1, f)


with open("cir_opt2.qasm", "w") as f:
    qasm3.dump(real_qc2, f)


with open("cir_opt3.qasm", "w") as f:
    qasm3.dump(real_qc3, f)



#save files
# qc_transpiled_0 = transpile(qc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'])

# qc_transpiled_1 = transpile(qc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'], optimization_level=1)

# qasm_string = qasm3.dumps(qc_transpiled_0)
# program_ast = openqasm3.parser.parse(qasm_string)
#print(program_ast)
# for statement in program_ast.statements:
#     if isinstance(statement, ast.QuantumGate):
#         print(f"Gate: {statement.name}")

#print(qasm_string)

# qc_transpiled_3 = transpile(qc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'], optimization_level=2)

# qc_transpiled_3 = transpile(qc, basis_gates=['rz', 'ry', 'rx', 'cx', 'ccx', 'x', 'h'], optimization_level=3)

