{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-} -- needs to be set in any files that use this module for prettyprinting to work
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

module QSym.Logic.SMT
  (SMT
  ,Symbol
  ,symbol
  ,int
  ,bool
  ,getNames
  ,getBlockNames
  ,assert
  ,setOption

  ,Array

  ,unvar

  ,varMap
  ,varMapBlock
  ,Decl

  ,Block
  -- block constructors
  ,one
  ,smtBlock

  -- boolean operations
  ,and'
  ,or'
  ,(^&&^)
  ,(^||^)

  ,var
  ,forAll
  ,exists

  ,pointsTo
  ,emp
  ,sep
  ,wand

  ,true
  ,false

  -- conditionals
  ,not'
  ,implies
  ,eq
  ,lt
  ,lte
  ,gt
  ,gte
  ,ifThenElse
  
  -- arithmetic operations
  ,add
  ,sub
  ,mul
  ,div
  ,mod'
  ,pow
  ,store
  ,Ixs (..)
  ,SomeIxs (..)
  ,ixsToList
  ,someIxsToList
  ,ixsToNames_unsafe
  ,someIxsToNames_unsafe
  ,retagIxs_unsafe
  ,select
  ,selects
  ,selectWithList
  ,double
  ,invSqrt2
  ,sqrt2

  ,sin'
  ,pi'
  ,omega
  ,ampFactor

  ,BitVector
  ,BitVecPosition
  ,bitVectorSize
  ,bvSMT
  ,bvPosition
  ,mkBitVectorOfSize
  ,bvLit
  ,bvConcat
  ,int2bv
  ,bv2nat
  ,bvOr
  ,bvXor
  ,bvAnd
  ,bvShiftL
  ,bvGetRange
  ,bvAdd
  ,bvSub
  ,bvMul
  ,bvMod
  ,invertBitVec
  ,ones
  ,getBit
  ,toBitVecFn
  -- ,overwriteIndexBits
  ,overwriteBits
  ,selectWithBitVector

  ,smtMap
  ,smtMapList

  ,setLogic

  ,declareHeap
  ,declareConst
  ,declareConstList
  ,setInfo

  ,smtPreamble

  ,checkSAT
  ,getModel
  )
  where

import Prelude hiding (div)

import QSym.Logic.Syntax hiding (Var)

import QSym.Utils (toLowerString)

import Prettyprinter hiding (sep)

import Data.Bits

import Numeric (showBin)

import Data.Foldable
import Data.Coerce
import Data.String

import GHC.Stack

data SExpr a
  = Atom a
  | Var String
  | ForAll [(String, String)] (SExpr a) -- TODO: Use a better approach for names
  | Exists [(String, String)] (SExpr a)
  | List [SExpr a]
  -- | StringLit String
  | BoolLit Bool
  | IntLit Int
  | BvLit Int -- | Bit length
          Int -- | Value
  | DoubleLit Double
  deriving (Show, Functor, Foldable)

unvar :: (Show a, HasCallStack) => SMT a b -> String
unvar (SExpr (Var v)) = v
unvar x = error $ "unvar " ++ show x

-- |SMT
data SMT a b
  = Decl (SExpr a)
  | Assert (SExpr a)
  | SExpr (SExpr a)
  deriving (Show)

-- -- NOTE: Only for internal use
-- shiftSExpr :: SExpr a -> SExpr a
-- shiftSExpr (Ix i) = Ix (i + 1)
-- shiftSExpr (Atom x) = Atom x
-- shiftSExpr (ForAll e) = ForAll e
-- shiftSExpr (List xs) = List $ map shiftSExpr xs
-- shiftSExpr (BoolLit b) = BoolLit b
-- shiftSExpr (IntLit i) = IntLit i
-- shiftSExpr (DoubleLit d) = DoubleLit d

-- -- NOTE: Only for internal use
-- shiftSMT :: SMT a b -> SMT a b
-- shiftSMT (Decl e) = Decl $ shiftSExpr e
-- shiftSMT (Assert e) = Assert $ shiftSExpr e
-- shiftSMT (SExpr e) = SExpr $ shiftSExpr e

