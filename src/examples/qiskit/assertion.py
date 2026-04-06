from qiskit.circuit import Instruction, Barrier

# class StateAssertion(Instruction):
#     def __init__(self, condition_str, qubits):
#         """
#         label: A name for the assertion 
#         condition_str: The actual Dafny logic (e.g., 's == One')
#         """
#         super().__init__("state_assertion", len(qubits), 0, [condition_str])
#         self.definition = None

class StateAssertion(Barrier): 
    def __init__(self, condition_str, qubits):
        super().__init__(len(qubits),label="state_assertion")
  #      self.name = "state_assertion"
        self.params = [condition_str]