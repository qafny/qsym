"""
This file contains a visitor which traverses a Qiskit Quantum Circuit and 
converts it into the format required for "XMLProgrammer.py".
"""

import math
import qiskit
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

from AST_Scripts.XMLProgrammer import QXProgram, QXQID, QXCU, QXX, QXH, QXRZ, QXRY, QXVexp, QXNum
from AST_Scripts.XMLPrinter import XMLPrinter

# Ensure graphviz is in the PATH (for dag drawing)
os.environ["PATH"] += os.pathsep + r"C:\Program Files\Graphviz\bin"

# ------------------------- DAG TO XMLPROGRAMMER -------------------------------

supportedGates = ['h','x','y','z','s','sdg','t','tdg','ry','rz','u','cx','cz']
ignoredGates = ['measure']

def decomposeToGates(qc, optimiseCircuit):
    # Unoptimised circuits are more readable.
    if optimiseCircuit:
        return transpile(qc, basis_gates=supportedGates + ignoredGates)
    return transpile(qc, basis_gates=supportedGates + ignoredGates, optimization_level=0)
   
class QCtoXMLProgrammer:
    def __init__(self):
        self.dag = None

    def startVisit(
        self,
        qc,
        circuitName=None,
        optimiseCircuit=False,
        showDecomposedCircuit=False,
        showInputCircuit=True,
        emit_xml=True,
    ):
        print()
        if circuitName is not None:
            print("------------------- COMPILING CIRCUIT: " + str(circuitName) + " -------------------")
        else:
            print("------------------- COMPILING CIRCUIT: " + "[Name Unknown]" + " -------------------")

        
        if showInputCircuit:
            print("Input Circuit:")
            print(qc.draw())
            print()


        qc = decomposeToGates(qc, optimiseCircuit)
        if showDecomposedCircuit:
            print("Decomposed Circuit:")
            print(qc.draw())

        self.dag = circuit_to_dag(qc)

        # Dictionary mapping Qiskit qubits to XMLProgrammer qubits
        self.XMLQubits = dict()
        for i, qubit in enumerate(self.dag.qubits):
            self.XMLQubits[qubit] = QXNum(i)
        self.visitedNodes = set()
        self.expList = []
        
        for startingNode in self.dag.input_map.values():
            self.visitNode(startingNode)

        self.program = QXProgram(self.expList)
        print("Extracted QXProgram (AST):")
        print(self.program)

        if emit_xml:
            xml = XMLPrinter()
            xml.visitProgram(self.program)
            print("XML Representation:")
            print(xml.xml_output)
        else:
            print("XML emission skipped; AST is available via return value.")

        print("------------------------------------------------------------")
        return self.program

    def visitNode(self, node):
        if node in self.visitedNodes:
            return
        else:
            self.visitedNodes.add(node)
            self.nodeToXMLProgrammer(node)
            for successor in self.dag.successors(node): # type: ignore
                self.visitNode(successor)


    def nodeToXMLProgrammer(self, node):
        if isinstance(node, DAGOpNode):
            inputBits = [self.XMLQubits[q] for q in node.qargs]
            exps = []

            # H, X, Y, Z:
            if node.name == "h":
                exps.append(QXH("test", inputBits[0]))
            elif node.name == "x":
                exps.append(QXX("test", inputBits[0]))
            elif node.name == "y":
                exps.append(QXRY("test", inputBits[0], QXNum(90)))
            elif node.name == "z":
                exps.append(QXRZ("test", inputBits[0], QXNum(180)))

            # Fractional phase shifts (S, SDG, T, TDG):
            elif node.name == "s":
                exps.append(QXRZ("test", inputBits[0], QXNum(90)))
            elif node.name == "sdg":
                exps.append(QXRZ("test", inputBits[0], QXNum(-90)))
            elif node.name == "t":
                exps.append(QXRZ("test", inputBits[0], QXNum(45)))
            elif node.name == "tdg":
                exps.append(QXRZ("test", inputBits[0], QXNum(-45)))

            # General rotations (RX, RY, RZ):
            # elif node.name == "rx":
            #     exps.append(QXRX("rx", inputBits[0], QXNum(node.params[0]*180/math.pi)))
            elif node.name == "ry":
                exps.append(QXRY("test", inputBits[0], QXNum(node.params[0]*180/math.pi)))
            elif node.name == "rz":
                exps.append(QXRZ("test", inputBits[0], QXNum(node.params[0]*180/math.pi)))

            # Universal single-qubit gate (U):
            elif node.name == "u":
                # U(a, b, c) = RZ(a) RY(b) RZ(c)
                exps.append(QXRZ("test", inputBits[0], QXNum(node.params[0]*180/math.pi)))
                exps.append(QXRY("test", inputBits[0], QXNum(node.params[1]*180/math.pi)))
                exps.append(QXRZ("test", inputBits[0], QXNum(node.params[2]*180/math.pi)))

            # Controlled operations (CX, CZ):
            elif node.name == "cx":
                exps.append(QXCU("test", inputBits[0], QXProgram([QXX("test", inputBits[1])])))
            elif node.name == "cz":
                exps.append(QXCU("test", inputBits[0], QXProgram([QXRZ("test", inputBits[1], QXNum(180))])))
            
            elif node.name in ignoredGates:
                pass

            else:
                print("Warning: Unrecognized operation ", node.name)

            # Turn the extracted operation into an expression, and add it to
            # the list of expressions
            for exp in exps:
                

                # Check if the QXNum is actually a number. This is important for
                # parameterised circuits, sunce otherwise we get compiled cases such as
                # QXRY(id=ry, v=QXQID(id=None), angle=57.29577951308232*θ[0]).
                # if there is an error, we raise it here

   
                if type(exp) in [QXRY, QXRZ]:
                    try:
                        float(exp.num().num())
                    except Exception as e:
                        raise TypeError("Error: An unset external parameter in a parameterised circuit was found. From gate: " + str(node.name) + " with angle: " + str(exp.angle) + ". Please bind all parameters before compiling to XMLProgrammer.")

                self.expList.append(exp)

            
            


