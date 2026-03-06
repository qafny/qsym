import sys
import os
import re
import inspect
import math
import rich

current_dir = os.path.dirname(os.path.abspath(__file__))
vendor_dir = os.path.abspath(os.path.join(current_dir, '../..', 'vendor', 'quantumTesting'))

if vendor_dir not in sys.path:
    sys.path.insert(0, vendor_dir)
    sys.path.insert(0, os.path.join(vendor_dir, 'qiskit-to-xmlprogrammer'))

#from qiskit_to_xmlprogrammer import QCtoXMLProgrammer
from AST_Scripts.XMLProgrammer import QXNum, QXX, QXCU, QXQFT, QXRshift, QXRZ, QXRQFT, QXSR, QXH, QXRev, QXLshift, QXRY
from AST_Scripts.simulator import CoqNVal, CoqYVal, Simulator, bit_array_to_int, to_binary_arr
from AST_Scripts.XMLPrinter import XMLPrinter
from hypothesis import given, settings, assume, strategies as st
from qsym.types import qnum, qidx

class DummyProgram:
    def __init__(self, exps):
        self._exps = exps
        
    def accept(self, visitor):
        for exp in self._exps:
            exp.accept(visitor)

#AST builder
def circuit_to_ast(qc, reg_name="test"):
    ast_nodes = []
    
    #qc = qc.decompose(reps=3) 
    
    for instruction in qc.data:
        gate = instruction.operation
        
        if gate.name in ['barrier', 'measure']:
            continue
            
        qubits = [q._index for q in instruction.qubits] 
        
        # Standard Single-Qubit Gates
        if gate.name == 'x':
            ast_nodes.append(QXX(id=reg_name, v=QXNum(qubits[0])))
            
        elif gate.name == 'h':
            ast_nodes.append(QXH(id=reg_name, v=QXNum(qubits[0])))
            
        elif gate.name == 'p':
            p_val = int(gate.params[0]) 
            ast_nodes.append(QXRZ(id=reg_name, v=QXNum(qubits[0]), v1=QXNum(p_val)))

        # QFT Operations
        elif gate.name == 'QFT':
            ast_nodes.append(QXQFT(id=reg_name, v=QXNum(qubits[0])))

        elif gate.name == 'IQFT':      
            ast_nodes.append(QXRQFT(id=reg_name))
        # Multi-Qubit and Controlled Gates
        elif gate.name == 'cx':
            ctrl, target = qubits[0], qubits[1]
            inner_node = QXX(id=reg_name, v=QXNum(target))
            ast_nodes.append(QXCU(id=reg_name, v=QXNum(ctrl), p=DummyProgram([inner_node])))
            
        elif gate.name == 'cp':
            ctrl, target = qubits[0], qubits[1]
            p_val = int(gate.params[0])
            inner_node = QXRZ(id=reg_name, v=QXNum(target), v1=QXNum(p_val))
            ast_nodes.append(QXCU(id=reg_name, v=QXNum(ctrl), p=DummyProgram([inner_node])))

        elif gate.name == 'swap':
            q1, q2 = qubits[0], qubits[1]
            
            # Helper to create a CX (QXCU wrapping a QXX)
            def make_cx(ctrl, target):
                inner = QXX(id=reg_name, v=QXNum(target))
                return QXCU(id=reg_name, v=QXNum(ctrl), p=DummyProgram([inner]))

            # Add the 3 CX gates that make up a SWAP
            ast_nodes.append(make_cx(q1, q2))
            ast_nodes.append(make_cx(q2, q1))
            ast_nodes.append(make_cx(q1, q2))
            
        else:
            raise ValueError(f"AST builder does not yet support Qiskit gate: {gate.name}")

    return DummyProgram(ast_nodes)

def _parse_lambda(math_spec: str):
    """
    Extract (var_name, body_expr, modulus_name) from strings like:
      x => |(x * pow(base, 2^i, N)) % N⟩
    modulus_name is the identifier after '%' if present, else None.
    """
    m = re.match(r"\s*([a-zA-Z_]\w*)\s*=>\s*\|(.*)⟩\s*$", math_spec.strip())
    if not m:
        return ("x", "", None)

    var_name = m.group(1)
    body = m.group(2)

    mm = re.search(r"%\s*([a-zA-Z_]\w*)\b", body)  # match "% N" where N is an identifier
    mod_name = mm.group(1) if mm else None

    return (var_name, body, mod_name)


