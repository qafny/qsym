from qiskit.circuit import Instruction, Barrier, Gate
from qiskit import QuantumCircuit

# class StateAssertion(Instruction):
#     def __init__(self, assertion_str, qubits):
#         """
#         label: A name for the assertion 
#         condition_str: The actual Dafny logic (e.g., 's == One')
#         """
#         super().__init__("state_assertion", len(qubits), 0, [assertion_str])
#         self.assertion_str = assertion_str
#         self.definition = None

# class StateAssertion(Barrier): 
#     def __init__(self, assertion_str, num_qubits):
#         super().__init__(num_qubits,label="state_assertion")
#         self.name = "state_assertion"
#         self.params = [assertion_str]
#     def copy(self, name=None):  
#         new_inst = StateAssertion(self.assertion_str, self.num_qubits, self.label)
#         return new_inst

# class StateAssertion(Instruction):
#     def __init__(self, assertion_str, num_qubits, line=None):
#         # We give it a unique name the transpiler will recognize
#         super().__init__("state_assertion", num_qubits, 0, [])
#         self.metadata = {
#             "assertion_str": assertion_str,
#             "line": line
#         }
#         qc = QuantumCircuit(num_qubits, name="state_assertion")
#         self.definition = qc

#     def copy(self, name=None):
#         # Ensure metadata is copied when the transpiler clones the instruction
#         new_inst = StateAssertion(
#             self.metadata["assertion_str"], 
#             self.num_qubits, 
#             line=self.metadata.get("line")
#         )
#         return new_inst


class StateAssertion(Gate):
    def __init__(self, assertion_str, num_qubits, line=None):
        super().__init__("state_assertion", num_qubits, [])
        
        self.metadata = {
            "assertion_str": assertion_str,
            "line": line
        }
        
        qc = QuantumCircuit(num_qubits, name="state_assertion")
        self.definition = qc

    def copy(self, name=None):
        new_inst = StateAssertion(
            self.metadata["assertion_str"], 
            self.num_qubits, 
            line=self.metadata.get("line")
        )
        return new_inst