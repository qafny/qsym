{-# OPTIONS_GHC -Wno-incomplete-patterns #-}
{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Redundant bracket" #-}
module QSym.ASTLogic
    where

import Prelude hiding (lookup)
import Numeric.Natural
import Data.Maybe
import QSym.Monad
import QSym.Utils
import QSym.Logic.Syntax hiding (Add)

-- Map of loci and corresponding vars. When a new var is created, it gets added to the front of the corresponding locus's list
type LMap = [(Locus, [Var])]

data Complex = Complex Double Double
data Sum = Sum Natural Natural [Complex] [Natural]

-- Arithmetic Expression, Comes from page 10 figure 7 in https://arxiv.org/pdf/2211.06411
data ArithExpr =
    AddrVar Var |
    HeapVar Var |
    StateVal QState' |
    SumVal Sum |
    ArithRange Var Natural Natural |    -- Range of bits in a variable
    Scal Double |                         -- Scalar value
    Add ArithExpr ArithExpr |
    Sub ArithExpr ArithExpr |
    Mult ArithExpr ArithExpr |
    Div ArithExpr ArithExpr
    --deriving (Eq, Show, Ord)

-- Boolean Expression, Comes from page 10 figure 7 in https://arxiv.org/pdf/2211.06411
data BoolExpr =
    Bit Var ArithExpr |   -- Gets boolean value from a bit
    CEq ArithExpr ArithExpr Var ArithExpr | -- Checks for equality using a control bit
    CLess ArithExpr ArithExpr Var ArithExpr  -- Compares values using a control bit
    --deriving (Eq, Show, Ord)

-- This is the core type of the predicates respresenting the symbolic executor at each step
data Pred =
    Equal ArithExpr ArithExpr |
    Less ArithExpr ArithExpr |
    Not Pred |
    And Pred Pred |
    Or Pred Pred |
    Imply Pred Pred |
    BEBit BoolExpr
    --deriving (Eq, Show, Ord)

data QafnyExpr =
    Apply Locus ArithExpr |     -- Used to apply arithmetic operations on locus in the interperet function
    IfExp BoolExpr QafnyExpr |  -- If BoolExpr, then QanfyExpr. Used in interepret function
    Measure Locus               -- Placeholder for now

newVar :: LMap -> Locus -> Var -> (LMap, Var) -- Placeholder until monad solution is implemented
newVar lm _ x = (lm, x)

-- Finds the current (first index) variable for a given Locus
lookup :: LMap -> Locus -> Maybe Var
lookup [] _ = Nothing
lookup (x:xs) loc = if fst x == loc then Just (head (snd x)) else lookup xs loc

-- Inserts the new var at the front of the list in the target locus's tuple
-- If the target locus can't be found, creates a new entry tuple at the end of the LMap
addVar :: LMap -> Locus -> Var -> LMap
addVar [] loc v = [(loc, [v])]
addVar (x:xs) loc v = if fst x == loc then (loc, v:(snd x)):(addVar xs loc v) else x:(addVar xs loc v)

-- Returns the new predicate from applying the QafnyExpr to the old Pred
interpret :: LMap -> Pred -> QafnyExpr -> (Pred, LMap)
interpret lm p (IfExp be qe) = (Or (And (Not (BEBit be)) p) (And (BEBit be) (fst prevPred)), snd prevPred)
    where prevPred = interpret lm p qe
interpret lmap p (Apply loc expr) = (And p (And (Equal (AddrVar x) (AddrVar new)) (Equal (HeapVar new) (arithApply expr (HeapVar x)))), addVar lm loc new)
    where x = fromJust (lookup lmap loc)
          newTuple = newVar lmap loc x
          lm = fst newTuple
          new = snd newTuple

-- Takes an ArithExpr and applies it on another ArithExpr
-- Wherever a var appears in the first ArithExpr, the second ArithExpr is inserted
arithApply :: ArithExpr -> ArithExpr -> ArithExpr
arithApply (HeapVar _) x = x        -- Base case that replaces the placeholder var with the supplied expression
arithApply (AddrVar _) x = x        -- Base case that replaces the placeholder var with the supplied expression
arithApply (Scal n) _ = Scal n      -- Base case that just returns a scalar back to its parent expression
arithApply (Add expr1 expr2) x = Add (arithApply expr1 x) (arithApply expr2 x)
arithApply (Sub expr1 expr2) x = Sub (arithApply expr1 x) (arithApply expr2 x)
arithApply (Mult expr1 expr2) x = Mult (arithApply expr1 x) (arithApply expr2 x)
arithApply (Div expr1 expr2) x = Div (arithApply expr1 x) (arithApply expr2 x)
