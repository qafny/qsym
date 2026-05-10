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

    try:
        # Validation of the Constraints.
        # Added per Dr. Li's suggestion on 11/16 to scoop out the validator behaviour out of the simulator as there can be
        # programs which does not always need to follow constraints like only having 1 app tag.
        validator = SimulatorValidator()
        validator.visitRoot(new_tree)

        # Non-Decreasing Recursive Fixed Point Factor Check
        rpf_retriever = RPFRetriever()
        rpf_retriever.visitRoot(new_tree)
        rpf_validator = AppRPFValidator(rpf_retriever)
        rpf_validator.visitRoot(new_tree)
    except Exception as e:
        print('\n ==============', e, '==============')
        valid_tree = False

    retriever = MatchCounterRetriever()
    retriever.visitRoot(new_tree)
    return new_tree, valid_tree


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
    print('pt_output', pt_output)
    print('pt_output type', type(pt_output))
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
    {"na": 20, "xa": 5, "ya": 5, "ca": 0, "expected": 10}
]

bitwise_test_instances = process_bitwise_test_cases(test_cases_for_bitwise)
range_addition_test_instances = [
    {"num_qubits": 20, "val_x": 22, "val_y": 971, "expected_result": 993, "description": "Small Even, Large Odd"},
    {"num_qubits": 16, "val_x": 150, "val_y": 25, "expected_result": 175, "description": "Medium Even, Small Odd"},
    {"num_qubits": 7, "val_x": 4, "val_y": 3, "expected_result": 7, "description": "Small Odd, Small Odd"},
    {"num_qubits": 11, "val_x": 100, "val_y": 1911, "expected_result": 2011,
     "description": "Small Even, Small Odd"},
    {"num_qubits": 3, "val_x": 1, "val_y": 2, "expected_result": 3, "description": "Medium Even, Medium Odd"},
    {"num_qubits": 38, "val_x": 40349, "val_y": 343804091, "expected_result": 343844440,
     "description": "Max 16-bit Odd, Small Odd"},
    {"num_qubits": 16, "val_x": 16383, "val_y": 16384, "expected_result": 32767,
     "description": "Half 16-bit Odd, Half 16-bit Even"},
    {"num_qubits": 16, "val_x": 1, "val_y": 65534, "expected_result": 65535,
     "description": "Small Odd, Max 16-bit Even"},
    {"num_qubits": 16, "val_x": 32768, "val_y": 32767, "expected_result": 65535,
     "description": "Half 16-bit Even, Half 16-bit Odd"},
]
zero_addition_test_instances = [
    {"num_qubits": 16, "val_x": 0, "val_y": 0, "expected_result": 0, "description": "Zero Addition"},
    {"num_qubits": 78, "val_x": 0, "val_y": 1, "expected_result": 1, "description": "Zero and Small Odd"},
    {"num_qubits": 2, "val_x": 0, "val_y": 2, "expected_result": 2, "description": "Zero and Small Even"},
]
overflow_test_instances = [
    {"num_qubits": 16, "val_x": 65535, "val_y": 1, "expected_result": 0, "description": "Max 16-bit Odd, 1"},
    {"num_qubits": 14, "val_x": 74734, "val_y": 47001, "expected_result": 7047,
     "description": "Half 16-bit Odd, Half 16-bit Odd"},
    {"num_qubits": 3, "val_x": 74, "val_y": 85310, "expected_result": 0,
     "description": "Half 16-bit Even, Half 16-bit Even"},
    {"num_qubits": 46, "val_x": 423532800, "val_y": 853232733800242510, "expected_result": 11711069599310,
     "description": "Half 16-bit Odd, Half 16-bit Even"},
]
negative_test_instances = [
    {"num_qubits": 5, "val_x": -20, "val_y": 5, "expected_result": 17,
     "description": "Small negative, positive sum"},
    {"num_qubits": 8, "val_x": -250, "val_y": 200, "expected_result": 206,
     "description": "Medium negative, medium positive"},
    {"num_qubits": 16, "val_x": -5000, "val_y": 4900, "expected_result": 65436,
     "description": "Large negative, large positive"},
    {"num_qubits": 24, "val_x": -16777210, "val_y": -10, "expected_result": 16777212,
     "description": "Negative and slightly more negative"},
    {"num_qubits": 32, "val_x": -4294967296, "val_y": -10, "expected_result": 4294967286,
     "description": "Large negative, slightly negative"},
    {"num_qubits": 40, "val_x": -1099511627776, "val_y": 100, "expected_result": 100,
     "description": "Very large negative, small positive"},
    {"num_qubits": 48, "val_x": -281474976710656, "val_y": -281474976700000, "expected_result": 10656,
     "description": "Very large negative, slightly less large negative"},
    {"num_qubits": 56, "val_x": -72057594037927936, "val_y": 1000, "expected_result": 1000,
     "description": "Huge negative, small positive"},
    {"num_qubits": 64, "val_x": -18446744073709551616, "val_y": 18446744073709551500,
     "expected_result": 18446744073709551500,
     "description": "Extremely large negative, slightly less large positive"},
    {"num_qubits": 78, "val_x": -151115727451828646838272, "val_y": -10,
     "expected_result": 151115727451828646838262, "description": "Maximum negative, slightly more negative"}
]

