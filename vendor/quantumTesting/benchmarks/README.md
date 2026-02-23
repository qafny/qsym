# Qiskit Circuit Library Benchmark Testing Framework

This directory contains a systematic testing framework for all Qiskit circuit library benchmarks.

## Structure

- `discovered_circuits.json` - All discovered circuits from Qiskit library
- `test_all_benchmarks.py` - Main testing script
- `organize_benchmarks.py` - Script to organize tested/untested benchmarks
- `specs/` - Test specifications (oracles) for each circuit
- `tested/` - Benchmarks that have been tested
- `untested/` - Benchmarks that haven't been tested yet
- `results/` - Test results in JSON and CSV format

## Usage

### Run all tests:
```bash
python test_all_benchmarks.py
```

### Organize benchmarks:
```bash
python organize_benchmarks.py
```

## Test Results

Results are saved in:
- `results/test_results.json` - Detailed JSON results
- `results/test_results.csv` - CSV format for analysis

## Test Pipeline

For each benchmark:
1. **Instantiation**: Try to create circuit with default parameters
2. **Specification**: Create test oracle describing expected behavior
3. **AST Generation**: Convert to XMLProgrammer AST using QCtoXMLProgrammer
4. **Validation**: Validate AST using SimulatorValidator
5. **Simulation**: Run through Simulator
6. **Recording**: Log results with status and error classification

## Error Classifications

- **FRAMEWORK_LIMITATION**: Issue with our testing framework (e.g., can't handle parameterized circuits, missing features)
- **QISKIT_ISSUE**: Potential issue in the Qiskit program itself
- **UNKNOWN**: Unexpected errors that need investigation

## Known Framework Limitations

1. **Parameterized Circuits**: Circuits with unbound parameters (θ, x, etc.) cannot be tested without binding values first
2. **Complex Parameters**: Circuits requiring complex list/array parameters need manual configuration
3. **Blueprint Circuits**: Some blueprint circuits need additional setup (operators, etc.) before they can be built
4. **Print Statements**: QCtoXMLProgrammer has debug print statements that can cause broken pipe errors when output is redirected

## Status Summary

See `results/test_results.json` for detailed results. Summary:
- **PASSED**: Circuit successfully went through entire pipeline
- **FAILED**: Circuit failed at some stage (see error_type for details)

