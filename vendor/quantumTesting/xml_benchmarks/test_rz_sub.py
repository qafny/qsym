import time
import pytest
from antlr4 import InputStream, CommonTokenStream

from Source.quantumCode.AST_Scripts.XMLExpLexer import XMLExpLexer
from Source.quantumCode.AST_Scripts.XMLExpParser import XMLExpParser
from Source.quantumCode.AST_Scripts.simulator import to_binary_arr, CoqNVal, Simulator, bit_array_to_int


def simulate_rz_sub(val_array_x, subtrahend, num_qubits):
    with open("rz_sub_good.xml", 'r') as f:
        str = f.read()
    i_stream = InputStream(str)
    lexer = XMLExpLexer(i_stream)
    t_stream = CommonTokenStream(lexer)
    parser = XMLExpParser(t_stream)
    tree = parser.root()
    #print(tree.toStringTree(recog=parser))

    val_array_x = to_binary_arr(val_array_x, num_qubits)

    state = dict(
        {"x": [CoqNVal(val_array_x, 0)],
         "na": num_qubits,
         "m": subtrahend,
         })
    environment = dict(
        {"x": num_qubits,
         })
    simulator = Simulator(state, environment)
    simulator.visitRoot(tree)
    new_state = simulator.get_state()
    return new_state

def test_in_range_subtraction():
    test_cases = [
        {"num_qubits": 16, "val_x": 100, "subtrahend": 50, "expected_result": (100 - 50) % 2**16, "description": "Small numbers"},
        {"num_qubits": 24, "val_x": 500000, "subtrahend": 250000, "expected_result": (500000 - 250000) % 2**24, "description": "Medium numbers"},
        {"num_qubits": 32, "val_x": 4000000000, "subtrahend": 2000000000, "expected_result": (4000000000 - 2000000000) % 2**32, "description": "Large numbers"}
    ]
    for case in test_cases:
        new_state = simulate_rz_sub(case["val_x"], case["subtrahend"], case["num_qubits"])
        assert (case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case["num_qubits"]))

def test_subtracting_zero():
    test_cases = [
        {"num_qubits": 16, "val_x": 12345, "subtrahend": 0, "expected_result": 12345, "description": "Subtracting zero"},
        {"num_qubits": 24, "val_x": 654321, "subtrahend": 0, "expected_result": 654321, "description": "Subtracting zero"},
        {"num_qubits": 32, "val_x": 987654321, "subtrahend": 0, "expected_result": 987654321, "description": "Subtracting zero"}
    ]
    for case in test_cases:
        new_state = simulate_rz_sub(case["val_x"], case["subtrahend"], case["num_qubits"])
        assert (case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case["num_qubits"]))

def test_negative_subtraction():
    test_cases = [
        {"num_qubits": 16, "val_x": 100, "subtrahend": 200, "expected_result": (100 - 200) % 2**16, "description": "Result negative"},
        {"num_qubits": 24, "val_x": 500000, "subtrahend": 1000000, "expected_result": (500000 - 1000000) % 2**24, "description": "Result negative"},
        {"num_qubits": 32, "val_x": 4000000000, "subtrahend": 8000000000, "expected_result": (4000000000 - 8000000000) % 2**32, "description": "Result negative"}
    ]
    for case in test_cases:
        new_state = simulate_rz_sub(case["val_x"], case["subtrahend"], case["num_qubits"])
        assert (case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case["num_qubits"]))

def test_overflow_subtraction():
    test_cases = [
        {"num_qubits": 16, "val_x": 2**16 - 1, "subtrahend": 1, "expected_result": (2**16 - 1 - 1) % 2**16, "description": "Overflow case 1"},
        {"num_qubits": 32, "val_x": 2**32 - 1, "subtrahend": 1, "expected_result": (2**32 - 1 - 1) % 2**32, "description": "Overflow case 2"},
        {"num_qubits": 24, "val_x": 2**24 - 1, "subtrahend": 100000, "expected_result": (2**24 - 1 - 100000) % 2**24, "description": "Overflow case 3"}
    ]
    for case in test_cases:
        new_state = simulate_rz_sub(case["val_x"], case["subtrahend"], case["num_qubits"])
        assert (case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case["num_qubits"]))

def test_large_number_subtraction():
    test_cases = [
        {"num_qubits": 48, "val_x": 2**47, "subtrahend": 2**46, "expected_result": (2**47 - 2**46) % 2**48, "description": "Large number subtraction 1"},
        {"num_qubits": 56, "val_x": 2**55, "subtrahend": 2**54, "expected_result": (2**55 - 2**54) % 2**56, "description": "Large number subtraction 2"},
        {"num_qubits": 64, "val_x": 2**63, "subtrahend": 2**62, "expected_result": (2**63 - 2**62) % 2**64, "description": "Large number subtraction 3"}
    ]
    for case in test_cases:
        new_state = simulate_rz_sub(case["val_x"], case["subtrahend"], case["num_qubits"])
        assert (case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case["num_qubits"]))
