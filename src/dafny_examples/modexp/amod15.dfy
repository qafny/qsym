function {:axiom} omega(n:nat, k:int): real

lemma {:axiom} omega_add(n: nat, a: int, b: int)
  ensures omega(n, a+b) == omega(n,a)*omega(n,b)

lemma {:axiom} omega_periodic(n: nat, k: int)
  ensures omega(n, k + pow2(n)) == omega(n,k)

lemma {:axiom} omega_identity(n: nat, k: int)
  ensures k == 0 || k == pow2(n) ==> omega(n, k) == 1.0

function flip(b: bv1): bv1
{
  ((b + 1) as int % 2) as bv1
}

function updateBit(s: seq<bv1>, i: nat, b: bv1): seq<bv1>
  requires i < |s|
{
  s[..i] + [b] + s[i+1..]
}

predicate validState(kets: seq<seq<bv1>>, amps: seq<real>, phases: seq<real>, nQ: nat)
{
  |kets| == |amps| &&
  |amps| == |phases| &&
  forall i :: 0 <= i < |kets| ==> |kets[i]| == nQ
}



method rz(
  kets: seq<seq<bv1>>,
  amps: seq<real>,
  phases: seq<real>,
  q: nat,
  n: nat,
  k: int
) returns (
  okets: seq<seq<bv1>>,
  oamps: seq<real>,
  ophases: seq<real>
)
  requires validState(kets, amps, phases, if |kets| == 0 then 0 else |kets[0]|)
  requires forall i :: 0 <= i < |kets| ==> q < |kets[i]|
  ensures okets == kets
  ensures oamps == amps
  ensures |ophases| == |phases|
  ensures forall i :: 0 <= i < |phases| ==>
    ophases[i] == (if kets[i][q] == 0
                   then phases[i] * omega(n, -k)
                   else phases[i] * omega(n, k))
{
  okets := kets;
  oamps := amps;
  ophases := [];
  var i: nat := 0;
  while i < |kets|
    invariant 0 <= i <= |kets|
    invariant |ophases| == i
    invariant forall j :: 0 <= j < i ==>
      ophases[j] == (if kets[j][q] == 0
                     then phases[j] * omega(n, -k)
                     else phases[j] * omega(n, k))
  {
    var newPhase :=
      if kets[i][q] == 0 then phases[i] * omega(n, -k)
      else phases[i] * omega(n, k);

    ophases := ophases + [newPhase];
    i := i + 1;
  }
}

method h(
  kets: seq<seq<bv1>>,
  amps: seq<real>,
  phases: seq<real>,
  nQ: nat,
  q: nat
) returns (
  okets: seq<seq<bv1>>,
  oamps: seq<real>,
  ophases: seq<real>
)
  requires validState(kets, amps, phases, nQ)
  requires q < nQ
//  ensures validState(okets, oamps, ophases, nQ)
  ensures |okets| == 2 * |kets|
  ensures |oamps| == 2 * |amps|
  ensures |ophases| == 2 * |phases|
{
  okets := [];
  oamps := [];
  ophases := [];

  var i: nat := 0;
  while i < |kets|
    invariant 0 <= i <= |kets|
    invariant |okets| == 2 * i
    invariant |oamps| == 2 * i
    invariant |ophases| == 2 * i
  {
    var ket0 := updateBit(kets[i], q, 0);
    var ket1 := updateBit(kets[i], q, 1);

    okets := okets + [ket0, ket1];
    oamps := oamps + [amps[i], amps[i]];

    if kets[i][q] == 0 {
      ophases := ophases + [phases[i], phases[i]];
    } else {
      ophases := ophases + [phases[i], phases[i] * omega(1,1)];
    }

    i := i + 1;
  }
}




//if it is in bit level, consider ^1 as not
method nx(n: nat, iq: seq<bv1>) returns (oq: seq<bv1>)
    requires |iq| == n
    requires n > 0
    requires forall i :: 0 <= i < |iq| ==> iq[i] == 0
    ensures |oq| == n
    ensures forall i :: 0 <= i < |oq| ==> oq[i] == 1
    {
        var q1 := seq(|iq|, k0 requires 0 <= k0 < |iq| => ((iq[k0]+ 1) as int %2) as bv1); // (x+1) mod 2
        oq := q1;
    }

method x(iq: bv1) returns (oq: bv1)
    ensures oq == ((iq+ 1) as int %2) as bv1
    {
        oq := ((iq+ 1) as int %2) as bv1;
    }

