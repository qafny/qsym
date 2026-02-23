import sys
import os
import re

current_dir = os.path.dirname(os.path.abspath(__file__))
vendor_dir = os.path.abspath(os.path.join(current_dir, '../..', 'vendor', 'quantumTesting'))

if vendor_dir not in sys.path:
    sys.path.insert(0, vendor_dir)
    sys.path.insert(0, os.path.join(vendor_dir, 'qiskit-to-xmlprogrammer'))

#from qiskit_to_xmlprogrammer import QCtoXMLProgrammer
from AST_Scripts.XMLProgrammer import QXNum, QXX, QXCU
from AST_Scripts.simulator import CoqNVal, CoqYVal, Simulator, bit_array_to_int, to_binary_arr
from hypothesis import given, settings, strategies as st

class DummyProgram:
    def __init__(self, exps):
        self._exps = exps
        
    def accept(self, visitor):
        for exp in self._exps:
            exp.accept(visitor)

#AST builder
def circuit_to_ast(qc, reg_name="test"):
    """
    manually nests CU gates for pure classical arithmetic simulation.
    """
    ast_nodes = []
    
    for instruction in qc.data:
        gate = instruction.operation
        qubits = [qc.find_bit(q).index for q in instruction.qubits]
        
        if gate.name == 'x':
            ast_nodes.append(QXX(id=reg_name, v=QXNum(qubits[0])))
            
        elif gate.name in ['cx', 'ccx', 'mcx']:
            controls = qubits[:-1]
            target = qubits[-1]
            
            nested_node = [QXX(id=reg_name, v=QXNum(target))]
            
            for ctrl in reversed(controls):
                nested_node = [QXCU(id=reg_name, v=QXNum(ctrl), p=DummyProgram(nested_node))]
                
            ast_nodes.extend(nested_node)
            
        else:
            raise ValueError(f"Fast-AST does not support non-computational gate: {gate.name}")

    return DummyProgram(ast_nodes)


def run_pbt_veri(circuit_factory, lambda_str: str):
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
        
        n = data.draw(st.integers(min_value=3, max_value=60)) 
        dim = 2 ** n
        
        x = data.draw(st.integers(min_value=0, max_value=dim - 1))
        
        qc = circuit_factory(n)
        
        reg_name = "test"
        ast_tree = circuit_to_ast(qc, reg_name)
        
        #setup simulator state
        bool_array = to_binary_arr(x, n) 
        input_vals = [CoqNVal(b, phase=0) for b in bool_array]
        
        state_map = {reg_name: input_vals}
        environment_map = {reg_name: n}
        
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
        expected_val = eval(python_expr, {var_name: x, "n": n}) % dim
        
        assert actual_val == expected_val, (
            f"❌ Contract Violation!\n"
            f"   n = {n}\n"
            f"   Input state: |{x}⟩\n"
            f"   Math expected: |{expected_val}⟩\n"
            f"   Circuit produced: |{actual_val}⟩"
        )

    try:
        check_circuit_property()
        print(f"PBT PASSED: No counterexamples found for {circuit_factory.__name__}.")
    except Exception as e:
        print(e)
        raise