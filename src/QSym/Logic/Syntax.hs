module QSym.Logic.Syntax
  where

import Prettyprinter

import Data.Coerce
import Data.Ord
import Data.List

data Range =
  Range
  { rangeName :: String
  , rangeStart :: SimpleExpr -- inclusive
  , rangeEnd :: SimpleExpr -- exclusive
  }
  deriving (Show, Eq)

data SimpleExpr
  = LocusVar SteppedLocus
  | Var String -- | "Logical" variable
  | Xor SimpleExpr SimpleExpr
  | Add SimpleExpr SimpleExpr
  | Lit Int
  | Hadamard String
  deriving (Show, Eq)

-- | Invariant: Ranges in list should be disjoint
newtype Locus = Locus { unLocus :: [Range] }
  deriving (Show, Eq)

invLocus :: Locus -> Locus
invLocus = coerce rev
  where
    rev :: [Range] -> [Range]
    rev = reverse
    {-# INLINE rev #-}

-- | Keeps track of the time step
data Stepped a = Current a | Step (Stepped a)
  deriving (Show, Eq)

type SteppedLocus = Stepped Locus

-- Proposition
newtype Prop a = Prop [Conjunct a]
  deriving (Show, Semigroup, Monoid)

data Conjunct a
  = PointsTo SteppedLocus a
  | Unchanged SteppedLocus -- | x[i,j)' = x[i,j)
  | If a a
  deriving (Show)

data LExpr
  = LApply SteppedLocus (Lambda SimpleExpr) 
  | LIfThenElse SimpleExpr LExpr SimpleExpr
  | LSimpleExpr SimpleExpr
  deriving (Show)

data Lambda a = String :=> a
  deriving (Show)

getMaxStepped :: Eq a => [Stepped a] -> a -> Maybe (Stepped a)
getMaxStepped [] _ = Nothing
getMaxStepped (x:xs) y
  | getSteppedName x == y =
      case  (getMaxStepped xs y) of
        Nothing -> Just x
        Just r -> Just $ maxBy (comparing steppedToInt) x r
  | otherwise = getMaxStepped xs y
  where
    maxBy :: (a -> a -> Ordering) -> a -> a -> a
    maxBy f x y = maximumBy f [x, y]

getSteppedName :: Stepped a -> a
getSteppedName (Current n) = n
getSteppedName (Step x) = getSteppedName x

steppedToInt :: Stepped a -> Int
steppedToInt (Current {}) = 0
steppedToInt (Step x) = 1 + steppedToInt x

toStepped :: Int -> a -> Stepped a
toStepped 0 x = Current x
toStepped n x = Step (toStepped (n-1) x)

lambdaApply :: Lambda SimpleExpr -> SimpleExpr -> SimpleExpr
lambdaApply (x :=> body) e = go body
  where
    go (Var v)
      | v == x = e
      | otherwise = Var v
    go (Add a b) = Add (go a) (go b)
    go (Xor a b) = Xor (go a) (go b)
    go (Lit i) = Lit i
    go (LocusVar locus) = LocusVar locus
    go (Hadamard h) = Hadamard h


type LExprProp = Prop LExpr
type LExprConjunct = Conjunct LExpr

instance Pretty Range where
  pretty r
    | rangeEnd r == (rangeStart r `Add` Lit 1) = pretty (rangeName r) <> pretty "[" <> pretty (rangeStart r) <> pretty "]"
    | otherwise =
        pretty (rangeName r) <> pretty "[" <> pretty (rangeStart r) <> pretty "," <+> pretty (rangeEnd r) <> pretty ")"

instance Pretty Locus where
  pretty (Locus xs) =
    separatedBy (pretty "++") $ map pretty xs

instance Pretty a => Pretty (Prop a) where
  pretty (Prop xs) =
    separatedBy (pretty "/\\") $ map pretty xs

instance Pretty a => Pretty (Conjunct a) where
  pretty (PointsTo lhs rhs) =
    pretty lhs <+> pretty "|->" <+> pretty rhs

  pretty (Unchanged (Step l)) =
    pretty (Step l) <+> pretty "=" <+> pretty l

instance Pretty LExpr where
  pretty (LApply lhs e) =
    pretty "apply(" <> pretty e <> pretty "," <+> pretty lhs <> pretty ")"

  pretty (LIfThenElse c t f) =
    pretty "ifThenElse(" <> pretty c <> pretty "," <+> pretty t <> pretty "," <+> pretty f <> pretty ")"

  pretty (LSimpleExpr e) = pretty e

instance Pretty a => Pretty (Stepped a) where
  pretty = go 0
    where
      go (i :: Int) (Current x) = pretty x <> pretty i
      go i (Step x) = go (i + 1) x
  -- pretty (Current x) = pretty x
  -- pretty (Step x) = pretty x <> pretty "'"

instance Pretty SimpleExpr where
  pretty (LocusVar x) = pretty x
  pretty (Var x) = pretty x
  pretty (Lit i) = pretty i
  pretty (Xor a b) = pretty a <+> pretty "+" <+> pretty b
  pretty (Hadamard x) = pretty "H" <> parens (pretty x)

instance Pretty a => Pretty (Lambda a) where
  pretty (x :=> body) = parens $ pretty x <+> pretty "=>" <+> pretty body

unitRange :: String -> SimpleExpr -> Range
unitRange x i = Range x i (Add i (Lit 1))

unitLocus :: String -> SimpleExpr -> Locus
unitLocus x i = Locus [unitRange x i]

separatedBy :: Doc a -> [Doc a] -> Doc a
separatedBy separator xs = concatWith go xs
  where
    go a b = a <+> separator <+> b

class Steppable a where
  step :: a -> a

instance Steppable (Stepped a) where
  step = Step

instance Steppable a => Steppable (Prop a) where
  step (Prop xs) = Prop $ map step xs

instance Steppable a => Steppable (Conjunct a) where
  step (PointsTo lhs rhs) = PointsTo (step lhs) (step rhs)
  step (Unchanged x) = Unchanged (step x)
  step (If x y) = If (step x) (step y)

instance Steppable SimpleExpr where
  step (Xor x y) = Xor (step x) (step y)
  step (Add x y) = Add (step x) (step y)
  step (LocusVar x) = LocusVar $ step x
  step x = x -- NOTE: This might need to be extended if we add more constructors to SimpleExpr

instance Steppable a => Steppable (Lambda a) where
  step (x :=> body) = x :=> step body

instance Steppable LExpr where
  step (LApply x rhs) =
    LApply (step x) (step rhs)

  step (LIfThenElse c t f) =
    LIfThenElse (step c) (step t) (step f)

  step (LSimpleExpr e) = LSimpleExpr $ step e

testProp :: LExprProp
testProp =
  Prop
    [ -- Step 0
      PointsTo (Current (unitLocus "q" (Lit 0))) (LSimpleExpr (Var "a"))
    , PointsTo (Current (unitLocus "q" (Lit 1))) (LSimpleExpr (Var "b"))

      -- Step 1
    , PointsTo (Step (Current (unitLocus "q" (Lit 0)))) (LApply (Current (unitLocus "q" (Lit 0))) ("x" :=> Hadamard "x"))
    , Unchanged (Step (Current (unitLocus "q" (Lit 1))))

      -- Step 2
    , Unchanged (Step (Step (Current (unitLocus "q" (Lit 0)))))
    , PointsTo (Step (Step (Current (unitLocus "q" (Lit 1)))))
        $ LIfThenElse (LocusVar (Step (Current (unitLocus "q" (Lit 0)))))
            (LApply (Step (Current (unitLocus "q" (Lit 1)))) ("x" :=> Xor (Var "x") (Lit 1)))
            (LocusVar (Step (Current (unitLocus "q" (Lit 1)))))
    ]