method cx(iq: bv1, ip: bv1) returns (oq: bv1, op: bv1)
    ensures oq == iq
    ensures op == (if iq == 0 then ip else ip ^ 1)
{
    oq := iq;
    op := if iq == 0 then ip else ip ^ 1;
}

method ccx(ic1: bv1, ic2: bv1, it: bv1) returns (oc1: bv1, oc2: bv1, ot: bv1)
    ensures oc1 == ic1
    ensures oc2 == ic2
    ensures ot == (if ic1 == 1 && ic2 == 1 then it ^ 1 else it)
{
    oc1 := ic1;
    oc2 := ic2;

    if ic1 == 0 {
        ot := it;
    } else {
        var tctrl: bv1;
        tctrl, ot := cx(ic2, it);
    }
}


method swap(a: bv1, b: bv1) returns (oa: bv1, ob: bv1)
    ensures oa == b
    ensures ob == a
{
    var a1: bv1;
    var b1: bv1;
    a1, b1 := cx(a, b);

    var b2: bv1;
    var a2: bv1;
    b2, a2 := cx(b1, a1);

    var a3: bv1;
    var b3: bv1;
    a3, b3 := cx(a2, b2);

    oa := a3;
    ob := b3;
}

method cswap(c: bv1, a: bv1, b: bv1) returns (oc: bv1, oa: bv1, ob: bv1)
    ensures oc == c
    ensures c == 0 ==> oa == a && ob == b
    ensures c == 1 ==> oa == b && ob == a
{
    var c1: bv1;
    var a1: bv1;
    var b1: bv1;
    c1, a1, b1 := ccx(c, a, b);

    var c2: bv1;
    var b2: bv1;
    var a2: bv1;
    c2, b2, a2 := ccx(c1, b1, a1);

    var c3: bv1;
    var a3: bv1;
    var b3: bv1;
    c3, a3, b3 := ccx(c2, a2, b2);

    oc := c3;
    oa := a3;
    ob := b3;
}



function {:axiom} sqrt(a:real): real
                requires a > 0.0
                ensures sqrt(a) > 0.0

function bv1ToNat(b: bv1): nat { if b == 1 then 1 else 0 }
function pow2(n:nat): nat
            ensures pow2(n) > 0
            {
              if n == 0 then 1
              else 2 * pow2(n-1)
            }

function castBVInt(x: seq<bv1>): nat
    ensures |x| == 0 ==> castBVInt(x) == 0
    ensures |x| > 0 ==> castBVInt(x) == bv1ToNat(x[0]) + 2 * castBVInt(x[1..])
    ensures castBVInt(x) >= 0
    ensures castBVInt(x) < pow2(|x|)
    decreases x

    {
      if |x| == 0 then 0
      else bv1ToNat(x[0]) + 2 * castBVInt(x[1..])
    }

function {:axiom} castIntBV(x: nat, n: nat) : seq<bv1>
                ensures castBVInt(castIntBV(x, n)) == x
                ensures |castIntBV(x, n)| == n 

//built-in the function, not needed any more
lemma castBVIntStep(x: seq<bv1>)
    requires |x| > 0
    ensures castBVInt(x) == bv1ToNat(x[0]) + 2 * castBVInt(x[1..])
{
}

function pow(base: nat, exp: nat): nat
    decreases exp
{
    if exp == 0 then 1
    else base * pow(base, exp - 1)
}

function powmod15(a: nat, power: nat): nat
    requires a == 2 || a == 4 || a == 7 || a == 8 || a == 11 || a == 13
{
    pow(a, power) % 15
}

function Exp15MultBit(b: bv1, y: int, a: nat, j: nat): int
  requires 0 <= y < 15
{
  if b == 0 then y
  else ((pow(a, pow2(j)) * y) % 15)
}


