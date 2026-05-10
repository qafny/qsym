import time
import pytest
from antlr4 import InputStream, CommonTokenStream
import os
import sys

current_dir = os.path.dirname(os.path.realpath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.insert(0,parent_dir)

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

def simulate_cl_mult(x_array_value, y_array_value, result_array_val, num_qubits, tree):

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
    simulator.visitRoot(tree[0])
    new_state = simulator.get_state()
    return new_state


parse_tree = get_tree()

from hypothesis import given, strategies as st, assume, settings, HealthCheck


@st.composite
def positive_inputs(draw):
    # generate only non-overflow positive cases.
    n = draw(st.sampled_from([8,16,24, 30, 32,40, 48, 56, 64]))
    x = draw(st.integers(min_value = 0, max_value = 2**(n-1)))
    y = draw(st.integers(min_value = 0, max_value = 2**(n-1)))
    assume (x * y < (2**n))
    expected = x * y
    return (n, x, y, expected)

@given(positive_inputs())
def test_positive_multiplication(case):
    n,x,y,expected = case
    new_state = simulate_cl_mult(x, y, 0, n, parse_tree)
    actual = bit_array_to_int(new_state.get('re')[0].getBits(), n)
    expected = case[3]
    print(f"x:{x}, y:{y}, num_bits:{n}, expected:{expected}, actual:{actual}")
    assert actual == expected


@st.composite
def overflow_inputs(draw):
    n = draw(st.sampled_from([8,12,16,24,32,40,48,56,64]))
    x = draw(st.integers(min_value = 0))
    y = draw(st.integers(min_value = 0))
    expected = (x * y) % (2 ** n)
    return (n,x,y,expected)

@given(overflow_inputs())
def test_overflow(case):
    n,x,y,expected = case
    new_state = simulate_cl_mult(x, y, 0, n, parse_tree)
    actual = bit_array_to_int(new_state.get('re')[0].getBits(), n)
    expected = case[3]
    print(f"x:{x}, y:{y}, num_bits:{n}, expected:{expected}, actual:{actual}")
    assert actual == expected

test_overflow()