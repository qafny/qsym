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

from qsym.sp_calc import compute_sp
from qsym.sp_pretty import pp_discharge_result


def _discover_qfy_files(examples_qafny_dir: Path) -> list[Path]:
    """Find all .qfy files in the specified directory."""
    return sorted(examples_qafny_dir.glob("*.qfy"))


def run_one_file(filename: Path) -> int:
    """
    Parses a single .qfy file, transforms it to Qafny AST, 
    collects kinds, and runs symbolic execution.
    """
    human = filename.name
    rich.print(f"\nRunning: [blue]{human}[/]")

    if not filename.exists():
        rich.print(f"[red]File not found:[/] {filename}")
        return 2

    # 1. Parse using ANTLR
    file_stream = FileStream(str(filename), encoding="utf-8")
    lexer = ExpLexer(file_stream)
    token_stream = CommonTokenStream(lexer)
    parser = ExpParser(token_stream)
    antlr_ast = parser.program()

    if parser.getNumberOfSyntaxErrors() > 0:
        rich.print(f"[red]Parse failed:[/] {human}")
        return 3

    # 2. ANTLR AST -> Qafny AST
    transformer = ProgramTransformer()
    qafny_ast = transformer.visitProgram(antlr_ast)

    print(f"\n qafny_ast: \n {qafny_ast}")

    # 3. Collect kinds (Type checking/Validation)
    collector = CollectKind()
    ok = qafny_ast.accept(collector)
    kind_env = collector.get_kenv()
    rich.print(f"[cyan]kind_env[/]: {kind_env}")

    if not ok:
        rich.print("[red]Kind collection failed.[/]")

    # 4. Symbolic execution (The core QSym engine)

    res = compute_sp(qafny_ast, want_trace=True, want_discharge=True)

    rich.print(f"[green]paths[/]: {len(res.finals)}")
    rich.print(f"[green]VCs[/]: {len(res.vcs)}")

    # Print Verification Conditions (VCs) that were successfully discharged
    for k, ok_vc in enumerate(res.ok_vcs):
        rich.print(f"  vc_ok_{k}: {pp_discharge_result(ok_vc)}")

    # Print VCs that failed to discharge
    for k, bad_vc in enumerate(res.bad_vcs):
        rich.print(f"  vc_bad_{k}: {pp_discharge_result(bad_vc)}")

    return 0


def main() -> int:
    cli = argparse.ArgumentParser(
        prog="run_qafny_examples",
        description="Run QSym (compute_sp) on Qafny .qfy examples.",
    )
    cli.add_argument(
        "filename",
        nargs="?",
        default=None,
        help="Optional .qfy path or basename (e.g., Shors or Shors.qfy). "
             "If omitted, runs all files under examples/qafny/.",
    )
    args = cli.parse_args()

    # script: examples/runners/run_qafny_programs.py
    runners_dir = Path(__file__).resolve().parent
    examples_dir = runners_dir.parent              # .../examples
    qafny_dir = examples_dir / "qafny"             # .../examples/qafny

    if args.filename:
        p = Path(args.filename)

        # 1) user gave a real path
        if p.exists():
            return run_one_file(p.resolve())

        # 2) basename under examples/qafny/
        cand1 = qafny_dir / args.filename
        if cand1.exists():
            return run_one_file(cand1.resolve())

        # 3) add .qfy if needed
        cand2 = qafny_dir / (args.filename + ".qfy")
        if cand2.exists():
            return run_one_file(cand2.resolve())

        rich.print(f"[red]File not found:[/] {args.filename}")
        rich.print(f"  Tried: {p.resolve()}")
        rich.print(f"         {cand1}")
        rich.print(f"         {cand2}")
        return 2

    # No filename: run all under examples/qafny/
    if not qafny_dir.exists():
        rich.print(f"[red]Missing directory:[/] {qafny_dir}")
        return 2

    files = _discover_qfy_files(qafny_dir)
    if not files:
        rich.print(f"[yellow]No .qfy files found in[/] {qafny_dir}")
        return 0

    rc = 0
    for f in files:
        rc = max(rc, run_one_file(f))
    return rc


if __name__ == "__main__":

    raise SystemExit(main())