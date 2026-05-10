"""
This file is used to compile a .pqasm file into a .qasm file.
Along the way, it checks for syntax errors.
"""

import sys
import argparse
import os
import subprocess
from antlr4 import *
from PQASMLexer import PQASMLexer
from PQASMParser import PQASMParser
from antlr4.error.ErrorListener import ErrorListener
from pathlib import Path


class EListener(ErrorListener):
    def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
        print("Parsing failed: Syntax error at line " + line + ", column " +
              column + ", with message: " + msg + "\n");


def main():

    # Read the file specified on the command line
    if len(sys.argv) != 2:
        print("Usage: python compilePQASM.py <inputfile.pqasm>")
        sys.exit(1)
    input_file = sys.argv[1]
    input_stream = FileStream(input_file)


    # Syntax check the .pqasm file using the parser
    lexer = PQASMLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = PQASMParser(stream)
    parser.removeErrorListeners()
    parser.addErrorListener(EListener())
    parser.program()
    print("Parsing finished. No syntax errors found.")


    # Get the argument from the cmd line
    parser = argparse.ArgumentParser()
    parser.add_argument("inputFile") # The file inputted in .pqasm
    args = parser.parse_args()

    # Call the preexisiting modules to compile the .pqasm file into a .qasm file
    experiments = Path(__file__).resolve().parent.parent / "experiments"
    subprocess.run(["bash", "extract.sh"], cwd=experiments)
    subprocess.run(["bash", "run.sh"], cwd=experiments)


    outputFile = os.path.splitext(args.inputFile)[0] + ".qasm"




# Ensure the main function runs
if __name__ == "__main__":
    main()