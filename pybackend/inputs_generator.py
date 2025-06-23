from hypothesis import strategies as st
from Programmer import *

def extract_input_strategy(sp, min_value=0, max_value=31):
    # Extract classical variable names from the env
    classical = sp.get('classical', {})
    # You can also extract from post_cond if needed
    # classical = post_cond.get('classical', {})
    strategy_dict = {}
    for var in classical:
        # You can customize ranges per variable if needed
        strategy_dict[var] = st.integers(min_value=min_value, max_value=max_value)
    return st.fixed_dictionaries(strategy_dict)

def extract_quantum_indices(sp):
    quantum = sp.get('quantum', {})
    indices = set()
    
    for var, (loci, ty, state) in quantum.items():
        # Recursively walk state to find QXBind or QXCon ids
        indices.update(find_indices_in_ast(state))
    return indices

def find_indices_in_ast(node):
    indices = set()
    if isinstance(node, QXBind):
        indices.add(node.ID())
    elif hasattr(node, '__dict__'):
        for v in node.__dict__.values():
            if isinstance(v, list):
                for item in v:
                    indices.update(find_indices_in_ast(item))
            else:
                indices.update(find_indices_in_ast(v))
    return indices