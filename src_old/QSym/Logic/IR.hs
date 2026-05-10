{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase #-}

module QSym.Logic.IR
  (Nat (..)
  -- ,IxBounds (..)
  -- ,Ixs (..)
  ,Sum
  ,pattern Sum
  ,mkSum

  ,realToSMT
  ,bitVecToSMT

  ,control
  ,Controlled
  ,pattern Controlled
  ,withPhaseFunction
  ,cCondition
  ,cBody

  ,Expr
  ,var
  ,mkSMT
  ,unMkVec

  ,EVec
  ,EBitVec
  ,EReal

  ,mul
  ,add
  ,sub
  ,modulo
  ,neg

  ,bvLit
  ,and'
  ,(.&&.)
  ,omega
  ,intLit
  ,overwriteBits
  ,getBitRange
  ,toBitVec
  ,fromBitVec
  ,fromInt
  ,(*.)
  ,(.==.)
  ,getBit
  ,invertBitVec
  ,getBitVec
  ,ampFactor
  ,getAmp
  ,getPhase
  ,mkVec
  )
  where

import Data.Ratio

import qualified QSym.Logic.SMT as SMT
import QSym.Logic.SMT (SMT, BitVector)

import QSym.Logic.Name

import Control.Monad.State

import Prettyprinter

data Nat = Z | S Nat

-- infixr :!
-- infixr :|

-- data IxBounds n where
--   IBZ :: IxBounds Z
--   (:!) :: Int -> IxBounds n -> IxBounds (S n)
--
-- data Ixs n where
--   IZ :: Ixs Z
--   (:|) :: Expr Int -> Ixs n -> Ixs (S n)

data Sum where
  MkSum ::
    [Int] ->
    (Expr EVec -> [Expr Int] -> Controlled EVec) ->
    Sum

-- | A unidirectional pattern. This allows us (outside this module)
-- to only match on Sum values, without being able to construct them using
-- the constructor.
-- To construct them outside the module, we must use the mkSum smart
-- constructor.
pattern Sum bounds f <- MkSum bounds f

instance Pretty Sum where
  pretty (Sum bounds f) =
    pretty "sum" <> parens (hsep $ punctuate (pretty ",") (pretty oldMemIx : zipWith (fmap pretty . showRange) indexVars bounds)) <> parens (pretty body)
    -- prettyCall "sum" (map pretty (zipWith showRange indexVars bounds) : pretty body)
    where
      oldMemIx = "j"
      indexVars = map (:[]) $ take (length bounds) "kabcd"
      vecName = "mem[" ++ oldMemIx ++ "]"
      body = f (Var vecName) (map Var indexVars)

      showRange var upperBound = var ++ "[1 to " ++ show upperBound ++ "]"

mkSum ::
  [Int] ->
  (Expr EVec -> [Expr Int] -> Expr EVec) ->
  Sum
mkSum bounds f =
  MkSum bounds $ \vec ixs ->
    MkControlled (BoolLit True) (f vec ixs)

withPhaseFunction :: (Expr Int -> Expr Int) -> Sum -> Sum
withPhaseFunction phaseF0 (MkSum bounds sumF) =
  let phaseF = FromInt . phaseF0 . ToInt
  in
  MkSum bounds $ \vec ixes ->
    let MkControlled pred body = sumF vec ixes
    in
    MkControlled pred $
    mkVec
      (getAmp body)
      (phaseF (getPhase body))
      (getBitVec body)

control :: (Expr EVec -> Expr Bool) -> Sum -> Sum
control predicate (MkSum bounds f) =
  MkSum bounds $ \vec ixs ->
    let Controlled fControlResult fBody = f vec ixs
    in
    MkControlled (predicate vec .&&. fControlResult) fBody

data Controlled a =
  MkControlled
    { cCondition :: Expr Bool
    , cBody :: Expr a
    }

pattern Controlled c b <- MkControlled c b

instance (Pretty (SmtTy a)) => Pretty (Controlled a) where
  pretty (Controlled (BoolLit True) body) = pretty body

  pretty (Controlled cond body) =
    prettyCall "controlled" [pretty cond, pretty body]


data EReal
data EBitVec
data EVec

unMkVec :: Expr b -> (Expr EReal, Expr EReal, Expr EBitVec)
unMkVec (MkVec x y z) = (x, y, z)

type family SmtTy a where
  SmtTy Bool = SMT Name Bool
  SmtTy Int = SMT Name Int
  SmtTy EReal = SMT Name Int
  SmtTy EBitVec = BitVector Name
  SmtTy EVec = ()

-- (Do not export the value constructors for Expr.)
data Expr b where
  Var :: String -> Expr a
  MkSMT :: SmtTy a -> Expr a

  BitVecVar :: Int -> String -> Expr EBitVec

  MkVec ::
    Expr EReal ->   -- | Amplitude
    Expr EReal ->   -- | Phase
    Expr EBitVec -> -- | Bit vector
    Expr EVec

  GetAmp :: Expr EVec -> Expr EReal
  GetPhase :: Expr EVec -> Expr EReal
  GetBitVec :: Expr EVec -> Expr EBitVec

    -- | (1/sqrt(2))^n
  AmpFactor :: Int -> Expr EReal

  -- Bit vectors --
  GetBit :: Expr EBitVec -> Int -> Expr EBitVec
  OverwriteBits :: Expr EBitVec -> Int -> Expr EBitVec -> Expr EBitVec
  GetBitRange :: Expr EBitVec -> Int -> Int -> Expr EBitVec
  InvertBitVec :: Expr EBitVec -> Expr EBitVec

  ToBitVec :: Int -> Expr Int -> Expr EBitVec
  FromBitVec :: Expr EBitVec -> Expr Int

  -- Integers --
  FromInt :: Expr Int -> Expr EReal
  ToInt :: Expr EReal -> Expr Int
  IntLit :: Int -> Expr Int
  Omega :: Expr Int -> Expr Int -> Expr EReal

  -- Scalars --
  ScalarMult :: Expr EReal -> Expr EVec -> Expr EVec

  -- Misc arithmetic --
  Add :: Expr b -> Expr b -> Expr b
  Sub :: Expr b -> Expr b -> Expr b
  Mul :: Expr b -> Expr b -> Expr b
  Div :: Expr b -> Expr b -> Expr b
  Mod :: Expr b -> Expr b -> Expr b

  -- Booleans --
  Equal :: (Pretty (SmtTy b), Show (SmtTy b)) => Expr b -> Expr b -> Expr Bool
  BoolLit :: Bool -> Expr Bool
  And :: [Expr Bool] -> Expr Bool
  Or :: [Expr Bool] -> Expr Bool
  Not :: Expr Bool -> Expr Bool
  -- deriving (Show)

deriving instance (Pretty (SmtTy a), Show (SmtTy a)) => Show (Expr a)

var :: String -> Expr a
var = Var

(.==.) :: (Pretty (SmtTy a), Show (SmtTy a)) => Expr a -> Expr a -> Expr Bool
(.==.) = Equal

instance Num (Expr EReal) where
  (+) = Add
  (-) = Sub
  (*) = mul
  abs = error "Expr Int: abs"
  signum = error "Expr Int: signum"

  fromInteger = FromInt . IntLit . fromInteger

instance Fractional (Expr EReal) where
  (/) = Div
  fromRational q = fromInteger (numerator q) / fromInteger (denominator q)

instance Num (Expr Int) where
  (+) = Add
  (-) = Sub
  (*) = Mul
  abs = error "Expr Int: abs"
  signum = error "Expr Int: signum"

  fromInteger = IntLit . fromInteger

bvLit :: Int -> Int -> Expr EBitVec
bvLit n = ToBitVec n . IntLit

mul :: Expr a -> Expr a -> Expr a
mul (AmpFactor a) (AmpFactor b) = AmpFactor (a + b)
mul a (AmpFactor b) = mul (AmpFactor b) a
mul a (Mul b c) = mul (mul a b) c
mul (Mul a b) c = mul (mul a b) c
mul a b = Mul a b

add = Add
sub = Sub
modulo = Mod

neg :: Expr Int -> Expr Int
neg = Sub (intLit 0)

and' :: [Expr Bool] -> Expr Bool
and' xs0 =
  case go xs0 of
    Left e -> e
    Right [] -> BoolLit True
    Right es -> And es
  where
    go :: [Expr Bool] -> Either (Expr Bool) [Expr Bool]
    go [] = Right []
    go (And xs : rest) = go (xs ++ rest)
    go (BoolLit False : _) = Left $ BoolLit False
    go (BoolLit True : rest) = go rest
    go (b : bs) = do
      rs <- go bs
      pure (b : rs)

(.&&.) :: Expr Bool -> Expr Bool -> Expr Bool
x .&&. y = and' [x, y]

omega :: Expr Int -> Expr Int -> Expr EReal
omega = Omega

intLit :: Int -> Expr Int
intLit = IntLit

overwriteBits :: Expr EBitVec -> Int -> Expr EBitVec -> Expr EBitVec
overwriteBits = OverwriteBits

getBitRange :: Expr EBitVec -> Int -> Int -> Expr EBitVec
getBitRange = GetBitRange

toBitVec :: Int -> Expr Int -> Expr EBitVec
toBitVec = ToBitVec

fromBitVec :: Expr EBitVec -> Expr Int
fromBitVec = FromBitVec

fromInt :: Expr Int -> Expr EReal
fromInt = FromInt

(*.) :: Expr EReal -> Expr EVec -> Expr EVec
(*.) = ScalarMult

getBit = GetBit
invertBitVec = InvertBitVec
ampFactor = AmpFactor

getAmp :: Expr EVec -> Expr EReal
getAmp (MkVec x _ _) = x
getAmp e = GetAmp e

getPhase :: Expr EVec -> Expr EReal
getPhase (MkVec _ x _) = x
getPhase e = GetPhase e

getBitVec :: Expr EVec -> Expr EBitVec
getBitVec (MkVec _ _ x) = x
getBitVec e = GetBitVec e

mkVec = MkVec
mkSMT = MkSMT

intToSMT :: Expr Int -> SMT Name Int
intToSMT (Var x) = SMT.var x
intToSMT (MkSMT x) = x
intToSMT (IntLit i) = SMT.int i
intToSMT (Add x y) = SMT.add (intToSMT x) (intToSMT y)
intToSMT (Sub x y) = SMT.sub (intToSMT x) (intToSMT y)
intToSMT (Mul x y) = SMT.mul (intToSMT x) (intToSMT y)
intToSMT (Div x y) = SMT.div (intToSMT x) (intToSMT y)
intToSMT (Mod x y) = SMT.mod' (intToSMT x) (intToSMT y)
intToSMT (FromBitVec x) = SMT.bv2nat $ bitVecToSMT x

realToSMT :: Expr EReal -> SMT Name Int
realToSMT (Var x) = SMT.var x
realToSMT (MkSMT x) = x
realToSMT (FromInt i) = intToSMT i
realToSMT (Add x y) = SMT.add (realToSMT x) (realToSMT y)
realToSMT (Sub x y) = SMT.sub (realToSMT x) (realToSMT y)
realToSMT (Mul x y) = SMT.mul (realToSMT x) (realToSMT y)
realToSMT (Div x y) = SMT.div (realToSMT x) (realToSMT y)
realToSMT (Omega x y) = SMT.omega (intToSMT x) (intToSMT y)
realToSMT (AmpFactor n) = SMT.ampFactor n
realToSMT (GetAmp x) =
  case x of
    MkVec amp _ _ -> realToSMT amp
realToSMT (GetPhase x) =
  case x of
    MkVec _ phase _ -> realToSMT phase

bitVecToSMT :: Expr EBitVec -> BitVector Name
bitVecToSMT (MkSMT x) = x
bitVecToSMT (BitVecVar size x) = SMT.int2bv size $ SMT.var x
bitVecToSMT (GetBitVec x) =
  case x of
    MkVec _ _ bitVec -> bitVecToSMT bitVec

bitVecToSMT (GetBit bv ix) =
  SMT.getBit (bitVecToSMT bv) (SMT.bvPosition ix)

bitVecToSMT (GetBitRange bv start end) =
  SMT.bvGetRange (bitVecToSMT bv) (SMT.bvPosition start) (SMT.bvPosition end)

bitVecToSMT (OverwriteBits bv pos newPart) =
  SMT.overwriteBits (bitVecToSMT bv) (SMT.bvPosition pos) (bitVecToSMT newPart)

bitVecToSMT (InvertBitVec bv) =
  SMT.invertBitVec $ bitVecToSMT bv

bitVecToSMT (Add x y) = SMT.bvAdd (bitVecToSMT x) (bitVecToSMT y)
bitVecToSMT (Sub x y) = SMT.bvSub (bitVecToSMT x) (bitVecToSMT y)
bitVecToSMT (Mul x y) = SMT.bvMul (bitVecToSMT x) (bitVecToSMT y)
bitVecToSMT (Mod x y) = SMT.bvMod (bitVecToSMT x) (bitVecToSMT y)
-- bitVecToSMT (Div x y) = SMT.div (bitVecToSMT x) (bitVecToSMT y)

bitVecToSMT (ToBitVec size e) =
  SMT.int2bv size $ intToSMT e

bitVecToSMT x = error $ "bitVecToSMT: " ++ show x

vecToSMT :: Expr EVec -> BitVector Name
vecToSMT (MkVec _ _ x) = bitVecToSMT x

instance Pretty (SmtTy a) => Pretty (Expr a) where
  pretty = \case
    Var x -> pretty x
    MkSMT x -> pretty x
    BitVecVar _size x -> pretty x
    MkVec amp phase bv ->
      parens (pretty amp <+> pretty "*" <+> pretty "exp" <> parens (pretty "i" <+> pretty "*" <+> pretty phase) <+> pretty bv)

    GetAmp x -> prettyCall "getAmp" [pretty x]
    GetPhase x -> prettyCall "getPhase" [pretty x]
    GetBitVec x -> prettyCall "getBitVec" [pretty x]

    AmpFactor i -> prettyCall "ampFactor" [pretty i]

    GetBit x y -> prettyCall "getBit" [pretty x, pretty y]
    OverwriteBits x y z -> prettyCall "overwriteBits" [pretty x, pretty y, pretty z]
    GetBitRange x y z -> prettyCall "getBitRange" [pretty x, pretty y, pretty z]
    InvertBitVec x -> prettyCall "invertBitVec" [pretty x]

    ToBitVec x y -> prettyCall "toBitVec" [pretty x, pretty y]
    FromBitVec x -> prettyCall "fromBitVec" [pretty x]

    FromInt x -> pretty x
    IntLit x -> pretty x
    Omega x y -> prettyCall "omega" [pretty x, pretty y]

    ScalarMult x y -> prettyCall "scalarMult" [pretty x, pretty y]
    Add x y -> prettyCall "add" [pretty x, pretty y]
    Sub x y -> prettyCall "sub" [pretty x, pretty y]
    Mul x y -> prettyCall "mul" [pretty x, pretty y]
    Div x y -> prettyCall "div" [pretty x, pretty y]
    Mod x y -> prettyCall "mod" [pretty x, pretty y]

    Equal x y -> prettyCall "equal" [pretty x, pretty y]
    BoolLit x -> pretty x
    And xs -> prettyCall "and" (map pretty xs)
    Or xs -> prettyCall "or" (map pretty xs)
    Not x -> prettyCall "not" [pretty x]

prettyLambda :: Pretty a => [String] -> a -> Doc ann
prettyLambda params body = pretty "\\" <> sep (map pretty params) <> pretty "." <+> pretty body

prettyCall :: Pretty a => a -> [Doc ann] -> Doc ann
prettyCall f args = pretty f <> parens (hsep (punctuate (pretty ",") args))

----

-- newtype Fresh a = Fresh (State Int a)
--   deriving (Functor, Applicative, Monad)
--
-- runFresh :: Fresh a -> a
-- runFresh (Fresh m) = evalState m 0
--
-- fresh :: Fresh Int
-- fresh = do
--   n <- Fresh get
--   Fresh $ modify (+1)
--   pure n

-- prettyPrint :: Expr a -> Fresh (Doc ann)
-- prettyPrint = \case
--   Var x -> pure $ pretty x

