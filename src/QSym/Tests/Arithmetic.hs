{-# LANGUAGE LambdaCase #-}

module QSym.Tests.Arithmetic
  where

import QSym.Syntax
import QSym.Monad
import QSym.Utils
import QSym.QState
import QSym.Interpret

import Test.QuickCheck

import qualified Data.Set as Set

import Data.Bits

import Debug.Trace

import Data.Word
-- import Data.Bits
import Numeric.Natural

-- needed for the checkInitV test to determine the bit size of the random number
-- note: since this import is used in both this file and Monad.hs in the exact 
--       same way, it might be a good idea to implement a helper function.
import Math.NumberTheory.Logarithms

maxVecSizeExponent :: Int
maxVecSizeExponent = 20


-- Get the variables in an expression ast
getVars :: Expr -> [Var]
getVars = Set.toList . go
  where
    go = \case
      SKIP -> mempty
      X p -> Set.singleton (getPosiVar p)
      CU p e -> Set.insert (getPosiVar p) (go e)
      RZ _ p -> Set.singleton (getPosiVar p)
      RRZ _ p -> Set.singleton (getPosiVar p)
      SR _ x -> Set.singleton x
      SRR _ x -> Set.singleton x
      Lshift x -> Set.singleton x
      Rshift x -> Set.singleton x
      Rev x -> Set.singleton x
      QFT x _ -> Set.singleton x
      RQFT x _ -> Set.singleton x
      Seq e1 e2 -> go e1 <> go e2

divModVars :: Natural -> [Var]
divModVars n = getVars (rzDivModOut n 1)

divModEnv :: Natural -> QEnv Natural
divModEnv n =
  mkQEnv $ take 3 (zip (map Var [0..]) (repeat (n + 1))) -- TODO: Is this okay?

interpretDivMod :: Natural -> Natural -> QState Value -> QState Value
interpretDivMod n m state =
  -- trace (pprExpr (rzDivModOut n m)) $
  let env = divModEnv n
  in
  execQSym env state
    (interpret
      (rzDivModOut n m))


rzDivModEnv :: Natural -> QEnv Natural
rzDivModEnv n = mkQEnv $ zip (map Var [0..2]) (repeat (n + 1))

checkrzDivMod :: Property
checkrzDivMod = 
  forAll (choose (1, 2 ^ maxVecSizeExponent)) $ \(ni :: Int) ->
  forAll (choose (1, 2 ^ maxVecSizeExponent)) $ \(mi :: Int) ->
    let
      n = intToNatural (maxVecSizeExponent)
      m = intToNatural mi
      x = intToNatural ni
      ex = intToNatural 0
      env = rzDivModEnv n
      toValue rz = NVal rz rz
      vars = getVars(rzDivMod n (Var x) (Var ex) m)
      initialState = mkState env [(xVar, toValue (fromIntegral x)), (yVar, toValue (fromIntegral ex))]
      expectedState = mkState env [(xVar, toValue (fromIntegral (x `div` m))),(yVar, toValue (fromIntegral (x `mod` m)))]
      expr = rzDivMod n (Var x) (Var ex) m
    in
    stEquiv vars env
      (execQSym env initialState (interpret expr))
      expectedState





-- checkDivMod :: Property
-- checkDivMod =
--   -- forAll (choose (0, 60)) $ \n ->
--   -- forAll (pure 10) $ \n ->
--   -- forAll (pure 60) $ \n ->
--   -- forAll (choose (1, 2^min n 30 - 1)) $ \m ->
--   -- forAll (genBvector n) $ \vx ->
--   forAll (pure 5) $ \(nw :: Word64) ->
--   forAll (pure 5) $ \(mw :: Word64) ->
--   let n, m :: Natural
--       n = fromNatural nw
--       m = fromNatural mw
--       mkRzValue = toRzValue n
--       toValue rz = NVal rz rz -- TODO: Does this make sense? 
--       env = divModEnv n
--   in
--   forAll (pure (mkRzValue (22 :: Word64))) $ \vx ->
--   stEquiv (divModVars n) env
--     (interpretDivMod n m
--       (mkState env [(xVar, toValue vx)]))
--     (mkState
--       env
--       [(xVar, toValue (vx `mod` mkRzValue mw))
--       ,(yVar, toValue (vx `div` mkRzValue mw))
--       ])

rzDivModOut :: Natural -> Natural -> Expr
rzDivModOut size = rzDivMod (size+1) xVar yVar

-- | x = (x % M, x / M) circuit.
rzDivMod :: Natural -> Var -> Var -> Natural -> Expr
rzDivMod 0 _ _ _ = error "divmod is 0"
rzDivMod n x ex m =
  let i = findNum m (n-1)
  in
  Rev x <>
  QFT x 0 <>
  rzModer' (i + 1) n x ex (mkRzValue' ((2^i) * m)) <>
  invExpr ( QFT x 0)

