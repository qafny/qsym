import re
from qiskit.quantum_info import Statevector
from hypothesis import given, settings, strategies as st

def run_pbt_veri(circuit_factory, lambda_str: str):
    """
    Sets up and runs the Property-Based Test for the quantum circuit.
    """
    print(f"PBT: Fuzzing {circuit_factory.__name__} against '{lambda_str}'...")

    # parse the lambda string
    match = re.match(r"([a-zA-Z_]\w*)\s*=>\s*\|(.*)⟩", lambda_str.strip())
    if not match:
        raise ValueError(f"PBT Error: Cannot parse lambda string '{lambda_str}'")
    
    var_name = match.group(1)
    python_expr = match.group(2).replace("^", "**")

    # define the property
    @given(data=st.data())
    @settings(max_examples=50, deadline=None) 
    def check_circuit_property(data):
        
        # draw a random qubit count 
        n = data.draw(st.integers(min_value=2, max_value=8))
        dim = 2 ** n
        
        # draw a random basis state 
        x = data.draw(st.integers(min_value=0, max_value=dim - 1))
        
        # setup the state and circuit
        input_sv = Statevector.from_int(x, dims=dim)
        qc = circuit_factory(n)
        
        # execute the circuit
        actual_sv = input_sv.evolve(qc)
        
        # calculate the mathematical expectation
        expected_val = eval(python_expr, {var_name: x, "n": n}) % dim
        expected_sv = Statevector.from_int(expected_val, dims=dim)
        
        # assert equivalence
        assert actual_sv.equiv(expected_sv), (
            f"❌ Contract Violation!\n"
            f"   n = {n}\n"
            f"   Input state: |{x}⟩\n"
            f"   Math expected: |{expected_val}⟩\n"
            f"   Circuit produced a different state."
        )

    # execute the test
    try:
        check_circuit_property()
        print(f"✅ PBT PASSED: No counterexamples found for {circuit_factory.__name__}.")
    except Exception as e:
        print(e)
        raise