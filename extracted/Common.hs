{-# LANGUAGE NPlusKPatterns #-}
{-# LANGUAGE PatternSynonyms #-}

import Numeric.Natural


module Common
  where

type Var = Nat
type Posi = Prod Var Nat

type Prod = (,)

-- data Prod a b =
--    Pair a b
--   deriving (Eq, Show)

type Nat = Natural
-- data Nat =
--    O
--  | S Nat

pattern O :: Nat
pattern O = 0

pattern S :: Nat -> Nat
pattern S x <- x + 1
  where
    S x = x + 1

data Exp =
   SKIP Posi
 | X Posi
 | CU Posi Exp
 | RZ Nat Posi
 | RRZ Nat Posi
 | SR Nat Var
 | SRR Nat Var
 | Lshift Var
 | Rshift Var
 | Rev Var
 | QFT Var Nat
 | RQFT Var Nat
 | Seq Exp Exp
 deriving (Show)

type Rz_val = Natural

data Val =
   Nval Bool Rz_val
 | Qval Rz_val Rz_val
 deriving (Show)

