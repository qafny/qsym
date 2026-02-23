import os
import sys
from tokenize import String

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from AST_Scripts.simulator import Simulator
from AST_Scripts.XMLProgrammer import QXH, QXCU, QXProgram
from qiskit_to_xmlprogrammer import QCtoXMLProgrammer
from qiskit import QuantumCircuit

qc = QuantumCircuit(3, 0)
qc.h(0)
qc.cx(0, 1)
qc.cx(1, 2)

def test_init():
    assert QCtoXMLProgrammer().dag == None

def test_visit():
    visit_output = QCtoXMLProgrammer().startVisit(qc)
    print(visit_output)
    print(visit_output.exp(0).ID())
    assert type(visit_output) == QXProgram
    assert len(visit_output._exps) == 3
    assert type(visit_output.exp(0)) == QXH
    assert type(visit_output.exp(1)) == QXCU
    assert type(visit_output.exp(2)) == QXCU
    assert type(visit_output.exp(0).ID()) == str
    # visit_output.exp(0).accept(Simulator())
    assert (visit_output.exp(0).ID()) == 'h'
    assert (visit_output.exp(1).ID()) == 'cx'
    assert (visit_output.exp(2).ID()) == 'cx'