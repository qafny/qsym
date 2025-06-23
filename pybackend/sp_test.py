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
from ConstraintSolver import ConstraintSolver
from hypothesis import strategies as st
from inputs_generator import extract_input_strategy
from CollectKind import CollectKind
from TypeCollector import TypeCollector
from TypeChecker import TypeChecker
from StateCollector import StateCollector
from PrettyPrinter import PrettyPrinter



def test_sp():
  
    with open("tests/test13.qfy", "r") as f:
        code = f.read()

    # 2. Parse the code snippet using ANTLR4
    lexer = ExpLexer(InputStream(code))
    stream = CommonTokenStream(lexer)
    parser = ExpParser(stream)
    tree = parser.program()

    transformer = ProgramTransformer()
    program = transformer.visitProgram(tree)
    print('\n', program, '\n\n')
    pretty = PrettyPrinter()
    print(pretty.visit(program))
    
                # Collect the types + kinds in the AST
    collect_kind = CollectKind()
    collect_kind.visit(program)
    print("\nCollected kinds:", collect_kind.get_kenv())
    
    type_collector = TypeCollector(collect_kind.get_kenv())
    type_collector.visit(program)
    print("\nCollected types:", type_collector.get_env())


    state_collector = StateCollector(collect_kind.get_kenv(), type_collector.get_env())
    state_collector.visitProgram(program)
    print("\nCollected states:", state_collector.get_env())
    

    


    executor = SymbolicExecutor(collect_kind.get_kenv(), type_collector.get_env(), state_collector.get_env())
    executor.visitProgram(program)
    outsp = executor.state_manager.get_curr_bind()
 #   print("sp:", outsp)
    post = executor.state_manager.get_postcond()
    print("\nPostcondition Pretty:", post)
    post_cond = executor.state_manager.get_postcond_nodes()
#    print("Postcondition:", post_cond)

    # if hasattr(executor, "assertions"): 
    #     for sp, assertion in executor.assertions:
    # #       print("\nAssertion:", assertion)
    #         solver = ConstraintSolver(sp, assertion, extract_input_strategy(sp))
    #         try: 
    #             solver.check_sp_implies_assertion()
    #         except AssertionError as e:
    #             print(f"Assertion failed: {e}")
    #             return 

    # solver = ConstraintSolver(outsp, post_cond, extract_input_strategy(outsp))
    # solver.check_sp_implies_assertion()
#    solver.print_test_cases()


    # input_strategy = st.fixed_dictionaries({
    #     'n': st.integers(min_value=1, max_value=5),
    #     'a': st.integers(min_value=1, max_value=20),
    #     'N': st.integers(min_value=2, max_value=30),
    #     'j': st.integers(min_value=0, max_value=31),
    #     'k': st.integers(min_value=0, max_value=31)
    # })


# Run the test
if __name__ == "__main__":
    test_sp()