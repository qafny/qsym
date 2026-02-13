from __future__ import annotations

import argparse
import sys
from pathlib import Path

import rich
from antlr4 import FileStream, CommonTokenStream

# Assuming these are available in the project structure
from qsym.parsers.qafny_parser.ExpLexer import ExpLexer
from qsym.parsers.qafny_parser.ExpParser import ExpParser
from qsym.parsers.qafny_parser.ProgramTransformer import ProgramTransformer
from qsym.analysis.CollectKind import CollectKind

from qsym.parsers.py2qfy import PythonToQafny

from qsym.sp_calc import compute_sp
from qsym.sp_pretty import pp_discharge_result


def _discover_files(dir: Path, ext: str) -> list[Path]:
    """Find all files in a specified directory."""
    return sorted(dir.glob(f"*.{ext}"))


def run_one_file(filename: Path) -> int:
    """
    Detects file type, parses to Qafny AST, and runs symbolic execution.
    """
    human = filename.name
    rich.print(f"\nRunning: [blue]{human}[/]")

    if not filename.exists():
        rich.print(f"[red]File not found:[/] {filename}")
        return 2

    qafny_ast = None

    # --- 1. Parsing Phase (Branch by file type) ---
    if filename.suffix == ".qfy":
        # Standard Qafny Parsing
        file_stream = FileStream(str(filename), encoding="utf-8")
        lexer = ExpLexer(file_stream)
        token_stream = CommonTokenStream(lexer)
        parser = ExpParser(token_stream)
        antlr_ast = parser.program()

        if parser.getNumberOfSyntaxErrors() > 0:
            rich.print(f"[red]Parse failed:[/] {human}")
            return 3

        transformer = ProgramTransformer()
        qafny_ast = transformer.visitProgram(antlr_ast)

    elif filename.suffix == ".py":
        # Qiskit Parsing Path
        try:
            # This assumes your qiskit_to_qafny parser returns a Qafny AST object directly
            qafny_ast = PythonToQafny(filename)
        except Exception as e:
            rich.print(f"[red]Qiskit conversion failed for {human}:[/] {e}")
            return 3
    else:
        rich.print(f"[yellow]Unsupported file type:[/] {filename.suffix}")
        return 1

    # --- 2. Shared Analysis Pipeline ---
    rich.print(f"\n[dim]qafny_ast generated for {human}[/]")

    # Collect kinds (Type checking/Validation)
    collector = CollectKind()
    ok = qafny_ast.accept(collector)
    kind_env = collector.get_kenv()
    rich.print(f"[cyan]kind_env[/]: {kind_env}")

    if not ok:
        rich.print("[red]Kind collection failed.[/]")

    # Symbolic execution
    res = compute_sp(qafny_ast, want_trace=True, want_discharge=True)

    rich.print(f"[green]paths[/]: {len(res.finals)}")
    rich.print(f"[green]VCs[/]: {len(res.vcs)}")

    for k, ok_vc in enumerate(res.ok_vcs):
        rich.print(f"  vc_ok_{k}: {pp_discharge_result(ok_vc)}")

    for k, bad_vc in enumerate(res.bad_vcs):
        rich.print(f"  vc_bad_{k}: {pp_discharge_result(bad_vc)}")

    return 0


def main() -> int:
    cli = argparse.ArgumentParser()
    cli.add_argument("filename", nargs="?", default=None)
    args = cli.parse_args()

    # 1. Resolve the script's own path
    script_path = Path(__file__).resolve()
    
    # 2. Try to find the 'examples' directory dynamically
    # We look for a directory named 'examples' in the script's parents
    examples_dir = None
    for parent in script_path.parents:
        cand = parent / "examples"
        if cand.is_dir():
            examples_dir = cand
            break
        # Also check if the parent itself is named examples
        if parent.name == "examples":
            examples_dir = parent
            break

    if not examples_dir:
        # Fallback to the original logic if discovery fails
        examples_dir = script_path.parent.parent

    qafny_dir = examples_dir / "qafny"
#    qiskit_dir = examples_dir / "qiskit"

    if args.filename:
        target = args.filename
        
        # Priority 1: Direct path (absolute or relative to where you are)
        p = Path(target)
        if p.exists():
            return run_one_file(p.resolve())

        # Priority 2: Check subdirectories
    #    search_dirs = [qafny_dir, qiskit_dir, examples_dir]
        search_dirs = [qafny_dir, examples_dir]
        extensions = ["", ".qfy", ".py"]

        for d in search_dirs:
            for ext in extensions:
                cand = d / (target + ext)
                if cand.exists():
                    return run_one_file(cand.resolve())

        # If we reach here, we failed. Let's show the user why.
        rich.print(f"[red]File not found:[/] {target}")
        rich.print("\n[yellow]Search locations attempted:[/]")
        for d in search_dirs:
            rich.print(f" - {d}")
        return 2

    # 2. Run all files in both directories
    rc = 0
    targets = [
        (qafny_dir, ".qfy"),
        (qiskit_dir, ".py"),
    ]

    for directory, ext in targets:
        if directory.exists():
            files = _discover_files(directory, ext)
            for f in files:
                rc = max(rc, run_one_file(f))
        else:
            rich.print(f"[dim]Skipping missing directory: {directory}[/]")

    return rc


if __name__ == "__main__":

    raise SystemExit(main())