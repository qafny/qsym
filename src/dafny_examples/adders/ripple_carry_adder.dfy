include "../gates.dfy"

method ripple_carry_adder(
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
  requires nQ == 11
  requires |kets| == nQ
  requires |amps| == 1
  requires |phases| == 1
  
  ensures validState(okets, oamps, ophases, nQ) 
  //Property 1: addend is set by NOT gates
  //Register A input is 6
  ensures forall i :: 0 <= i < |okets| ==> castBVInt(okets[i][0..4]) == 6 
  // Property 2: Addition Logic (Modulo 16 for 4 bits)
  // Register B (4..8) stores the sum
  ensures forall i :: 0 <= i < |okets| ==> 
    castBVInt(okets[i][4..8]) == (castBVInt(kets[i][4..8]) + castBVInt(kets[i][0..4])) % 16   
  // Property 3: Clean Ancilla
  // return the carry qubits (8..11) back to 0
  ensures forall i :: 0 <= i < |okets| ==> castBVInt(okets[i][8..11]) == 0

  {
  var k1, a1, p1 := x(kets, amps, phases, nQ, 1);         
  var k2, a2, p2 := x(k1, a1, p1, nQ, 2);                

  var k3, a3, p3 := cx(k2, a2, p2, nQ, 3, 7);           
  
  // Carry Block 0 -> 4 -> 8
  var k4, a4, p4 := ccx(k3, a3, p3, nQ, 0, 4, 8);          
  
  // Carry Block 1 -> 5 -> 9
  var k5, a5, p5 := ccx(k4, a4, p4, nQ, 1, 5, 9);          
  var k6, a6, p6 := cx(k5, a5, p5, nQ, 1, 5);             
  var k7, a7, p7 := ccx(k6, a6, p6, nQ, 8, 5, 9);         

  // Carry Block 2 -> 6 -> 10
  var k8, a8, p8 := ccx(k7, a7, p7, nQ, 2, 6, 10);        
  var k9, a9, p9 := cx(k8, a8, p8, nQ, 2, 6);              
  var k10, a10, p10 := ccx(k9, a9, p9, nQ, 9, 6, 10);     

  // Final Sum Bit Calculation
  var k11, a11, p11 := cx(k10, a10, p10, nQ, 9, 7);        

  // Uncomputation (Cleaning the Carry Qubits)
  var k12, a12, p12 := ccx(k11, a11, p11, nQ, 9, 6, 10);   
  var k13, a13, p13 := cx(k12, a12, p12, nQ, 2, 6);       
  var k14, a14, p14 := ccx(k13, a13, p13, nQ, 2, 6, 10);   
  var k15, a15, p15 := cx(k14, a14, p14, nQ, 2, 6);        
  var k16, a16, p16 := cx(k15, a15, p15, nQ, 9, 6);      
  
  var k17, a17, p17 := ccx(k16, a16, p16, nQ, 8, 5, 9);  
  var k18, a18, p18 := cx(k17, a17, p17, nQ, 1, 5);        
  var k19, a19, p19 := ccx(k18, a18, p18, nQ, 1, 5, 9);   
  var k20, a20, p20 := cx(k19, a19, p19, nQ, 1, 5);        
  var k21, a21, p21 := cx(k20, a20, p20, nQ, 8, 5);       
  
  var k22, a22, p22 := ccx(k21, a21, p21, nQ, 0, 4, 8);  
  var k23, a23, p23 := cx(k22, a22, p22, nQ, 0, 4);    
  okets, oamps, ophases := k23, a23, p23;
  }