grammar PQASMPaper;

// This grammar is only aligned with the paper, not the actual syntax being used
// in the real PQASM code.

// -------------------------- Parser Rules ------------------------------------

// High Level

program : statement+ ;

statement : instruction
          | hadamardOp
          | newQubit
          | measurement
          | conditional;

instruction : oqasmArithmeticOp
            | yRotation
            | controlledInstruction;

oqasmArithmeticOp : addition
                  | modMult // modular multiplication
                  | equality
                  | comparison;

parameter : QUBIT
          | NAT;


// Low Level

hadamardOp : 'h(' QUBIT ')';

newQubit : 'new (' QUBIT ')';

measurement : 'M (' QUBIT ')';

conditional : 'if (' BOOL ')' program 'else' program;

yRotation : 'Ry' angle QUBIT;

controlledInstruction : 'CU' QUBIT instruction;

addition : 'add(' parameter ',' parameter ')';

modMult : '(' NAT '*' parameter ') % ' NAT;

equality : '(' parameter '=' parameter ') @ ' QUBIT;

comparison : '(' parameter '<' parameter ') @ ' QUBIT;

angle : NAT;


// -------------------------- Lexer Tokens ------------------------------------

NAT : [0-9]+;

DIGIT : [0-9];

BOOL : 'true'
     | 'false';

QUBIT : [a-zA-Z_][a-zA-Z_0-9]*; // Anything that starts with a letter


WS : [ \t\r\n]+ -> skip; // ignore any whitespace


