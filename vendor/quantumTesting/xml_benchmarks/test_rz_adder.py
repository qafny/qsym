import os
import time
import pytest
import random
import json
from antlr4 import InputStream, CommonTokenStream
from Source.quantumCode.AST_Scripts.Counters import VexpCounter
from Source.quantumCode.AST_Scripts.Retrievers import RPFRetriever, MatchCounterRetriever, VexpRetriever
from Source.quantumCode.AST_Scripts.TypeChecker import TypeChecker
from Source.quantumCode.AST_Scripts.TypeDetector import TypeDetector
from Source.quantumCode.AST_Scripts.Validators import SimulatorValidator, AppRPFValidator
from Source.quantumCode.AST_Scripts.XMLExpLexer import XMLExpLexer
from Source.quantumCode.AST_Scripts.XMLExpParser import XMLExpParser
from Source.quantumCode.AST_Scripts.XMLProgrammer import Qty, Nat
from Source.quantumCode.AST_Scripts.simulator import CoqNVal, Simulator, bit_array_to_int, to_binary_arr
from Source.quantumCode.AST_Scripts.ProgramTransformer import ProgramTransformer
import math


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
    #new_tree = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/mutants/mutant_38.xml")
    new_tree = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/rz_adder_good.xml")

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
    return new_tree, retriever, valid_tree


@pytest.fixture(scope="module")
def parse_tree():
    return get_tree()


def run_simulator(n, i, X, M, parseTree):
    val_array = to_binary_arr(X, n)  # Convert value to array
    state = dict({"x": [CoqNVal(val_array, 0)],
                  "size": n,
                  "na": i,
                  "m": M})  # Initial state
    environment = dict({"x": n})  # Environment for simulation

    # Run the Simulator
    y = Simulator(state, environment)
    y.visitRoot(parseTree)
    new_state = y.get_state()
    return bit_array_to_int(new_state.get('x')[0].getBits(), n)


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
                if key == 'n':
                    current_case['n'] = value
                elif key == 'i':
                    current_case['i'] = value
                elif key == 'm':
                    current_case['M'] = value
                elif key == 'x':
                    current_case['X'] = value

    # Append the last case if it exists
    if current_case:
        test_cases.append(current_case)

    return test_cases


# Mapping TSL inputs to actual values
def map_tsl_to_values(term, parameter_type):
    mappings = {
        'n': {  # Size of the qubit array
            'small': (1, 4),
            'medium': (4, 8),
            'large': (8, 16),
        },
        'i': {
            'small': (1, 4),  # Small iteration range
            'medium': (5, 8),
            'large': (9, 16)
        },
        'M': {  # Natural number 'm' to be added in rz_adder
            'small': (1, 10),
            'medium': (11, 100),
            'large': (101, 1000),
            'zero': (0, 0),
            'max_value': (10001, 65535)
        },
        'X': {  # Initial state of the qubit array 'x'
            'zero_state': (0, 0),
            'random_state': (101, 1000),
            'max_state': (10001, 65535),

        }
    }

    return mappings[parameter_type].get(term, (0, 0))


# Function to apply the constraint that 'na' should not exceed 'size'
def apply_constraints(mapped_case):
    # Ensure 'na' is less than or equal to 'size'
    if mapped_case['i'] > mapped_case['n']:
        mapped_case['i'] = random.randint(1, mapped_case['n'])

    max_val_represent_with_n_bit = ((2 ** mapped_case['n']) - 1)

    # ensure 'X' < 2^n
    if mapped_case['X'] > max_val_represent_with_n_bit:
        mapped_case['X'] = random.randint(1, max_val_represent_with_n_bit)

    # ensure 'M' < 2^n
    if mapped_case['M'] > max_val_represent_with_n_bit:
        mapped_case['M'] = random.randint(1, max_val_represent_with_n_bit)

    return mapped_case


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
            'n': random.randint(*map_tsl_to_values(case['n'], 'n')),
            'i': random.randint(*map_tsl_to_values(case['i'], 'i')),
            'X': random.randint(*map_tsl_to_values(case['X'], 'X')),
            'M': random.randint(*map_tsl_to_values(case['M'], 'M')),
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
test_cases = parse_tsl_file(f"{os.path.dirname(os.path.realpath(__file__))}/rz_adder.tsl.tsl")
save_mapped_tsl_to_file(test_cases, f"{os.path.dirname(os.path.realpath(__file__))}/mapped_tsl_values_new.json")

