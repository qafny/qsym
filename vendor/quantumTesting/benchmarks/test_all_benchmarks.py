#!/usr/bin/env python3
"""
Systematic testing framework for Qiskit circuit library benchmarks.

This script:
1. Reads all circuits from discovered_circuits.json
2. For each untested circuit:
   - Creates a specification (test oracle)
   - Runs through pipeline (QCtoXMLProgrammer → Simulator)
   - Records testing outcome
3. Organizes benchmarks into tested/untested categories
4. Logs all results to CSV/JSON
"""

import array
import json
import os
import sys
import traceback
import importlib
from datetime import datetime
from pathlib import Path
import inspect
from hypothesis import given, strategies as st, assume, settings, HealthCheck

# Add parent directory to path
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.insert(0, parent_dir)
sys.path.append(os.path.join(parent_dir, 'qiskit-to-xmlprogrammer'))

from qiskit_to_xmlprogrammer import QCtoXMLProgrammer
from AST_Scripts.simulator import Simulator, CoqNVal
from AST_Scripts.ValidatorProgramVisitors import SimulatorValidator
from AST_Scripts.Retrievers import MatchCounterRetriever
from program_properties import properties, test_properties
from qiskit import QuantumCircuit

class BenchmarkTester:
    def __init__(self, benchmarks_dir):
        self.benchmarks_dir = Path(benchmarks_dir)
        self.discovered_file = self.benchmarks_dir / "discovered_circuits.json"
        self.specs_dir = self.benchmarks_dir / "specs"
        self.tested_dir = self.benchmarks_dir / "tested"
        self.untested_dir = self.benchmarks_dir / "untested"
        self.results_dir = self.benchmarks_dir / "results"
        
        # Create directories if they don't exist
        for dir_path in [self.specs_dir, self.tested_dir, self.untested_dir, self.results_dir]:
            dir_path.mkdir(parents=True, exist_ok=True)
        
        self.visitor = QCtoXMLProgrammer()
        self.results = []
    
    def get_default_parameters(self, circuit_info):
        """Generate default parameters for circuit instantiation."""
        params = {}
        param_info = circuit_info.get('parameters', {})
        
        for param_name, param_data in param_info.items():
            if param_name == 'name':
                continue  # Skip name parameter
            
            default = param_data.get('default')
            annotation = param_data.get('annotation', '')
            
            # Handle None defaults
            if default is None:
                continue
            else:
                params[param_name] = default
        print('params', params)
        return params
    
    def instantiate_circuit(self, circuit_info):
        """Try to instantiate a circuit with default parameters."""
        try:
            module_path = circuit_info['module']
            class_name = circuit_info['class_name']
            
            # Import the module
            module = importlib.import_module(module_path)
            circuit_class = getattr(module, class_name)
            
            # Get default parameters
            params = self.get_default_parameters(circuit_info)
            print('params after getting defaults', params)
            # Check if it's a BlueprintCircuit (needs special handling)
            base_classes = [b.__name__ for b in circuit_class.__bases__]
            if 'BlueprintCircuit' in base_classes:
                print('in if case')
                # Blueprint circuits need to be built
                circuit = circuit_class(**params)
                if hasattr(circuit, '_build'):
                    circuit._build()
            else:
                print('in else case')
                # Regular instantiation
                circuit = circuit_class(**params)
                print('circuit after instantiation in else case', circuit)
            
            # Generate a unique name
            circuit_name = f"{class_name}_{params.get('num_qubits', params.get('num_state_qubits', params.get('num_variable_qubits', 2)))}"
            circuit.name = circuit_name
            print('circuit', circuit)
            return circuit
            
        except Exception as e:
            print('exception', e)
            return None
    
    def test_circuit(self, circuit_info):
        """Test a single circuit through the pipeline."""
        result = {
            "timestamp": datetime.now().isoformat(),
            "circuit_name": None,
            "class_name": circuit_info['class_name'],
            "module": circuit_info['module'],
            "num_qubits": None,
            "status": "UNKNOWN",
            "error_type": "N/A",
            "error_classification": "N/A",
            "error_details": "N/A",
            "notes": "",
            "full_error": "N/A"
        }
        
        try:
            # Step 1: Instantiate circuit
            print('about to try instantiating circuit')
            circuit = self.instantiate_circuit(circuit_info)
            if circuit is None:
                result["status"] = "FAILED"
                result["error_type"] = "INSTANTIATION_ERROR"
                result["error_classification"] = "FRAMEWORK_LIMITATION"
                result["error_details"] = "Cannot instantiate circuit with default parameters"
                result["full_error"] = "Unknown instantiation error"
                result["notes"] = "Circuit requires non-default parameters or special handling"
                return result
            
            result["circuit_name"] = circuit.name
            result["num_qubits"] = circuit.num_qubits
            
            # Step 3: Convert to AST using QCtoXMLProgrammer (Step 2: Create specification - removed for now)
            try:
                print('about to try converting to AST')
                # Suppress stdout to avoid broken pipe errors
                # import io
                # import contextlib
                # f = io.StringIO()
                # with contextlib.redirect_stdout(f):
                    # default values
                num_classical_bits = 4
                num_quantum_bits = 4
                if circuit_info.get("quantum_bits") != None:
                    num_quantum_bits = circuit_info.get("quantum_bits")
                if circuit_info.get("classical_bits") != None:
                    num_classical_bits = circuit_info.get("classical_bits")    
                print('circuit', circuit)
                qc = QuantumCircuit(num_quantum_bits, num_classical_bits)
                qc.append(circuit, array.array('i', range(0, num_quantum_bits)))
                ast_tree = self.visitor.startVisit(
                    qc,
                    circuitName=circuit.name,
                    optimiseCircuit=False,
                    showDecomposedCircuit=True,
                    showInputCircuit=True,
                    emit_xml=False
                )
                print('ast_tree', ast_tree)
                result["notes"] += "AST generation: SUCCESS; "
            except Exception as e:
                print(e)
                result["status"] = "FAILED"
                result["error_type"] = "AST_GENERATION_ERROR"
                result["error_classification"] = "FRAMEWORK_LIMITATION"
                result["error_details"] = f"QCtoXMLProgrammer failed: {str(e)}"
                result["full_error"] = traceback.format_exc()
                result["notes"] += "AST generation: FAILED; "
                return result
            
            # Step 4: Validate AST
            try:
                print('about to validate AST')
                validator = SimulatorValidator()
                validator.visitProgram(ast_tree)
                result["notes"] += "AST validation: SUCCESS; "
            except Exception as e:
                result["status"] = "FAILED"
                result["error_type"] = "VALIDATION_ERROR"
                result["error_classification"] = "FRAMEWORK_LIMITATION"
                result["error_details"] = f"Validation failed: {str(e)}"
                result["full_error"] = traceback.format_exc()
                result["notes"] += f"AST validation: FAILED ({str(e)}); "
                return result
            
            # Step 5: Run simulator
            try:
                # Initialize state (may have to move this to specs file)
                self.run_simulation(result, circuit, ast_tree)
            except Exception as e:
                result["status"] = "FAILED"
                result["error_type"] = "SIMULATION_ERROR"
                result["error_classification"] = "FRAMEWORK_LIMITATION"
                result["error_details"] = f"Simulator failed: {str(e)}"
                result["full_error"] = traceback.format_exc()
                result["notes"] += f"Simulation: FAILED ({str(e)})"
                return result
            
        except Exception as e:
            print(e)
            result["status"] = "FAILED"
            result["error_type"] = "UNEXPECTED_ERROR"
            result["error_classification"] = "UNKNOWN"
            result["error_details"] = f"Unexpected error: {str(e)}"
            result["full_error"] = traceback.format_exc()
            result["notes"] = f"Unexpected error occurred: {str(e)}"
        
        return result

    def run_simulation(self, result, circuit, ast_tree):
        print('circuit.num_qubits', circuit.num_qubits)
        # Generate different state and environment configurations.
        @settings(max_examples=20, suppress_health_check=[HealthCheck.too_slow])
        @given(
            state_bits=st.lists(st.booleans(), min_size=circuit.num_qubits-1, max_size=circuit.num_qubits-1),
            env_xa=st.integers(min_value=0, max_value=circuit.num_qubits)
        )
        def simulate_instances(state_bits, env_xa):
            state = {"test": [CoqNVal(state_bits+[False], phase=0)]}
            environment = {"xa": env_xa}
            sim = Simulator(state, environment)
            sim.visitProgram(ast_tree)
            # TODO: validate properties for each instance
            post_sim_state = sim.state
            print(post_sim_state['test'][0].getBits())

        try:
            simulate_instances()
            
        except Exception as e:
            # TODO: catch exceptions from hypothesis.
            result["status"] = "FAILED"
            result["error_type"] = "SIMULATION_ERROR"
            result["error_classification"] = "PROPERTY_FAILURE"
            result["error_details"] = f"Simulator failed on generated case: {str(e)}"
            result["full_error"] = traceback.format_exc()
            result["notes"] += f"Simulation: FAILED ({str(e)})"

        result["notes"] += "Simulation: SUCCCESS"
        result["status"] = "PASSED"
    
    def run_all_tests(self):
        """Run tests on all discovered circuits."""
        # Load discovered circuits
        with open(self.discovered_file, 'r') as f:
            circuits = json.load(f)
        
        print(f"Found {len(circuits)} circuits to test")
           
        # Test each circuit
        for i, circuit_info in enumerate(circuits, 1):
            print(f"\n[{i}/{len(circuits)}] Testing {circuit_info['class_name']}...")
            result = self.test_circuit(circuit_info)
            self.results.append(result)
            
            # Print status
            status_icon = "✓" if result["status"] == "PASSED" else "✗"
            print(f"  {status_icon} {result['status']}: {result['error_type']}")
            
            # Save intermediate results periodically
            if i % 10 == 0:
                self.save_results()
        
        # Final save
        self.save_results()
        self.save_csv_results()
        
        # Print summary
        self.print_summary()
    
    def save_results(self):
        """Save results to JSON file."""
        results_file = self.results_dir / "test_results.json"
        
        # Load existing results if any
        if results_file.exists():
            with open(results_file, 'r') as f:
                existing = json.load(f)
        else:
            existing = []
        
        # Merge results (avoid duplicates)
        existing_names = {r.get('circuit_name', '') for r in existing}
        new_results = [r for r in self.results if r.get('circuit_name', '') not in existing_names]
        
        all_results = existing + new_results
        
        with open(results_file, 'w') as f:
            json.dump(all_results, f, indent=2)
    
    def save_csv_results(self):
        """Save results to CSV file."""
        import csv
        csv_file = self.results_dir / "test_results.csv"
        
        if not self.results:
            return
        
        fieldnames = ['timestamp', 'circuit_name', 'class_name', 'module', 'num_qubits', 
                     'status', 'error_type', 'error_classification', 'error_details', 'notes', 'full_error']
        
        with open(csv_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            
            # Load all results
            results_file = self.results_dir / "test_results.json"
            if results_file.exists():
                with open(results_file, 'r') as json_f:
                    all_results = json.load(json_f)
                    writer.writerows(all_results)
    
    def print_summary(self):
        """Print testing summary."""
        passed = sum(1 for r in self.results if r['status'] == 'PASSED')
        failed = sum(1 for r in self.results if r['status'] == 'FAILED')
        total = len(self.results)
        
        print("\n" + "="*60)
        print("TESTING SUMMARY")
        print("="*60)
        print(f"Total tested: {total}")
        print(f"Passed: {passed} ({passed/total*100:.1f}%)")
        print(f"Failed: {failed} ({failed/total*100:.1f}%)")
        
        # Error classification summary
        if failed > 0:
            print("\nError Classifications:")
            error_types = {}
            for r in self.results:
                if r['status'] == 'FAILED':
                    et = r.get('error_type', 'UNKNOWN')
                    error_types[et] = error_types.get(et, 0) + 1
            
            for et, count in sorted(error_types.items(), key=lambda x: -x[1]):
                print(f"  {et}: {count}")
        
        print("\nResults saved to:")
        print(f"  JSON: {self.results_dir / 'test_results.json'}")
        print(f"  CSV: {self.results_dir / 'test_results.csv'}")


def main():
    benchmarks_dir = Path(__file__).parent
    tester = BenchmarkTester(benchmarks_dir)
    tester.run_all_tests()


if __name__ == "__main__":
    main()