data Symbol
data Decl
data Array i a

data SomeSMT a = forall b. SomeSMT (SMT a b)

deriving instance Show a => Show (SomeSMT a)

getNames :: SMT a b -> [a]
getNames (Decl x) = toList x
getNames (Assert x) = toList x
getNames (SExpr x) = toList x

getBlockNames :: Block a -> [a]
getBlockNames (Block xs) = concatMap go xs
  where
    go (SomeSMT x) = getNames x

instance IsString a => IsString (SExpr a) where
  fromString = Atom . fromString

instance IsString a => IsString (SMT a b) where
  fromString = SExpr . fromString

instance IsString a => IsString (SomeSMT a) where
  fromString = SomeSMT . fromString

instance IsString a => Num (SMT a Int) where
  SExpr (IntLit 0) + y = y
  x + SExpr (IntLit 0) = x
  x + y = add x y

  SExpr (IntLit 0) * _ = 0
  SExpr (IntLit 1) * y = y
  x * y = mul x y

  (-) = sub
  fromInteger = int . fromInteger
  signum = error "SMT.signum"

var :: String -> SMT a b
var = SExpr . Var

symbol :: a -> SMT a b --Symbol
symbol = SExpr . Atom

int :: Int -> SMT a Int
int = SExpr . IntLit

bool :: Bool -> SMT a Bool
bool = SExpr . BoolLit

nil :: SMT a Symbol
nil = SExpr (IntLit 0)

newtype Block a = Block [SomeSMT a]
  deriving (Semigroup, Monoid, Show)