# Load the mapped values from the JSON file
mapped_test_cases = load_mapped_tsl_from_file(
    f"{os.path.dirname(os.path.realpath(__file__))}/mapped_tsl_values_new.json")

''' Support functions for binary tests '''


def process_bitwise_test_cases(test_cases: list):
    pt_output = get_tree()

    insts = []
    for test_case in test_cases:
        X = test_case['X']
        M = test_case['M']
        n = test_case['n']
        i = test_case['i']
        j = test_case['j']

        expected = (X + (M % (2 ** i))) % 2 ** n
        calculated = run_simulator(n, i, X, M, pt_output[0])

        insts.append((n, i, j, X, M, expected, calculated))

    return insts


mapped_bitwise_test_cases = load_mapped_tsl_from_file(
    f"{os.path.dirname(os.path.realpath(__file__))}/mapped_bitwise_values.json")
bitwise_test_instances = process_bitwise_test_cases(mapped_bitwise_test_cases)

''' Support functions for tests that check for the constraints '''


def get_initial_tree():
    initial_tree = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/rz_adder.xml")

    counter = VexpCounter()
    counter.visitRoot(initial_tree)

    return initial_tree, counter.get_count()


initial_tree, vexp_count = get_initial_tree()

''' Tests that check the correctness of the final or computed result/state of the rz_adder'''

'''
Test Bitwise Addition at jth-bit
================================

Given an input I = (n, i, X, M, e) to the program P where,
    1. n is the total number of qubits supported
    2. i is the index of the qubit considered for the calculation; i in Z^+, i in [1, n)
    3. j is the index of the qubit tested
    4. X is the input register 1 (Operand 1); X in {0, 1, 2, 4, ..., 2 ^ (i - 2)}
    5. M is the input register 2 (Operand 2); M = 0 or M = X
    6. e is the expected value from P
, it produces the output c in Z, such that,
    c = P(n, i, X, M)
in which jth qubit e is equal to jth qubit of c. i.e.,
    e[j] = c[j]

[I = (n, i, X, M, e)] ∧ [c = P(n, i, X, M)] --> [e[j] = c[j]]

'''
@pytest.mark.parametrize("i, j, expected, calculated", [
                                                           (i, j, expected, calculated)
                                                           for (_, i, j, X, M, expected, calculated) in
                                                           bitwise_test_instances
                                                       ][:150])
def test_addition_bitwise_at_j_bit(i, j, expected, calculated, parse_tree):
    if parse_tree[2]:
        b_expected = to_binary_arr(expected, i)
        b_calculated = to_binary_arr(calculated, i)

        try:
            assert b_expected[j] == b_calculated[j]

        except Exception as e:
            print()
    else:
        assert False


'''
Test Bitshift Equality
======================

Given an input I = (n, i, X, M, e, b) to the program P where,
    1. n is the total number of qubits supported
    2. i is the index of the qubit considered for the calculation; i in Z^+, i in [1, n)
    3. j is the index of the qubit tested
    4. X is the input register 1 (Operand 1); X in {0, 1, 2, 4, ..., 2 ^ (i - 2)}
    5. M is the input register 2 (Operand 2); M = 0 or M = X
    6. e is the expected value from P
    7. b is the offset of bitshift; b in N, b in [0, i]
, it produces the output c in Z, such that,
    c = P(n, i, X, M)
in which either c left-shifted/right-shifted by b bits is equal to e or e left-shifted/right-shifted by b bits is equal to c. i.e.,
    (e << b = c) V (e >> b = c) V (c << b = e) V (c >> b = e)

[I = (n, i, X, M, e, b)] ∧ [c = P(n, i, X, M)] --> (e << b = c) V (e >> b = c) V (c << b = e) V (c >> b = e)

Intuitively, this fails as much test cases as needed unless the single bit position operation as anticipated from the program
is not observed, even after shifting by b positions.

'''
@pytest.mark.parametrize("i, b, expected, calculated", [
                                                           (i, b, expected, calculated)
                                                           for (_, i, _, _, _, expected, calculated) in
                                                           bitwise_test_instances
                                                           for b in range(1, i + 1)
                                                       ][:150])