// pow_0, with a = 7, multiplier 7(for verifying)
method c7_1_mod_15(gate_q_0: bv1, gate_q_1: bv1, gate_q_2: bv1, gate_q_3: bv1, gate_q_4: bv1)
    returns (oq0: bv1, oq1: bv1, oq2: bv1, oq3: bv1, oq4: bv1)
    requires 0 < castBVInt([gate_q_1, gate_q_2, gate_q_3, gate_q_4]) < 15 //this 0 < constraint comes from the circuit's limitation, the reason why the target is initialized to 1. 
    ensures oq0 == gate_q_0
    ensures castBVInt([oq1, oq2, oq3, oq4]) < 15
    ensures castBVInt([oq1, oq2, oq3, oq4]) == Exp15MultBit(gate_q_0, castBVInt([gate_q_1, gate_q_2, gate_q_3, gate_q_4]), 7, 0)
{
    var q0 := gate_q_0;
    var q1 := gate_q_1;
    var q2 := gate_q_2;
    var q3 := gate_q_3;
    var q4 := gate_q_4;

    // --- CSWAP q1, q2 ---
    q0, q1, q2 := ccx(q0, q1, q2);
    q0, q2, q1 := ccx(q0, q2, q1);
    q0, q1, q2 := ccx(q0, q1, q2);
    
    // --- CX q1 ---
    q0, q1 := cx(q0, q1);

    // --- CSWAP q2, q3 ---
    q0, q2, q3 := ccx(q0, q2, q3);
    q0, q3, q2 := ccx(q0, q3, q2);
    q0, q2, q3 := ccx(q0, q2, q3);

    // --- CX q2 ---
    q0, q2 := cx(q0, q2);

    // --- CSWAP q3, q4 ---
    q0, q3, q4 := ccx(q0, q3, q4);
    q0, q4, q3 := ccx(q0, q4, q3);
    q0, q3, q4 := ccx(q0, q3, q4);

    // --- CX q3 & q4 ---
    q0, q3 := cx(q0, q3);
    q0, q4 := cx(q0, q4);

    oq0 := q0;
    oq1 := q1;
    oq2 := q2;
    oq3 := q3;
    oq4 := q4;
}

//pow1, multiplier 4
method c7_2_mod_15(gate_q_0: bv1, gate_q_1: bv1, gate_q_2: bv1, gate_q_3: bv1, gate_q_4: bv1)
    returns (oq0: bv1, oq1: bv1, oq2: bv1, oq3: bv1, oq4: bv1)
    requires 0 < castBVInt([gate_q_1, gate_q_2, gate_q_3, gate_q_4]) < 15 //this 0 < constraint comes from the circuit's limitation, the reason why the target is initialized to 1. 
    ensures oq0 == gate_q_0
    ensures castBVInt([oq1, oq2, oq3, oq4]) < 15
    ensures castBVInt([oq1, oq2, oq3, oq4]) == Exp15MultBit(gate_q_0, castBVInt([gate_q_1, gate_q_2, gate_q_3, gate_q_4]), 7, 1)
    {
        var q0 := gate_q_0;
        var q1 := gate_q_1;
        var q2 := gate_q_2;
        var q3 := gate_q_3;
        var q4 := gate_q_4;
        // --- CSWAP q1, q2 ---
        q0, q1, q2 := ccx(q0, q1, q2);
        q0, q2, q1 := ccx(q0, q2, q1);
        q0, q1, q2 := ccx(q0, q1, q2);

        // --- CX q1 ---
        q0, q1 := cx(q0, q1);

        // --- CSWAP q2, q3 ---
        q0, q2, q3 := ccx(q0, q2, q3);
        q0, q3, q2 := ccx(q0, q3, q2);
        q0, q2, q3 := ccx(q0, q2, q3);

        // --- CX q2 ---
        q0, q2 := cx(q0, q2);

        // --- CSWAP q1, q2 ---
        q0, q1, q2 := ccx(q0, q1, q2);
        q0, q2, q1 := ccx(q0, q2, q1);
        q0, q1, q2 := ccx(q0, q1, q2);

        // --- CX q1 ---
        q0, q1 := cx(q0, q1);

        // --- CSWAP q3, q4 ---
        q0, q3, q4 := ccx(q0, q3, q4);
        q0, q4, q3 := ccx(q0, q4, q3);
        q0, q3, q4 := ccx(q0, q3, q4);

        // --- CX q3 ---
        q0, q3 := cx(q0, q3);

        // --- CSWAP q2, q3 ---
        q0, q2, q3 := ccx(q0, q2, q3);
        q0, q3, q2 := ccx(q0, q3, q2);
        q0, q2, q3 := ccx(q0, q2, q3);

        // --- CX q2 ---
        q0, q2 := cx(q0, q2);

        // --- CX q4 ---
        q0, q4 := cx(q0, q4);

        // --- CSWAP q3, q4 ---
        q0, q3, q4 := ccx(q0, q3, q4);
        q0, q4, q3 := ccx(q0, q4, q3);
        q0, q3, q4 := ccx(q0, q3, q4);

        // --- CX q3 & q4 ---
        q0, q3 := cx(q0, q3);
        q0, q4 := cx(q0, q4);

        oq0 := q0;
        oq1 := q1;
        oq2 := q2;
        oq3 := q3;
        oq4 := q4;
    }

