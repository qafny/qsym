from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from Programmer import *
from PrettyPrinter import PrettyPrinter

class QEnv:
    """Environment for quantum and classical variables with alphabetic quantum var names"""
    def __init__(self):
        self.q_env: Dict[str, Tuple[List[QXQRange], QXQTy, QXQState]] = {}
        self.c_env: Dict[str, Tuple[TySingle, QXAExp]] = {}
        self.counter = 0
        self.var_names = "abcdefgh"

    def next_var_name(self) -> str:
        idx = self.counter
        name = ""
        while True:
            name = self.var_names[idx % 26] + name
            idx = idx // 26 - 1
            if idx < 0:
                break
        return name

    def extend(self, loci: List[QXQRange], type_info: QXQTy, state: QXQState) -> str:
        """Create a new quantum variable in environment"""
        var_name = self.next_var_name()
        self.counter += 1
        self.q_env[var_name] = (loci, type_info, state)
        return var_name

    def extend_c(self, var_id: str, type_info: TySingle):
        """Store a QXBind as the value, not a string"""
        self.c_env[var_id] = (type_info, QXBind(var_id))

    def lookup(self, var: str) -> Optional[Tuple[List[QXQRange], QXQTy, QXQState]]:
        return self.q_env.get(var)

    def update(self, loci: List[QXQRange], type_info: QXQTy, state: QXQState):
        """Update the quantum variable with matching loci in place, or add new if not found."""
        for var_name, (old_loci, _, _) in self.q_env.items():
            if len(old_loci) == len(loci) and all(l1.ID() == l2.ID() for l1, l2 in zip(old_loci, loci)):
                self.q_env[var_name] = (loci, type_info, state)
                return var_name
        return self.extend(loci, type_info, state)

    def to_string(self, mode: str = "all") -> str:
        """Show all current classical and quantum variables."""
        printer = PrettyPrinter()
        result = []
        # Classical bindings
        for var, (type_info, value) in self.c_env.items():
            type_str = type_info.accept(printer)
            value_str = value.accept(printer)
            entry = f"Env ⊢ {var} : {type_str} = {value_str}"
            result.append(entry)
        # Quantum bindings
        for var, (loci, type_info, state) in self.q_env.items():
            loci_str = " ".join(loc.accept(printer) for loc in loci)
            type_str = type_info.accept(printer)
            state_str = state.accept(printer)
            entry = f"Env ⊢ {var} : {loci_str} : {type_str} ↦ {state_str}"
            result.append(entry)
        return "\n".join(result)

    def __repr__(self):
        return self.to_string(mode="all")

@dataclass
class StateSnapshot:
    """Snapshot of quantum state at a point in execution"""
    q_env: Dict[str, Tuple[List[QXQRange], QXQTy, QXQState]]
    c_env: Dict[str, Tuple[TySingle, QXAExp]]
    operation: str

class StateManager:
    """Manages quantum state and execution history"""
    def __init__(self):
        self.q_env = QEnv()
        self.path_conds: List[QXBExp] = []
        self.precond_q: Optional[QXQSpec] = None
        self.precond_c: Optional[QXComp] = None
        self.postcond: Optional[QXQSpec] = None
        self.history: List[StateSnapshot] = []
        self.sum_var_idx = 0
        self.sum_var_letters = 'ijklmn'
        self.curr_state: Optional[str] = None

    def to_string(self, mode: str = "all") -> str:
        return self.q_env.to_string(mode=mode)

    def get_curr_bind(self):
        """Return all current quantum and classical bindings as a dict."""
        curr = {}
        if self.q_env.q_env:
            curr['quantum'] = self.q_env.q_env.copy()
        if self.q_env.c_env:
            curr['classical'] = self.q_env.c_env.copy()
        if not curr:
            raise AssertionError("No current state available.")
        return curr

    def set_pre_bind(self, bind: QXBind):
        if bind.ID() not in self.q_env.c_env:
            self.q_env.extend_c(bind.ID(), bind.type())

    def set_precond_c(self, spec: QXComp):
        self.precond_c = spec
        binds = self._extract_binds(spec)
        for bind in binds:
            if bind.ID() not in self.q_env.c_env:
                self.q_env.extend_c(bind.ID(), bind.type())

    def set_precond_q(self, spec: QXQSpec):
        self.precond_q = spec
        self.q_env.extend(spec.locus(), spec.qty(), spec.state())
        # Do not snapshot here; call init_snapshot after all preconditions are set

    def init_snapshot(self):
        """Take a snapshot of the initial state after all preconditions are set."""
        self._snapshot("init")

    def set_postcond(self, spec: QXQSpec):
        self.postcond = spec

    def add_path_cond(self, cond: QXBExp):
        self.path_conds.append(cond)

    def remove_path_cond(self):
        if self.path_conds:
            self.path_conds.pop()

    def update_state(self, loci: List[QXQRange], type_info: QXQTy, new_state: QXQState, operation: str):
        self.q_env.update(loci, type_info, new_state)
        self._snapshot(operation)

    def _snapshot(self, operation: str):
        self.history.append(StateSnapshot(
            self.q_env.q_env.copy(),
            self.q_env.c_env.copy(),
            operation
        ))

    def get_history(self) -> List[StateSnapshot]:
        return self.history

    def _extract_binds(self, expr: QXAExp) -> List[QXBind]:
        if isinstance(expr, QXBind):
            return [expr]
        elif isinstance(expr, QXComp):
            return self._extract_binds(expr.left) + self._extract_binds(expr.right)
        return []

    def get_fresh_sum_var(self) -> str:
        var = self.sum_var_letters[self.sum_var_idx % len(self.sum_var_letters)]
        num = self.sum_var_idx // len(self.sum_var_letters)
        self.sum_var_idx += 1
        return f"{var}{num}" if num > 0 else var

    def __repr__(self) -> str:
        return repr(self.q_env)

    def show_history(self) -> str:
        printer = PrettyPrinter()
        lines = []
        for i, snap in enumerate(self.history):
            lines.append(f"--- Snapshot {i} ({snap.operation}) ---")
            for var, (type_info, value) in snap.c_env.items():
                type_str = type_info.accept(printer)
                value_str = value.accept(printer)
                lines.append(f"Env ⊢ {var} : {type_str} = {value_str}")
            for var, (loci, type_info, state) in snap.q_env.items():
                loci_str = " ".join(loc.accept(printer) for loc in loci)
                type_str = type_info.accept(printer)
                state_str = state.accept(printer)
                lines.append(f"Env ⊢ {var} : {loci_str} : {type_str} ↦ {state_str}")
        return "\n".join(lines)