@pytest.mark.parametrize("num_qubits, val_x, val_y, expected", [
    (case["num_qubits"], case["val_x"], case["val_y"], case["expected_result"])
    for case in range_addition_test_instances
])
def test_in_range_addition_expected(num_qubits, val_x, val_y, expected, parse_tree):
    if parse_tree[1]:
        new_state = simulate_cl_adder(val_x, val_y, 0, num_qubits, parse_tree[0])
        assert expected == bit_array_to_int(new_state.get('ya')[0].getBits(), num_qubits)
    else:
        assert False

@pytest.mark.parametrize("num_qubits, val_x, val_y, expected", [
    (case["num_qubits"], case["val_x"], case["val_y"], case["expected_result"])
    for case in range_addition_test_instances
])
def test_in_range_addition_val_x(num_qubits, val_x, val_y, expected, parse_tree):
    if parse_tree[1]:
        new_state = simulate_cl_adder(val_x, val_y, 0, num_qubits, parse_tree[0])
        assert val_x == bit_array_to_int(new_state.get('xa')[0].getBits(), num_qubits)
    else:
        assert False


@pytest.mark.parametrize("num_qubits, val_x, val_y, expected", [
    (case["num_qubits"], case["val_x"], case["val_y"], case["expected_result"])
    for case in zero_addition_test_instances
])
def test_zero_addition_expected(num_qubits, val_x, val_y, expected, parse_tree):
    if parse_tree[1]:
        new_state = simulate_cl_adder(val_x, val_y, 0, num_qubits, parse_tree[0])
        assert expected == bit_array_to_int(new_state.get('ya')[0].getBits(), num_qubits)
    else:
        assert False


@pytest.mark.parametrize("num_qubits, val_x, val_y, expected", [
    (case["num_qubits"], case["val_x"], case["val_y"], case["expected_result"])
    for case in zero_addition_test_instances
])
def test_zero_addition_val_x(num_qubits, val_x, val_y, expected, parse_tree):
    if parse_tree[1]:
        new_state = simulate_cl_adder(val_x, val_y, 0, num_qubits, parse_tree[0])
        assert val_x == bit_array_to_int(new_state.get('xa')[0].getBits(), num_qubits)
    else:
        assert False


# TODO: Please check whether this test case is correct
@pytest.mark.parametrize("num_qubits, val_x, val_y, expected", [
    (case["num_qubits"], case["val_x"], case["val_y"], case["expected_result"])
    for case in overflow_test_instances
])
def test_overflow_addition(num_qubits, val_x, val_y, expected, parse_tree):
    if parse_tree[1]:
        new_state = simulate_cl_adder(val_x, val_y, 0, num_qubits, parse_tree[0])
        assert expected == bit_array_to_int(new_state.get('ya')[0].getBits(), num_qubits)
    else:
        assert False


@pytest.mark.parametrize("num_qubits, val_x, val_y, expected", [
    (case["num_qubits"], case["val_x"], case["val_y"], case["expected_result"])
    for case in negative_test_instances
])
def test_negative_addition(num_qubits, val_x, val_y, expected, parse_tree):
    if parse_tree[1]:
        new_state = simulate_cl_adder(val_x, val_y, 0, num_qubits, parse_tree[0])
        assert expected == bit_array_to_int(new_state.get('ya')[0].getBits(), num_qubits)
    else:
        assert False


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
    if parse_tree[1]:
        b_expected = to_binary_arr(expected, na)
        b_calculated = to_binary_arr(calculated, na)

        try:
            assert b_expected[j] == b_calculated[j]

        except Exception as e:
            print()
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


@pytest.mark.parametrize("na ,ca , xa, ya", [
    (case['na'], case['ca'], case['xa'], case['ya'])
    for case in [{'na': 10, 'ca': 0, 'xa': 30, 'ya': 0}, {'na': 16, 'ca': 0, 'xa': 100, 'ya': 0}]
])
def test_addition_with_edge_case_M(na, ca, xa, ya, parse_tree):
    if parse_tree[1]:
        expected = (xa + ya) % (2 ** na)
        new_state = simulate_cl_adder(xa, ya, ca, na, parse_tree[0])
        calculated = bit_array_to_int(new_state.get('ya')[0].getBits(), na)
        assert calculated == expected
    else:
        assert False


@pytest.mark.parametrize("na ,ca , xa, ya", [
    (case['na'], case['ca'], case['xa'], case['ya'])
    for case in [{'na': 8, 'ca': 0, 'xa': 30, 'ya': 10}, {'na': 16, 'ca': 0, 'xa': 30, 'ya': 50},
                 {'na': 32, 'ca': 0, 'xa': 30, 'ya': 999}]
])
def test_addition_with_med_i(na, ca, xa, ya, parse_tree):
    if parse_tree[1]:
        expected = (xa + ya) % (2 ** na)
        new_state = simulate_cl_adder(xa, ya, ca, na, parse_tree[0])
        calculated = bit_array_to_int(new_state.get('ya')[0].getBits(), na)
        assert calculated == expected
    else:
        assert False


