from enum import Enum

class OpType(Enum):
    HADAMARD = 'hadamard'
    LAMBDA = 'lambda'
    QFT = 'qft'
    RQFT = 'rqft'
    MEASUREMENT = 'measurement'