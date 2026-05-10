import os
import sys
import time
import pytest
import random
import json
from antlr4 import InputStream, CommonTokenStream
current_dir = os.path.dirname(os.path.realpath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.insert(0,parent_dir)
from AST_Scripts.Retrievers import RPFRetriever, MatchCounterRetriever
from AST_Scripts.ValidatorProgramVisitors import SimulatorValidator
from AST_Scripts.XMLExpLexer import XMLExpLexer
from AST_Scripts.XMLExpParser import XMLExpParser
from AST_Scripts.simulator import CoqNVal, Simulator, bit_array_to_int, to_binary_arr
from AST_Scripts.ProgramTransformer import ProgramTransformer


# for the first step, the fitness is the percentage of correctness. How many test cases a program run correctly.
# the correctness is defined as array, x, y and c, the input is (x,y,c), and the output is (x,x+y,c)
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
    new_tree = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/cl_adder_good.xml")

    valid_tree = True

    # try:
    #     # Validation of the Constraints.
    #     # Added per Dr. Li's suggestion on 11/16 to scoop out the validator behaviour out of the simulator as there can be
    #     # programs which does not always need to follow constraints like only having 1 app tag.
    #     validator = SimulatorValidator()
    #     validator.visitRoot(new_tree)

    # except Exception as e:
    #     print('\n =========', e, '==============')
    #     valid_tree = False

    return new_tree, valid_tree
get_tree()

@pytest.fixture(scope="module")
def parse_tree():
    return get_tree()


def simulate_cl_adder(x_array_value, y_array_value, c_array_value, num_qubits, parse_tree):
    val_array_x = to_binary_arr(x_array_value, num_qubits)
    val_array_y = to_binary_arr(y_array_value, num_qubits)
    num_qubits_ca = 1
    val_array_ca = to_binary_arr(c_array_value, num_qubits_ca)

    state = dict(
        {"xa": [CoqNVal(val_array_x, 0)],
         "ya": [CoqNVal(val_array_y, 0)],
         "ca": [CoqNVal(val_array_ca, 0)],
         "na": num_qubits,
         })
    environment = dict(
        {"xa": num_qubits,
         "ya": num_qubits,
         "ca": num_qubits_ca,
         })

    simulator = Simulator(state, environment)
    simulator.visitRoot(parse_tree)
    new_state = simulator.state
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
                    current_case['na'] = value
                elif key == 'ca':
                    current_case['ca'] = value
                elif key == 'xa':
                    current_case['xa'] = value
                elif key == 'ya':
                    current_case['ya'] = value

    # Append the last case if it exists
    if current_case:
        test_cases.append(current_case)

    return test_cases


# Mapping TSL inputs to actual values
def map_tsl_to_values(term, parameter_type):
    mappings = {
        'na': {  # Size of the qubit array
            'small': (1, 4),
            'medium': (4, 8),
            'large': (8, 16),
        },
        'ca': {  # Initial state of the carry qubit
            'zero_state': (0, 0),
        },
        'xa': {  # Initial state of the qubit array 'x'
            'zero_state': (0, 0),
            'random_state': (101, 1000),
            'max_state': (10001, 65535),

        },
        'ya': {  # Initial state of the qubit array 'y'
            'zero_state': (0, 0),
            'random_state': (101, 1000),
            'max_state': (10001, 65535),

        }
    }

    return mappings[parameter_type].get(term, (0, 0))


def apply_constraints(mapped_case):
    max_val_represent_with_n_bit = ((2 ** mapped_case['na']) - 1)

    # ensure 'xa' < 2^n
    if mapped_case['xa'] > max_val_represent_with_n_bit:
        mapped_case['xa'] = random.randint(1, max_val_represent_with_n_bit)

    # ensure 'ya' < 2^n
    if mapped_case['ya'] > max_val_represent_with_n_bit:
        mapped_case['ya'] = random.randint(1, max_val_represent_with_n_bit)

    return mapped_case


# Save the mapped TSL values to a JSON file so they can be reused
def save_mapped_tsl_to_file(test_cases, output_file):
    # If the file already exists, load it instead of generating new values
    if os.path.exists(output_file):
        print(f"Mapped TSL file {output_file} already exists. Loading existing values.")
        return
    mapped_test_cases = []

    for case in test_cases:
        mapped_case = {
            'na': random.randint(*map_tsl_to_values(case['na'], 'na')),
            'ca': random.randint(*map_tsl_to_values(case['ca'], 'ca')),
            'xa': random.randint(*map_tsl_to_values(case['xa'], 'xa')),
            'ya': random.randint(*map_tsl_to_values(case['ya'], 'ya')),
        }
        mapped_case = apply_constraints(mapped_case)
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


# Usage: First, parse and save the mapped TSL values to a JSON file
# test_cases = parse_tsl_file(f"{os.path.dirname(os.path.realpath(__file__))}/cl_adder.tsl.tsl")
# save_mapped_tsl_to_file(test_cases, f"{os.path.dirname(os.path.realpath(__file__))}/mapped_tsl_values_new.json")

# mapped_test_cases = load_mapped_tsl_from_file(
#     f"{os.path.dirname(os.path.realpath(__file__))}/mapped_tsl_values_new.json")


def process_bitwise_test_cases(test_cases: list):
    pt_output = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/cl_adder_good.xml")
    insts = []
    for test_case in test_cases:
        na = test_case['na']
        ca = test_case['ca']
        xa = test_case['xa']
        ya = test_case['ya']

        expected = (xa + ya) % (2 ** na)
        new_state = simulate_cl_adder(xa, ya, ca, na, pt_output)
        calculated = bit_array_to_int(new_state.get('ya')[0].getBits(), na)

        insts.append((na, expected, calculated))

    return insts

test_cases_for_bitwise = [
    {"na": 20, "xa": 0, "ya": 10, "ca": 10},
    {"na": 20, "xa": 10, "ya": 10, "ca": 10}
]

bitwise_test_instances = process_bitwise_test_cases(test_cases_for_bitwise)
'''
Test Bitwise Addition at j-th bit
=================================

Given an input I, this test checks that for any given bit position 'j',
the j-th bit of the calculated result 'c' matches the j-th bit of the
expected result 'e'. This is a stricter form of functional correctness,
verifying the output at a granular, bit-level.

[c = P(I)] --> c[j] = e[j] for all j in [0, na-1]
'''
@pytest.mark.parametrize("j, na, expected, calculated", [
                                                            (j, na, expected, calculated)
                                                            for (na, expected, calculated) in
                                                            bitwise_test_instances
                                                            for j in range(na)
                                                        ][:150])
def test_addition_bitwise_at_j_bit(j, na, expected, calculated, parse_tree):
    print(expected)
    print(calculated)
    print(parse_tree)
    if parse_tree[1]:
        b_expected = to_binary_arr(expected, na)
        b_calculated = to_binary_arr(calculated, na)
        try:
            assert b_expected[j] == b_calculated[j]

        except Exception as e:
            print()
            assert False
    else:
        assert False


'''
Test Bitshift Equality
======================

Given an input I, this test checks that if the calculated result 'c' is not
equal to the expected result 'e', it might become equal if one of the values
is bit-shifted by 'b' positions. This is a way to check if the result is
"close" to the expected value in a bitwise sense, which can be a desirable
property for programs that fail gracefully.

[c = P(I)] --> (e = c) V (e << b = c) V (e >> b = c) V (c << b = e) V (c >> b = e)
'''
@pytest.mark.parametrize("na, b, expected, calculated", [
                                                            (na, b, expected, calculated)
                                                            for (na, expected, calculated) in
                                                            bitwise_test_instances
                                                            for b in range(1, na + 1)
                                                        ][:150])
def test_addition_bitshifted(na, b, expected, calculated, parse_tree):
    if parse_tree[1]:
        bitshift_stop = expected == calculated
        if not bitshift_stop:
            for k in range(1, b + 1):
                bitshift_stop = bitshift_stop or calculated << b == expected or expected << b == calculated or calculated >> b == expected or expected >> b == calculated

                if bitshift_stop:
                    break

        assert bitshift_stop
    else:
        assert False


'''
Test for the Consistency of Accuracy or Error on jth qubit
==========================================================

Given two inputs I1 and I2, this test checks that if both simulations
produce an incorrect result, the error at a specific bit 'k' is consistent.
This means that if both results are wrong, the bit at position 'k' must also
be wrong in both cases. This rewards predictable error patterns over random ones.

[c1 = P(I1)] ∧ [c2 = P(I2)] --> [(e1 = c1) V (e2 = c2)] V [(e1 != c1) ∧ (e2 != c2) ∧ (e1[k] != c1[k]) ∧ (e2[k] != c2[k])]
'''
@pytest.mark.parametrize("k, na1, e1, c1, na2, e2, c2", [
                                                            (k, na1, e1, c1, na2, e2, c2)
                                                            for idx1, (na1, e1, c1) in
                                                            enumerate(bitwise_test_instances)
                                                            for idx2, (na2, e2, c2) in
                                                            enumerate(bitwise_test_instances) if idx1 < idx2
                                                            for k in range(min(na1, na2))
                                                        ][:150])
def test_bitwise_sets_j_bit_correctly(k, na1, e1, c1, na2, e2, c2, parse_tree):
    if parse_tree[1]:
        b_e1 = to_binary_arr(e1, na1)
        b_c1 = to_binary_arr(c1, na1)

        b_e2 = to_binary_arr(e2, na2)
        b_c2 = to_binary_arr(c2, na2)

        # This case asserts if and only if one of the answers is correct (which makes no room for error at jth bit) or,
        # if both answers are incorrect but in both the answers jth-bit is incorrect (which makes the program preferred)
        correct_case = (e1 == c1 or e2 == c2)
        wrong_case = (e1 != c1 and e2 != c2) and (b_e1[k] != b_c1[k] and b_e2[k] != b_c2[k])

        assert correct_case or wrong_case
    else:
        assert False


@pytest.mark.parametrize("k, e, c", [
                                        (k, e, c)
                                        for (na, e, c) in bitwise_test_instances
                                        for k in range(1, na + 1)
                                        # We need to check whether the difference is less than from 2 ^ 1 to 2 ^ na
                                    ][:150])
def test_bit_position_value_range_boundedness(k, e, c, parse_tree):
    if parse_tree[1]:
        r = 2 ** k
        assert abs(e - c) < r
    else:
        assert False