grammar XMLExp;

root: '<' Root '>' program '</' Root '>';

nextexp: '<' Next '>' program '</' Next '>';

program: (exp)+ ;

exp: letexp | appexp | cuexp | ifexp | matchexp | skipexp | xexp | srexp | qftexp | lshiftexp | rshiftexp | revexp | rqftexp;

// blockexp : '<' BLOCK '>' '</' BLOCK '>' | '<' BLOCK '/>';

idexp : '<' VEXP OP '=' '"' ID '"' ('type' '=' '"' atype '"')? ( BLOCK '=' '"' '"')? ('rec' '=' '"' Identifier '"')? '>' Identifier '</' VEXP '>'
      |  '<' QVEXP OP '=' '"' ID '"' ('type' '=' '"' atype '"')? ( BLOCK '=' '"' '"')? '>' Identifier '</' QVEXP '>'  ;

exppair : '<' Pair 'case' '=' '"' element '"' '>' program '</' Pair '>' ;

matchexp : '<' Match 'id' '=' '"' Identifier '"' '>' exppair (exppair)* '</' Match '>' ;

letexp : '<' Let 'id' '=' '"' Identifier '"' '>' (idexp)* program '</' Let '>' ;

ifexp : '<' Ifa ( BLOCK '=' '"' '"')? '>' vexp nextexp nextexp '</' Ifa '>';

appexp : '<' APP 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' (vexp)* '</' APP '>';

vexp: idexp | '<' VEXP OP '=' '"' NUM '"' ( BLOCK '=' '"' '"')? ('rec' '=' '"' Identifier '"')? '>' numexp '</' VEXP '>'
    | '<' VEXP OP '=' '"' op '"' ( BLOCK  '=' '"' '"')? ('rec' '=' '"' Identifier '"')? '>' vexp vexp '</' VEXP '>';

element : numexp | Identifier;

numexp: Number | Minus Number;
        
 // Lexical Specification of this Programming Language
 //  - lexical specification rules start with uppercase

skipexp: '<' PEXP 'gate' '=' '"' 'SKIP' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' vexp '</' PEXP '>' ;

xexp: '<' PEXP 'gate' '=' '"' 'X' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' vexp '</' PEXP '>' ;

cuexp: '<' PEXP 'gate' '=' '"' 'CU' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' vexp program '</' PEXP '>' ;

//rzexp: '<' PEXP 'gate' '=' '"' 'RZ' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' vexp vexp '</' PEXP '>' ;

srexp: '<' PEXP 'gate' '=' '"' 'SR' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' vexp '</' PEXP '>' ;

lshiftexp: '<' PEXP 'gate' '=' '"' 'Lshift' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' '</' PEXP '>'
        | '<' PEXP 'gate' '=' '"' 'Lshift' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '/>' ;

rshiftexp: '<' PEXP 'gate' '=' '"' 'Rshift' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' '</' PEXP '>'
        | '<' PEXP 'gate' '=' '"' 'Rshift' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '/>' ;

revexp: '<' PEXP 'gate' '=' '"' 'Rev' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' '</' PEXP '>'
        | '<' PEXP 'gate' '=' '"' 'Rev' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '/>' ;

qftexp: '<' PEXP 'gate' '=' '"' 'QFT' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' vexp '</' PEXP '>' ;

rqftexp: '<' PEXP 'gate' '=' '"' 'RQFT' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '>' '</' PEXP '>'
        | '<' PEXP 'gate' '=' '"' 'RQFT' '"' 'id' '=' '"' Identifier '"' ( BLOCK '=' '"' '"')? '/>' ;

op: Plus | Minus | Times | Div | Mod | Exp | GNum;

atype: Nat | Qt '(' element ')' | Nor '(' element ')' | Phi '(' element ',' element ')';

//boolexp: TrueLiteral | FalseLiteral;

BLOCK: 'block';

Root : 'root';

Next : 'next';

Let : 'let';

Ifa : 'if';

Match : 'match';

Pair : 'pair';

Qubits : 'qubits';

Nat : 'Nat';

Qt : 'Q';

Nor : 'Nor';

Phi : 'Phi';

//Bits : 'bits';

 TrueLiteral : '#t' ;
 FalseLiteral : '#f' ;
 Dot : '.' ;

 RQFT : 'RQFT' ;

 OP : 'op';

 Plus : '+';

 Minus : '-';

 Times : '*';

 Div : '/';

 Mod : '%';

 Exp : '^';

 GNum : '$';

 APP : 'app';

 PEXP : 'pexp';

 VEXP : 'vexp';

 QVEXP : 'qvexp';

 ID : 'id';

 NUM: 'num';

 Number : DIGIT+ ;



 Identifier :   Letter LetterOrDigit*;

 Letter :   [a-zA-Z$_];

 LetterOrDigit: [a-zA-Z0-9$_];

 fragment DIGIT: ('0'..'9');

 AT : '@';
 ELLIPSIS : '...';
 WS  :  [ \t\r\n\u000C]+ -> skip;
 Comment :   '/*' .*? '*/' -> skip;
 Line_Comment :   '//' ~[\r\n]* -> skip;
