import time
import pytest
from antlr4 import InputStream, CommonTokenStream

from Source.quantumCode.AST_Scripts.ProgramTransformer import ProgramTransformer
# from Benchmark.Triangle.triangle import TriangleType, classify_triangle # this might not be correct
from Source.quantumCode.AST_Scripts.XMLExpLexer import XMLExpLexer
from Source.quantumCode.AST_Scripts.XMLExpParser import XMLExpParser
from Source.quantumCode.AST_Scripts.simulator import to_binary_arr, CoqNVal, Simulator, bit_array_to_int

#use findnum n x (2^(n-1)) 0
def findnum(size,x,y,i):
    if size == 0:
        return i
    else:
        if y <= x:
            return i
        else:
            return findnum(size-1,2*x,y,i+1)

def find_num(modulo, num_bits):
    def find_num_recursive(size, x, y, i):
        if size == 0:
            return i
        elif y <= x:
            return i
        else:
            return find_num_recursive(size - 1, 2 * x, y, i + 1)

    return find_num_recursive(num_bits, modulo, 2 ** (num_bits - 1), 0)


def simulate_rz_mod_div(val_x, val_ex, num_qubits, modulo, i):
    with open("Benchmark/rz_mod_div/rz_mod_div_good.xml", 'r') as f:
        str = f.read()
    i_stream = InputStream(str)
    lexer = XMLExpLexer(i_stream)
    t_stream = CommonTokenStream(lexer)
    parser = XMLExpParser(t_stream)
    tree = parser.root()
    # print(tree.toStringTree(recog=parser))
    transform = ProgramTransformer()
    new_tree = transform.visitRoot(tree)

    val_array_x = to_binary_arr(val_x, num_qubits)
    val_array_ex = to_binary_arr(val_ex, num_qubits)

    state = dict(
        {"x": [CoqNVal(val_array_x, 0)],
         "ex": [CoqNVal(val_array_ex, 0)],
         "na": num_qubits,
         "m": modulo,
         "i": i,
         })
    environment = dict(
        {"x": num_qubits,
         "ex": num_qubits,
         })
    # env has the same variables as state, but here, variable is initiliazed to its qubit num
    simulator = Simulator(state, environment)
    simulator.visitRoot(new_tree)
    new_state = simulator.get_state()
    return new_state