// pow_2, multiplier 1 (for verifying)
method c7_4_mod_15(gate_q_0: bv1, gate_q_1: bv1, gate_q_2: bv1, gate_q_3: bv1, gate_q_4: bv1)
    returns (oq0: bv1, oq1: bv1, oq2: bv1, oq3: bv1, oq4: bv1)
    requires 0 < castBVInt([gate_q_1, gate_q_2, gate_q_3, gate_q_4]) < 15
    ensures oq0 == gate_q_0
    ensures castBVInt([oq1, oq2, oq3, oq4]) < 15
    ensures castBVInt([oq1, oq2, oq3, oq4]) ==
            Exp15MultBit(gate_q_0, castBVInt([gate_q_1, gate_q_2, gate_q_3, gate_q_4]), 7, 2)
{
    var q0 := gate_q_0;
    var q1 := gate_q_1;
    var q2 := gate_q_2;
    var q3 := gate_q_3;
    var q4 := gate_q_4;

    // --- CSWAP q1, q2 ---
    q0, q1, q2 := ccx(q0, q1, q2);
    q0, q2, q1 := ccx(q0, q2, q1);
    q0, q1, q2 := ccx(q0, q1, q2);

    // --- CX q1 ---
    q0, q1 := cx(q0, q1);

    // --- CSWAP q2, q3 ---
    q0, q2, q3 := ccx(q0, q2, q3);
    q0, q3, q2 := ccx(q0, q3, q2);
    q0, q2, q3 := ccx(q0, q2, q3);

    // --- CX q2 ---
    q0, q2 := cx(q0, q2);

    // --- CSWAP q1, q2 ---
    q0, q1, q2 := ccx(q0, q1, q2);
    q0, q2, q1 := ccx(q0, q2, q1);
    q0, q1, q2 := ccx(q0, q1, q2);

    // --- CX q1 ---
    q0, q1 := cx(q0, q1);

    // --- CSWAP q3, q4 ---
    q0, q3, q4 := ccx(q0, q3, q4);
    q0, q4, q3 := ccx(q0, q4, q3);
    q0, q3, q4 := ccx(q0, q3, q4);

    // --- CX q3 ---
    q0, q3 := cx(q0, q3);

    // --- CSWAP q2, q3 ---
    q0, q2, q3 := ccx(q0, q2, q3);
    q0, q3, q2 := ccx(q0, q3, q2);
    q0, q2, q3 := ccx(q0, q2, q3);

    // --- CX q2 ---
    q0, q2 := cx(q0, q2);

    // --- CSWAP q1, q2 ---
    q0, q1, q2 := ccx(q0, q1, q2);
    q0, q2, q1 := ccx(q0, q2, q1);
    q0, q1, q2 := ccx(q0, q1, q2);

    // --- CX q1 ---
    q0, q1 := cx(q0, q1);

    // --- CX q4 ---
    q0, q4 := cx(q0, q4);

    // --- CSWAP q3, q4 ---
    q0, q3, q4 := ccx(q0, q3, q4);
    q0, q4, q3 := ccx(q0, q4, q3);
    q0, q3, q4 := ccx(q0, q3, q4);

    // --- CX q3 ---
    q0, q3 := cx(q0, q3);

    // --- CSWAP q2, q3 ---
    q0, q2, q3 := ccx(q0, q2, q3);
    q0, q3, q2 := ccx(q0, q3, q2);
    q0, q2, q3 := ccx(q0, q2, q3);

    // --- CX q2 ---
    q0, q2 := cx(q0, q2);

    // --- CSWAP q1, q2 ---
    q0, q1, q2 := ccx(q0, q1, q2);
    q0, q2, q1 := ccx(q0, q2, q1);
    q0, q1, q2 := ccx(q0, q1, q2);

    // --- CX q1 ---
    q0, q1 := cx(q0, q1);

    // --- CX q4 ---
    q0, q4 := cx(q0, q4);

    // --- CSWAP q3, q4 ---
    q0, q3, q4 := ccx(q0, q3, q4);
    q0, q4, q3 := ccx(q0, q4, q3);
    q0, q3, q4 := ccx(q0, q3, q4);

    // --- CX q3 ---
    q0, q3 := cx(q0, q3);

    // --- CSWAP q2, q3 ---
    q0, q2, q3 := ccx(q0, q2, q3);
    q0, q3, q2 := ccx(q0, q3, q2);
    q0, q2, q3 := ccx(q0, q2, q3);

    // --- CX q2 ---
    q0, q2 := cx(q0, q2);

    // --- CX q4 ---
    q0, q4 := cx(q0, q4);

    // --- CSWAP q3, q4 ---
    q0, q3, q4 := ccx(q0, q3, q4);
    q0, q4, q3 := ccx(q0, q4, q3);
    q0, q3, q4 := ccx(q0, q3, q4);

    // --- CX q3 ---
    q0, q3 := cx(q0, q3);

    // --- CX q4 ---
    q0, q4 := cx(q0, q4);

    oq0 := q0;
    oq1 := q1;
    oq2 := q2;
    oq3 := q3;
    oq4 := q4;
}