# def test_constraint_if_checking_holds(parse_tree):
#     if parse_tree[1]:
#         if_validate = IfConditionValidator()
#         if_validate.visitRoot(parse_tree[0])

#         assert True
#     else:
#         assert False


# def test_constraint_subtraction_holds(parse_tree):
#     if parse_tree[1]:
#         subtraction_validate = SubtractionSecondOperandValidator()
#         subtraction_validate.visitRoot(parse_tree[0])

#         assert True
#     else:
#         assert False


# def test_constraint_operators_holds(parse_tree):
#     if parse_tree[1]:
#         operators_validate = SRGateVexpValidator()
#         operators_validate.visitRoot(parse_tree[0])

#         assert True
#     else:
#         assert False


def test_to_check_at_least_one_app_func(parse_tree):
    retriever = MatchCounterRetriever()
    retriever.visitRoot(parse_tree[0])
    app_count = retriever.get_app_counter()
    assert app_count >= 1


def test_to_ensure_no_if_exp(parse_tree):
    retriever = MatchCounterRetriever()
    retriever.visitRoot(parse_tree[0])
    if_count = retriever.get_if_counter()
    assert if_count == 0


def test_to_check_result_greater_than_input(parse_tree):
    na, ca, xa, ya = 8, 0, 20, 30

    if parse_tree[1]:
        new_state = simulate_cl_adder(xa, ya, ca, na, parse_tree[0])
        calculated = bit_array_to_int(new_state.get('ya')[0].getBits(), na)
        assert calculated > ya
    else:
        assert False


# @pytest.mark.parametrize("na, xa_val, ya_val, ca_val", [
#     (case['na'], case['xa'], case['ya'], case['ca'])
#     for case in mapped_test_cases
# ])
def test_cl_adder_correctness_x(na: int, xa_val: int, ya_val: int, ca_val: int, parse_tree):
    """
    Tests the functional correctness of the cl_adder:
    - ya should be (xa + ya) % 2^na
    - xa should remain unchanged
    - ca should remain unchanged (0)
    """
    # cl_adder_parse_tree will now raise an exception directly if validation fails
    # So, valid_tree check is no longer needed here.

    # Expected values based on the problem description
    expected_xa = xa_val  # xa should be unchanged

    # Run the simulator
    if parse_tree[1]:
        new_state = simulate_cl_adder(xa_val, ya_val, ca_val, na, parse_tree[0])
        result_xa = bit_array_to_int(new_state.get('xa')[0].getBits(), na)

        assert result_xa == expected_xa
    else:
        assert False


# @pytest.mark.parametrize("na, xa_val, ya_val, ca_val", [
#     (case['na'], case['xa'], case['ya'], case['ca'])
#     for case in mapped_test_cases
# ])
def test_cl_adder_correctness_y(na: int, xa_val: int, ya_val: int, ca_val: int, parse_tree):
    """
    Tests the functional correctness of the cl_adder:
    - ya should be (xa + ya) % 2^na
    - xa should remain unchanged
    - ca should remain unchanged (0)
    """
    # cl_adder_parse_tree will now raise an exception directly if validation fails
    # So, valid_tree check is no longer needed here.

    # Expected values based on the problem description
    expected_ya = (xa_val + ya_val) % (2 ** na)

    # Run the simulator
    if parse_tree[1]:
        new_state = simulate_cl_adder(xa_val, ya_val, ca_val, na, parse_tree[0])
        result_ya = bit_array_to_int(new_state.get('ya')[0].getBits(), na)

        assert result_ya == expected_ya
    else:
        assert False


# @pytest.mark.parametrize("na, xa_val, ya_val, ca_val", [
#     (case['na'], case['xa'], case['ya'], case['ca'])
#     for case in mapped_test_cases
# ])
def test_cl_adder_correctness_c(na: int, xa_val: int, ya_val: int, ca_val: int, parse_tree):
    """
    Tests the functional correctness of the cl_adder:
    - ya should be (xa + ya) % 2^na
    - xa should remain unchanged
    - ca should remain unchanged (0)
    """
    # cl_adder_parse_tree will now raise an exception directly if validation fails
    # So, valid_tree check is no longer needed here.

    # Expected values based on the problem description
    expected_ca = ca_val  # ca should be unchanged (initialized to 0)

    # Run the simulator
    if parse_tree[1]:
        new_state = simulate_cl_adder(xa_val, ya_val, ca_val, na, parse_tree[0])
        result_ca = bit_array_to_int(new_state.get('ca')[0].getBits(), 1)

        assert result_ca == expected_ca
    else:
        assert False


@pytest.fixture(scope="session", autouse=True)
def starter(request):
    start_time = time.time()

    def finalizer():
        print("runtime: {}".format(str(time.time() - start_time)))

    request.addfinalizer(finalizer)
