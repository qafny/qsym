from Programmer import *
from StateManager import StateManager
from OpType import OpType


class ExprTransformer:
    """Handles expression transformations"""
    def __init__(self, state_manager: StateManager):
        self.state_manager = state_manager
    
    def trans_vec(self, vector, param: str, reg_idx: int, op_type: OpType, **kwargs):
        """Transform vector expressions"""
        # Handle Hadamard transformations
        if op_type == OpType.HADAMARD or op_type == OpType.QFT or op_type == OpType.RQFT:
            if isinstance(vector, (QXNum, QXHad, QXBind, QXSKet)):
                return self._trans_qft_bind(vector, param, reg_idx, op_type)
            elif isinstance(vector, QXBin):
                if self.state_manager.path_conds:
                    return QXBin('*', QXBind(param), QXBin(vector.op(), vector.left(), vector.right()))
                return QXBind(param)
            #    return self._trans_had_bin(vector, param, reg_idx)
        
        # Handle Lambda transformations
        elif op_type == OpType.LAMBDA:
            if isinstance(vector, QXBind):
                return self._trans_lambda_bind(vector, param, reg_idx, **kwargs)      
            elif isinstance(vector, QXBin):
                return self._trans_lambda_bin(vector, param, reg_idx, op_type, **kwargs)
        
        # elif op_type == OpType.QFT:
        #     if isinstance(vector, QXBind):
        #         return self._trans_qft_bind(vector, param, reg_idx)
        
        return vector
            
    def trans_amp(self, state: QXSum, op_type: OpType, **kwargs):
        """Transform amplitude expressions"""
        if op_type == OpType.LAMBDA:
            return self._trans_lambda_amp(state, **kwargs)
        elif op_type == OpType.HADAMARD or op_type == OpType.QFT or op_type == OpType.RQFT:
            return self._trans_qft_amp(state, op_type, **kwargs)
        return state.amp()
    def _trans_lambda_bind(self, vector: QXBind, param: str, reg_idx: int, **kwargs) -> QXBind:
        """Transform binding for lambda operation"""
        kets = kwargs.get('kets')
        if kets is not None:
            # Get the current ket for this register
            curr_ket = kets[reg_idx]
            if param is not None and vector.ID() == param:
                # Use the current ket's vector ID
                return QXBind(curr_ket.vector().ID())
        return vector
    
    def _trans_lambda_bin(self, vector: QXBin, param: str, reg_idx: int, op_type, **kwargs) -> QXBin:
        """Transform binary operation for lambda operation"""
        kets = kwargs.get('kets')
        # Recursively transform left and right
        left = self.trans_vec(vector.left(), param, reg_idx, op_type, kets=kets)
        right = self.trans_vec(vector.right(), param, reg_idx, op_type, kets=kets)
        return QXBin(vector.op(), left, right)
    
    def _trans_had_bin(self, vector: QXBin, param: str, reg_idx: int, **kwargs) -> QXBin:
        """Transform binary operation for Hadamard operation"""
        
        print(f"\nvector: {vector}, param: {param}, reg_idx: {reg_idx}")

    def _trans_qft_bind(self, vector, param: str, reg_idx: int, op_type: OpType, **kwargs) -> QXBind:
        """Transform binding for Hadamard operation"""

        if isinstance(vector, QXNum):
            # Computational basis states transform to Hadamard basis   
            if op_type == OpType.HADAMARD:      
                num = vector.num()
                if num == 0:
                    return QXHad('+')
                elif num == 1:
                    return QXHad('-')
                #TODO other cases
            elif op_type == OpType.QFT:
                return QXBind(param)

        elif isinstance(vector, QXHad):
            # Hadamard basis states transform to computational basis
            if vector.state() == '+':
                return QXNum(0)
            else:
                return QXNum(1)
        elif isinstance(vector, QXBind):
            print(f"vector: {vector}, param: {param}, reg_idx: {reg_idx}")
            if vector.ID() != param:  # Current ket variable
                # if self.state_manager.path_conds:
                #     return QXBin('*', QXBind(vector.ID()), QXBind(param))
                return QXBind(param)  # Replace with new sum variable
        
        elif isinstance(vector, QXSKet):
            # Transform the vector inside the ket
            new_vec = self._trans_had_bind(vector.vector(), param, reg_idx, **kwargs)
            return QXSKet(new_vec)
               
        return vector
    
    def _trans_qft_amp(self, state: QXQState, op_type: OpType, **kwargs):
        """Transform amplitude for Hadamard operation"""     
        if isinstance(state, QXSum) or (isinstance(state, QXTensor) and op_type == OpType.QFT) or (isinstance(state, QXTensor) and op_type == OpType.RQFT):
            new_sums = kwargs.get('new_sums')
            new_kets = kwargs.get('new_kets')
            reg_idx = kwargs.get('reg_idx')
            old_kets = state.kets()
            
            if not new_sums or not new_kets:
                return state.amp()
            amp = state.amp()
     #       print(f"\nold_ket: {old_kets} \nnew_sums: {new_sums}, \n\nnew_ket: {new_kets}")
               
            if isinstance(new_sums[reg_idx].range().right(), QXBin):
                print(f"sum_var: {new_sums[reg_idx]}")
                amp = QXBin('*',
                            amp,
                        QXBin('/',
                        QXNum(1), 
                        QXUni('sqrt',  
                        QXBin(
                            '^', 
                            QXNum(2), 
                            QXBind(new_sums[reg_idx].range().right().right()
                            )
                        )
                    )
                 )
            )
            elif isinstance(new_sums[reg_idx].range().right(), QXNum):
                amp = QXBin('*',
                            amp,
                        QXBin('/',
                        QXNum(1), 
                        QXUni('sqrt',  
                        new_sums[reg_idx].range().right()
                        )
                    )
                 )
            if op_type == OpType.HADAMARD:
                amp = QXBin(
                        '*',
                        amp,
                        QXCall('ω', [QXBin('*', QXBind(new_sums[reg_idx].ID()), old_kets[reg_idx]), QXNum(2)])) #new_var*old_ket
            elif op_type == OpType.QFT:
                amp = QXBin(
                        '*',
                        amp,
                        QXCall('ω', 
                               [QXBin('*', QXBind(new_sums[reg_idx].ID()), old_kets[reg_idx]), 
                                QXBin('^', 
                                      QXNum(2), 
                                      QXBind(new_sums[reg_idx].range().right().right()))]))
            elif op_type == OpType.RQFT:
                print(f"\namp: \n{new_sums[reg_idx].ID()}")
                amp = QXBin(
                        '*',
                        amp,
                        QXCall('ω', 
                               [QXBin('*', QXNum(-1),
                                QXBin('*', QXBind(new_sums[reg_idx].ID()), old_kets[reg_idx])), 
                                QXBin('^', 
                                      QXNum(2), 
                                      QXBind(new_sums[reg_idx].range().right().right()))]))
            return amp
                
        
        #TODO to be fixed
        elif isinstance(state, QXTensor):
            # Handle computational basis states |0⟩ and |1⟩
            if isinstance(state.kets()[0].vector(), QXNum):
                num = state.kets()[0].vector().num()
                if num == 0:
                    return QXBin('/', QXNum(1), QXUni('sqrt', QXNum(2)))
                elif num == 1:
                    return QXBin('/', QXNum(-1), QXUni('sqrt', QXNum(2)))
            # Handle Hadamard basis states |+⟩ and |-⟩
            elif isinstance(state.kets()[0].vector(), QXHad):
                if state.kets()[0].vector().state() == '+':
                    # |+⟩ -> |0⟩
                    return QXNum(1)
                else:
                    # |-⟩ -> |1⟩
                    return QXNum(1)
        return state.amp()

    def _trans_lambda_amp(self, state: QXSum, **kwargs):
        """Transform amplitude for lambda operation"""
        fn = kwargs.get('fn')
        params = kwargs.get('params', [])
        
        if isinstance(fn, QXCall) and fn.ID() == 'omega':
            new_args = [self.trans_vec(exp, params[0], 0, OpType.LAMBDA) 
                       for exp in fn.exps()]
            return QXBin('*', state.amp(), QXCall('ω', new_args))
        return state.amp()