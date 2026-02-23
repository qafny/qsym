import os
import random
import json
import pytest
from antlr4 import InputStream, CommonTokenStream

from Source.quantumCode.AST_Scripts.ProgramTransformer import ProgramTransformer
from Source.quantumCode.AST_Scripts.Retrievers import RPFRetriever
from Source.quantumCode.AST_Scripts.Validators import SimulatorValidator, AppRPFValidator
from Source.quantumCode.AST_Scripts.XMLExpLexer import XMLExpLexer
from Source.quantumCode.AST_Scripts.XMLExpParser import XMLExpParser
from Source.quantumCode.AST_Scripts.simulator import to_binary_arr, CoqNVal, Simulator, bit_array_to_int

@pytest.fixture(scope="module")
def parse_tree():
    test_file_path = f"{os.path.dirname(os.path.realpath(__file__))}/rz_mod_adder_good.xml"
    with open(test_file_path, 'r') as f:
        str = f.read()
    i_stream = InputStream(str)
    lexer = XMLExpLexer(i_stream)
    t_stream = CommonTokenStream(lexer)
    parser = XMLExpParser(t_stream)
    tree = parser.root()
    transform = ProgramTransformer()
    new_tree = transform.visitRoot(tree)
    return new_tree


def simulate_rz_mod_adder(parseTree, val_array_x, addend, modulo, num_qubits, val_array_carry=0):

    x_array = to_binary_arr(val_array_x, num_qubits)
    carry_array = to_binary_arr(val_array_carry, 1)
    state = dict(
        {"x": [CoqNVal(x_array, 0)],
         "c": [CoqNVal(carry_array, 0)],
         "na": num_qubits,
         "a": addend,
         "m": modulo
         })
    environment = dict(
        {"x": num_qubits,
         "c": 1
         })
    simulator = Simulator(state, environment)
    simulator.visitRoot(parseTree)
    new_state = simulator.get_state()
    return new_state


# Function to parse TSL file
def parse_tsl_file(file_path):
    test_cases = []
    current_case = {}

    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if not line:
                continue  # Skip empty lines

            if line.startswith("Test Case"):
                if current_case:
                    test_cases.append(current_case)
                current_case = {}  # Reset current case for next one
                continue  # Move to the next line

            # Split the line into key and value based on ':'
            if ':' in line:
                key, value = line.split(":", 1)
                key = key.strip().lower()  # Normalize key to lowercase
                value = value.strip()

                # Assign the value to the appropriate key in the current case
                if key == 'na':
                    current_case['n'] = value
                elif key == 'x':
                    current_case['x'] = value
                elif key == 'a':
                    current_case['a'] = value
                elif key == 'm':
                    current_case['m'] = value
                elif key =='c':
                    current_case['c']=value

    # Append the last case if it exists
    if current_case:
        test_cases.append(current_case)

    return test_cases




def get_value_n():
    pass
def get_value_m():
    pass

# Returns the value for the variable type in the specified range
def get_value(range_type, param_type, val):

    if range_type == 'small':
       pass
    elif range_type== 'medium':
        pass
    elif range_type== 'large':
        pass
    elif range_type== 'max_value':
        pass
    elif range_type== 'zero':
        pass

# Save the mapped TSL values to a JSON file so they can be reused
def save_mapped_tsl_to_file(test_cases, output_file):
    # If the file already exists, load it instead of generating new values
    if os.path.exists(output_file):
        print(f"Mapped TSL file {output_file} already exists. Loading existing values.")
        return
    mapped_test_cases = []

    for case in test_cases:
        print(f"Current case: {case}")  # Debugging output

        if 'M' not in case:  # Check if 'M' is missing
            print("Skipping test case due to missing 'M'")  # Handle missing M
            continue  # Skip the test case if 'M' is missing
    for case in test_cases:
        mapped_case = {

        }

        mapped_test_cases.append(mapped_case)

    # Save the mapped values to a JSON file
    with open(output_file, 'w') as f:
        json.dump(mapped_test_cases, f, indent=4)

    print(f"Mapped TSL values saved to {output_file}")


# Load mapped values from JSON file
def load_mapped_tsl_from_file(file_path):
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File {file_path} not found. Ensure the values are saved first.")

    with open(file_path, 'r') as f:
        return json.load(f)




#def test_tsl_case():




