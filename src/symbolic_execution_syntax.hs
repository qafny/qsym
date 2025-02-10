-- Planning for grammar
-- 

-- cases
-- addition
-- { P }   
-- x[i,j) <- lambda(a => | a + 10 >)  (* program *)
-- { P /\ …  } 
-- lambda is an oracle function, we assume it provides the proper post-addition quantum state

-- for loop
-- { P }    (* e does not contain measurement *)
-- for x in [i, j) {
--  If (B(x)) { // quantum conditional, B is quantum boolean guard, such as q[x], q < n @ p[x]
--     e
--  }
-- }
-- { P /\ … } 
-- Any qubits measured in quantum conditional are 0 or 1
-- Only Nor type qubits will be unaffected.
-- Had type qubits will have superposition broken and will be either 0 or 1 (Nor type)
-- EN type qubits will have entanglement broken and will be either 0 or 1 (Nor type)
-- Methods: if measured call measure method
-- 

--Hadamard
-- { P }   

-- If (x[i]) then {x[i+1,j) <- H  }

-- { P /\ …  } 
-- If x[i+1,j) is a Hadamard type, applying Hadamard type will convert it to Nor type. 
-- If x[i+1,j) is a Nor type, applying Hadamard type will convert it to Hadamard type. 
-- If x[i+1,j) is a EN type, it will remain in EN type after applying a Hadamard transformation. 
-- Method: if applying Hadamard method then [case match on type]

-- conditional
-- { P }   

-- If (x[i]) then {x[i+1,j) <- H  }
-- { P /\ …  } 
-- Assuming a control gate setup is used, if and only if x[i] is |0> or 
-- |1> is x[i] unchanged
-- If and only if x[i] is |1> then same effect to x[i,j] as Hadamard
-- assuming measurement is used for conditional, call measurement method
-- method: if contains conditional then call Hadamard method
-- do we have to account for two types of conditionals: a direct measurement or a control gate?

-- measurement
-- { P }    
-- p,v = measure(x[i,j))  ===> p is a probability, and v is the measured outcome
-- { P /\ V = (0 or 1)^+ (regular expression notation)  } 
-- The result is just v, v is the measurement result of x[i,j), the probability p is built on relating to x[i,j), v == mea(x[i,j)) /\ p ~ v
-- Remember that x[i,j) is of type Nor, End, Had
-- we get a bitstring upon measurement regardless of the type (Nor, EN, Had)

