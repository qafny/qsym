from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit.circuit.library import QFT
from qsym.spec_api import qlambda
from qsym.spec_api import qspec
from qsym.types import qidx, qnum
import numpy as np
from hypothesis import assume

import math

def add_constant_in_fourier(qc, target, a, ctrl=None, sign=1):
    """Adds constant 'a' to 'target' in Fourier space using phase gates."""
    n = target.size
    for j in range(n):
        angle = sign * 2 * math.pi * a / (2 ** (n - j))
        angle = angle % (2 * math.pi) # Normalize
        
        if angle == 0:
            continue
            
        if ctrl is not None:
            qc.cp(angle, ctrl, target[j])
        else:
            qc.p(angle, target[j])

def append_c_mod_add(qc, ctrl, target, overflow_anc, A, N):
    n = target.size
    
    # enter fourier basis
    qc.append(QFT(n, do_swaps=True), target)
    
    # add controlled by ctrl
    add_constant_in_fourier(qc, target, A, ctrl=ctrl, sign=1)
    
    # substract to prep for overflow check
    add_constant_in_fourier(qc, target, N, ctrl=None, sign=-1)
    
    # inverse QFT to computational basis to check the MSB
    qc.append(QFT(n, do_swaps=True).inverse(), target)
    
    # if target < 0 (MSB is 1), x+A < N. Flip MSB into the overflow ancilla.
    qc.cx(target[-1], overflow_anc)
    
    # get back to fourier basis
    qc.append(QFT(n, do_swaps=True), target)
    
    # add N back if it underflowed (if overflow_anc is 1)
    add_constant_in_fourier(qc, target, N, ctrl=overflow_anc, sign=1)
    
    # uncompute the overflow ancilla to maintain pure reversibility
    add_constant_in_fourier(qc, target, A, ctrl=ctrl, sign=-1)
    qc.append(QFT(n, do_swaps=True).inverse(), target)
    qc.x(target[-1])
    qc.cx(target[-1], overflow_anc)
    qc.x(target[-1])
    qc.append(QFT(n, do_swaps=True), target)
    add_constant_in_fourier(qc, target, A, ctrl=ctrl, sign=1)
    
    # return to computational basis
    qc.append(QFT(n, do_swaps=True).inverse(), target)

#@qlambda("x => |base ^ (2 ^ i) * x % N⟩") 
def make_inplace_multiplier(n_work: qnum, base: int, i: qidx, N: int):
    C = pow(base, 2**i, N)

    logical_reg = QuantumRegister(n_work, 'p')
    
    # Ancilla needs n_work + 1 qubits to safely hold modular additions
    anc_size = n_work + 1 
    ancilla_reg = QuantumRegister(anc_size, 'anc') 
    overflow_anc = QuantumRegister(1, 'overflow') 
    
    qc = QuantumCircuit(logical_reg, ancilla_reg, overflow_anc, name=f"MUL_{C}mod{N}")
    
    if C == 1: 
        return qc
    
    assume(N >= 2)
    assume(math.gcd(base, N) == 1)
    assume(base > 0)
    
    C_inv = pow(C, -1, N)

    # compute: anc = (anc + C * p) % N
    for bit in range(n_work):
        add_val = (C * (1 << bit)) % N
        if add_val != 0:
            append_c_mod_add(qc, logical_reg[bit], ancilla_reg, overflow_anc[0], add_val, N)

    # swap
    for bit in range(n_work):
        qc.swap(logical_reg[bit], ancilla_reg[bit])

    # uncompute: anc = (anc - C_inv * p_new) % N
    for bit in range(n_work):
        sub_val = (C_inv * (1 << bit)) % N
        add_inv_val = (N - sub_val) % N
        if add_inv_val != 0:
            append_c_mod_add(qc, logical_reg[bit], ancilla_reg, overflow_anc[0], add_inv_val, N)
            
    return qc

# @qlambda("x => |base ^ (2 ^ i) * x % N⟩") #x is the previous value in register before iteration i
# def make_inplace_multiplier(n_work: qnum, base: int, i: qidx, N: int):
  
#     C = pow(base, 2**i, N)

#     logical_reg = QuantumRegister(n_work, 'p')
#     ancilla_reg = QuantumRegister(n_work, 'anc') 
#     qc = QuantumCircuit(logical_reg, ancilla_reg, name=f"MUL_{C}mod{N}")
    
#     if C == 1:
#         return qc
    
#     assume(N >= 2)
#     assume(math.gcd(base, N) == 1)
#     assume(base > 0)
    
#     if math.gcd(base, N) != 1:
#         raise ValueError("Base must be coprime to N.")

#     # 1. COMPUTE
#     for val in range(2**n_work):
#         y = (C * val) % N if val < N else val
#         if y == 0: continue
#         for bit in range(n_work):
#             if not (val & (1 << bit)): qc.x(logical_reg[bit])
#         for bit in range(n_work):
#             if (y & (1 << bit)): qc.mcx(logical_reg, ancilla_reg[bit])
#         for bit in range(n_work):
#             if not (val & (1 << bit)): qc.x(logical_reg[bit])

#     # 2. SWAP
#     for bit in range(n_work):
#         qc.swap(logical_reg[bit], ancilla_reg[bit])

#     # 3. UNCOMPUTE
#     for val in range(2**n_work):
#         y = (C * val) % N if val < N else val
#         if val == 0: continue
#         for bit in range(n_work):
#             if not (y & (1 << bit)): qc.x(logical_reg[bit])
#         for bit in range(n_work):
#             if (val & (1 << bit)): qc.mcx(logical_reg, ancilla_reg[bit])
#         for bit in range(n_work):
#             if not (y & (1 << bit)): qc.x(logical_reg[bit])
            
#     return qc

def shors_circuit(base: int, N: int):
    if math.gcd(base, N) != 1:
        raise ValueError(f"Base {base} is not coprime to N={N}.")
        
    n_work = math.ceil(math.log2(N))
    n_count = 2 * n_work
    
    count_reg = QuantumRegister(n_count, 'count')
    work_reg = QuantumRegister(n_work, 'work')
    ancilla_reg = QuantumRegister(n_work + 1, 'ancilla')
    overflow_anc = QuantumRegister(1, 'overflow')
    c_reg = ClassicalRegister(n_count, 'c')
    
    circuit = QuantumCircuit(count_reg, work_reg, ancilla_reg, overflow_anc, c_reg, name=f"Shors_{base}_{N}")

    circuit.h(count_reg)
    qspec(f"assert {{count_reg[0, {n_count}): en ↦ ∑ k ∈ [0, 2^{n_count}) . 1/sqrt(2^{n_count}) |k⟩ }};")
    
    circuit.x(work_reg[0])
    circuit.barrier()

    for i in range(n_count):
        mul_gate = make_inplace_multiplier(n_work, base, i, N)
        c_mul_gate = mul_gate.control(1)   
        circuit.append(c_mul_gate, [count_reg[i]] + list(work_reg) + list(ancilla_reg))
    
    circuit.append(QFT(n_count, do_swaps=True).inverse(), count_reg)
    circuit.barrier()
    circuit.measure(count_reg, c_reg)

    return circuit

if __name__ == "__main__":
    qc = shors_circuit(base=7, N=15)