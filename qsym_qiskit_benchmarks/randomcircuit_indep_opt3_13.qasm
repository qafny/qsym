// Benchmark created by MQT Bench on 2025-10-16
// For more info: https://www.cda.cit.tum.de/mqtbench/
// MQT Bench version: 2.0.1
// Qiskit version: 2.1.1
// Output format: qasm3

OPENQASM 3.0;
include "stdgates.inc";
gate csdg _gate_q_0, _gate_q_1 {
  tdg _gate_q_0;
  cx _gate_q_0, _gate_q_1;
  t _gate_q_1;
  cx _gate_q_0, _gate_q_1;
  tdg _gate_q_1;
}
gate rccx _gate_q_0, _gate_q_1, _gate_q_2 {
  h _gate_q_2;
  t _gate_q_2;
  cx _gate_q_1, _gate_q_2;
  tdg _gate_q_2;
  cx _gate_q_0, _gate_q_2;
  t _gate_q_2;
  cx _gate_q_1, _gate_q_2;
  tdg _gate_q_2;
  h _gate_q_2;
}
gate ccz _gate_q_0, _gate_q_1, _gate_q_2 {
  h _gate_q_2;
  ccx _gate_q_0, _gate_q_1, _gate_q_2;
  h _gate_q_2;
}
gate ecr _gate_q_0, _gate_q_1 {
  s _gate_q_0;
  sx _gate_q_1;
  cx _gate_q_0, _gate_q_1;
  x _gate_q_0;
}
gate rcccx _gate_q_0, _gate_q_1, _gate_q_2, _gate_q_3 {
  h _gate_q_3;
  t _gate_q_3;
  cx _gate_q_2, _gate_q_3;
  tdg _gate_q_3;
  h _gate_q_3;
  cx _gate_q_0, _gate_q_3;
  t _gate_q_3;
  cx _gate_q_1, _gate_q_3;
  tdg _gate_q_3;
  cx _gate_q_0, _gate_q_3;
  t _gate_q_3;
  cx _gate_q_1, _gate_q_3;
  tdg _gate_q_3;
  h _gate_q_3;
  t _gate_q_3;
  cx _gate_q_2, _gate_q_3;
  tdg _gate_q_3;
  h _gate_q_3;
}
gate r(p0, p1) _gate_q_0 {
  U(p0, -pi/2 + p1, pi/2 - p1) _gate_q_0;
}
gate c3sx _gate_q_0, _gate_q_1, _gate_q_2, _gate_q_3 {
  h _gate_q_3;
  cp(pi/8) _gate_q_0, _gate_q_3;
  h _gate_q_3;
  cx _gate_q_0, _gate_q_1;
  h _gate_q_3;
  cp(-pi/8) _gate_q_1, _gate_q_3;
  h _gate_q_3;
  cx _gate_q_0, _gate_q_1;
  h _gate_q_3;
  cp(pi/8) _gate_q_1, _gate_q_3;
  h _gate_q_3;
  cx _gate_q_1, _gate_q_2;
  h _gate_q_3;
  cp(-pi/8) _gate_q_2, _gate_q_3;
  h _gate_q_3;
  cx _gate_q_0, _gate_q_2;
  h _gate_q_3;
  cp(pi/8) _gate_q_2, _gate_q_3;
  h _gate_q_3;
  cx _gate_q_1, _gate_q_2;
  h _gate_q_3;
  cp(-pi/8) _gate_q_2, _gate_q_3;
  h _gate_q_3;
  cx _gate_q_0, _gate_q_2;
  h _gate_q_3;
  cp(pi/8) _gate_q_2, _gate_q_3;
  h _gate_q_3;
}
gate sxdg _gate_q_0 {
  s _gate_q_0;
  h _gate_q_0;
  s _gate_q_0;
}
gate xx_plus_yy(p0, p1) _gate_q_0, _gate_q_1 {
  rz(p1) _gate_q_0;
  sdg _gate_q_1;
  sx _gate_q_1;
  s _gate_q_1;
  s _gate_q_0;
  cx _gate_q_1, _gate_q_0;
  ry((-0.5)*p0) _gate_q_1;
  ry((-0.5)*p0) _gate_q_0;
  cx _gate_q_1, _gate_q_0;
  sdg _gate_q_0;
  sdg _gate_q_1;
  sxdg _gate_q_1;
  s _gate_q_1;
  rz(-p1) _gate_q_0;
}
gate iswap _gate_q_0, _gate_q_1 {
  s _gate_q_0;
  s _gate_q_1;
  h _gate_q_0;
  cx _gate_q_0, _gate_q_1;
  cx _gate_q_1, _gate_q_0;
  h _gate_q_1;
}
bit[13] meas;
qubit[13] q;
u3(2.405358320221107, -2.204901315398946, -0.23521883274038657) q[2];
ccx q[6], q[1], q[4];
cswap q[10], q[9], q[7];
csdg q[7], q[1];
rccx q[8], q[11], q[0];
cz q[8], q[9];
ccz q[3], q[5], q[12];
cswap q[5], q[11], q[6];
sdg q[6];
ccz q[10], q[3], q[0];
ch q[9], q[0];
ccz q[10], q[5], q[8];
ecr q[12], q[4];
rccx q[1], q[11], q[12];
ccz q[1], q[9], q[11];
rcccx q[4], q[3], q[2], q[7];
cy q[0], q[7];
ccz q[2], q[4], q[5];
p(2.2426295156381317) q[4];
csdg q[6], q[12];
crz(2.401193884234052) q[7], q[2];
ccx q[8], q[10], q[3];
rccx q[0], q[11], q[8];
sdg q[0];
ccz q[1], q[3], q[6];
ccz q[9], q[12], q[5];
ccx q[4], q[8], q[9];
y q[4];
cz q[5], q[3];
cy q[8], q[3];
t q[8];
r(0.9052373921267518, 5.087406807216837) q[10];
ccz q[2], q[10], q[6];
rcccx q[11], q[7], q[12], q[1];
c3sx q[5], q[10], q[7], q[2];
t q[5];
cswap q[9], q[1], q[0];
sx q[9];
rccx q[11], q[12], q[6];
rccx q[1], q[2], q[6];
ccx q[5], q[10], q[6];
cswap q[9], q[8], q[1];
rccx q[6], q[9], q[5];
ccz q[11], q[0], q[3];
cx q[3], q[0];
xx_plus_yy(3.650842432466433, 0.7871534634082653) q[11], q[2];
rccx q[10], q[11], q[8];
rccx q[12], q[4], q[7];
ccz q[4], q[7], q[12];
rcccx q[2], q[1], q[12], q[7];
tdg q[1];
t q[2];
ccx q[3], q[0], q[4];
ccz q[3], q[4], q[10];
ccz q[9], q[6], q[0];
cswap q[9], q[4], q[0];
U(0.8989729695019022, 2.836148587154802, 2.833584415720613) q[0];
rcccx q[11], q[7], q[5], q[8];
iswap q[2], q[8];
ccx q[7], q[1], q[5];
p(4.9769972339930675) q[7];
t q[11];
ccz q[5], q[1], q[11];
s q[12];
rcccx q[6], q[3], q[12], q[10];
ccz q[8], q[2], q[10];
ccz q[4], q[8], q[11];
rccx q[9], q[8], q[2];
ccx q[12], q[6], q[3];
c3sx q[1], q[10], q[6], q[7];
cswap q[0], q[11], q[1];
cswap q[10], q[6], q[4];
r(4.293549040632536, 5.7319921890492616) q[4];
crz(2.115194114548841) q[6], q[10];
rccx q[12], q[5], q[3];
ccz q[3], q[5], q[12];
ccx q[1], q[11], q[5];
cswap q[3], q[0], q[7];
sx q[0];
rccx q[6], q[4], q[5];
c3sx q[9], q[12], q[8], q[2];
ccx q[2], q[9], q[8];
cz q[0], q[9];
U(3.568967231508171, 5.468967898137674, 5.6946507737984255) q[8];
ccz q[11], q[7], q[3];
ccz q[2], q[7], q[6];
ccx q[6], q[8], q[7];
cswap q[2], q[7], q[6];
t q[11];
cswap q[12], q[10], q[1];
ccx q[4], q[1], q[10];
cry(3.8194794471039017) q[1], q[10];
ccz q[12], q[3], q[5];
sx q[5];
cswap q[9], q[3], q[4];
rccx q[11], q[0], q[12];
ccz q[8], q[0], q[5];
csdg q[7], q[5];
rccx q[9], q[12], q[1];
ccx q[0], q[1], q[12];
z q[9];
cswap q[11], q[10], q[4];
c3sx q[10], q[4], q[3], q[8];
ch q[8], q[3];
u2(-pi/2, 0.7223617177699095) q[3];
ccx q[11], q[2], q[6];
ccx q[6], q[9], q[4];
cswap q[10], q[7], q[2];
u2(1.4073080668162754, 0.28133025188542254) q[11];
rccx q[12], q[5], q[1];
c3sx q[1], q[8], q[0], q[9];
ccx q[5], q[6], q[11];
ccz q[6], q[1], q[0];
u2(5.56747622367805, 2.1140484731424545) q[6];
ccz q[11], q[8], q[7];
cx q[1], q[8];
rccx q[12], q[10], q[2];
u3(0.2449755639009652, 1.632717464139418, 3.10743595974429) q[2];
c3sx q[4], q[5], q[9], q[10];
rccx q[7], q[4], q[11];
ccz q[2], q[1], q[11];
ccx q[9], q[3], q[5];
rccx q[4], q[9], q[3];
rccx q[7], q[8], q[5];
rx(5.514100154870899) q[12];
rccx q[0], q[12], q[10];
sx q[0];
tdg q[12];
barrier q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7], q[8], q[9], q[10], q[11], q[12];
meas[0] = measure q[0];
meas[1] = measure q[1];
meas[2] = measure q[2];
meas[3] = measure q[3];
meas[4] = measure q[4];
meas[5] = measure q[5];
meas[6] = measure q[6];
meas[7] = measure q[7];
meas[8] = measure q[8];
meas[9] = measure q[9];
meas[10] = measure q[10];
meas[11] = measure q[11];
meas[12] = measure q[12];
