function {:axiom} omega(n:nat, k:int): real

function {:axiom} sqrt(a:real): real
                requires a > 0.0
                ensures sqrt(a) > 0.0

function {:axiom} inv_sqrt(a: real): real
    requires a > 0.0
    ensures inv_sqrt(a) == 1.0/sqrt(a)

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

method x(
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
  ensures validState(okets, oamps, ophases, nQ)
  ensures oamps == amps
  ensures ophases == phases
  ensures forall i :: 0 <= i < |kets| ==> |okets[i]| == nQ
  ensures forall i :: 0 <= i < |kets| ==> okets[i][q] == flip(kets[i][q])
  ensures forall i, j :: 0 <= i < |kets| && 0 <= j < nQ && j != q ==> okets[i][j] == kets[i][j]
{
  okets := [];
  oamps := amps;
  ophases := phases;

  var i: nat := 0;
  while i < |kets|
    invariant 0 <= i <= |kets|
    invariant |okets| == i
    invariant oamps == amps
    invariant ophases == phases
    invariant forall j :: 0 <= j < i ==> |okets[j]| == nQ
  invariant forall j :: 0 <= j < i ==> |okets[j]| == nQ
  invariant forall j :: 0 <= j < i ==> okets[j][q] == flip(kets[j][q])
  invariant forall j, t :: 0 <= j < i && 0 <= t < nQ && t != q ==> okets[j][t] == kets[j][t]
  {
    okets := okets + [updateBit(kets[i], q, flip(kets[i][q]))];
    i := i + 1;
  }
}

method cx(
  kets: seq<seq<bv1>>,
  amps: seq<real>,
  phases: seq<real>,
  nQ: nat,
  c: nat,
  t: nat
) returns (
  okets: seq<seq<bv1>>,
  oamps: seq<real>,
  ophases: seq<real>
)
  requires validState(kets, amps, phases, nQ)
  requires c < nQ && t < nQ && c != t
  ensures validState(okets, oamps, ophases, nQ)
    ensures oamps == amps
    ensures ophases == phases
    ensures |okets| == |kets|
    ensures forall i :: 0 <= i < |kets| ==> |okets[i]| == nQ
    ensures forall i, j :: 0 <= i < |kets| && 0 <= j < nQ && j != t ==> okets[i][j] == kets[i][j]
    ensures forall i :: 0 <= i < |kets| ==> okets[i][t] == (if kets[i][c] == 0 then kets[i][t] else flip(kets[i][t]))
{
  okets := [];
  oamps := amps;
  ophases := phases;

  var i: nat := 0;
  while i < |kets|
    invariant 0 <= i <= |kets|
    invariant |okets| == i
    invariant oamps == amps
    invariant ophases == phases
    invariant forall j :: 0 <= j < i ==> |okets[j]| == nQ
    invariant forall j :: 0 <= j < i ==> |okets[j]| == nQ
    invariant forall j, q :: 0 <= j < i && 0 <= q < nQ && q != t ==> okets[j][q] == kets[j][q]
    invariant forall j :: 0 <= j < i ==> okets[j][t] == (if kets[j][c] == 0 then kets[j][t] else flip(kets[j][t]))
  {
    var out := kets[i];
    if kets[i][c] == 1 {
      out := updateBit(out, t, flip(out[t]));
    }
    okets := okets + [out];
    i := i + 1;
  }
}

method ccx(
  kets: seq<seq<bv1>>,
  amps: seq<real>,
  phases: seq<real>,
  nQ: nat,
  c1: nat,
  c2: nat,
  t: nat
) returns (
  okets: seq<seq<bv1>>,
  oamps: seq<real>,
  ophases: seq<real>
)
  requires validState(kets, amps, phases, nQ)
  requires c1 < nQ && c2 < nQ && t < nQ
  requires c1 != c2 && c1 != t && c2 != t
  ensures validState(okets, oamps, ophases, nQ)
  ensures oamps == amps
  ensures ophases == phases
  ensures forall i :: 0 <= i < |kets| ==>
    okets[i][t] == (if kets[i][c1] == 1 && kets[i][c2] == 1 then flip(kets[i][t]) else kets[i][t])
  ensures forall i, j :: 0 <= i < |kets| && 0 <= j < nQ && j != t ==> okets[i][j] == kets[i][j]
{
  okets := [];
  oamps := amps;
  ophases := phases;

  var i: nat := 0;
  while i < |kets|
    invariant 0 <= i <= |kets|
    invariant |okets| == i
    invariant oamps == amps
    invariant ophases == phases
    invariant forall j :: 0 <= j < i ==> |okets[j]| == nQ
    invariant forall j :: 0 <= j < i ==> okets[j][t] == (if kets[j][c1] == 1 && kets[j][c2] == 1 then flip(kets[j][t]) else kets[j][t])
    invariant forall j, p :: 0 <= j < i && 0 <= p < nQ && p != t ==> okets[j][p] == kets[j][p]
  {
    var out := kets[i];
    if kets[i][c1] == 1 && kets[i][c2] == 1 {
      out := updateBit(out, t, flip(out[t]));
    }
    okets := okets + [out];
    i := i + 1;
  }
}

method swap(
  kets: seq<seq<bv1>>,
  amps: seq<real>,
  phases: seq<real>,
  nQ: nat,
  a: nat,
  b: nat
) returns (
  okets: seq<seq<bv1>>,
  oamps: seq<real>,
  ophases: seq<real>
)
  requires validState(kets, amps, phases, nQ)
  requires a < nQ && b < nQ && a != b
  ensures validState(okets, oamps, ophases, nQ)
  ensures oamps == amps
  ensures ophases == phases
  ensures |okets| == |kets|
  ensures forall i :: 0 <= i < |kets| ==> |okets[i]| == nQ
  ensures forall i :: 0 <= i < |kets| ==> okets[i][a] == kets[i][b]
  ensures forall i :: 0 <= i < |kets| ==> okets[i][b] == kets[i][a]
  ensures forall i, j :: 0 <= i < |kets| && 0 <= j < nQ && j != a && j != b ==> okets[i][j] == kets[i][j]
{
  okets := [];
  oamps := amps;
  ophases := phases;

  var i: nat := 0;
  while i < |kets|
    invariant 0 <= i <= |kets|
    invariant |okets| == i
    invariant oamps == amps
    invariant ophases == phases
    invariant forall j :: 0 <= j < i ==> |okets[j]| == nQ
    invariant forall j :: 0 <= j < i ==> okets[j][a] == kets[j][b]
    invariant forall j :: 0 <= j < i ==> okets[j][b] == kets[j][a]
    invariant forall j, p :: 0 <= j < i && 0 <= p < nQ && p != a && p != b ==> okets[j][p] == kets[j][p]
  {
    var ka := kets[i][a];
    var kb := kets[i][b];
    var tmp := updateBit(kets[i], a, kb);
    var out := updateBit(tmp, b, ka);
    okets := okets + [out];
    i := i + 1;
  }
}

method rz(
  kets: seq<seq<bv1>>,
  amps: seq<real>,
  phases: seq<real>,
  nQ: nat,
  q: nat,
  n: nat, //omega(n, k)
  k: int
) returns (
  okets: seq<seq<bv1>>,
  oamps: seq<real>,
  ophases: seq<real>
)
  requires validState(kets, amps, phases, nQ)
  requires q < nQ
  ensures validState(okets, oamps, ophases, nQ)
  ensures okets == kets
  ensures oamps == amps
  ensures |ophases| == |phases|
  ensures forall i :: 0 <= i < |phases| ==>
    ophases[i] == (if kets[i][q] == 0
                   then phases[i] * omega(n, -k)
                   else phases[i] * omega(n,  k))
{
  okets := kets;
  oamps := amps;
  ophases := [];

  var i: nat := 0;
  while i < |kets|
    invariant 0 <= i <= |kets|
    invariant okets == kets
    invariant oamps == amps
    invariant |ophases| == i
    invariant forall j :: 0 <= j < i ==>
        ophases[j] == (if kets[j][q] == 0
                    then phases[j] * omega(n, -k)
                    else phases[j] * omega(n,  k))
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
  ensures validState(okets, oamps, ophases, nQ)
  ensures |okets| == 2 * |kets|
  ensures |oamps| == 2 * |amps|
  ensures |ophases| == 2 * |phases|
  ensures forall i :: 0 <= i < |kets| ==> okets[2*i] == updateBit(kets[i], q, 0)
  ensures forall i :: 0 <= i < |kets| ==> okets[2*i + 1] == updateBit(kets[i], q, 1)
  ensures forall i :: 0 <= i < |amps| ==> oamps[2*i] == amps[i] * inv_sqrt(2.0) && oamps[2*i + 1] == amps[i] * inv_sqrt(2.0)
  ensures forall i :: 0 <= i < |phases| ==>
    (if kets[i][q] == 0 then
        ophases[2*i] == phases[i] &&
        ophases[2*i + 1] == phases[i]
     else
        ophases[2*i] == phases[i] &&
        ophases[2*i + 1] == phases[i] * omega(1,1))
  ensures forall i, j :: 0 <= i < |kets| && 0 <= j < nQ && j != q ==> okets[2*i][j] == kets[i][j] && okets[2*i + 1][j] == kets[i][j]
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
    invariant forall j :: 0 <= j < |okets| ==> |okets[j]| == nQ
    invariant forall j :: 0 <= j < i ==> okets[2*j] == updateBit(kets[j], q, 0)
    invariant forall j :: 0 <= j < i ==> okets[2*j + 1] == updateBit(kets[j], q, 1)
    invariant forall j :: 0 <= j < i ==> oamps[2*j] == amps[j] * inv_sqrt(2.0) && oamps[2*j + 1] == amps[j] * inv_sqrt(2.0)
    invariant forall j :: 0 <= j < i ==>
        (if kets[j][q] == 0 then
            ophases[2*j] == phases[j] &&
            ophases[2*j + 1] == phases[j]
        else
            ophases[2*j] == phases[j] &&
            ophases[2*j + 1] == phases[j] * omega(1,1))
    invariant forall j, t :: 0 <= j < i && 0 <= t < nQ && t != q ==> okets[2*j][t] == kets[j][t] && okets[2*j + 1][t] == kets[j][t]
  {
    var ket0 := updateBit(kets[i], q, 0);
    var ket1 := updateBit(kets[i], q, 1);

    var amp_norm := amps[i] * inv_sqrt(2.0);
    okets := okets + [ket0, ket1];
    oamps := oamps + [amp_norm, amp_norm];

    if kets[i][q] == 0 {
      ophases := ophases + [phases[i], phases[i]];
    } else {
      ophases := ophases + [phases[i], phases[i] * omega(1,1)];
    }

    i := i + 1;
  }
}