def test_addition_bitshifted(i, b, expected, calculated, parse_tree):
    if parse_tree[2]:
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

Given two inputs I1 = (n1, i1, X1, M1, e1), I2 = (n2, i2, X2, M2, e2) and j to the program P where,
    1. nK is the total number of qubits supported in K-th input
    2. iK is the index of the qubit considered for the calculation in K-th input; iK in Z^+, iK in [1, n)
    3. j is the index of the qubit tested
    4. XK is the input register 1 (Operand 1) in K-th input; XK in {0, 1, 2, 4, ..., 2 ^ (i - 2)}
    5. MK is the input register 2 (Operand 2) in K-th input; MK = 0 or MK = XK
    6. eK is the expected value from P for K-th input
    7. k is the index of the qubit of interest; j in N, j in [1, min{i1, i2}]
, it produces the output cK in Z for K-th input, such that,
    cK = P(nK, iK, XK, MK)
for which strictly one of the following is true:
    1. At least one input produces the expected output. i.e., (e1 = c1) V (e2 = c2)
    2. None of the inputs produces the expected output but the error at jth bit is consistent (incorrect at jth bit for both outputs. i.e., 
            (e1 != c1) ∧ (e2 != c2) ∧ (e1[j] != c1[j]) ∧ (e2[j] != c2[j])

[I1 = (n1, i1, X1, M1, e1)] ∧ [c1 = P(n1, i1, X1, M1)] ∧ [I2 = (n2, i2, X2, M2, e2)] ∧ [c2 = P(n2, i2, X2, M2)] --> [(e1 = c1) V (e2 = c2)] V [(e1 != c1) ∧ (e2 != c2) ∧ (e1[j] != c1[j]) ∧ (e2[j] != c2[j])]

Intuitively this fails whenever the bit at a given position is different from the bit at the same position of another test instance, 
given that both test instances have produced wrong outputs. Whenever the output is correct, we do not have to check.

Effectively, this fails when the program fails to produce the same behavior on a single bit position whenever answers are wrong.
Notion: Whenever program misbehaves, predictable error on a bit position is better than random errors on different bit positions.

'''


@pytest.mark.parametrize("k, i1, e1, c1, i2, e2, c2", [
                                                          (k, i1, e1, c1, i2, e2, c2)
                                                          for idx1, (n1, i1, _, _, _, e1, c1) in
                                                          enumerate(bitwise_test_instances)
                                                          for idx2, (n2, i2, _, _, _, e2, c2) in
                                                          enumerate(bitwise_test_instances) if idx1 < idx2
                                                          for k in range(min(i1, i2))
                                                          # 1 * 63 * 16 + 1 * 62 * 16 + ... = 64 * 16 * (Arithmetic Sum of n = 63) = 64 * 16 * 1953 Maximum tests
                                                      ][:150])
def test_bitwise_sets_j_bit_correctly(k, i1, e1, c1, i2, e2, c2, parse_tree):
    if parse_tree[2]:
        b_e1 = to_binary_arr(e1, i1)
        b_c1 = to_binary_arr(c1, i1)

        b_e2 = to_binary_arr(e2, i2)
        b_c2 = to_binary_arr(c2, i2)

        # This case asserts if and only if one of the answers is correct (which makes no room for error at jth bit) or,
        # if both answers are incorrect but in both the answers jth-bit is incorrect (which makes the program preferred)
        correct_case = (e1 == c1 or e2 == c2)
        wrong_case = (e1 != c1 and e2 != c2) and (b_e1[k] != b_c1[k] and b_e2[k] != b_c2[k])

        assert correct_case or wrong_case
    else:
        assert False


'''
Test for the Output within a Bounded Range
==========================================

Given an input I = (n, i, X, M, e, j) to the program P where,
    1. n is the total number of qubits supported
    2. i is the index of the qubit considered for the calculation; i in Z^+, i in [1, n)
    3. j is the index of the qubit tested
    4. X is the input register 1 (Operand 1); X in {0, 1, 2, 4, ..., 2 ^ (i - 2)}
    5. M is the input register 2 (Operand 2); M = 0 or M = X
    6. e is the expected value from P
    7. j is the exponent of base 2 for which the difference between e and c (defined below) is compared against; j in Z^+, j in [1, i]
, it produces the output c in Z, such that,
    c = P(n, i, X, M)
for which the c is bounded within the range of error 2 ^ j. i.e.,
    |e - c| < 2 ^ j

[I = (n, i, X, M, e, j)] ∧ [c = P(n, i, X, M)] --> |e - c| < 2 ^ j

---------------------
Intuitive Explanation
---------------------

Example 1
---------

X = 00010000
M = 00000000

E = 00010000
C = 01100000

This will fail even by bitshift test --> But this is better than 11100000, because of the extra bit (MSB) being wrong.
But this must be rewarded in a certain way since this is better than having a complete random answer.

Example 2
---------

e = 00010000 = 00 + 16 = 16
c = 01100000 = 32 + 64 = 96

Since there are two bits with value 0, this is missed under bitshift test cases.
d = 01010000 = 64 + 16 = 80  (Difference between e and c)
When j = 7; d = 80 < 2 ** 7 => It is always the case that test cases with j >= 7 holds

'''


@pytest.mark.parametrize("k, e, c", [
                                        (k, e, c)
                                        for (_, i, _, _, _, e, c) in bitwise_test_instances
                                        for k in range(1, i + 1)
                                        # We need to check whether the difference is less than from 2 ^ 1 to 2 ^ i
                                    ][:150])
def test_bit_position_value_range_boundedness(k, e, c, parse_tree):
    if parse_tree[2]:
        r = 2 ** k
        assert abs(e - c) < r
    else:
        assert False


@pytest.mark.parametrize("n ,i , X, M", [
    (case['n'], case['i'], case['X'], case['M'])
    for case in [{'n': 10, 'i': 5, 'X': 30, 'M': 0}, {'n': 16, 'i': 5, 'X': 100, 'M': 0}]
])
def test_addition_with_edge_case_M(n, i, X, M, parse_tree):
    if parse_tree[2]:
        expected = (X + (M % (2 ** i))) % 2 ** n
        assert run_simulator(n, i, X, M, parse_tree[0]) == expected
    else:
        assert False


@pytest.mark.parametrize("n ,i , X, M", [
    (case['n'], case['i'], case['X'], case['M'])
    for case in [{'n': 8, 'i': 1, 'X': 30, 'M': 10}, {'n': 16, 'i': 1, 'X': 30, 'M': 50},
                 {'n': 32, 'i': 2, 'X': 30, 'M': 1000}]
])
def test_addition_with_small_i(n, i, X, M, parse_tree):
    if parse_tree[2]:
        expected = (X + (M % (2 ** i))) % 2 ** n
        assert run_simulator(n, i, X, M, parse_tree[0]) == expected
    else:
        assert False


@pytest.mark.parametrize("n ,i , X, M", [
    (case['n'], case['i'], case['X'], case['M'])
    for case in [{'n': 8, 'i': 5, 'X': 30, 'M': 10}, {'n': 16, 'i': 16, 'X': 30, 'M': 50},
                 {'n': 32, 'i': 16, 'X': 30, 'M': 999}]
])
def test_addition_with_med_i(n, i, X, M, parse_tree):
    if parse_tree[2]:
        expected = (X + (M % (2 ** i))) % 2 ** n
        assert run_simulator(n, i, X, M, parse_tree[0]) == expected
    else:
        assert False


''' Tests for Constraints '''

'''
Test for Type Checking
======================

Given the initial program P_0 and the current program P_i, it should always be the case that for all j, j-th vexp in 
P_0 and the j-th vexp in P_i should be of the same type, where 0 < j < K and K is the number of vexp expressions in P_0.

'''


# @pytest.mark.parametrize("idx", [idx for idx in range(vexp_count)])
# def test_constraint_type_checking_holds(idx, parse_tree):
#     if parse_tree[2]:
#         initial_type_environment = {
#             'x': Qty('size'),
#             'na': Nat(),
#             'size': Nat(),
#             'm': Nat()
#         }
#         type_checker = TypeChecker(initial_type_environment)
#         type_checker.visitRoot(initial_tree)

#         type_detector = TypeDetector(type_checker.type_environment)
#         type_detector.visitRoot(initial_tree)

#         it_vexp_ret = VexpRetriever(idx)
#         it_vexp_ret.visitRoot(initial_tree)
#         it_vexp = it_vexp_ret.get_vexp()

#         vexp_val = VexpTypeValidator(idx, it_vexp, type_detector.type_environment)
#         vexp_val.visitRoot(parse_tree[0])

#         assert True
#     else:
#         assert False


'''
It is always the case that the condition of an if expression should be a binary expression 
and must operate using a comparison operator -- the only binary comparison operator we have so far is GNum($)
'''


# def test_constraint_if_checking_holds(parse_tree):
#     if parse_tree[2]:
#         if_validate = IfConditionValidator()
#         if_validate.visitRoot(parse_tree[0])

#         assert True
#     else:
#         assert False


'''
It is always the case that the second operand of a binary expression with the subtraction operator 
“-” remains positive. In the case of num, choose from the set of all natural numbers
'''


# def test_constraint_subtraction_holds(parse_tree):
#     if parse_tree[2]:
#         subtraction_validate = SubtractionSecondOperandValidator()
#         subtraction_validate.visitRoot(parse_tree[0])

#         assert True
#     else:
#         assert False


'''
It is always the case that we only allow addition (+) and subtraction (-) operators inside the SR gate vexp expression.
'''


# def test_constraint_operators_holds(parse_tree):
#     if parse_tree[2]:
#         operators_validate = SRGateVexpValidator()
#         operators_validate.visitRoot(parse_tree[0])

#         assert True
#     else:
#         assert False


''' tests check the generated program correctness with reference to the rz_adder_good program; 
     where the tests check for the presence of certain components like app, if, and other 
     tags or expressions as present in the good program'''


def test_to_ensure_at_most_one_app_func(parse_tree):
    app_count = parse_tree[1].get_app_counter()
    assert app_count <= 1


def test_to_check_at_least_one_app_func(parse_tree):
    app_count = parse_tree[1].get_app_counter()
    assert app_count >= 1


def test_to_ensure_at_most_one_if_exp(parse_tree):
    if_count = parse_tree[1].get_if_counter()
    assert if_count <= 1


def test_to_check_at_least_if_exp(parse_tree):
    if_count = parse_tree[1].get_if_counter()
    assert if_count >= 1


''' Metamorphic tests'''


# To tests the adder always results in a value greater than input (or equal when M is 0).
def test_to_check_result_greater_than_input(parse_tree):
    n, i, X, M = 8, 3, 20, 30

    if parse_tree[2]:
        assert run_simulator(n, i, X, M, parse_tree[0]) > X
    else:
        assert False


# Fixture to track the runtime of tests
@pytest.fixture(scope="session", autouse=True)
def starter(request):
    start_time = time.time()

    def finalizer():
        print("\n runtime: {}".format(str(time.time() - start_time)))

    request.addfinalizer(finalizer)
