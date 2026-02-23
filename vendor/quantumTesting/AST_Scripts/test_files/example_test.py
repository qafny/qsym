import sys
import os

current_dir = os.path.dirname(os.path.realpath(__file__))
parent_dir = os.path.dirname(current_dir)
grandparent_dir = os.path.dirname(parent_dir)
sys.path.insert(0,parent_dir)
sys.path.insert(0,grandparent_dir)
sys.path.append(grandparent_dir+'/qiskit-to-xmlprogrammer')
from XMLProgrammer import * 
from AbstractProgramVisitor import *
from ProgramVisitor import *
from ValidatorProgramVisitors import *
from Retrievers import * 
from simulator import *
from qiskit_to_xmlprogrammer import *

# example from https://docs.pytest.org/en/stable/
# def inc(x):
#     return x + 1

# def test_answer():
#     assert inc(3) == 4

def test_qxexp():
    test = QXProgram([QXExp()])
    assert type(test.exp(0)) == QXExp

def test_not_qxexp():
    test = QXProgram([])
    assert not type(test.exp(0)) == QXExp

def test_qxroot_prog():
    test = QXRoot(QXProgram([QXExp()]))
    assert type(test.program()) == QXProgram

def test_rpfretriever_idx():
    test = RPFRetriever()
    assert test.get_rpf_index() == -1

# def test_program_visitor_idexp_program_visitor():
#     test = ProgramVisitor()
#     assert not type(test.visitIDExp(QXIDExp('test'))) == int

def test_program_visitor_idexp_sim_validator():
    test = SimulatorValidator()
    assert type(test.visitIDExp(QXIDExp('test'))) == int

def test_coq_n_val():
    test = CoqNVal([True, False], 1)
    assert test.getPhase() == 1
    assert test.getBits()[0]
    assert not test.getBits()[1]

def test_bit_array_to_int():
    assert bit_array_to_int([True, True], 2) == 3

def test_bit_array_to_int_2():
    assert bit_array_to_int([False, True], 2) == 2

def test_bit_array_to_int_3():
    assert bit_array_to_int([True, False], 2) == 1

def test_bit_array_to_int_4():
    test = [True, False]
    test.reverse()
    assert bit_array_to_int(test, 2) == 2