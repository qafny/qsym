from hypothesis import given, settings, Verbosity
from Programmer import *
from ProgramTransformer import ProgramTransformer

class ConstraintSolver:
    def __init__(self, sp, assertion, input_strategy, max_examples=10, verbosity=False):
        """
        sp: symbolic state (dict)
        assertion: assertion or postcondition (dict)
        input_strategy: hypothesis strategy for input generation
        """
        self.sp = sp
        self.assertion = assertion
        self.input_strategy = input_strategy
        self.max_examples = max_examples
        self.verbosity = verbosity
        self.test_cases = []

    def eval_ast(self, node, inputs):
        if isinstance(node, QXNum):
            return node.num()
        elif isinstance(node, QXBind):
            return inputs.get(node.ID(), node.ID())
        elif isinstance(node, QXBin):
            left = self.eval_ast(node.left(), inputs)
            right = self.eval_ast(node.right(), inputs)
            op = node.op()
            if op == '+':
                return left + right
            elif op == '-':
                return left - right
            elif op == '*':
                return left * right
            elif op == '/':
                return left / right
            elif op == '%':
                return left % right
            elif op == '^':
                return left ** right
            else:
                raise NotImplementedError(f"Unknown binary op: {op}")
        elif isinstance(node, QXCall):
            return tuple(self.eval_ast(exp, inputs) for exp in node.exps())
        elif isinstance(node, QXUni):
            val = self.eval_ast(node.next(), inputs)
            op = node.op()
            if op == 'abs':
                return abs(val)
            elif op == 'sqrt':
                return val ** 0.5
            else:
                raise NotImplementedError(f"Unknown unary op: {op}")
        elif isinstance(node, QXSKet):
            return self.eval_ast(node.vector(), inputs)
        elif isinstance(node, QXCon):
            return node.ID()
        elif isinstance(node, QXSum):
            amp = self.eval_ast(node.amp(), inputs)
            kets = [self.eval_ast(ket, inputs) for ket in node.kets()]
            return (amp, tuple(kets))
        return node

    def eval_sp(self, inputs):
        """Evaluate the symbolic state (sp) with the given inputs."""
        quantum = self.sp.get('quantum', {})
        results = {}
        for var, (loci, ty, state) in quantum.items():
            results[var] = self.eval_ast(state, inputs)
        return results

    def eval_assertion(self, inputs):
        """
        Evaluate the assertion dict (quantum or classical) with the given inputs.
        """
        if 'quantum' in self.assertion and self.assertion['quantum']:
            quantum = self.assertion['quantum']
            results = {}
            for var, (loci, ty, state) in quantum.items():
                results[var] = self.eval_ast(state, inputs)
            return results
        elif 'classical' in self.assertion and self.assertion['classical']:
            classical = self.assertion['classical']
            results = {}
            for var, (ty, expr) in classical.items():
                results[var] = self.eval_ast(expr, inputs)
            return results
        else:
            raise ValueError("Assertion dict must have 'quantum' or 'classical' key with content.")

    def check_sp_implies_assertion(self):
        """
        Use Hypothesis to check that sp implies assertion for all generated inputs.
        Handles classical and quantum assertions separately.
        Only tests if the assertion variable is present in the symbolic state.
        """
        @given(self.input_strategy)
        @settings(max_examples=self.max_examples, verbosity=self.verbosity)
        def property_test(inputs):
            sp_val = self.eval_sp(inputs)
            assertion_val = self.eval_assertion(inputs)

            # Classical assertion: check all classical variables present in both sp and assertion
            if 'classical' in self.assertion and self.assertion['classical']:
                for var in assertion_val:
                    if var in sp_val:
                        print(f"Checking variable '{var}': sp={sp_val[var]}, assertion={assertion_val[var]}")   
                        self.test_cases.append({
                            "inputs": dict(inputs),
                            "sp": sp_val[var],
                            "assertion": assertion_val[var],
                            "var": var,
                            "result": bool(assertion_val[var])
                        })
                        assert assertion_val[var], (
                            f"Counterexample: inputs={inputs}, assertion failed for var '{var}': sp={sp_val[var]}, assertion={assertion_val[var]}"
                        )
                    else:
                        # If no variable match, just check the assertion value
                        self.test_cases.append({
                            "inputs": dict(inputs),
                            "sp": None,
                            "assertion": assertion_val[var],
                            "var": var,
                            "result": bool(assertion_val[var])
                        })
                        assert assertion_val[var], (
                            f"Counterexample: inputs={inputs}, assertion failed: assertion={assertion_val[var]}"
                        )

            # Quantum assertion: check all quantum variables present in both sp and assertion
            elif 'quantum' in self.assertion and self.assertion['quantum']:
                for var in sp_val:
                    if var in assertion_val:
                        self.test_cases.append({
                            "inputs": dict(inputs),
                            "sp": sp_val[var],
                            "assertion": assertion_val[var],
                            "var": var,
                            "result": sp_val[var] == assertion_val[var]
                        })
                        assert sp_val[var] == assertion_val[var], (
                            f"\nCounterexample: inputs={inputs}, sp[{var}]={sp_val[var]}, assertion[{var}]={assertion_val[var]}"
                        )
                    else:
                        continue
            else:
                raise ValueError("Assertion dict must have 'quantum' or 'classical' key with content.")

        try:
            property_test()
        except AssertionError as e:
            print(e)

    def print_test_cases(self):
        """Print all test cases generated during the property test."""
        if not self.test_cases:
            print("No test cases generated.")
            return

        print(f"Generated {len(self.test_cases)} test cases:")
        for i, case in enumerate(self.test_cases):
            inputs = case['inputs']
            sp = case['sp']
            assertion = case['assertion']
            var = case['var']
            result = case['result']
            print(f"Test Case {i + 1}:")
            print(f"  Inputs: {inputs}")
            print(f"  SP[{var}]: {sp}")
            print(f"  Assertion[{var}]: {assertion}")
            print(f"  Result: {'Passed' if result else 'Failed'}\n")