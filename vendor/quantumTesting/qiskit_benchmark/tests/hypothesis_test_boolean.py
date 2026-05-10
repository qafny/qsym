import os
import json
import time
import warnings
import numpy as np
import sys

from hypothesis import (
    given,
    settings,
    strategies as st,
    HealthCheck,
    assume,
)

from qiskit import QuantumCircuit, transpile
from qiskit_aer import AerSimulator
from qiskit.circuit.library import XOR, AND, OR, InnerProduct


# Config
MAX_EXAMPLES = int(os.getenv("HYP_MAX_EXAMPLES", "200"))
DERANDOMIZE = os.getenv("HYP_DERANDOMIZE", "0") == "1"
LOG_PASSES_MAX_PER_TEST = int(os.getenv("HYP_LOG_PASSES_MAX", "50"))

SIM = AerSimulator(method="statevector")


class Logger:
    def __init__(self):
        self.passed = {}
        self.constructor_error = {}
        self.assert_failed = {}
        self.pass_logged = {}

    def _inc(self, dct, key):
        dct[key] = dct.get(key, 0) + 1

    def log(self, test: str, status: str, data: dict):
        record = {
            "ts": time.time(),
            "test": test,
            "status": status,
            "data": data,
        }
        print(json.dumps(record, sort_keys=True), flush=True)

        if status == "pass":
            self._inc(self.passed, test)
        elif status == "constructor_error":
            self._inc(self.constructor_error, test)
        elif status == "assert_fail":
            self._inc(self.assert_failed, test)

    def log_pass(self, test: str, trial: dict):
        count = self.pass_logged.get(test, 0)
        if count < LOG_PASSES_MAX_PER_TEST:
            self.log(test, "pass", trial)
            self.pass_logged[test] = count + 1

    def summary(self):
        def fmt(d):
            return ", ".join(f"{k}={v}" for k, v in sorted(d.items())) or "none"

        return (
            "\n=== SUMMARY ===\n"
            f"Passed: {fmt(self.passed)}\n"
            f"Constructor errors (discarded): {fmt(self.constructor_error)}\n"
            f"Assertion failures: {fmt(self.assert_failed)}\n"
        )


LOGGER = Logger()


# Helpers
def set_bits(qc: QuantumCircuit, qubits, value: int, nbits: int):
    for i in range(nbits):
        if (value >> i) & 1:
            qc.x(qubits[i])


def run_statevector(qc: QuantumCircuit) -> np.ndarray:
    tqc = qc.copy()
    tqc.save_statevector()
    tqc = transpile(tqc, SIM, optimization_level=0)
    result = SIM.run(tqc).result()
    return np.asarray(result.get_statevector(tqc), dtype=complex)


def run_basis_output_bitstring_le(qc: QuantumCircuit) -> str:
    sv = run_statevector(qc)
    idx = int(np.argmax(np.abs(sv)))
    return format(idx, f"0{qc.num_qubits}b")[::-1]


def int_from_le_bits(bits: str, n: int) -> int:
    return sum((bits[i] == "1") << i for i in range(n))


def parity(x: int) -> int:
    p = 0
    while x:
        p ^= x & 1
        x >>= 1
    return p


def normalize_bits_flags(n, bits, flags):
    bits = (bits + [0] * n)[:n]
    flags = (flags + [1] * n)[:n]
    return bits, flags


def oracle_and(bits, flags):
    active = [i for i, f in enumerate(flags) if f != 0]
    if not active:
        return True
    for i in active:
        if flags[i] == 1 and bits[i] != 1:
            return False
        if flags[i] == -1 and bits[i] != 0:
            return False
    return True


def oracle_or(bits, flags):
    active = [i for i, f in enumerate(flags) if f != 0]
    if not active:
        return False
    for i in active:
        if flags[i] == 1 and bits[i] == 1:
            return True
        if flags[i] == -1 and bits[i] == 0:
            return True
    return False


# -----------------------------
# Hypothesis settings
# -----------------------------
COMMON_SETTINGS = dict(
    max_examples=MAX_EXAMPLES,
    derandomize=DERANDOMIZE,
    deadline=None,
    suppress_health_check=[HealthCheck.too_slow],
)


# -----------------------------
# Properties
@settings(**COMMON_SETTINGS)
@given(
    n=st.integers(1, 8),
    x=st.integers(0, 255),
    amount=st.integers(0, 255),
)
def prop_xor(n, x, amount):
    # check XOR property
    test = "XOR"
    x &= (1 << n) - 1
    amount &= (1 << n) - 1
    trial = {"n": n, "x": x, "amount": amount}

    try:
        g = XOR(n, amount=amount)
        qc = QuantumCircuit(n)
        set_bits(qc, range(n), x, n)
        qc.append(g, range(n))
    except Exception as e:
        LOGGER.log(test, "constructor_error", {**trial, "error": str(e)})
        assume(False)

    out = int_from_le_bits(run_basis_output_bitstring_le(qc), n)
    assert out == (x ^ amount)

    LOGGER.log_pass(test, trial)


@settings(**COMMON_SETTINGS)
@given(
    n=st.integers(1, 8),
    bits=st.lists(st.integers(0, 1), min_size=1, max_size=8),
    flags=st.lists(st.sampled_from([-1, 0, 1]), min_size=1, max_size=8),
    init_out=st.integers(0, 1),
)
def prop_and(n, bits, flags, init_out):
    # check AND gate.
    test = "AND"
    bits, flags = normalize_bits_flags(n, bits, flags)
    assume(any(f != 0 for f in flags))

    trial = {"n": n, "bits": bits, "flags": flags, "init_out": init_out}

    try:
        qc = QuantumCircuit(n + 1)
        for i, b in enumerate(bits):
            if b:
                qc.x(i)
        if init_out:
            qc.x(n)
        qc.append(AND(n, flags=flags), range(n + 1))
    except Exception as e:
        LOGGER.log(test, "constructor_error", {**trial, "error": str(e)})
        assume(False)

    out = run_basis_output_bitstring_le(qc)
    assert out[:n] == "".join(str(b) for b in bits)
    assert int(out[n]) == (init_out ^ oracle_and(bits, flags))

    LOGGER.log_pass(test, trial)


@settings(**COMMON_SETTINGS)
@given(
    n=st.integers(1, 8),
    a=st.integers(0, 255),
    b=st.integers(0, 255),
)
def prop_inner_product(n, a, b):
    test = "InnerProduct"
    a &= (1 << n) - 1
    b &= (1 << n) - 1
    trial = {"n": n, "a": a, "b": b}

    qc = QuantumCircuit(2 * n)
    set_bits(qc, range(n), a, n)
    set_bits(qc, range(n, 2 * n), b, n)
    qc.append(InnerProduct(n), range(2 * n))

    sv = run_statevector(qc)
    amp = sv[a | (b << n)]
    assert (amp.real >= 0) == (parity(a & b) == 0)

    LOGGER.log_pass(test, trial)


def main():
    try:
        prop_xor()
        prop_and()
        prop_inner_product()
        print("\nAll Hypothesis checks passed.", file=sys.stderr)
    finally:
        print(LOGGER.summary(), file=sys.stderr)


if __name__ == "__main__":
    main()
