import argparse  
import os  
import rich 
import sys

from antlr4 import FileStream, CommonTokenStream  
from qsym.parsers.qafny_parser.ExpLexer import ExpLexer  
from qsym.parsers.qafny_parser.ExpParser import ExpParser  
from qsym.parsers.qafny_parser.ProgramTransformer import ProgramTransformer 
from qsym.analysis.CollectKind import CollectKind 
from qsym.analysis.TypeCollector import TypeCollector 
from qsym.analysis.TypeChecker import TypeChecker 
import subprocess 
import re 
from qsym.sp_calc import compute_sp
from qsym.ast.Programmer import QXNum

#######################################
# Qafny Options (a.k.a. Defines)
#######################################

## Functions required for the Qafny Options

# returns a path transformed to be relative to this script file as opposed to the current working directory 
from pathlib import Path

def path_relative_to_self(path: str) -> str:
    """Return path relative to the current script (__file__)."""
    script_dir = Path(__file__).resolve().parent
    full_path = (script_dir / path).resolve()
    return str(full_path)

def example_program(filename: str) -> str:
    """Return full path to '../test/Qafny/<filename>.qfy' relative to __main__.py."""
    return path_relative_to_self(f"../test/Qafny/{filename}.qfy")

# The suite of test qafny files (Qafny defaults to verifying these)
DEFAULT_FILENAMES = [
#     example_program("test1"),
#     example_program("test2"),
#     example_program("test3"),
#     example_program("test4"),
# #   example_program("test5"),
#     example_program("test6"),
#     example_program("test7"),
#   example_program("test8"),
#   example_program("test9"),
# #  example_program("test10"),
#    example_program("test11"),
#    example_program("test12"),
#      example_program("test13"),
#       example_program("test14"),
#      example_program("BellPair"),
#      example_program("GHZ"),
#     example_program("Teleportation"),
    # example_program("Superdense"),
    # example_program("Shors"), 
       example_program("HammingWeight"),  
    #  example_program("DeutschJozsa"),
    #  example_program("simon"),
#      example_program("DiscreteLog"),
    # example_program("Grovers"),
    # example_program("QPE"),
    # example_program("SWAPTest"),
    # example_program("AmpAmp"),
    # example_program("AmplitudeEstimation"),
    # example_program("AppxCounting"),
    # example_program("BHSP"),
    # example_program("FirstAmpEstimate"),
    # example_program("FOQA"),
    # example_program("LongDistanceEntangle"),
    # example_program("NonBoolean"),
    # example_program("QFTModQ"),
    # example_program("SimpleAmpEstimate"),
    # example_program("Stabilizer"),
    # example_program("StateDistinguishing")
]

#######################################
# Helper Functions
#######################################
# output_dir = "generated"
# os.makedirs(output_dir, exist_ok=True)  # Ensure the directory exists

def show_step_status(filename: str, description: str, is_success: bool):
    """show_step_status shows a status message to the user about the current file"""
    human_readable_filename = os.path.basename(filename)
    rich.print(f"{description} [blue]{human_readable_filename}[/]:", end='')
    if is_success:
        rich.print("[green] ✓ (pass)")
    else:
        rich.print("[red] 🞫 (fail)")

#######################################
# Main Routine
#######################################

# standard top-level run check
# Qafny usage:
# qafny BellPair.qfy
# running without arguments will cause it to loop through a list of test files
#? Do we want to make the cli similar to dafny?
#? i.e. qafny verify <file> for verification
#?      qafny build <file> for compilation (i.e. to QASM)
if __name__ == "__main__":
    # extremely simple argument parsing (see above usage)
    cli_parser = argparse.ArgumentParser(prog="qafny", description="A Quantum Program Verifier")
    # the file to verify
    cli_parser.add_argument('filename', nargs='?', default=DEFAULT_FILENAMES, help="the location of the qafny file to verify. if not specified, qafny verifies all the files in DEFAULT_FILENAMES from __main__.py")
    
    # --- Mode Selection ---
    cli_parser.add_argument('-m',
        '--mode', 
        choices=['verify', 'pbt'], 
        default='pbt', 
        help="Select operation mode: 'verify' (Standard Dafny Verification) or 'concolic' (pbt-based Symbolic Execution)"
    )
    args = cli_parser.parse_args()
    
    # if the user provided a filename, it's not going to be an array
    # so we have to convert it to one
    if not isinstance(args.filename, list):
        args.filename = [args.filename]

    # loop through each file in args.filename
    for filename in args.filename:
        # filename w/o the folders
        human_readable_filename = os.path.basename(filename)
        rich.print(f"Verifying: [blue]{human_readable_filename}[/]")
        # create a file stream
        file_stream = FileStream(filename, encoding="utf-8")
        # scan (lex the file)
        lexer = ExpLexer(file_stream)
        token_stream = CommonTokenStream(lexer)
        # parse
        parser = ExpParser(token_stream)
        # abstract syntax tree
        ast = parser.program() # program is the root node in the tree as defined in Exp.g4
        if parser.getNumberOfSyntaxErrors() > 0:
            print(f"Failed to parse: {human_readable_filename}")
        else:
            # DEBUG
            # print out ast in lisp like format
            # print(ast.toStringTree(recog=parser))
            # print out tokens from TerminalNodes
            # token_printer = TokenPrinter()
            # token_printer.visit(ast)
            # /DEBUG

            # Transform ANTLR AST to Qafny AST
            transformer = ProgramTransformer()
            qafny_ast = transformer.visitProgram(ast)
            rich.print(qafny_ast)

            collector = CollectKind()
            success = qafny_ast.accept(collector)
            kind_env = collector.get_kenv()
    #        print(f"\n kind_env: {kind_env}")


            if success:
                kind_env = collector.get_kenv()
    #            print(f"\n kind_env: {kind_env}")
            else:
                print(f"Verification failed: Variable used without definition or type mismatch. \n {success}")

            
            # MODE 1: PBT Concolic Execution
            if args.mode == 'pbt':
                res = compute_sp(qafny_ast, want_trace=True, want_discharge=True)
                print("paths:", len(res.finals))
                from qsym.sp_pretty import pp_vc, pp_discharge_result

                print(f"VCs: {len(res.vcs)}")
                # for k, vc in enumerate(res.vcs, 1):
                #     print(f"  VC{k}: {pp_vc(vc)}")
                
                for k, ok in enumerate(res.ok_vcs):
                    print(f"  vc_ok_{k}: {pp_discharge_result(ok)}")

                for k, bad in enumerate(res.bad_vcs):
                    print(f"  vc_bad_{k}: {pp_discharge_result(bad)}")
                

    #            for vc in res.vcs:
    #                print(f"qstore: {vc.antecedent_qstore}, \n pc: {vc.antecedent_pc}, \n org: {vc.origin}, \n line: {vc.source_line}, \n consq: {vc.consequent}")
                
                #visualization
                # rich.print(f"[bold yellow]Generated {len(assertions)} assertions.[/]")
                # for i, assertion in enumerate(assertions):
                #     rich.print(f"  [yellow]{i+1}. {assertion}[/]")

    sys.exit(0)