varMap :: (a -> a') -> SMT a b -> SMT a' b
varMap f (Decl x) = Decl $ fmap f x
varMap f (Assert x) = Assert $ fmap f x
varMap f (SExpr x) = SExpr $ fmap f x

varMapBlock :: (a -> a') -> Block a -> Block a'
varMapBlock f (Block xs) = Block $ map go xs
  where
    go (SomeSMT x) = SomeSMT (varMap f x)

one :: SMT a b -> Block a
one x = Block [SomeSMT x]

smtBlock :: forall a b. [SMT a b] -> Block a
smtBlock = Block . map SomeSMT

apply' :: SExpr a -> [SExpr a] -> SExpr a
apply' f xs = List (f : xs)

-- NOTE: Do not export
apply :: a -> [SExpr a] -> SExpr a
apply f = apply' (Atom f)

assert :: SMT a Bool -> SMT a Decl
assert (SExpr e) = Assert e

and' :: IsString a => [SMT a Bool] -> SMT a Bool
and' = SExpr . apply "and" . map toSExpr

or' :: IsString a => [SMT a Bool] -> SMT a Bool
or' = SExpr . apply "or" . map toSExpr

(^||^) :: IsString a => SMT a Bool -> SMT a Bool -> SMT a Bool
(^||^) x y = or' [x, y]

(^&&^) :: IsString a => SMT a Bool -> SMT a Bool -> SMT a Bool
(^&&^) x y = and' [x, y]

pointsTo :: IsString a => SMT a b -> SMT a b -> SMT a Bool
pointsTo lhs rhs = SExpr $ apply "pto" [toSExpr lhs, toSExpr rhs]

emp :: IsString a => SMT a Bool
emp = SExpr $ Atom "sep.emp"

sep :: IsString a => [SMT a Bool] -> SMT a Bool
sep = SExpr . apply "sep" . map toSExpr

wand :: IsString a => SMT a Bool -> SMT a Bool -> SMT a Bool
wand lhs rhs = SExpr (apply "wand" [toSExpr lhs, toSExpr rhs])

setLogic :: IsString a => a -> SMT a Decl
setLogic x = Decl $ apply "set-logic" [Atom x]

declareHeap :: IsString a => a -> a -> SMT a Decl
declareHeap lhs rhs = Decl $ apply "declare-heap" [Atom lhs, Atom rhs]

declareConst :: IsString a => a -> a -> SMT a Decl
declareConst name ty = Decl $ apply "declare-const" [Atom name, Atom ty]

declareFun :: IsString a => a -> [a] -> a -> SMT a Decl
declareFun name argTys resTy =
  Decl $ apply "declare-fun" [Atom name, List (map Atom argTys), Atom resTy]

declareConstList :: IsString a => [(a, a)] -> Block a
declareConstList = smtBlock . map (uncurry declareConst)

not' :: IsString a => SMT a Bool -> SMT a Bool
not' = SExpr . apply "not" . (:[]) . toSExpr

implies :: IsString a => SMT a Bool -> SMT a Bool -> SMT a Bool
implies x y = SExpr (apply "=>" [toSExpr x, toSExpr y])

eq :: IsString a => SMT a b -> SMT a b -> SMT a Bool
eq x y = SExpr (apply "=" [toSExpr x, toSExpr y])

-- |lt (less than) corresponds to the SMT expression (< <lh> <rh>)
lt :: IsString a => SMT a b -> SMT a b -> SMT a Bool
lt x y = SExpr (apply "<" [toSExpr x, toSExpr y])

-- |lte (less than equal to) corresponds to the SMT expression (<= <lh> <rh>)
lte :: IsString a => SMT a b -> SMT a b -> SMT a Bool
lte x y = SExpr (apply "<=" [toSExpr x, toSExpr y])

-- |gt (greater than) corresponds to the SMT expression (> <lh> <rh>)
gt :: IsString a => SMT a b -> SMT a b -> SMT a Bool
gt x y = SExpr (apply ">" [toSExpr x, toSExpr y])

-- |gte (greater than equal) corresponds to the SMT expression (>= <lh> <rh>)
gte :: IsString a => SMT a b -> SMT a b -> SMT a Bool
gte x y = SExpr (apply ">=" [toSExpr x, toSExpr y])

ifThenElse :: IsString a => SMT a Bool -> SMT a b -> SMT a b -> SMT a b
ifThenElse c t f = SExpr (apply "ite" [toSExpr c, toSExpr t, toSExpr f])

add :: IsString a => SMT a Int -> SMT a Int -> SMT a Int
add x y = SExpr $ apply "+" [toSExpr x, toSExpr y]

sub :: IsString a => SMT a Int -> SMT a Int -> SMT a Int
sub x y = SExpr $ apply "-" [toSExpr x, toSExpr y]

mul :: IsString a => SMT a Int -> SMT a Int -> SMT a Int
mul x y = SExpr $ apply "*" [toSExpr x, toSExpr y]

div :: IsString a => SMT a Int -> SMT a Int -> SMT a Int
div x y = SExpr $ apply "/" [toSExpr x, toSExpr y]

mod' :: IsString a => SMT a Int -> SMT a Int -> SMT a Int
mod' x y = SExpr $ apply "mod" [toSExpr x, toSExpr y]

pow :: IsString a => SMT a Int -> SMT a Int -> SMT a Int
pow x y = SExpr $ apply "to_int" [apply "^" [toSExpr x, toSExpr y]]

true :: SMT a Bool
true = SExpr (BoolLit True)

false :: SMT a Bool
false = SExpr (BoolLit False)

overSExpr :: (SExpr a -> SExpr a) -> (SMT a b -> SMT a b)
overSExpr f (SExpr e) = SExpr (f e)

forAll :: [(String, String)] -> SMT a Bool -> SMT a Bool
forAll bnds body = SExpr $ ForAll bnds (toSExpr body)

exists :: [(String, String)] -> SMT a Bool -> SMT a Bool
exists bnds body = SExpr $ Exists bnds (toSExpr body)

-- freshIndex :: SMT a b -> Int
-- freshIndex x = 1 + maxVar (toSExpr x)

-- maxVar :: SExpr a -> Int
-- maxVar (Atom {}) = 0
-- maxVar (Var (_, i)) = i
-- maxVar (ForAll (_, i) e) = i `max` maxVar e
-- maxVar (List xs) = maximum (map maxVar xs)
-- maxVar (BoolLit {}) = 0
-- maxVar (IntLit {}) = 0
-- maxVar (DoubleLit {}) = 0
-- maxVar (BvLit {}) = 0

-- -- NOTE: For internal use only
-- shiftBinders :: SExpr a -> SExpr a
-- shiftBinders (ForAll e) = ForAll $ shiftSExpr e
-- shiftBinders (Ix i) = Ix i
-- shiftBinders (Atom x) = Atom x
-- shiftBinders (List xs) = List $ map shiftBinders xs
-- shiftBinders (BoolLit b) = BoolLit b
-- shiftBinders (IntLit i) = IntLit i
-- shiftBinders (DoubleLit d) = DoubleLit d

data Ixs a b i r where
  OneIx :: String -> Ixs a (Array i r) i r
  ConsIx :: String -> Ixs a b i r -> Ixs a (Array i b) i r

data SomeIxs a i r = forall b. SomeIxs (Ixs a (Array i b) i r)

-- TODO: Find a better way
retagIxs_unsafe :: Ixs a b i r -> SomeIxs a i r'
retagIxs_unsafe (OneIx x) = SomeIxs (OneIx x)
retagIxs_unsafe (ConsIx x xs) =
  case retagIxs_unsafe xs of
    SomeIxs xs' -> SomeIxs (ConsIx x xs')

ixsToList :: Ixs a b i r -> [String]
ixsToList (OneIx x) = [x]
ixsToList (ConsIx x xs) = x : ixsToList xs

someIxsToList :: SomeIxs a i r -> [String]
someIxsToList (SomeIxs i) = ixsToList i

-- TODO: Find a better approach
ixsToNames_unsafe :: Ixs a b i r -> [String]
ixsToNames_unsafe (OneIx v) = [v]
ixsToNames_unsafe (ConsIx v rest) = v : ixsToNames_unsafe rest

someIxsToNames_unsafe :: SomeIxs a i r -> [String]
someIxsToNames_unsafe (SomeIxs i) = ixsToNames_unsafe i

updateIx :: IsString a => Int -> a -> a -> (SMT a b -> SMT a b) -> SMT a Bool
updateIx i oldName newName f =
  store i newName (f (symbol newName))
  -- SExpr $ apply "store" [Atom newName, IntLit i, at oldName i]

store :: IsString a => Int -> a -> SMT a b -> SMT a Bool
store i name v =
  SExpr $ apply "store" [Atom name, IntLit i, toSExpr v]

at' :: IsString a => SExpr a -> SExpr a -> SExpr a
at' arr i = apply "select" [arr, i]

select :: IsString a => SMT a (Array i b) -> SMT a i -> SMT a b
select arr i = SExpr (at' (toSExpr arr) (toSExpr i))

-- type family ArrayBase a :: * where
--   ArrayBase (Array i (Array i b)) = ArrayBase (Array i b)
--   ArrayBase (Array i b) = b

-- TODO: Find a way to improve type-safety here
selectWithList :: forall a b i r. (HasCallStack, IsString a) => SMT a (Array i b) -> [SMT a i] -> SMT a r
selectWithList _ [] = error "selectWithList _ []"
selectWithList arr [i] = SExpr (at' (toSExpr arr) (toSExpr i))
selectWithList arr0 (i:is) =
  let arr = selectWithList arr0 is
  in
  SExpr (at' (toSExpr arr) (toSExpr i))

selects :: forall a b i r. IsString a => SMT a (Array i b) -> Ixs a (Array i b) i r -> SMT a r
selects arr ixs0 = SExpr (go (map var (ixsToList ixs0)))
  where
    go :: [SMT a i] -> SExpr a
    go [i] = at' (toSExpr arr) (toSExpr i)
    go (i:is) = at' (go is) (toSExpr i)

smtMap :: IsString a => Int -> (Int -> SMT a b -> SMT a b) -> a -> a -> SMT a Bool
smtMap size f oldName newName =
  and' (map go [0..size-1])
  where
    go i = updateIx i oldName newName (f i)

smtMapList :: IsString a => (SMT a b -> SMT a b) -> a -> a -> [SMT a b] -> SMT a Bool
smtMapList f oldName newName list =
  and' (zipWith go [0..] list)
  where
    go i v = store i newName (f v)

setInfo :: IsString a => [(a, a)] -> SMT a Decl
setInfo = Decl . apply "set-info" . map Atom . flatten
  where
    flatten :: [(a, a)] -> [a]
    flatten = concat . map (\(x, y) -> [x, y])

-- |setOption corresponds to the (set-option <keyword> <attr-value>) SMTLIB command
-- TODO: take in a list of tuples and return a Block a instead
setOption :: IsString a => a -> a -> SMT a Decl
setOption keyword attr_value = Decl $ apply "set-option" [Atom keyword, Atom attr_value]

smtPreamble :: IsString a => Block a
smtPreamble =
  smtBlock
    [setLogic "ALL"
    ,setOption ":timeout" "5000"
    -- ,setOption ":produce-models" "true"
    ,setOption ":pp.decimal" "true"
    -- ,setOption ":produce-unsat-cores" "true"
    -- ,setOption ":verbose" "10"
    ,declareConst "sqrt2" "Real"
    ,assert $ eq (mul "sqrt2" "sqrt2") (int 2)
    ,assert $ gt "sqrt2" (int 0)

    ,declareFun "omega" ["Real", "Real"] "Real"
    ] <> omegaSpec

-- TODO: Improve type safety
double :: Double -> SMT a Int
double = SExpr . DoubleLit

sin' :: IsString a => SMT a Int -> SMT a Int
sin' x = SExpr $ apply "sin" [toSExpr x]

pi' :: IsString a => SMT a Int
pi' = symbol "pi"

omega :: IsString a => SMT a Int -> SMT a Int -> SMT a Int
omega a b =
  SExpr $ apply "omega" [toSExpr a, toSExpr b]
  -- sin' (2 * pi' * a `div` b)

ampFactor :: IsString a => Int -> SMT a Int
ampFactor n = pow invSqrt2 (int n)

omegaSpec :: IsString a => Block a
omegaSpec =
  smtBlock
    [ assert $ forAll [("a", "Real"), ("b", "Real"), ("c", "Real")] $
        eq (mul (omega (var "a") (var "b")) (omega (var "c") (var "b")))
           (omega (add (var "a") (var "c")) (var "b"))

    , assert $ forAll [("b", "Real")] $
        eq (omega (int 0) (var "b"))
           (int 1)
    ]

invSqrt2 :: IsString a => SMT a Int
invSqrt2 = div (int 1) sqrt2

sqrt2 :: IsString a => SMT a Int
sqrt2 = SExpr $ Atom "sqrt2"

checkSAT :: IsString a => SMT a Decl
checkSAT = Decl $ apply "check-sat" []

getModel :: IsString a => SMT a Decl
getModel = Decl $ apply "get-model" []

-- NOTE: Do not export
toSExpr :: SMT a b -> SExpr a
toSExpr (SExpr e) = e

-- | Operations on bit vectors where the size is known "statically" (before
-- the SMT solver runs).
data BitVector a = BitVector Int                     -- Length of the bit vector
                           (SMT a (Array Int Int))
  deriving (Show)

newtype BitVecPosition = BitVecPosition Int
  deriving (Show)

mkBitVectorOfSize :: Int -> SMT a (Array Int Int) -> BitVector a
mkBitVectorOfSize = BitVector

bvPosition :: Int -> BitVecPosition
bvPosition = BitVecPosition

bvSMT :: BitVector a -> SMT a (Array Int Int)
bvSMT (BitVector _ e) = e

getBit :: IsString a => BitVector a -> BitVecPosition -> BitVector a
getBit (BitVector _ e) (BitVecPosition pos) =
  BitVector 1 $ SExpr $ apply' (apply "_" ["extract", IntLit pos, IntLit pos]) [toSExpr e]

toInt :: IsString a => BitVector a -> SMT a Int
toInt (BitVector _ e) = SExpr $ apply "bv2nat" [toSExpr e]

int2bv :: IsString a => Int -> SMT a Int -> BitVector a
int2bv size e = BitVector size (SExpr (apply' (apply "_" ["int2bv", IntLit size]) [toSExpr e]))

bv2nat :: IsString a => BitVector a -> SMT a Int
bv2nat (BitVector _ e) = SExpr $ apply "bv2nat" [toSExpr e]

bvLit :: Int -> Int -> BitVector a
bvLit size bits = BitVector size (SExpr (BvLit size bits))

bvConcat :: IsString a => [BitVector a] -> BitVector a
bvConcat bvs = BitVector totalSize $ SExpr $ apply "concat" (map (toSExpr . get) bvs)
  where
    totalSize = sum $ map bitVectorSize bvs
    get (BitVector _ e) = e


-- | Assumes that each item of the list is either 0 or 1.
-- The least-significant bit should be first in the list.
listToBits :: IsString a => [SMT a Int] -> BitVector a
listToBits xs = int2bv (length xs) . go $ reverse xs
  where
    go [] = 0
    go (b:bs) = b + (2 * go bs)

toBitVecFn :: IsString a => (SMT a Int -> SMT a Int) -> (BitVector a -> BitVector a)
toBitVecFn f x =
  int2bv (bitVectorSize x) (f (bv2nat x))

withPadding :: IsString a => (BitVector a -> BitVector a -> r) -> BitVector a -> BitVector a -> r
withPadding k x@(BitVector n _) y@(BitVector m _) =
  let paddedX = pad n m x
      paddedY = pad m n y
  in
  k paddedX paddedY
  where
    pad thisSize otherSize v
      | otherSize > thisSize =
          let padding = bvLit (otherSize - thisSize) 0
          in
          bvConcat [padding, v]
      | otherwise = v

bvShiftL :: IsString a => BitVector a -> Int -> BitVector a
bvShiftL v@(BitVector n x) amount =
  bvConcat [v, bvLit amount 0]
  -- BitVector (n + amount) $ SExpr $ apply "bvshl" [toSExpr x, BvLit n amount]
  -- BitVector (n + amount) $ SExpr $ apply "bvlshr" [toSExpr x, BvLit n amount]

bvOr :: IsString a => BitVector a -> BitVector a -> BitVector a
bvOr = \(BitVector n x) (BitVector m y) ->
  BitVector (max n m) $ SExpr $ apply "bvor" [toSExpr x, toSExpr y]

bvXor :: IsString a => BitVector a -> BitVector a -> BitVector a
bvXor = \(BitVector n x) (BitVector m y) ->
  BitVector (max n m) $ SExpr $ apply "bvxor" [toSExpr x, toSExpr y]

bvAnd :: IsString a => BitVector a -> BitVector a -> BitVector a
bvAnd = \(BitVector n x) (BitVector m y) ->
  BitVector (max n m) $ SExpr $ apply "bvand" [toSExpr x, toSExpr y]

bvGetRange :: IsString a => BitVector a -> BitVecPosition -> BitVecPosition -> BitVector a
bvGetRange (BitVector n x) (BitVecPosition start) (BitVecPosition end) =
  BitVector (end - start + 1) $ SExpr $ apply' (apply "_" ["extract", IntLit end, IntLit start]) [toSExpr x]

bvAdd :: IsString a => BitVector a -> BitVector a -> BitVector a
bvAdd = \(BitVector n x) (BitVector m y) ->
  BitVector (max n m) $ SExpr $ apply "bvadd" [toSExpr x, toSExpr y]

bvSub :: IsString a => BitVector a -> BitVector a -> BitVector a
bvSub = \(BitVector n x) (BitVector m y) ->
  BitVector (max n m) $ SExpr $ apply "bvsub" [toSExpr x, toSExpr y]

bvMul :: IsString a => BitVector a -> BitVector a -> BitVector a
bvMul = \(BitVector n x) (BitVector m y) ->
  BitVector (max n m) $ SExpr $ apply "bvmul" [toSExpr x, toSExpr y]

bvMod :: IsString a => BitVector a -> BitVector a -> BitVector a
bvMod = \(BitVector n x) (BitVector m y) ->
  BitVector (max n m) $ SExpr $ apply "bvsmod" [toSExpr x, toSExpr y]

-- overwriteIndexBits :: IsString a => Int -> SMT a Int -> BitVecPosition -> BitVector a -> SMT a Int
-- overwriteIndexBits overallSize ix (BitVecPosition pos) newMiddleVec@(BitVector middleSize newMiddle) =
--   let
--       -- Example: 00011000
--       mask :: Int
--       mask = (2 ^ (middleSize - 1)) `shiftL` pos
--
--       -- Example: 11100111
--       invertedMask = bvLit overallSize $ (2 ^ (overallSize - 1)) `xor` mask
--
--       -- Example: bb  -->  bbb00
--       newBits = newMiddleVec `bvShiftL` pos
--
--       bv = int2bv overallSize ix
--   in
--   bv2nat $ bvOr (bvAnd bv invertedMask) newBits

bitVectorSize :: BitVector a -> Int
bitVectorSize (BitVector n _) = n

ones :: IsString a => Int -> BitVector a
ones size = BitVector size (SExpr (BvLit size (2 ^ (size - 1))))

invertBitVec :: IsString a => BitVector a -> BitVector a
invertBitVec bv@(BitVector size x) = bvXor bv (ones size)

-- | Overwrite the bits starting at the given position
overwriteBits :: IsString a => BitVector a -> BitVecPosition -> BitVector a -> BitVector a
overwriteBits bv@(BitVector n _) (BitVecPosition pos) newMiddlePart =
  let
      -- Example: 00011000
      mask :: Int
      mask = (2 ^ (bitVectorSize newMiddlePart - 1)) `shiftL` pos

      -- Example: 11100111
      invertedMask = bvLit n $ (2 ^ (n - 1)) `xor` mask

      -- Example: bb  -->  bb00
      newBits = int2bv n (bv2nat (newMiddlePart `bvShiftL` pos)) -- TODO: Could this be nicer?
  in
  bvOr (bvAnd bv invertedMask) newBits

selectWithBitVector :: forall a b. IsString a => SMT a (Array Int b) -> BitVector a -> SMT a b
selectWithBitVector arr bv =
  let ix :: SMT a Int
      ix = bv2nat bv
  in
  select arr ix


-- freshBase :: String
-- freshBase = "rr"

instance (IsString a, Pretty a) => Pretty (SExpr a) where
  pretty (Atom x) = pretty x
  pretty (Var v) = pretty v

  pretty (ForAll bnds body) =
    pretty $ List [Atom "forall", List (map pairToList bnds), body]
    where
      pairToList (v, type_) = List [Atom (fromString v), Atom (fromString type_)]

  pretty (Exists bnds body) =
    pretty $ List [Atom "exists", List (map pairToList bnds), body]
    where
      pairToList (v, type_) = List [Atom (fromString v), Atom (fromString type_)]

  pretty (List xs) = parens $ hsep $ map pretty xs
  pretty (BoolLit b) = pretty $ toLowerString $ show b -- SMTLIB v2 specifies booleans as lowercase keywords
  pretty (IntLit i) = pretty i
  pretty (DoubleLit x) = pretty x
  pretty (BvLit size x) =
    let bin = showBin x ""
        paddingSize = size - length bin
        padding = replicate paddingSize '0'
        paddedBin = padding ++ bin
    in
    "#b" <> pretty paddedBin

instance (IsString a, Pretty a) => Pretty (SMT a b) where
  pretty (Decl x) = pretty x
  pretty (Assert x) = pretty (List [Atom "assert", x])
  pretty (SExpr x) = pretty x

instance (IsString a, Pretty a) => Pretty (SomeSMT a) where
  pretty (SomeSMT x) = pretty x

instance (IsString a, Pretty a) => Pretty (Block a) where
  pretty (Block xs) = vcat $ map pretty xs

instance (IsString a, Pretty a) => Pretty (BitVector a) where
  pretty (BitVector _ x) = pretty x

-- convertProp :: LExprProp -> SBool
-- convertProp (Prop xs) = foldr (.&&) sTrue (map convertConjunct xs)
--
-- convertConjunct :: LExprConjunct -> SBool
-- convertConjunct (PointsTo lhs rhs) = undefined
--
-- convertSteppedLocus :: SteppedLocus -> 
--
-- -- class ToSMT a where
-- --   toSMT :: a -> SBV a
--
--
--
