import time
import pytest
from antlr4 import InputStream, CommonTokenStream
import os
import sys

current_dir = os.path.dirname(os.path.realpath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.insert(0,parent_dir)

# from Benchmark.Triangle.triangle import TriangleType, classify_triangle # this might not be correct
from AST_Scripts.XMLExpLexer import XMLExpLexer
from AST_Scripts.XMLExpParser import XMLExpParser
from AST_Scripts.ProgramTransformer import ProgramTransformer
from AST_Scripts.Retrievers import MatchCounterRetriever
from AST_Scripts.ValidatorProgramVisitors import SimulatorValidator
from AST_Scripts.simulator import to_binary_arr, CoqNVal, Simulator, bit_array_to_int

def read_program(file_path: str):
    with open(file_path, 'r') as f:
        str = f.read()
    i_stream = InputStream(str)
    lexer = XMLExpLexer(i_stream)
    t_stream = CommonTokenStream(lexer)
    parser = XMLExpParser(t_stream)
    tree = parser.root()
    transform = ProgramTransformer()
    new_tree = transform.visitRoot(tree)
    return new_tree 

def get_tree():
    new_tree = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/cl_mult_good.xml")
    valid_tree = True
    try:
        validator = SimulatorValidator()
        validator.visitRoot(new_tree)
    except:
        vali_tree = False
    retriever = MatchCounterRetriever()
    retriever.visitRoot(new_tree)
    return new_tree, retriever, valid_tree

def simulate_cl_mult(x_array_value, y_array_value, result_array_val, num_qubits):
    # with open("/home/biryani/research/quantumTesting/xml_benchmarks/cl_mult_good.xml", 'r') as f:
    #     str = f.read()
    # i_stream = InputStream(str)
    # lexer = XMLExpLexer(i_stream)
    # t_stream = CommonTokenStream(lexer)
    # parser = XMLExpParser(t_stream)
    # tree = parser.program()
    # print(tree.toStringTree(recog=parser))
    tree = get_tree()

    x_array_value = to_binary_arr(x_array_value, num_qubits)
    y_array_value = to_binary_arr(y_array_value, num_qubits)
    num_qubits_ca = 1
    ca_array_val = to_binary_arr(0, num_qubits_ca)
    result_array_val = to_binary_arr(result_array_val, num_qubits)


    state = dict(
        {"x": [CoqNVal(x_array_value, 0)],
         "y": [CoqNVal(y_array_value, 0)],
         "c": [CoqNVal(ca_array_val, 0)],
         "re": [CoqNVal(result_array_val, 0)],
         "n": num_qubits,
         })
    environment = dict(
        {"x": num_qubits,
         "y": num_qubits,
         "c": 1,
         "re": num_qubits
         })
    simulator = Simulator(state, environment)
    # simulator.visitProgram(tree)
    simulator.visitRoot(tree[0])
    new_state = simulator.get_state()
    return new_state


def test_in_range_multiplication():
    test_cases = [
        {"num_qubits": 20, "val_x": 3, "val_y": 4, "expected_result": 12, "description": "Small Multiplication"},
        {"num_qubits": 16, "val_x": 7, "val_y": 8, "expected_result": 56, "description": "Medium Multiplication"},
        {"num_qubits": 12, "val_x": 15, "val_y": 15, "expected_result": 225, "description": "Medium Multiplication with same values"},
        {"num_qubits": 5, "val_x": 1, "val_y": 1, "expected_result": 1, "description": "Multiplication of ones"},
        {"num_qubits": 6, "val_x": 9, "val_y": 2, "expected_result": 18, "description": "Small Even and Odd Multiplication"}
    ]
    for case in test_cases:
        new_state = simulate_cl_mult(case["val_x"], case["val_y"], 0, case["num_qubits"])
        expected = case["expected_result"]
        actual = bit_array_to_int(new_state.get('re')[0].getBits(), case['num_qubits'])
        print( "expected: ", expected, " actual: ", actual)
        assert expected == actual
        # assert (case["expected_result"] == bit_array_to_int(new_state.get('y')[0].getBits(), case["num_qubits"]))


def test_zero_multiplication():
    test_cases = [
        {"num_qubits": 16, "val_x": 0, "val_y": 4, "expected_result": 0, "description": "Zero multiplied by non-zero"},
        {"num_qubits": 16, "val_x": 7, "val_y": 0, "expected_result": 0, "description": "Non-zero multiplied by zero"},
        {"num_qubits": 16, "val_x": 0, "val_y": 0, "expected_result": 0, "description": "Zero multiplied by zero"}
    ]

    for case in test_cases:
        new_state = simulate_cl_mult(case["val_x"], case["val_y"], 0, case["num_qubits"])
        assert (case["expected_result"] == bit_array_to_int(new_state.get('re')[0].getBits(), case["num_qubits"]))

def test_overflow_multiplication():
    test_cases = [
        {"num_qubits": 16, "val_x": 65535, "val_y": 65535, "expected_result": 1, "description": "Overflow multiplication resulting in wrap around"},
        {"num_qubits": 16, "val_x": 32768, "val_y": 2, "expected_result": 0, "description": "Large value multiplication causing overflow to zero"},
        {"num_qubits": 24, "val_x": 16777215, "val_y": 2, "expected_result": 16777214, "description": "Large value multiplication close to overflow"}
    ]
    for case in test_cases:
        new_state = simulate_cl_mult(case["val_x"], case["val_y"], 0, case["num_qubits"])
        expected = case["expected_result"]
        actual = bit_array_to_int(new_state.get('re')[0].getBits(), case['num_qubits'])
        print("expected: ", expected, " actual: ", actual)
        assert actual == expected
        # assert (case["expected_result"] == bit_array_to_int(new_state.get('re')[0].getBits(), case["num_qubits"]))


def test_negative_multiplication():
    test_cases = [
        {"num_qubits": 24, "val_x": -10, "val_y": 4, "expected_result": 16777256, "description": "Negative and positive multiplication"},
        {"num_qubits": 32, "val_x": -65536, "val_y": -2, "expected_result": 131072, "description": "Negative multiplied by negative"},
        {"num_qubits": 40, "val_x": -1099511627776, "val_y": 1, "expected_result": 1099511627776, "description": "Negative multiplied by one"},
        {"num_qubits": 48, "val_x": -281474976710656, "val_y": -281474976700000, "expected_result": 0, "description": "Negative multiplied by negative with large values"},
        {"num_qubits": 56, "val_x": -72057594037927936, "val_y": 1000, "expected_result": 0, "description": "Large negative and small positive"}
    ]
    for case in test_cases:
        new_state = simulate_cl_mult(case["val_x"], case["val_y"], 0, case["num_qubits"])
        expected = case["expected_result"]
        actual = bit_array_to_int(new_state.get('re')[0].getBits(), case['num_qubits'])
        print("expected: ", expected, " actual: ", actual)
        assert actual == expected
        # assert (case["expected_result"] == bit_array_to_int(new_state.get('re')[0].getBits(), case["num_qubits"]))


def test_multiplication_by_zero():
    test_cases = [
        {"num_qubits": 11, "val_x": 0, "val_y": 4, "expected_result": 0, "description": "Zero multiplied by non-zero"},
        {"num_qubits": 20, "val_x": 7, "val_y": 0, "expected_result": 0, "description": "Non-zero multiplied by zero"},
        {"num_qubits": 30, "val_x": 0, "val_y": 0, "expected_result": 0, "description": "Zero multiplied by zero"}
    ]
    for case in test_cases:
        new_state = simulate_cl_mult(case["val_x"], case["val_y"], 0, case["num_qubits"])
        assert case["expected_result"] == bit_array_to_int(new_state.get('re')[0].getBits(), case["num_qubits"]), f"Test failed for case: {case['description']}. Expected {case['expected_result']}, got {bit_array_to_int(new_state.get('re')[0].getBits(), case['num_qubits'])}"


def test_values_greater_than_2_power_num_qubits():
    test_cases = [
        {"num_qubits": 19, "val_x": 70000, "val_y": 524288, "expected_result": (70000 % (2 ** 19)) * (524288 % (2 ** 19)), "description": "Both values greater than 2^na"},
        {"num_qubits": 22, "val_x": 4194304, "val_y": 2097152, "expected_result": (4194304 % (2 ** 22)) * (2097152 % (2 ** 22)), "description": "Both values equal to 2^na"},
        {"num_qubits": 14, "val_x": 70000, "val_y": 2, "expected_result": (70000 % (2 ** 14)) * 2, "description": "One value greater, one within range"},
        {"num_qubits": 25, "val_x": 33554432, "val_y": 5, "expected_result": (33554432 % (2 ** 25)) * 5, "description": "Value equal to 2^na multiplied by a small number"},
        {"num_qubits": 13, "val_x": 8191, "val_y": 16384, "expected_result": 8191 * (16384 % (2 ** 13)), "description": "Value within range multiplied by a value greater than 2^na"},
        {"num_qubits": 30, "val_x": 1073741824, "val_y": 2147483647, "expected_result": (1073741824 % (2 ** 30)) * 2147483647, "description": "Very large values with one equal to 2^na and one just below"},
        {"num_qubits": 15, "val_x": 32768, "val_y": 0, "expected_result": 0, "description": "Multiplication with zero and a value greater than 2^na"},
        {"num_qubits": 28, "val_x": 134217728, "val_y": 1, "expected_result": (134217728 % (2 ** 28)) * 1, "description": "Multiplication of a very large value equal to 2^na by 1"},
        {"num_qubits": 21, "val_x": 2097152, "val_y": 8388608, "expected_result": 2097152 * (8388608 % (2 ** 21)), "description": "Multiplication of a within range value by a multiple of 2^na"},
        {"num_qubits": 26, "val_x": 67108864, "val_y": 134217728, "expected_result": (67108864 % (2 ** 26)) * (134217728 % (2 ** 26)), "description": "Multiplication of large values both greater than 2^na"},
    ]
    for case in test_cases:
        new_state = simulate_cl_mult(case["val_x"], case["val_y"], 0, case["num_qubits"])
        assert case["expected_result"] == bit_array_to_int(new_state.get('re')[0].getBits(), case["num_qubits"]), f"Test failed for case: {case['description']}. Expected {case['expected_result']}, got {bit_array_to_int(new_state.get('re')[0].getBits(), case['num_qubits'])}"


@pytest.fixture(scope="session", autouse=True)
def starter(request):
    start_time = time.time()

    def finalizer():
        print("runtime: {}".format(str(time.time() - start_time)))

    request.addfinalizer(finalizer)


# test_in_range_multiplication()
# test_overflow_multiplication()
test_negative_multiplication()