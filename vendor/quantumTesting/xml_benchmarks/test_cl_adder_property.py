from antlr4 import InputStream, CommonTokenStream
import sys
import os

current_dir = os.path.dirname(os.path.realpath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.insert(0,parent_dir)

from AST_Scripts.XMLExpLexer import XMLExpLexer
from AST_Scripts.XMLExpParser import XMLExpParser
from AST_Scripts.ProgramTransformer import ProgramTransformer
from AST_Scripts.ValidatorProgramVisitors import SimulatorValidator
from AST_Scripts.Retrievers import MatchCounterRetriever
from AST_Scripts.simulator import CoqNVal, Simulator, bit_array_to_int, to_binary_arr

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
    new_tree = read_program(f"{os.path.dirname(os.path.realpath(__file__))}/cl_adder_good.xml")

    valid_tree = True

    try:
        # Validation of the Constraints.
        # Added per Dr. Li's suggestion on 11/16 to scoop out the validator behaviour out of the simulator as there can be
        # programs which does not always need to follow constraints like only having 1 app tag.
        validator = SimulatorValidator()
        validator.visitRoot(new_tree)

        # Non-Decreasing Recursive Fixed Point Factor Check
    except Exception as e:
        print('\n ==============', e, '==============')
        valid_tree = False

    retriever = MatchCounterRetriever()
    retriever.visitRoot(new_tree)
    return new_tree, retriever, valid_tree

parsetree = get_tree()


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


from hypothesis import given, strategies as st, assume, settings, HealthCheck

@settings(suppress_health_check=[HealthCheck.filter_too_much], deadline = None)
@given( na = st.sampled_from([8,16,32,64]),
    ca = st.sampled_from([0]),
    xa = st.sampled_from([30,100]),
    ya = st.sampled_from([0, 10, 50, 999, 1000, 100])    
)
def test_property_addition_with_edge_case_M(na, ca, xa, ya, parse_tree):
    print (f"test_property_addition_with_edge_case_M() called with na = {na}, ca = {ca}, xa = {xa}, ya = {ya}")
    if (parse_tree[1]):
        expected = (xa + ya) % (2 ** na)
        new_state = simulate_cl_adder(xa, ya, ca, na, parse_tree[0])
        ya_value = new_state.get('ya')
        assert ya_value is not None, "Key 'ya' not found in new_state"
        calculated = bit_array_to_int(ya_value[0].getBits(), na)
        print("expected: ", expected , " calculated: ", calculated)        
        assert calculated == expected
    else:
         assert False
        

@settings(suppress_health_check=[HealthCheck.filter_too_much], deadline= None)
@given( na = st.sampled_from([10,16]),
    ca = st.sampled_from([0]),
    xa = st.sampled_from([30,100]),
    ya = st.sampled_from([0])    
)
def test_addition_with_med_i(na, ca, xa, ya, parse_tree):
    if parse_tree[1]:
        expected = (xa + ya) % (2 ** na)
        new_state = simulate_cl_adder(xa, ya, ca, na, parse_tree[0])
        ya_value = new_state.get('ya')
        assert ya_value is not None, "Key 'ya' not found in new_state"
        calculated = bit_array_to_int(ya_value[0].getBits(), na)
        assert calculated == expected
    else:
        assert False

test_property_addition_with_edge_case_M(parse_tree = parsetree)

@settings(suppress_health_check=[HealthCheck.filter_too_much])
@given(
        num_qubits = st.sampled_from([8*i for i in range(1,9)]),
        val_x = st.integers(min_value = 0),
        val_y= st.integers(min_value = 0)
)
def test_in_range_addition(num_qubits, val_x, val_y, parse_tree):
    # test for positive integers.
    print(f"range_addition() called with n_bits= {num_qubits}, x = {val_x}, y = {val_y}")
    # print(f"parse_tree valid: {parse_tree}")

    if parse_tree[0]:
        expected = (val_x + val_y) % (2 ** num_qubits)
        new_state = simulate_cl_adder(val_x, val_y, 0, num_qubits, parse_tree[0])
        ya_value = new_state.get('ya')
        assert ya_value is not None, "Key 'ya' not found in new_state"
        actual = bit_array_to_int(ya_value[0].getBits(), num_qubits) 
        assert expected == actual
    else:
        assert False

# test_in_range_addition(parse_tree = parsetree) # fails for val_x == val_y

@settings(suppress_health_check=[HealthCheck.filter_too_much])
@given(
        num_qubits = st.sampled_from([8*i for i in range(1,9)]),
        val_x = st.integers(min_value = 0),
        val_y= st.integers(min_value = 0)
)
def test_in_range_addition_val_x(num_qubits, val_x, val_y, parse_tree):
    # test for positive integers.
    if (val_x == val_y):
        return
    print(f"range_addition() called with n_bits = {num_qubits}, x = {val_x}, y = {val_y}")
    if (parse_tree[0]):
        new_state = simulate_cl_adder(val_x, val_y, 0, num_qubits, parse_tree[0])
        xa_value = new_state.get('xa')
        assert xa_value is not None, "Key 'xa' not found in new_state"
        assert val_x == bit_array_to_int(xa_value[0].getBits(), num_qubits)
    else:
        assert False

# test_in_range_addition_val_x(parse_tree=parsetree) # fails for smaller inputs.