def test_in_range_addition(parse_tree):
    test_cases = [
        {"num_qubits": 16, "val_x": 22, "val_a": 971, "modulo": 1024, "expected_result": (22 + 971) % 1024, "description": "Small Even, Large Odd"},
        {"num_qubits": 16, "val_x": 150, "val_a": 25, "modulo": 256, "expected_result": (150 + 25) % 256, "description": "Medium Even, Small Odd"},
        {"num_qubits": 16, "val_x": 999, "val_a": 1025, "modulo": 2048, "expected_result": (999 + 1025) % 2048, "description": "Large Odd, Medium Odd"},
        {"num_qubits": 16, "val_x": 0, "val_a": 1, "modulo": 16, "expected_result": (0 + 1) % 16, "description": "Small Even, Small Odd"},
        {"num_qubits": 32, "val_x": 500000, "val_a": 1000000, "modulo": 1048576, "expected_result": (500000 + 1000000) % 1048576, "description": "Medium Even, Large Odd"}
    ]

    for case in test_cases:
        assert case["val_x"] < 2**(case["num_qubits"] - 1), f"val_x exceeds limit for {case['description']}"
        assert case["val_a"] < 2**(case["num_qubits"] - 1), f"val_a exceeds limit for {case['description']}"
        new_state = simulate_rz_mod_adder(parse_tree, case["val_x"], case["val_a"], case["modulo"], case["num_qubits"])
        assert case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case["num_qubits"]), f"Test failed for case: {case['description']}. Expected {case['expected_result']}, got {bit_array_to_int(new_state.get('x')[0].getBits(), case['num_qubits'])}"


def test_large_numbers_addition(parse_tree):
    test_cases = [
        {"num_qubits": 24, "val_x": 1000000, "val_a": 1000000, "modulo": 16777216, "expected_result": (1000000 + 1000000) % 16777216, "description": "Large numbers with large modulo"},
        {"num_qubits": 48, "val_x": 200000000000, "val_a": 300000000000, "modulo": 281474976710656, "expected_result": (200000000000 + 300000000000) % 281474976710656, "description": "Very large numbers with large modulo"},
        {"num_qubits": 64, "val_x": 2**63 - 1, "val_a": 1, "modulo": 2**64, "expected_result": (2**63 - 1 + 1) % 2**64, "description": "Edge case with max 64-bit integer"},
        {"num_qubits": 24, "val_x": 500000, "val_a": 2000000, "modulo": 8388608, "expected_result": (500000 + 2000000) % 8388608, "description": "Large number addition with 24-bit modulo"},
        {"num_qubits": 32, "val_x": 12345678, "val_a": 98765432, "modulo": 494967295, "expected_result": (12345678 + 98765432) % 494967295, "description": "Arbitrary large numbers with 32-bit modulo"}
    ]

    for case in test_cases:
        assert case["val_x"] < 2**(case["num_qubits"] - 1), f"val_x exceeds limit for {case['description']}"
        assert case["val_a"] < 2**(case["num_qubits"] - 1), f"val_a exceeds limit for {case['description']}"
        new_state = simulate_rz_mod_adder(parse_tree, case["val_x"], case["val_a"], case["modulo"], case["num_qubits"])
        assert case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case["num_qubits"]), f"Test failed for case: {case['description']}. Expected {case['expected_result']}, got {bit_array_to_int(new_state.get('x')[0].getBits(), case['num_qubits'])}"


def test_zero_addition(parse_tree):
    test_cases = [
        {"num_qubits": 16, "val_x": 1234, "val_a": 0, "modulo": 27160, "expected_result": 1234 % 27160, "description": "Adding zero"}
    ]

    for case in test_cases:
        assert case["val_x"] < 2**(case["num_qubits"] - 1), f"val_x exceeds limit for {case['description']}"
        new_state = simulate_rz_mod_adder(parse_tree, case["val_x"], case["val_a"], case["modulo"], case["num_qubits"])
        assert case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case["num_qubits"]), f"Test failed for case: {case['description']}. Expected {case['expected_result']}, got {bit_array_to_int(new_state.get('x')[0].getBits(), case['num_qubits'])}"


def test_overflow_addition(parse_tree):
    test_cases = [
        {"num_qubits": 16, "val_x": 2**15 - 2, "val_a": 1, "modulo": 2**15-1, "expected_result": (2**15 - 2 + 1) % (2**15-1), "description": "Overflow case 1"},
        {"num_qubits": 32, "val_x": 2**31 - 2, "val_a": 1, "modulo": 2**31-1, "expected_result": (2**31 - 2 + 1) % (2**31-1), "description": "Overflow case 2"}
    ]

    for case in test_cases:
        assert case["val_x"] < 2**(case["num_qubits"] - 1), f"val_x exceeds limit for {case['description']}"
        assert case["val_a"] < 2**(case["num_qubits"] - 1), f"val_a exceeds limit for {case['description']}"
        new_state = simulate_rz_mod_adder(parse_tree, case["val_x"], case["val_a"], case["modulo"], case["num_qubits"])
        assert case["expected_result"] == bit_array_to_int(new_state.get('x')[0].getBits(), case["num_qubits"]), f"Test failed for case: {case['description']}. Expected {case['expected_result']}, got {bit_array_to_int(new_state.get('x')[0].getBits(), case['num_qubits'])}"