// method qasm_modexp7_15_stepwise()
//     returns (amp: seq<real>, ctrl: seq<seq<bv1>>, targ: seq<seq<bv1>>)
//     ensures |amp| == pow2(8)
//     ensures |ctrl| == pow2(8)
//     ensures |targ| == pow2(8)
//     ensures forall k :: 0 <= k < pow2(8) ==> |ctrl[k]| == 8
//     ensures forall k :: 0 <= k < pow2(8) ==> |targ[k]| == 4
//     ensures forall k :: 0 <= k < pow2(8) ==> amp[k] == 1.0 / 16.0
//     ensures forall k :: 0 <= k < pow2(8) ==> castBVInt(ctrl[k]) == k
//     ensures forall k :: 0 <= k < pow2(8) ==> castBVInt(targ[k]) == pow(7, k) % 15
// {
//     // Initial control register: after H on q[0..7], enumerate all 8-bit branches
//     ctrl := seq(pow2(8), k requires 0 <= k < pow2(8) => castIntBV(k, 8));

//     // Uniform amplitudes: 1/sqrt(2^8) = 1/16
//     amp := seq(pow2(8), k requires 0 <= k < pow2(8) => 1.0 / 16.0);

//     // Initial target register: start from |0000>, then x q[8] => |0001>
//     targ := seq(pow2(8), k requires 0 <= k < pow2(8) => castIntBV(1, 4));
//     assert |castIntBV(1, 4)| == 4;
// //    assert forall k :: 0 <= k < pow2(8) ==> |targ[k]| == 4; 

//     // _c7_1_mod_15 q[0], q[8], q[9], q[10], q[11];
//     targ := seq(pow2(8), k requires 0 <= k < pow2(8) =>
//         if ctrl[k][0] == 0
//         then targ[k]
//         else castIntBV((castBVInt(targ[k]) * 7) % 15, 4)
//     );

//     // _c7_2_mod_15 q[1], q[8], q[9], q[10], q[11];
//     targ := seq(pow2(8), k requires 0 <= k < pow2(8) =>
//         if ctrl[k][1] == 0
//         then targ[k]
//         else castIntBV((castBVInt(targ[k]) * 4) % 15, 4)
//     );

//     // _c7_4_mod_15 q[2], q[8], q[9], q[10], q[11];
//     targ := seq(pow2(8), k requires 0 <= k < pow2(8) =>
//         if ctrl[k][2] == 0
//         then targ[k]
//         else castIntBV((castBVInt(targ[k]) * 1) % 15, 4)
//     );

//     // _c7_8_mod_15 q[3], q[8], q[9], q[10], q[11];
//     targ := seq(pow2(8), k requires 0 <= k < pow2(8) =>
//         if ctrl[k][3] == 0
//         then targ[k]
//         else castIntBV((castBVInt(targ[k]) * 1) % 15, 4)
//     );

//     // _c7_16_mod_15 q[4], q[8], q[9], q[10], q[11];
//     targ := seq(pow2(8), k requires 0 <= k < pow2(8) =>
//         if ctrl[k][4] == 0
//         then targ[k]
//         else castIntBV((castBVInt(targ[k]) * 1) % 15, 4)
//     );

//     // _c7_32_mod_15 q[5], q[8], q[9], q[10], q[11];
//     targ := seq(pow2(8), k requires 0 <= k < pow2(8) =>
//         if ctrl[k][5] == 0
//         then targ[k]
//         else castIntBV((castBVInt(targ[k]) * 1) % 15, 4)
//     );

//     // _c7_64_mod_15 q[6], q[8], q[9], q[10], q[11];
//     targ := seq(pow2(8), k requires 0 <= k < pow2(8) =>
//         if ctrl[k][6] == 0
//         then targ[k]
//         else castIntBV((castBVInt(targ[k]) * 1) % 15, 4)
//     );

//     // _c7_128_mod_15 q[7], q[8], q[9], q[10], q[11];
//     targ := seq(pow2(8), k requires 0 <= k < pow2(8) =>
//         if ctrl[k][7] == 0
//         then targ[k]
//         else castIntBV((castBVInt(targ[k]) * 1) % 15, 4)
//     );
// }