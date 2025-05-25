import sys
import os
pj_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
os.chdir(pj_root)

#print(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))


from antlr4 import *
from Programmer import *
from ProgramTransformer import ProgramTransformer
from ExpLexer import ExpLexer
from ExpParser import ExpParser
#from SPVisitor import SymbolicExecutor
from SymEx import SymbolicExecutor


def test_sp():
  
    with open("tests/test10.qfy", "r") as f:
        code = f.read()

    # 2. Parse the code snippet using ANTLR4
    lexer = ExpLexer(InputStream(code))
    stream = CommonTokenStream(lexer)
    parser = ExpParser(stream)
    tree = parser.program()

    transformer = ProgramTransformer()
    program = transformer.visitProgram(tree)
    print(program, '\n\n')
    executor = SymbolicExecutor()
    executor.visitProgram(program)

#     sp_visitor = SPGenerator()
#     program.accept(sp_visitor)

#     # 5. Get the final postcondition
#     final_postcondition = sp_visitor.current_sp

#     # 6. Print the results
#  #   print("Initial Precondition:", initial_precondition)
#     print("Final Postcondition:", final_postcondition)

# Run the test
if __name__ == "__main__":
    test_sp()