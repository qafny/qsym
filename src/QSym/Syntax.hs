module QSym.Syntax
  where

import QSym.Utils
import Data.Bits hiding (xor, rotate, rotateR)
import qualified Data.Bits as Bits

import Numeric.Natural

import Prettyprinter

data Posi = -- posi is x[v] where x is a quantum variable and v is an aexp
  Posi
    { posiVar :: Var
    , posiInt :: Natural
    }
  deriving (Show, Eq)

getPosiVar :: Posi -> Var
getPosiVar (Posi x _) = x

nextPos :: Posi -> Posi
nextPos (Posi x i) = Posi x (i + 1)

-- returns a posi where posiInt has been decreased by one.
-- a natural complement to nextPos
prevPos :: Posi -> Posi
prevPos (Posi x i) = Posi x (i - 1)

data Expr
  = SKIP -- do nothing
  | X Posi  -- x[v] posi qubit |0> -> |1> and |1> -> |0>, x is Nor type
  | CU Posi Expr  -- CU on x[v] posi qubit to control if we apply expr, x is Nor type.
  | RZ Natural Posi -- RZ on x[v] posi qubit to rotate Natural degree, x is Nor type
  | RRZ Natural Posi -- RRZ on x[v] posi qubit to rotate -Natural degree, x is Nor type
  | SR Natural Var -- SR on x array qubit to rotate a series of Natural degree, x is Phi type
  | SRR Natural Var -- SRR on x array qubit to rotate a series of -Natural degree, x is Phi type
  | Lshift Var  -- left-shift on x array, x is Nor type
  | Rshift Var  -- right shift-on x array, x is Nor type
  | Rev Var     -- rev on x array, x is nor type
  | QFT Var Natural -- QFT x i means "for array named x, change its type from Nor to Phi i"
  | RQFT Var Natural -- RQFT x i means "for array named x, change its type from Phi i to Nor"
  | Seq Expr Expr
  deriving (Show)

block :: [Expr] -> Expr  
block = mconcat

-- pretty print expression
-- TODO: Implement this properly
instance Pretty Expr where
  pretty = pretty . pprExpr

pprExpr :: Expr -> String
pprExpr SKIP = "SKIP"
pprExpr (X p) = "X " ++ show p
pprExpr (CU p e) =
  unlines
    ["CU " ++ show p ++ " ["
    ,unlines $ map ("  "++) $ lines (pprExpr e)
    ,"]"
    ]
pprExpr (RZ i p) = "RZ " ++ show i ++ ", " ++ show p
pprExpr (RRZ i p) = "RRZ " ++ show i ++ ", " ++ show p
pprExpr (SR i p) = "SR " ++ show i ++ ", " ++ show p
pprExpr (SRR i p) = "SRR " ++ show i ++ ", " ++ show p
pprExpr (Lshift v) = "Lshift " ++ show v
pprExpr (Rshift v) = "Rshift " ++ show v
pprExpr (Rev v) = "Rev " ++ show v
pprExpr (QFT v i) = "QFT " ++ show v ++ ", " ++ show i
pprExpr (RQFT v i) = "RQFT " ++ show v ++ ", " ++ show i
pprExpr (Seq a b) =
  let seqs = getSeqs a <> getSeqs b
  in
  unlines $ map pprExpr seqs

getSeqs :: Expr -> [Expr]
getSeqs (Seq a b) = getSeqs a <> getSeqs b
getSeqs e = [e]

instance Semigroup Expr where
  (<>) = Seq

instance Monoid Expr where
  mempty = SKIP

