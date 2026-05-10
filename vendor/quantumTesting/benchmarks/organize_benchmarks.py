#!/usr/bin/env python3
"""
Organize benchmarks into tested/untested directories based on test results.
"""

import json
import shutil
from pathlib import Path

def organize_benchmarks(benchmarks_dir):
    """Organize benchmarks based on test results."""
    benchmarks_dir = Path(benchmarks_dir)
    results_file = benchmarks_dir / "results" / "test_results.json"
    tested_dir = benchmarks_dir / "tested"
    untested_dir = benchmarks_dir / "untested"
    
    # Create directories
    tested_dir.mkdir(exist_ok=True)
    untested_dir.mkdir(exist_ok=True)
    
    # Load test results
    if not results_file.exists():
        print("No test results found. Run test_all_benchmarks.py first.")
        return
    
    with open(results_file, 'r') as f:
        results = json.load(f)
    
    # Get tested circuit names
    tested_circuits = {r['circuit_name'] for r in results if r.get('circuit_name')}
    
    # Load discovered circuits
    discovered_file = benchmarks_dir / "discovered_circuits.json"
    with open(discovered_file, 'r') as f:
        circuits = json.load(f)
    
    # Organize specs
    specs_dir = benchmarks_dir / "specs"
    if specs_dir.exists():
        for spec_file in specs_dir.glob("*_spec.json"):
            circuit_name = spec_file.stem.replace("_spec", "")
            
            if circuit_name in tested_circuits:
                # Move to tested
                dest = tested_dir / spec_file.name
                shutil.copy2(spec_file, dest)
                print(f"Moved {spec_file.name} to tested/")
            else:
                # Move to untested
                dest = untested_dir / spec_file.name
                shutil.copy2(spec_file, dest)
                print(f"Moved {spec_file.name} to untested/")
    
    print(f"\nOrganized {len(tested_circuits)} tested and {len(circuits) - len(tested_circuits)} untested benchmarks")

if __name__ == "__main__":
    import sys
    benchmarks_dir = Path(__file__).parent
    organize_benchmarks(benchmarks_dir)

