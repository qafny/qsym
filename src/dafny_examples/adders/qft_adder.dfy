include "../gates.dfy"


method qft_adder(
  kets: seq<seq<bv1>>,
  amps: seq<real>,
  phases: seq<real>,
  nQ: nat
) returns (
  okets: seq<seq<bv1>>,
  oamps: seq<real>,
  ophases: seq<real>
)
  requires validState(kets, amps, phases, nQ)
  requires 8 == nQ
  requires |kets| == nQ
  requires |amps| == 1
  requires |phases| == 1
  ensures validState(okets, oamps, ophases, nQ)
  ensures forall i :: 0 <= i < |okets| ==> castBVInt(okets[i][0..4]) == 6
  ensures forall i :: 0 <= i < |okets| ==>  castBVInt(okets[i][4..8]) == (castBVInt(kets[i][4..8]) + castBVInt(kets[i][0..4])) % pow2(4)
{
  var k0, a0, p0 := rz(kets, amps, phases, nQ, 0, 2, 1);
  var k1, a1, p1 := x(k0, a0, p0, nQ, 1);
  var k2, a2, p2 := rz(k1, a1, p1, nQ, 1, 2, 1);
  var k3, a3, p3 := x(k2, a2, p2, nQ, 2);
  var k4, a4, p4 := rz(k3, a3, p3, nQ, 2, 2, 1);
  var k5, a5, p5 := rz(k4, a4, p4, nQ, 3, 2, 1);

  var k6, a6, p6 := h(k5, a5, p5, nQ, 7);
  var k7, a7, p7 := rz(k6, a6, p6, nQ, 7, 3, 1);
  var k8, a8, p8 := cx(k7, a7, p7, nQ, 7, 6);
  var k9, a9, p9 := rz(k8, a8, p8, nQ, 6, 3, -1);
  var k10, a10, p10 := cx(k9, a9, p9, nQ, 7, 6);
  var k11, a11, p11 := rz(k10, a10, p10, nQ, 6, 3, 1);

  var k12, a12, p12 := h(k11, a11, p11, nQ, 6);
  var k13, a13, p13 := rz(k12, a12, p12, nQ, 6, 3, 1);
  var k14, a14, p14 := rz(k13, a13, p13, nQ, 7, 4, 1);
  var k15, a15, p15 := cx(k14, a14, p14, nQ, 7, 5);
  var k16, a16, p16 := rz(k15, a15, p15, nQ, 5, 4, -1);
  var k17, a17, p17 := cx(k16, a16, p16, nQ, 7, 5);
  var k18, a18, p18 := rz(k17, a17, p17, nQ, 5, 4, 1);
  var k19, a19, p19 := cx(k18, a18, p18, nQ, 6, 5);
  var k20, a20, p20 := rz(k19, a19, p19, nQ, 5, 3, -1);
  var k21, a21, p21 := cx(k20, a20, p20, nQ, 6, 5);
  var k22, a22, p22 := rz(k21, a21, p21, nQ, 5, 3, 1);

  var k23, a23, p23 := h(k22, a22, p22, nQ, 5);
  var k24, a24, p24 := rz(k23, a23, p23, nQ, 5, 3, 1);
  var k25, a25, p25 := rz(k24, a24, p24, nQ, 6, 4, 1);
  var k26, a26, p26 := rz(k25, a25, p25, nQ, 7, 5, 1);
  var k27, a27, p27 := cx(k26, a26, p26, nQ, 7, 4);
  var k28, a28, p28 := rz(k27, a27, p27, nQ, 4, 5, -1);
  var k29, a29, p29 := cx(k28, a28, p28, nQ, 7, 4);
  var k30, a30, p30 := rz(k29, a29, p29, nQ, 4, 5, 1);
  var k31, a31, p31 := cx(k30, a30, p30, nQ, 6, 4);
  var k32, a32, p32 := rz(k31, a31, p31, nQ, 4, 4, -1);
  var k33, a33, p33 := cx(k32, a32, p32, nQ, 6, 4);
  var k34, a34, p34 := rz(k33, a33, p33, nQ, 4, 4, 1);
  var k35, a35, p35 := cx(k34, a34, p34, nQ, 5, 4);
  var k36, a36, p36 := rz(k35, a35, p35, nQ, 4, 3, -1);
  var k37, a37, p37 := cx(k36, a36, p36, nQ, 5, 4);
  var k38, a38, p38 := rz(k37, a37, p37, nQ, 4, 3, 1);

  var k39, a39, p39 := h(k38, a38, p38, nQ, 4);
  var k40, a40, p40 := cx(k39, a39, p39, nQ, 0, 4);
  var k41, a41, p41 := rz(k40, a40, p40, nQ, 4, 2, -1);
  var k42, a42, p42 := cx(k41, a41, p41, nQ, 0, 4);
  var k43, a43, p43 := rz(k42, a42, p42, nQ, 0, 3, 1);
  var k44, a44, p44 := cx(k43, a43, p43, nQ, 0, 5);
  var k45, a45, p45 := rz(k44, a44, p44, nQ, 4, 2, 1);



  var k46, a46, p46 := h(k45, a45, p45, nQ, 4);
  var k47, a47, p47 := rz(k46, a46, p46, nQ, 5, 3, -1);
  var k48, a48, p48 := cx(k47, a47, p47, nQ, 0, 5);
  var k49, a49, p49 := rz(k48, a48, p48, nQ, 0, 4, 1);
  var k50, a50, p50 := cx(k49, a49, p49, nQ, 0, 6);
  var k51, a51, p51 := rz(k50, a50, p50, nQ, 5, 3, 1);
  var k52, a52, p52 := cx(k51, a51, p51, nQ, 1, 5);
  var k53, a53, p53 := rz(k52, a52, p52, nQ, 5, 2, -1);
  var k54, a54, p54 := cx(k53, a53, p53, nQ, 1, 5);
  var k55, a55, p55 := rz(k54, a54, p54, nQ, 1, 3, 1);
  var k56, a56, p56 := rz(k55, a55, p55, nQ, 5, 2, 1);
  var k57, a57, p57 := rz(k56, a56, p56, nQ, 5, 3, -1);
  var k58, a58, p58 := cx(k57, a57, p57, nQ, 5, 4);
  var k59, a59, p59 := rz(k58, a58, p58, nQ, 4, 3, 1);
  var k60, a60, p60 := cx(k59, a59, p59, nQ, 5, 4);
  var k61, a61, p61 := rz(k60, a60, p60, nQ, 4, 3, -1);

  var k62, a62, p62 := h(k61, a61, p61, nQ, 5);
  var k63, a63, p63 := rz(k62, a62, p62, nQ, 6, 4, -1);
  var k64, a64, p64 := cx(k63, a63, p63, nQ, 0, 6);
  var k65, a65, p65 := rz(k64, a64, p64, nQ, 0, 5, 1);
  var k66, a66, p66 := cx(k65, a65, p65, nQ, 0, 7);
  var k67, a67, p67 := rz(k66, a66, p66, nQ, 6, 4, 1);
  var k68, a68, p68 := cx(k67, a67, p67, nQ, 1, 6);
  var k69, a69, p69 := rz(k68, a68, p68, nQ, 6, 3, -1);
  var k70, a70, p70 := cx(k69, a69, p69, nQ, 1, 6);
  var k71, a71, p71 := rz(k70, a70, p70, nQ, 1, 4, 1);
  var k72, a72, p72 := rz(k71, a71, p71, nQ, 6, 3, 1);
  var k73, a73, p73 := cx(k72, a72, p72, nQ, 2, 6);
  var k74, a74, p74 := rz(k73, a73, p73, nQ, 6, 2, -1);
  var k75, a75, p75 := cx(k74, a74, p74, nQ, 2, 6);
  var k76, a76, p76 := rz(k75, a75, p75, nQ, 2, 3, 1);
  var k77, a77, p77 := rz(k76, a76, p76, nQ, 6, 2, 1);
  var k78, a78, p78 := rz(k77, a77, p77, nQ, 6, 4, -1);
  var k79, a79, p79 := cx(k78, a78, p78, nQ, 6, 4);
  var k80, a80, p80 := rz(k79, a79, p79, nQ, 4, 4, 1);
  var k81, a81, p81 := cx(k80, a80, p80, nQ, 6, 4);
  var k82, a82, p82 := rz(k81, a81, p81, nQ, 4, 4, -1);
  var k83, a83, p83 := rz(k82, a82, p82, nQ, 6, 3, -1);
  var k84, a84, p84 := cx(k83, a83, p83, nQ, 6, 5);
  var k85, a85, p85 := rz(k84, a84, p84, nQ, 5, 3, 1);
  var k86, a86, p86 := cx(k85, a85, p85, nQ, 6, 5);
  var k87, a87, p87 := rz(k86, a86, p86, nQ, 5, 3, -1);

  var k88, a88, p88 := h(k87, a87, p87, nQ, 6);
  var k89, a89, p89 := rz(k88, a88, p88, nQ, 7, 5, -1);
  var k90, a90, p90 := cx(k89, a89, p89, nQ, 0, 7);
  var k91, a91, p91 := rz(k90, a90, p90, nQ, 7, 5, 1);
  var k92, a92, p92 := cx(k91, a91, p91, nQ, 1, 7);
  var k93, a93, p93 := rz(k92, a92, p92, nQ, 7, 4, -1);
  var k94, a94, p94 := cx(k93, a93, p93, nQ, 1, 7);
  var k95, a95, p95 := rz(k94, a94, p94, nQ, 7, 4, 1);
  var k96, a96, p96 := cx(k95, a95, p95, nQ, 2, 7);
  var k97, a97, p97 := rz(k96, a96, p96, nQ, 7, 3, -1);
  var k98, a98, p98 := cx(k97, a97, p97, nQ, 2, 7);
  var k99, a99, p99 := rz(k98, a98, p98, nQ, 7, 3, 1);
  var k100, a100, p100 := cx(k99, a99, p99, nQ, 3, 7);
  var k101, a101, p101 := rz(k100, a100, p100, nQ, 7, 2, -1);
  var k102, a102, p102 := cx(k101, a101, p101, nQ, 3, 7);
  var k103, a103, p103 := rz(k102, a102, p102, nQ, 7, 2, 1);
  var k104, a104, p104 := rz(k103, a103, p103, nQ, 7, 5, -1);
  var k105, a105, p105 := cx(k104, a104, p104, nQ, 7, 4);
  var k106, a106, p106 := rz(k105, a105, p105, nQ, 4, 5, 1);
  var k107, a107, p107 := cx(k106, a106, p106, nQ, 7, 4);
  var k108, a108, p108 := rz(k107, a107, p107, nQ, 4, 5, -1);
  var k109, a109, p109 := rz(k108, a108, p108, nQ, 7, 4, -1);
  var k110, a110, p110 := cx(k109, a109, p109, nQ, 7, 5);
  var k111, a111, p111 := rz(k110, a110, p110, nQ, 5, 4, 1);
  var k112, a112, p112 := cx(k111, a111, p111, nQ, 7, 5);
  var k113, a113, p113 := rz(k112, a112, p112, nQ, 5, 4, -1);
  var k114, a114, p114 := rz(k113, a113, p113, nQ, 7, 3, -1);
  var k115, a115, p115 := cx(k114, a114, p114, nQ, 7, 6);
  var k116, a116, p116 := rz(k115, a115, p115, nQ, 6, 3, 1);
  var k117, a117, p117 := cx(k116, a116, p116, nQ, 7, 6);
  var k118, a118, p118 := rz(k117, a117, p117, nQ, 6, 3, -1);
  okets, oamps, ophases := h(k118, a118, p118, nQ, 7);
}

