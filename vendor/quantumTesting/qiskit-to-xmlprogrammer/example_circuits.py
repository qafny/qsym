"""
This file contains three example circuits to showcase qiskit_to_xmlprogrammer.

Run this file to convert the QuantumCircuits into XMLProgrammer format.
"""

import math
import qiskit
from qiskit_to_xmlprogrammer import QCtoXMLProgrammer
from qiskit import transpile
from qiskit import QuantumCircuit
from qiskit.converters import circuit_to_dag
from qiskit.dagcircuit import DAGInNode, DAGOpNode, DAGNode, DAGOutNode
from qiskit.visualization import dag_drawer
import graphviz
import os
import sys
from qiskit.circuit.library.arithmetic import FullAdderGate

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
# current_dir = os.path.dirname(os.path.abspath(__file__))
# sys.path.append(os.path.join(current_dir, "PQASM"))

from AST_Scripts.XMLProgrammer import QXProgram, QXQID, QXCU, QXX, QXH, QXRZ, QXRY

# Ensure graphviz is in the PATH (for dag drawing)
os.environ["PATH"] += os.pathsep + r"C:\Program Files\Graphviz\bin"



# --------------------------- EXAMPLE CIRCUITS ---------------------------------

# ----- 1: Common gates

qc = QuantumCircuit(2, 2)
qc.h(0)
qc.cx(0, 1)
qc.h(1)
qc.x(1)
qc.measure([0,1], [0,1])
qcEx1 = qc.copy()

# dag_img = dag_drawer(dagEx1, style="color")
# dag_img.save('dagEx1.png')

# ----- 2: All qiskit gates

qc = QuantumCircuit(3, 1)
qc.h(0)
qc.cx(0, 1)
qc.x(2)
qc.z(2)
qc.s(1)
qc.t(0)
qc.cz(1, 2)
qc.sdg(1)
qc.tdg(0)
qc.y(0)
qcEx2 = qc.copy()

# ----- 3: 3-Qubit GHZ

qc = QuantumCircuit(3, 0)
qc.h(0)
qc.cx(0, 1)
qc.cx(1, 2)
qcEx3 = qc.copy()


# -------------------------- COMPILE TO XMLPROGRAMMER --------------------------


visitor = QCtoXMLProgrammer()

visitor.startVisit(qcEx1, circuitName="Example Circuit 1", optimiseCircuit=True, showDecomposedCircuit=True)
visitor.startVisit(qcEx2, circuitName="Example Circuit 2", optimiseCircuit=True)
visitor.startVisit(qcEx3, circuitName="Example Circuit 3", optimiseCircuit=True)