def build_dynamic_strategy(func, math_spec):
    """
    A purely generic PBT strategy builder. It inspects the function signature 
    and randomly generates integers for all required arguments, bounded only 
    by the register size to prevent infinite memory usage.
    """
    sig = inspect.signature(func)
    params = list(sig.parameters.keys())

    var_name, body, mod_name = _parse_lambda(math_spec)
    
    @st.composite
    def dynamic_strategy(draw):
        kwargs = {}

        #extract qubits#    
        n_keys = [p for p in params if p in ["n", "n_work", "num_qubits"]]        
        n_val = draw(st.integers(min_value=3, max_value=20)) if n_keys else 5
        
        for k in n_keys:
            kwargs[k] = n_val
            
        dim = 2 ** n_val

        if mod_name and mod_name in sig.parameters:
            kwargs[mod_name] = draw(st.integers(min_value=2, max_value=dim - 1))
        
        for param_name, param_obj in sig.parameters.items():
            if param_name not in kwargs:
                if param_obj.annotation is qidx:
                    kwargs[param_name] = draw(st.integers(min_value=0, max_value=n_val * 2))
                else:
                    # Treat as a standard state value
                    kwargs[param_name] = draw(st.integers(min_value=2, max_value=dim - 1))
        if var_name not in kwargs:
            if mod_name and mod_name in kwargs:
                kwargs[var_name] = draw(st.integers(min_value=0, max_value=kwargs[mod_name] - 1))
            else:
                kwargs[var_name] = draw(st.integers(min_value=1, max_value=dim - 1))
        
        return kwargs
        
    return dynamic_strategy

def run_pbt_veri(circuit_factory, lambda_str: str, param_strategy: None):
    """
    Sets up and runs the Property-Based Test for the quantum circuit 
    using the quantumTesting Simulator.
    """
    print(f"PBT: Fuzzing {circuit_factory.__name__} against '{lambda_str}'...")

    match = re.match(r"([a-zA-Z_]\w*)\s*=>\s*\|(.*)⟩", lambda_str.strip())
    if not match:
        raise ValueError(f"PBT Error: Cannot parse lambda string '{lambda_str}'")
    
    var_name = match.group(1)
    python_expr = match.group(2).replace("^", "**")

    @given(data=st.data())
    @settings(max_examples=50, deadline=None) # Set deadline to None to prevent timeout failures
    def check_circuit_property(data):
        if param_strategy:
            params = data.draw(param_strategy())
            n = params.pop("n_work") # Extract n_work specifically for array sizing
            x = params.pop("x")      # Extract x for the initial state
        else:
            n = data.draw(st.integers(min_value=3, max_value=30)) 
            x = data.draw(st.integers(min_value=1, max_value=(2**n) - 1))
            params = {}
        
        qc = circuit_factory(n_work=n, **params) if param_strategy else circuit_factory(n)

        total_qubits = qc.num_qubits
        
        reg_name = "test"
        ast_tree = circuit_to_ast(qc, reg_name)
        
        #setup simulator state
        bool_array = to_binary_arr(x, n) 
        bool_array.extend([False] * (total_qubits - len(bool_array)))
        input_vals = [CoqNVal(b, phase=0) for b in bool_array]
        
        state_map = {reg_name: input_vals}
        environment_map = {reg_name: total_qubits}
        
        sim = Simulator(state_map, environment_map)

        #execute
        ast_tree.accept(sim)
        
        post_sim_vals = sim.state[reg_name]
        
        result_bits = []
        for val in post_sim_vals:
            if isinstance(val, CoqNVal):
                result_bits.append(val.getBit())
            elif isinstance(val, CoqYVal):
                zero_state = val.getZero()
                if not zero_state:
                    result_bits.append(True)
                else:
                    amp_zero = sum(abs(amp) for amp, phase in zero_state)
                    result_bits.append(amp_zero < 1e-6)
            else:
                raise AssertionError(f"Simulation leaked unknown state format: {type(val)}")
        
        actual_val = bit_array_to_int(result_bits, n)    
        eval_context = {var_name: x, "n": n, **params}
        expected_val = eval(python_expr, eval_context)
        
        assert actual_val == expected_val, (
            f"❌ Contract Violation!\n"
            f"   n = {n}, params = {params}\n"
            f"   Input state: |{x}⟩\n"
            f"   Math expected: |{expected_val}⟩\n"
            f"   Circuit produced: |{actual_val}⟩"
        )

    try:
        check_circuit_property()
        print(f"PBT PASSED: No counterexamples found for {circuit_factory.__name__}.")
    except Exception as e:
        print(f"PBT FAILED for {circuit_factory.__name__}.")
        raise e