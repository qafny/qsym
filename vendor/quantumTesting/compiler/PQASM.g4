/*
This grammar may be used for parsing or syntax-checking PQASM code.
*/

grammar PQASM;

// -------------------------- Parser Rules ------------------------------------

program : 'ESKIP'
        | 'Next' instr
        | 'Had' list
        | 'New' list
        | 'ESeq' program program
        | 'Meas' natOrVarname list program
        | 'IFa' cBoolExp program program
        | instr
        | '(' program ')';

instr : 'ISeq' instr instr
      | 'ICU' pos instr
      | 'Ora' mu
      | 'Ry' pos rot
      | mu
      | '(' instr ')';

// OQASM arithmetic operations
mu : 'Add' list natOrVarname
   | 'Less' list natOrVarname pos
   | 'Equal' list natOrVarname pos
   | 'ModMult' list natOrVarname natOrVarname
   | 'Equal_posi_list' list pos
   | '(' mu ')';

// Arithmetic expression
arithExp : 'BA' VARNAME       // 'BA' seems to be a variable literal
         | 'Num' natOrNatMaker
         | 'APlus' arithExp arithExp
         | 'AMult' arithExp arithExp
         | natOrVarname
         | '(' arithExp ')';

// Classical boolean expression
cBoolExp : 'CEq' arithExp arithExp
         | 'CLt' arithExp arithExp
         | '(' cBoolExp ')';


// Low Level

list : '['VARNAME']';

pos : natOrVarname; // Position (in a list)
rot : natOrVarname; // Rotation (this seems to be defined only as a NAT and not REAL?)

natOrVarname : natOrNatMaker
             | VARNAME;

boolOrVarName : BOOL
              | VARNAME;

natOrNatMaker : NAT
              | 'nat2fb' NAT
              | '(' natOrNatMaker ')';
// -------------------------- Lexer Tokens ------------------------------------

ESKIP : 'eskip';

NAT : [0-9]+;

BOOL : 'true'
     | 'false'; // I'm not sure how booleans are even written in PQASM, this is a guess

VARNAME : [a-zA-Z_0-9]+; // Any combo of letters and numbers

WS : [ \t\r\n]+ -> skip ;