#findnum input (size = num_qubits -1, x = modulo, y = pow(2,num_qubits - 2), i = 0
def test_in_range_division():
    test_cases = [
        {"num_qubits": 17, "val_x": 22, "modulo": 7, "i": findnum(16,7,int(pow(2,17-2)),0), "expected_result": 22 % 7, "expected_ex": 22 // 7,
         "description": "In range division 1"},
        {"num_qubits": 25, "val_x": 150, "modulo": 25, "i": findnum(25,25,int(pow(2,25-2)),0), "expected_result": 150 % 25, "expected_ex": 150 // 25,
         "description": "In range division 2"},
        {"num_qubits": 33, "val_x": 987654321, "modulo": 123456, "i": findnum(33,123456,int(pow(2,33-2)),0), "expected_result": 987654321 % 123456,
         "expected_ex": 987654321 // 123456, "description": "In range division 3"},
        {"num_qubits": 41, "val_x": 4294967295, "modulo": 1234567, "i": findnum(41,1234567,int(pow(2,41-2)),0), "expected_result": 4294967295 % 1234567,
         "expected_ex": 4294967295 // 1234567, "description": "In range division 4"},
        {"num_qubits": 49, "val_x": 281474976710656, "modulo": 123456789, "i": findnum(49,123456789,int(pow(2,49-2)),0),
         "expected_result": 281474976710656 % 123456789, "expected_ex": 281474976710656 // 123456789,
         "description": "In range division 5"}
    ]

    for case in test_cases:
        i = find_num(case["modulo"], case["num_qubits"] - 1)
        new_state = simulate_rz_mod_div(case["val_x"], 0, case["num_qubits"] - 1, case["modulo"], i)
        print("i: ", i)
        assert case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case[
            "num_qubits"]), f"Test failed for case: {case['description']}. Expected {case['expected_result']}, got {bit_array_to_int(new_state.get('x')[0].getBits(), case['num_qubits'])}"
        assert case["expected_ex"] == bit_array_to_int(new_state.get('ex')[0].getBits(), case[
            "num_qubits"]), f"Test failed for case: {case['description']}. Expected {case['expected_ex']}, got {bit_array_to_int(new_state.get('ex')[0].getBits(), case['num_qubits'])}"

'''
def test_zero_division():
    test_cases = [
        {"num_qubits": 16, "val_x": 0, "modulo": 25, "i": 5, "expected_result": 0 % 25, "expected_ex": 0 // 25,
         "description": "Zero val_x"},
        {"num_qubits": 23, "val_x": 150, "modulo": 1, "i": 4, "expected_result": 150 % 1, "expected_ex": 150 // 1,
         "description": "Modulo is 1"},
        {"num_qubits": 31, "val_x": 0, "modulo": 123456, "i": 6, "expected_result": 0 % 123456,
         "expected_ex": 0 // 123456, "description": "Zero val_x with larger modulo"},
        {"num_qubits": 39, "val_x": 4294967295, "modulo": 1, "i": 7, "expected_result": 4294967295 % 1,
         "expected_ex": 4294967295 // 1, "description": "Modulo is 1 with large val_x"},
        {"num_qubits": 47, "val_x": 0, "modulo": 123456789, "i": 8, "expected_result": 0 % 123456789,
         "expected_ex": 0 // 123456789, "description": "Zero val_x with very large modulo"}
    ]

    for case in test_cases:
        i = find_num(case["modulo"], case["num_qubits"] - 1)
        print("i: ", i)
        new_state = simulate_rz_mod_div(case["val_x"], 0, case["num_qubits"] - 1, case["modulo"], i)
        assert case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case[
            "num_qubits"]), f"Test failed for x. Case: {case['description']}. Expected {case['expected_result']}, got {bit_array_to_int(new_state.get('x')[0].getBits(), case['num_qubits'])}"
        assert case["expected_ex"] == bit_array_to_int(new_state.get('ex')[0].getBits(), case[
            "num_qubits"]), f"Test failed for ex. Case: {case['description']}. Expected {case['expected_ex']}, got {new_state.get('ex')}"


def test_negative_division():
    test_cases = [
        {"num_qubits": 15, "val_x": -22, "modulo": 7, "i": 4, "expected_result": -22 % 7, "expected_ex": -22 // 7,
         "description": "Negative val_x"},
        {"num_qubits": 29, "val_x": 150, "modulo": -25, "i": 5, "expected_result": 150 % -25, "expected_ex": 150 // -25,
         "description": "Negative modulo"},
        {"num_qubits": 30, "val_x": -987654321, "modulo": 123456, "i": 6, "expected_result": -987654321 % 123456,
         "expected_ex": -987654321 // 123456, "description": "Negative val_x with large modulo"},
        {"num_qubits": 38, "val_x": 4294967295, "modulo": -1234567, "i": 7, "expected_result": 4294967295 % -1234567,
         "expected_ex": 4294967295 // -1234567, "description": "Negative modulo with large val_x"},
        {"num_qubits": 46, "val_x": -281474976710656, "modulo": 123456789, "i": 8,
         "expected_result": -281474976710656 % 123456789, "expected_ex": -281474976710656 // 123456789,
         "description": "Negative val_x with very large modulo"}
    ]

    for case in test_cases:
        i = find_num(case["modulo"], case["num_qubits"] - 1)
        new_state = simulate_rz_mod_div(case["val_x"], 0, case["num_qubits"]-1, case["modulo"], i)
        assert case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case[
            "num_qubits"]-1), f"Test failed for case: {case['description']}. Expected {case['expected_result']}, got {bit_array_to_int(new_state.get('x')[0].getBits(), case['num_qubits'])}"
        assert case["expected_ex"] == new_state.get(
            'ex'), f"Test failed for case: {case['description']}. Expected {case['expected_ex']}, got {new_state.get('ex')}"


def test_overflow_division():
    test_cases = [
        {"num_qubits": 15, "val_x": 2 ** 15 - 1, "modulo": 7, "i": 4, "expected_result": (2 ** 15 - 1) % 7,
         "expected_ex": (2 ** 15 - 1) // 7, "description": "Overflow case 1"},
        {"num_qubits": 31, "val_x": 2 ** 31 - 1, "modulo": 9, "i": 5, "expected_result": (2 ** 31 - 1) % 9,
         "expected_ex": (2 ** 31 - 1) // 9, "description": "Overflow case 2"},
        {"num_qubits": 47, "val_x": 2 ** 47 - 1, "modulo": 11, "i": 6, "expected_result": (2 ** 47 - 1) % 11,
         "expected_ex": (2 ** 47 - 1) // 11, "description": "Overflow case 3"},
        {"num_qubits": 25, "val_x": 2 ** 25 - 1, "modulo": 13, "i": 7, "expected_result": (2 ** 25 - 1) % 13,
         "expected_ex": (2 ** 25 - 1) // 13, "description": "Overflow case 4"},
        {"num_qubits": 39, "val_x": 2 ** 39 - 1, "modulo": 15, "i": 8, "expected_result": (2 ** 39 - 1) % 15,
         "expected_ex": (2 ** 39 - 1) // 15, "description": "Overflow case 5"}
    ]

    for case in test_cases:
        i = find_num(case["modulo"], case["num_qubits"]-1)
        new_state = simulate_rz_mod_div(case["val_x"], 0, case["num_qubits"]-1, case["modulo"], i)
        assert case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case[
            "num_qubits"]-1), f"Test failed for case: {case['description']}. Expected {case['expected_result']}, got {bit_array_to_int(new_state.get('x')[0].getBits(), case['num_qubits'])}"
        assert case["expected_ex"] == new_state.get(
            'ex'), f"Test failed for case: {case['description']}. Expected {case['expected_ex']}, got {new_state.get('ex')}"
'''