rzModer' :: Natural -> Natural -> Var -> Var -> RzValue -> Expr
rzModer' 0 _ x _ _ = SKIP
rzModer' i n x ex m =
  let j = i - 1
  in
  rzCompareHalf3 x n (Posi ex j) m <> QFT x 0 <>
  CU (Posi ex j) (rzAdder x n m) <>
  X (Posi ex j) <>
  rzModer' j n x ex ((divTwoSpec m))

divTwoSpec :: RzValue -> RzValue
divTwoSpec v = v `div` 2
  --RzValue $ \i -> f ! (i + 1)

-- compare x < m --> the value is stored in c : 1 or 0
rzCompareHalf3 :: Var -> Natural -> Posi -> RzValue -> Expr
rzCompareHalf3 x n c m =
  let p = Posi x (n-1)
  in
  rzSub x n m <>
  RQFT x 0 <>
  cnot p c
  -- let p = Posi x 0
  -- in
  -- rzSub x n m <>
  -- RQFT x n <>
  -- X p <>
  -- cnot p c <>
  -- X p

rzSub' :: Var -> Natural -> Natural -> RzValue -> Expr
rzSub' x 0 _size _fm = SKIP
rzSub' x n size fm =
  let m = n - 1
  in
  rzSub' x m size fm <> if fm ! m then SRR (size - n) x else SKIP

rzSub :: Var -> Natural -> RzValue -> Expr
rzSub x n = rzSub' x n n

modSub :: Natural -> Natural -> Natural -> Natural
modSub size a b = (a - b + 2^size) `mod` (2^size)

-- x stores 10 , m = 20 --> 5, 2^5, (x-m) ---> 2^5 + 10 - 20 = 22 

rzSub_test :: Var -> Natural -> RzValue -> Expr
rzSub_test x n v =
  block
    [ QFT x 0
    , rzSub' x n n v
    , RQFT x 0
    ]

rzSubEnv :: Natural -> QEnv Natural
rzSubEnv n = mkQEnv $ zip (map Var [0..2]) (repeat (n + 1))

