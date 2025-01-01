{-# LANGUAGE GADTs #-}

module QSym.Logic.Builtins
  where

import QSym.Logic.IR

-- import Debug.Trace

hadamard :: Int -> Sum
hadamard whichQubit =
  let qubitsAppliedTo = 1
  in
  mkSum [2]          -- Upper bounds for additional indices for summation
    $ \oldVec [j] -> -- Additional indices for summation
        let bit = fromBitVec (getBit (getBitVec oldVec) whichQubit)
        in
        mkVec
          (ampFactor 1 * getAmp oldVec)
          (omega (bit * j) (2 ^ qubitsAppliedTo)) -- TODO: Do we use the phase of the old vector?
          (overwriteBits (getBitVec oldVec)
                         whichQubit
                         (toBitVec qubitsAppliedTo j))

notOp :: Int -> Sum
notOp whichQubit =
  unaryOp invertBitVec whichQubit whichQubit

controlledNot :: Int -> Int -> Sum
controlledNot controlPosition notPosition =
  withControlBit controlPosition (notOp notPosition)

unaryOp ::
  (Expr EBitVec -> Expr EBitVec) ->
  Int -> Int -> Sum
unaryOp op startQubit endQubit =
  mkSum []
    $ \oldVec [] ->
      let oldBits = getBitVec oldVec
          argBits = getBitRange oldBits startQubit (endQubit - 1)
          newBits = op argBits
      in
      mkVec
        (getAmp oldVec)
        (getPhase oldVec)
        (overwriteBits oldBits startQubit newBits)

unaryIntOp ::
  (Expr Int -> Expr Int) ->
  Int -> Int -> Sum
unaryIntOp op startQubit endQubit =
  let bitCount = endQubit - startQubit
  in
  unaryOp (toBitVec bitCount . op . fromBitVec) startQubit endQubit

withControlBit :: Int -> Sum -> Sum
withControlBit controlPosition = control predicate
  where
    predicate :: Expr EVec -> Expr Bool
    predicate oldVec =
      getBit (getBitVec oldVec) controlPosition .==. bvLit 1 0x1

-- import QSym.Logic.Memory
-- import QSym.Logic.Operation
--
-- hadamard :: Int -> Operation
-- hadamard gatePosition0 =
--   let gatePosition = bvPosition gatePosition0
--       bitsAppliedTo = 1
--   in
--   mkOperation [2] $
--     \accessor mem' oldIxs ixs ->
--       case ixs of
--         [k] ->
--           let fullIx = oldIxs ++ ixs
--           in
--           runAccessor accessor mem' oldIxs fullIx $ \oldEntry ->
--             let oldBvEntry = memEntryBitVec oldEntry
--                 bit = bv2nat (bvGetRange oldBvEntry gatePosition gatePosition)
--             in
--             setToMemEntry mem' fullIx $
--               MemEntry
--                 { memEntryAmp = memEntryAmp oldEntry -- TODO: Is this right?
--                 , memEntryPhase = omega (bit * k) (2 ^ bitsAppliedTo)
--                 , memEntryBitVec = overwriteBits oldBvEntry gatePosition (int2bv bitsAppliedTo k)
--                 }
--         _ -> error $ "ixs = " ++ show ixs
--
-- notOp :: Int -> Operation
-- notOp gatePosition0 =
--   let gatePosition = bvPosition gatePosition0
--   in
--   mkOperation [] $
--     \accessor mem' oldIxs ixs ->
--       let fullIxs = oldIxs ++ ixs
--       in
--         runAccessor accessor mem' oldIxs fullIxs $ \oldEntry ->
--           let oldBvEntry = memEntryBitVec oldEntry
--               bit = bv2nat (bvGetRange oldBvEntry gatePosition gatePosition)
--           in
--           setToMemEntry mem' fullIxs $
--           MemEntry
--             { memEntryAmp = memEntryAmp oldEntry
--             , memEntryPhase = memEntryPhase oldEntry
--             , memEntryBitVec = overwriteBits oldBvEntry gatePosition (invertBitVec (int2bv 1 bit))
--             }
--
-- addOp :: SMT Name Int -> Int -> Operation
-- addOp x = numericOp (add x)
--
-- mulOp :: SMT Name Int -> Int -> Operation
-- mulOp x = numericOp (mul x)
--
-- modOp2 :: SMT Name Int -> Int -> Operation
-- modOp2 x = numericOp (`mod'` x)
--
-- powOp2 :: SMT Name Int -> Int -> Operation
-- powOp2 x = numericOp (`pow` x)
--
-- controlledAccessor :: Int -> (MemEntry -> SMT Name Bool) -> Memory -> Accessor
-- controlledAccessor gatePosition p mem = Accessor $ \mem' ix newIx k ->
--   let entry = indexMemoryByList mem ix
--   in
--   ifThenElse (p entry)
--     (k entry)
--     (setToMemEntry mem' newIx entry)
--
-- controlled :: Int -> (MemEntry -> SMT Name Bool) -> Operation -> Operation
-- controlled gatePosition p op =
--   extendAccessor op $ controlledAccessor gatePosition p
--
-- controlled' :: Int -> (SMT Name Int -> SMT Name Bool) -> Operation -> Operation
-- controlled' gatePosition p = controlled gatePosition (p . bv2nat . memEntryBitVec)
--
-- controlledNot :: Int -> Int -> Operation
-- controlledNot controlPosition notPosition =
--   controlled controlPosition predicate (notOp notPosition)
--   where
--     predicate entry =
--       eq (bvSMT (getBit (memEntryBitVec entry) (bvPosition controlPosition)))
--          (bvSMT (bvLit 1 0x1))
--
