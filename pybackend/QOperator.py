from enum import Enum
from typing import List, Optional
from Programmer import *
from StateManager import StateManager
from ExprTransformer import ExprTransformer
from OpType import OpType

class QOperator:
    """Handles quantum operations"""
    def __init__(self, state_manager: 'StateManager'):
        self.state_manager = state_manager
        self.transformer = ExprTransformer(self.state_manager)

    def apply_hadamard(self, regs: List[str], qexp: QXSingle):
        """Apply Hadamard operation"""
        curr = self.state_manager.get_curr_bind()
        q_vars = curr.get('quantum', {})
        for reg in regs:
            found = False
            for loci, type_info, state in q_vars.values():
                print(f"loci: {loci}, type_info: {type_info}, state: {state}, \nreg: {reg}")
                if any(loc.ID() == reg for loc in loci):
                    found = True
        #            print('check', self.state_manager.path_conds[0].ID(), loci)
                    if self.state_manager.path_conds:
                        if not any(loc.ID() == self.state_manager.path_conds[0].ID() for loc in loci):
                            path_reg = self.state_manager.path_conds[0].ID()
                            # Find the loci for the path_reg in the current quantum variables
                            path_loci = None
                            for l2, t2, s2 in q_vars.values():
                                if any(loc.ID() == path_reg for loc in l2):
                                    path_loci = l2
                                    break
                            if path_loci is None:
                                raise AssertionError(f"Register {path_reg} from path condition not found in current quantum variables.")
                            # Merge the loci
                            loci = [loc for loc in path_loci if loc.ID() == path_reg] + loci 
                            reg = [path_reg, reg]
                            print(f"loci: {loci}, reg: {reg}")

                        if isinstance(type_info, TyEn):
                            self._apply_had2en(loci, type_info, state, reg)
                        elif isinstance(type_info, TyHad):
                            self._apply_chad2had(loci, type_info, state, reg)
                        elif isinstance(type_info, TyNor):
                            self._apply_chad2nor(loci, type_info, state, reg)
                    else:

                        if isinstance(type_info, TyEn):
                            self._apply_had2en(loci, type_info, state, [reg])
                        elif isinstance(type_info, TyHad):
                            self._apply_had2had(loci, type_info, state, [reg])
                        elif isinstance(type_info, TyNor):
                            self._apply_had2nor(loci, type_info, state, [reg])

                    break
            if not found:
                raise AssertionError(f"Register {reg} not found in current quantum variables.")

    def apply_lambda(self, regs: List[str], oracle: QXOracle):
        """Apply lambda operation to all current quantum variables."""
        curr = self.state_manager.get_curr_bind()
        q_vars = curr.get('quantum', {})
        vectors = oracle.vectors()
        params = oracle.ids()
        fn = oracle.phase()

        for reg in regs:
                found = False
                for loci, type_info, state in q_vars.values():
                    if any(loc.ID() == reg for loc in loci):
                        found = True
                        if self.state_manager.path_conds:
                            path_reg = self.state_manager.path_conds[0].ID()
                            # Find the loci for the path_reg in the current quantum variables
                            path_loci = None
                            for l2, t2, s2 in q_vars.values():
                                if any(loc.ID() == path_reg for loc in l2):
                                    path_loci = l2
                                    break
                            if path_loci is None:
                                raise AssertionError(f"Register {path_reg} from path condition not found in current quantum variables.")
                            # Merge the loci
                            loci = loci + [loc for loc in path_loci if loc.ID() == path_reg]
                            reg = [path_reg, reg]

                        if isinstance(type_info, TyEn):
                                self._apply_lambda_en(loci, type_info, state, reg, vectors, params, fn)
                        elif isinstance(type_info, TyHad):
                                self._apply_lambda_had(loci, type_info, state, reg, vectors, params, fn)
                        elif isinstance(type_info, TyNor):
                                self._apply_lambda_nor(loci, type_info, state, reg, vectors, params, fn)


                        break
                if not found:
                    raise AssertionError(f"Register {reg} not found in current quantum variables.")

    def apply_mea(self, regs: List[str], qexp: QXSingle):
        pass

    def apply_qft(self, regs: List[str], qexp: QXSingle):
        pass

    def apply_rqft(self, regs: List[str], qexp: QXSingle):
        pass

    def apply_cast(self, regs: List[str], ty: QXQTy):
        """Handle quantum cast"""
        print(f"Visiting cast: {ty}, loci: {regs}")
        curr = self.state_manager.get_curr_bind()
        q_vars = curr.get('quantum', {})
        print(f"q_vars: {q_vars}")
        for reg in regs:
            found = False
            for loci, type_info, state in q_vars.values():
                if any(loc.ID() == reg for loc in loci):
                    found = True
                    if isinstance(type_info, TyEn):
                        self._cast_en2had(loci, ty)
                    elif isinstance(type_info, TyHad):
                        self._cast_had2en(loci, ty)
                    elif isinstance(type_info, TyNor):
                        self._cast_nor2had(loci, ty)

    def _cast_en2had(self, loci, ty):
        pass
    
    #TODO fix
    def _cast_had2en(self, loci, ty):
        """Cast Hadamard basis state to entangled state"""
        new_kets = []
        new_sums = []
        sum_vars = []

        # Introduce a sum variable for each ket (qubit)
        for i, reg in enumerate(loci):
            sum_var = self.state_manager.get_fresh_sum_var()
            sum_vars.append(sum_var)
            new_sums.append(QXCon(sum_var, QXCRange(QXNum(0), QXBin('^', QXNum(2), QXBind('n')))))
            # Replace the ket with a bound variable
            new_kets.insert(i, QXSKet(QXBind(sum_var)))

        # The amplitude is typically 1/(sqrt(2^n)) for a uniform superposition
        # You may want to generalize this if needed
            new_amp = QXBin(
                '/',
                QXNum(1),
                QXUni('sqrt', QXBin('^', QXNum(2), QXBind('n')))
            )

        new_type = TyEn(flag=QXNum(num=len(new_sums)))
        new_state = QXSum(sums=new_sums, amp=new_amp, kets=new_kets)
        print(f"\nnew_state: {new_state}")
        self.state_manager.update_state(loci, new_type, new_state, 'cast_had2en')

    def _apply_had2en(self, loci: list[QXQRange], type_info, state: QXSum, regs):
        """Apply H gate to entangled state"""
        new_kets = state.kets().copy()
        new_sums = state.sums().copy()
        print(f"regs: {regs}")          
   
        for reg in regs:
            reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
            sum_var = self.state_manager.get_fresh_sum_var()
            
            if isinstance(loci[reg_idx].crange().right(), QXNum):
                new_sum = QXCon(sum_var, QXCRange(QXNum(0),
                        QXNum(2**loci[reg_idx].crange().right().num())))
            elif isinstance(loci[reg_idx].crange().right(), QXBind):
                new_sum = QXCon(sum_var, QXCRange(QXNum(0), 
                        QXBin('^', QXNum(2), QXBind('n'))))
            new_sums.insert(reg_idx, new_sum)
            
            curr_vec = state.kets()[reg_idx].vector()
            new_vector = self.transformer.trans_vec(curr_vec, sum_var, reg_idx, OpType.HADAMARD)
            new_kets[reg_idx] = QXSKet(new_vector)
        new_flag_num = len(new_sums)
        new_type = TyEn(flag=QXNum(num=new_flag_num))  
        new_amp = self.transformer.trans_amp(state, OpType.HADAMARD, new_sums=new_sums, new_kets=new_kets, reg_idx=reg_idx)
        
        # Update the amplitude for the new state
        new_state = QXSum(sums=new_sums, amp=new_amp, kets=new_kets)
        self.state_manager.update_state(loci, new_type, new_state, 'H')

    def _apply_had2had(self, loci, type_info, state: QXTensor, regs):
        """Apply H gate to Hadamard basis state"""
        new_kets = state.kets().copy()
        
        for reg in regs:
            reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
            curr_ket = state.kets()[reg_idx].vector()
            new_vector = self.transformer.trans_vec(
                curr_ket,
                None,
                reg_idx,
                OpType.HADAMARD
            )
            new_kets[reg_idx] = QXSKet(new_vector)

        new_state = QXTensor(new_kets)
        self.state_manager.update_state(loci, type_info, new_state, 'H')

    def _apply_had2nor(self, loci, type_info, state: QXTensor, regs):
        """Apply H gate to normal state"""
        new_kets = state.kets().copy()
        
        for reg in regs:
            reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
            curr_ket = state.kets()[reg_idx].vector()
            print(f"org_ket: {curr_ket}, reg_idx: {reg_idx}, loci: {loci}")
            new_vector = self.transformer.trans_vec(
                curr_ket,
                None,
                reg_idx,
                OpType.HADAMARD
            )
    #        print(f"new_vector: {new_vector}")
            new_kets[reg_idx] = QXSKet(new_vector)
            print(f"new_kets: {new_kets}")
            new_state = QXTensor(new_kets)
            new_type = TyHad()
        self.state_manager.update_state(loci, new_type, new_state, 'H')

    def _apply_chad2nor(self, loci, type_info, state: QXTensor, regs):
        """Cast Hadamard basis state to normal state"""
        new_kets = []
        new_sums = []
        sum_vars = []
        new_amp = state.amp()
        print(f"amp: {new_amp}")
        print(f"regs: {regs}, \n\nloci: {loci}, \n\nstate: {state}")


        # Introduce a sum variable for each ket (qubit)
        for i, reg in enumerate(regs):
            sum_var = self.state_manager.get_fresh_sum_var()
            sum_vars.append(sum_var)
            if isinstance(loci[i].crange().right(), QXNum):
                new_sum = QXCon(sum_var, QXCRange(QXNum(0),
                        QXNum(2**loci[i].crange().right().num())))
                if not new_amp:
                    new_amp = QXBin(
                    '/',
                    QXNum(1),
                    QXUni('sqrt', QXNum(2**loci[i].crange().right().num())))
                
                else:
                    new_amp = QXBin('*', 
                            new_amp,
                            QXBin(
                            '/',
                            QXNum(1),
                            QXUni('sqrt', QXNum(2**loci[i].crange().right().num())))
                )
            elif isinstance(loci[i].crange().right(), QXBind):
                new_sum = QXCon(sum_var, QXCRange(QXNum(0), 
                        QXBin('^', QXNum(2), QXBind('n'))))
                if not new_amp:
                    new_amp = QXBin(
                    '/',
                    QXNum(1),
                    QXUni('sqrt', QXBin('^', QXNum(2), QXBind('n')))
                        )
                else:
                    new_amp = QXBin('*', 
                                    new_amp,
                                    QXBin(
                                    '/',
                                    QXNum(1),
                                    QXUni('sqrt', QXBin('^', QXNum(2), QXBind('n')))
                                )
                    )
                
            new_sums.insert(i, new_sum)
            print(new_sums)
            # Replace the ket with a bound variable
            # if i < len(regs):
            #     ew_kets.insert(i, QXSKet(QXBin(sum_var)))
            if i == 0: 
                new_kets.insert(i, QXSKet(QXBind(sum_var)))
            else:
                new_kets.insert(i, QXSKet(QXBin('*', QXBind(sum_vars[0]), QXBind(sum_var))))
            


        new_type = TyEn(flag=QXNum(num=len(new_sums)))
        new_state = QXSum(sums=new_sums, amp=new_amp, kets=new_kets)
        self.state_manager.update_state(loci, new_type, new_state, 'CH')

    def _apply_chad2had(self, loci, type_info, state: QXTensor, regs):
        pass

    def _apply_chad2en(self, loci, type_info, state: QXTensor, regs):
        pass


    def _apply_lambda_en(self, loci, type_info, state: QXSum, regs, vectors, params, fn):
        """Apply lambda to entangled state"""
        if not isinstance(state, QXSum):
            return

        new_kets = state.kets().copy()
        for i, reg in enumerate(regs):
            if i >= len(vectors):
                break
            reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
            param = params[i] if isinstance(params, list) else params
        #    print(f"vector: {vectors[i].vector()}")
            new_vector = self.transformer.trans_vec(
                vectors[i].vector(),
                param,
                reg_idx,
                OpType.LAMBDA,
                kets=new_kets
            )
            new_kets[reg_idx] = QXSKet(new_vector)

        new_amp = self.transformer.trans_amp(state, OpType.LAMBDA, fn=fn, params=params)
        new_state = QXSum(sums=state.sums(), amp=new_amp, kets=new_kets)
        self.state_manager.update_state(loci, type_info, new_state, 'λ')

    def _apply_lambda_had(self, loci, type_info, state: QXTensor, regs, vectors, params, fn):
        """Apply lambda to Hadamard basis state"""
        new_kets = state.kets().copy()
        
        for i, reg in enumerate(regs):
            if i >= len(vectors):
                break
            reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
            param = params[i] if isinstance(params, list) else params
            new_vector = QXBin(
                'H',
                self.transformer.trans_vec(
                    vectors[i].vector(),
                    param,
                    reg_idx,
                    OpType.LAMBDA,
                    kets = new_kets
                ),
                None
            )
            new_kets[reg_idx] = QXSKet(new_vector)
            
        new_state = QXTensor(new_kets)
        self.state_manager.update_state(loci, type_info, new_state, 'λ')

    def _apply_lambda_nor(self, loci, type_info, state: QXTensor, regs, vectors, params, fn):
        """Apply lambda to normal state"""
        new_kets = state.kets().copy()
        
        for i, reg in enumerate(regs):
            if i >= len(vectors):
                break
            reg_idx = next(j for j, loc in enumerate(loci) if loc.ID() == reg)
            param = params[i] if isinstance(params, list) else params
            new_vector = self.transformer.trans_vec(
                vectors[i].vector(),
                param,
                reg_idx,
                OpType.LAMBDA, 
                kets=new_kets
            )
            new_kets[reg_idx] = QXSKet(new_vector)
        
        new_state = QXTensor(new_kets)
        self.state_manager.update_state(loci, type_info, new_state, 'λ')