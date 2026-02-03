# QSym

The project designs a symbolic execution engine for quantum programs based on Qafny.

## Requirements

* Python **3.10+** 



## Install

From the repo root:

```bash
pip install -e .
```

## Quick Start

Show CLI help:

```bash
python -m qsym --help
```

Run an example script:

```bash
python src/examples/runners/run_qafny_programs.py Shors
```


## Repo Layout

* `src/qsym/`: Core symbolic engine 

* `src/qsym/ast/`: Qafny AST + visitor base

* `src/qsym/analysis/`: Analysis passes (e.g., substitution)

* `src/qsym/parsers/`: qafny/qiskit parsers

* `examples/`: example programs (Qafny / Qiskit sources)
    * `examples/runners/`: Python entry scripts
    * `examples/qafny/`: `.qfy` programs
    * `examples/qiskit/`: Qiskit circuits (`.py`)