checkrzSub :: Property
checkrzSub = 
  forAll (choose (2, 2 ^ 8)) $ \(xi :: Int) ->
  forAll (choose (2, 2 ^ 8)) $ \(ni :: Int) ->
    let
      x = intToNatural xi
      n = intToNatural ni
      toValue rz = NVal rz rz
      expectedSum = (modSub n n x)
      env = rzSubEnv n
      vars = getVars(rzSub (Var x) n (mkRzValue' n))
      initialState = mkState env [(xVar, toValue (fromIntegral x)), (yVar, toValue (fromIntegral n))]
      expectedState = mkState env [(xVar, toValue (fromIntegral expectedSum))]
      expr = rzSub xVar n (mkRzValue' n)
    in
    stEquiv vars env
      (execQSym env initialState (interpret expr))
      expectedState







rzAdder' :: Var -> Natural -> Natural -> RzValue -> Expr
rzAdder' _ n _ _ | n < 0 = error $ "rzAdder': negative n: " ++ show n
rzAdder' x 0 _size _fm = SKIP
rzAdder' x n size fm =
  let m = n - 1
  in
  rzAdder' x m size fm <> if fm ! m then SR (size - n) x else SKIP

rzAdder :: Var -> Natural -> RzValue -> Expr
rzAdder x n = rzAdder' x n n

rzAdder_test :: Var -> Natural -> RzValue -> Expr
rzAdder_test x n v =
  block
    [ QFT x 0
    , rzAdder' x n n v
    , RQFT x 0
    ]

rzadderEnv :: Natural -> QEnv Natural
rzadderEnv n = mkQEnv $ zip (map Var [0..2]) (repeat (n + 1))

checkrzAdder :: Property
checkrzAdder = 
  forAll (choose (0, 2 ^ maxVecSizeExponent)) $ \(xi :: Int) ->
  forAll (choose (0, 2 ^ maxVecSizeExponent)) $ \(ni :: Int) ->
    let
      x = intToNatural xi
      n = intToNatural ni
      toValue rz = NVal rz rz
      expectedSum = x + n
      env = rzadderEnv n
      vars = getVars(rzAdder (Var x) n (mkRzValue' n))
      initialState = mkState env [(xVar, toValue (fromIntegral x)), (yVar, toValue (fromIntegral n))]
      expectedState = mkState env [(xVar, toValue (fromIntegral expectedSum))]
      expr = rzAdder xVar n (mkRzValue' n)
    in
    stEquiv vars env
      (execQSym env initialState (interpret expr))
      expectedState



--Fixpoint rz_full_adder' (x:var) (n:nat) (size:nat) (y:var) :=
---  match n with
--  | 0 => (SKIP (x,0))
--  | S m => ((CU (y,m) (SR (size - n) x)); rz_full_adder' x m size y)
--  end.
-- Definition rz_full_adder (x:var) (n:nat) (y:var) := rz_full_adder' x n n y.

-- we have two arrays, x and y, and they have the same size (size), x,y ---> x,(x+y)%2^size



---multiplication given array x, and a number M, and an extra qubit array ex (ex starts with 0),
---- result is x,ex ---> x, (x*M) % 2^size

---Fixpoint nat_mult' (n:nat) (size:nat) (x:var) (ex:var) (M:nat->bool) :=
--  match n with 
--  | 0 => SKIP (x,0)
--  | S m => one_cu_adder ex size (x,m) M; 
--          nat_mult' m size x ex (cut_n (times_two_spec M) size)
--  end.
--Definition nat_mult (size:nat) (x:var) (re:var) (M:nat -> bool) := 
--   (Rev x; Rev re) ; QFT re size; nat_mult' size size x re M;
--  RQFT re size; inv_exp ( (Rev x; Rev re)).


findNum :: Natural -> Natural -> Natural
findNum x n = findNum' n x (2 ^ (n-1)) 0

-- Example Circuits that are definable by OQASM.
-- find a number that is great-equal than 2^(n-1), assume that the number is less than 2^n
findNum' :: Natural -> Natural -> Natural -> Natural -> Natural
findNum' 0 _x _y i = i
findNum' size x y i =
  let n = size-1
  in
  if y <= x
  then i
  else findNum' n (2 * x) y (i+1)

fromNatural :: (Integral a, Num b) => a -> b
fromNatural x
  | x >= 0    = fromIntegral x
  | otherwise = error "fromIntegral: negative number"

-- |maj (see: https://github.com/inQWIRE/VQO/blob/main/CLArith.v#L27)
-- an implementation of a modmult adder based on classical circuits
maj :: Posi -> Posi -> Posi -> Expr
maj a b c = cnot c b <> cnot c a <> ccx a b c

-- |uma (see: https://github.com/inQWIRE/VQO/blob/main/CLArith.v#L28)
-- an implementation of a modmult adder based on classical circuits
uma :: Posi -> Posi -> Posi -> Expr
uma a b c = ccx a b c <> cnot c a <> cnot a b

majSeq' :: Natural -> Var -> Var -> Posi -> Expr
majSeq' 0 x y c = maj c (Posi y 0) (Posi x 0)
majSeq' n x y c = majSeq' (n - 1) x y c <> maj (Posi x (n - 1)) (Posi y n) (Posi x n)

-- |majSeq (see: https://github.com/inQWIRE/VQO/blob/main/CLArith.v#L37)
-- The following defines n-bits MAJ and UMA circuit. 
-- Eventually, MAJ circuit takes [x][y] and produce [x][(x+y) % 2 ^ n]
majSeq :: Natural -> Var -> Var -> Posi -> Expr
majSeq n x y c = majSeq' (n - 1) x y c

umaSeq' :: Natural -> Var -> Var -> Posi -> Expr
umaSeq' 0 x y c = uma c (Posi y 0) (Posi x 0)
umaSeq' n x y c = uma (Posi x (n - 1)) (Posi y n) (Posi x n) <> umaSeq' (n - 1) x y c

-- |umaSeq (see: https://github.com/inQWIRE/VQO/blob/main/CLArith.v#L37)
-- The following defines n-bits MAJ and UMA circuit. 
-- Eventually, UMA circuit takes [x][(x+y) % 2 ^ n] and produce [x][y]
umaSeq :: Natural -> Var -> Var -> Posi -> Expr
umaSeq n x y c = umaSeq' (n - 1) x y c


-- Define adder 
adder :: Natural -> Var -> Var -> Posi -> Expr
adder n x y c = trace (show y) $  majSeq n x y c <> umaSeq n x y c



adderEnv :: Natural -> QEnv Natural
adderEnv n = mkQEnv $ zip (map Var [0..2]) (repeat (n + 1))

checkAdder :: Property
checkAdder =
  forAll (choose (2,maxVecSizeExponent)) $ \(vci :: Int) ->
  forAll (choose (2, 2^(vci - 1))) $ \(vxi :: Int) ->
  forAll (choose (2, 2^(vci - 1))) $ \(vyi :: Int) ->
  let 
      n = intToNatural vci
      vx = intToNatural vxi
      vy = intToNatural vyi
      toValue rz = NVal rz rz
      env = adderEnv n
      expectedSum = (vx + vy) `mod` 2^n
      vars = getVars (adder n (Var vx) (Var vy) (Posi zVar 0))
      initialState = mkState env [(xVar, toValue (fromIntegral vx)), (yVar, toValue (fromIntegral vy))]
      expectedState = mkState env [(xVar, toValue (fromIntegral expectedSum))]
  in
  stEquiv vars env
    (execQSym env initialState (interpret (adder n xVar yVar (Posi zVar 0))))
    expectedState

-- |initV (see: https://github.com/inQWIRE/VQO/blob/main/OQASM.v#L431C10-L431C17)
-- Initialize qubits given a bitstring b and empty qubits |0>
--  where:
--    var of type `Posi` is the empty qubit array
--    bits of type `(Natural -> Bool)` is a function that returns a boolean for a natural number index into a bitstring
-- 
-- return of type `Expr`: an AST of expressions that produce |b>
initV :: Posi -> (Natural -> Bool) -> Expr
initV var bits -- should bits instead be a byte string?
  | (posiInt var) == 0 = SKIP
  | otherwise = 
    let next = prevPos(var) in
      if bits(posiInt next) then
        Seq (initV next bits) (X next)
      else
        initV next bits

-- |acceptNaturalInstead converts a function that takes an integer and converts
-- it to a function that takes a natural. This is used by the checkInitV test case.
acceptNaturalInstead :: (Integral a, Num t1) => (t1 -> t2) -> a -> t2
acceptNaturalInstead f = (\nat -> (f (fromInteger (toInteger nat))))

-- [test case]: initV
checkInitV :: Property
checkInitV = 
  forAll (choose (0, 2^maxVecSizeExponent)) $ \(randomNumI :: Int) ->
  let
    -- set up a simple test case for now.
    randomNum = intToNatural randomNumI
    -- we need to know how large randomNum is in bits so that we can
    -- initialize the qubit properly
    numSizeInBits = getSizeInBits randomNum
    -- helper function to convert a number into an NVal
    toValue rz = NVal rz rz
    -- bits
    -- testBit is a builtin Data.Bits function (https://hackage.haskell.org/package/base-4.14.1.0/docs/Data-Bits.html#v:testBit)
    -- acceptNaturalInstead works around the fact that testBit takes an Int as it's "indexing" argument
    bits = acceptNaturalInstead $ testBit randomNum
    -- empty qubits of the required size
    var = Posi xVar (numSizeInBits + 1)
    vars = getVars (initV var bits)
    -- initialize the environment
    -- only one variable (our 0 initialized qubit array), with a size equal to the number of bytes
    -- needed to store our bitstring
    env = mkQEnv [(xVar, numSizeInBits)]
    -- initial state should be a qubit initialized to 0
    initialState = mkState env [(xVar, toValue (RzValue numSizeInBits 0))]
    -- expected state is our qubit now set to the test int
    -- this will only change the first RzValue, not the second
    expectedState = mkState env [(xVar, NVal (fromIntegral randomNum) (RzValue numSizeInBits 0))]
  in
    stEquiv 
      vars 
      env 
      (execQSym env initialState (interpret (initV var bits))) 
      expectedState

-- |notIsHighBitSet (see: https://github.com/inQWIRE/VQO/blob/main/CLArith.v#L55)
-- part of the comparator circuit, highbit n x c2
--  where:
--    n of type `Natural` is the size of the qubit array stored in x.
--    x of type `Var` is the variable that stores the bitstring.
--    c2 of type `Posi` is the qubit array that we should flip if the first bit of x is 0.
-- return of type `Expr`: an AST of expressions that flips c2 if the first bit of x is 0.
--
-- a.k.a: Called highbit in VQO.
-- [VQO Note]: The following implements an comparator. 
--             The first step is to adjust the adder circuit above to be
--             MAJ;high_bit_manipulate;UMA.
--             This is based on a binary number circuit observation that:
--             To compare if x < y, we just need to do x - y, and see the high bit of the binary
--             format of x - y. If the high_bit is zero, that means that x >= y;
--             otherwise x < y.
notIsHighBitSet :: Natural -> Var -> Posi -> Expr
notIsHighBitSet n x c2 = X (Posi x (n - 1)) <> X c2 <> cnot (Posi x (n - 1)) c2 <> X c2 <> X (Posi x (n - 1))

-- [test case]: notIsHighBitSet
checkNotIsHighBitSet :: Property
-- there are two things that we can randomize here:
--  (1) the number of bits in the qubit string
--  (2) whether or not the highest bit is set
checkNotIsHighBitSet =
  forAll (choose (2, maxVecSizeExponent)) $ \(qubitStrSizeI :: Int) ->
  forAll (choose (False, True)) $ \(isBitSet :: Bool) -> -- represents whether the highest bit should be a one or a zero for this test.
  let
    qubitStrSize = intToNatural qubitStrSizeI
    -- We use xVar for the qubit string to test and yVar for the result.
    -- the posi that the result is stored in
    result = Posi yVar 0
    -- grab the vars that are used.
    vars = getVars (notIsHighBitSet qubitStrSize xVar result)
    -- helper function for making NVal
    toValue rz = NVal rz rz
    -- helper function for making NVal that sets the amplitude to 0.
    toValueZeroAmp rz = NVal rz (RzValue (rzBitCount rz) 0) 
    -- initialize the environment.
    -- xVar should have the random number of bits, whilst yVar should only have one
    env = mkQEnv [(xVar, qubitStrSize), (yVar, 1)]
    -- this is the qubit value that the function will test
    qubitValue = if isBitSet then 2^(qubitStrSize - 1) else 0
    -- create the initial state. The highest bit in xVar should be set to 1 or 0
    -- yVar should be blank
    initialState = mkState env [(xVar, toValue (RzValue qubitStrSize qubitValue)), (yVar, toValue (fromIntegral 0))]
    -- create the expected state. xVar shouldn't change.
    -- yVar should be a 1 or a 0 depending on isBitNotSet
    -- we can use fromEnum to get the correct value for yVar because Haskell's Bool implments the Enum trait
    expectedState = mkState env [(xVar, toValue (RzValue qubitStrSize qubitValue)), (yVar, toValueZeroAmp (fromIntegral (fromEnum (not isBitSet))))]
  in
    stEquiv
      vars
      env
      (execQSym env initialState (interpret (notIsHighBitSet qubitStrSize xVar result)))
      expectedState

-- |addAndCompare (see: https://github.com/inQWIRE/VQO/blob/main/CLArith.v#L57C1-L58C1)
-- part of the comparator circuit in VQO, this function sums two numbers and 
-- then checks if the highest bit of x is NOT set.
--  where:
--    n of type `Natural` is the length of the two Vars (x and y) to sum
--    x of type `Var` is the first term
--    y of type `Var` is the second term
--    c1 of type `Posi` is storage for the carry bit and should be set to 0 (and will stay at 0)
--    c2 of type `Posi` is the location that we should store the result of the comparison
--  return of type `Expr`: an AST of expressions that 
--
-- a.k.a: Called highb01 in VQO.
addAndCompare :: Natural -> Var -> Var -> Posi -> Posi -> Expr
addAndCompare n x y c1 c2 = majSeq n x y c1 <> notIsHighBitSet n x c2 <> invExpr (majSeq n x y c1)

-- |flipBits (see: https://github.com/inQWIRE/VQO/blob/main/CLArith.v#L59-L65)
-- For a qubit string variable x of arbitrary size n, it produces an Expression AST that flips every single bit in the string.
-- where:
--  n of type `Natural` is the length of the qubit string.
--  x of type `Var` is the variable identifier.
-- return of type `Expr` is the AST that will flip every bit in the qubit string when interpreted.
-- 
-- a.k.a: Called negator0 in VQO.
-- [VQO Note]: The following will do the negation of the first input value in the qubit sequence 00[x][y][z].
--             The actual effect is to make the sequence to be 00[-x][y][z].
flipBits :: Natural -> Var -> Expr
flipBits n x
  | n == 0 = SKIP
  | otherwise = Seq (flipBits (n - 1) x) (X (Posi x (n - 1)))

-- [test case]: flipBits
checkFlipBits :: Property
checkFlipBits =
  forAll (choose (0, 2^maxVecSizeExponent)) $ \(randomNumI :: Int) ->
  let
    -- convert random num to a natural number to be used by var
    randomNum = intToNatural randomNumI
    -- get the size of random num in bits
    numSizeInBits = getSizeInBits randomNum
    -- we only need one var for this test, so we use the xVar definition found
    -- in Utils.hs
    -- retrieve a list of all the vars used in the function
    vars = getVars (flipBits numSizeInBits xVar)
    -- intialize the environment
    env = mkQEnv [(xVar, numSizeInBits)]
    -- initial state should be our qubit set to the random number
    initialState = mkState env [(xVar, (NVal (RzValue numSizeInBits randomNum) (RzValue numSizeInBits 0)))]
    -- expected state is the inverse of the initial state. (i.e. all bits flipped)
    flipped = xor randomNum (2^numSizeInBits - 1)
    expectedState = mkState env [(xVar, (NVal (RzValue numSizeInBits flipped) (RzValue numSizeInBits 0)))]
  in
    stEquiv
      vars
      env
      (execQSym env initialState (interpret (flipBits numSizeInBits xVar)))
      expectedState

-- |comparator (see: https://github.com/inQWIRE/VQO/blob/main/CLArith.v#L73)
-- checks if one value is greater than the other
-- where:
--  n of type `Natural` is the maximum length (in bits) of the two numbers to compare
--  x of type `Var` is the variable on the left hand side of the greater than comparison
--  y of type `Var` is the variable on the right hand side of the greater than comparison
--  c1 of type `Posi` is a carry bit (used for the underlying implementation) and should be initialized to 0
--  c2 of type `Posi` is the bit to store the result in. It will be flipped if x > y and left unchanged otherwise.
--  return of type `Expr`: the AST that, when executed, performs the comparison and potentially flips c2
--
-- a.k.a. called comparator01 in VQO
-- [VQO Note]: The actual comparator implementation. 
--             We first flip the x positions, then use the high-bit comparator above. 
--             Then, we use an inverse circuit of flipping x positions to turn the
--             low bits back to store the value x.
--             The actual implementation in the comparator is to do (x' + y)' as x - y,
--             and then, the high-bit actually stores the boolean result of x - y < 0.
comparator :: Natural -> Var -> Var -> Posi -> Posi -> Expr
comparator n x y c1 c2 = X c1 <> flipBits n x <> addAndCompare n x y c1 c2 <> invExpr (X c1 <> flipBits n x)

-- [test case]: comparator
checkComparator :: Property
checkComparator = 
  forAll (choose (0, 2^maxVecSizeExponent)) $ \(xInt :: Int) ->
  forAll (choose (0, 2^maxVecSizeExponent)) $ \(yInt :: Int) -> 
  let
    xValue = intToNatural xInt -- convert the random test variable to a natural
    yValue = intToNatural yInt -- convert the random test variable to a natural
    bitCount = maximum [(getSizeInBits xValue), (getSizeInBits yValue)] -- find n for the comparator
    -- this is the condition that the comparator actually checks
    cond = xValue > yValue

    carryVar = zVar -- alias for a better understanding
    carryBit = Posi carryVar 0 -- needed for comparator

    resultVar = Var 3 -- a place for the result
    resultBit = Posi resultVar 0 -- needed for comparator

    expr = comparator bitCount xVar yVar carryBit resultBit
    vars = getVars expr
    -- the environment basically stores the bit count of the variables
    -- x and y var need an extra bit to store the sign
    env = mkQEnv [(xVar, bitCount + 1), (yVar, bitCount + 1), (carryVar, 1), (resultVar, 1)]
    -- helper value to convert an rz value into an NVal with no amplitude
    toValueZeroAmp rz = NVal rz (RzValue (rzBitCount rz) 0) 
    -- helper function to convert a natural number into an NVal
    natToNVal nat = toValueZeroAmp (fromIntegral nat)

    -- nothing changes between the initial state and the final state, except the result has been flipped if x is less than y
    initialState = mkState env [(xVar, natToNVal xValue), (yVar, natToNVal yValue), (carryVar, natToNVal 0), (resultVar, natToNVal 0)]
    expectedState = mkState env [(xVar, natToNVal xValue), (yVar, natToNVal yValue), (carryVar, natToNVal 0), (resultVar, natToNVal (fromEnum cond))]
  in
    stEquiv vars env (execQSym env initialState (interpret expr)) expectedState