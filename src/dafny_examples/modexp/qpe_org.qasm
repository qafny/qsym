OPENQASM 3.0;
include "stdgates.inc";
gate qft_dg _gate_q_0, _gate_q_1, _gate_q_2 {
  swap _gate_q_0, _gate_q_2;
  h _gate_q_0;
  cp(-pi/2) _gate_q_1, _gate_q_0;
  h _gate_q_1;
  cp(-pi/4) _gate_q_2, _gate_q_0;
  cp(-pi/2) _gate_q_2, _gate_q_1;
  h _gate_q_2;
}
bit[3] c;
qubit[4] q;
h q[0];
h q[1];
h q[2];
x q[3];
cp(2*pi/3) q[0], q[3];
cp(2*pi/3) q[1], q[3];
cp(2*pi/3) q[1], q[3];
cp(2*pi/3) q[2], q[3];
cp(2*pi/3) q[2], q[3];
cp(2*pi/3) q[2], q[3];
cp(2*pi/3) q[2], q[3];
qft_dg q[0], q[1], q[2];
