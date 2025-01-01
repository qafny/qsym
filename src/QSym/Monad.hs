module QSym.Monad
  -- (QSym
  -- ,execQSym
  -- ,atPosi
  -- ,update
  -- ,atVar
  -- ,emptyState
  -- ,mkState
  -- -- ,mkEnv
  -- )
  where

-- import QSym.QState (QEnv', QState', emptyState, mkState)
import qualified QSym.QState as QS
-- import QSym.QState (QEnv, mkEnv)

import GHC.Stack

import QSym.Utils
import QSym.Syntax

import Control.Monad
import Control.Monad.Reader
import Control.Monad.State

import Math.NumberTheory.Logarithms

import Numeric.Natural
import Test.QuickCheck
import Data.Bits as Bits

newtype QSym a = QSym (ReaderT QEnv' (State QState') a)
  deriving (Functor, Applicative, Monad, MonadReader QEnv')

-- Specialized to () so that we know we're forgetting the "result"
execQSym :: QEnv' -> QState' -> QSym () -> QState'
execQSym env st (QSym m) =
  execState (runReaderT m env) st

stateGet :: Var -> QSym Value
stateGet x =
  stateGet' <$> QSym get <*> pure x

update :: Var -> Value -> QSym ()
update i new =
  QSym $ modify $ \st -> update' st i new

envGet :: Var -> QSym Natural
envGet x = envGet' <$> QSym ask <*> pure x

-- Bit count usually won't change, except Nor -> Phi
-- (Starts at Nor type)
-- Initial bit count is determined by the environment size
data RzValue = RzValue
  { rzBitCount :: Natural
  , rzNatural :: Natural
  }
  deriving (Show) --(Eq, Ord, Num, Bits, Show)

instance Eq RzValue where
  RzValue sz1 f == RzValue sz2 g =
    sz1 == sz2 && f == g

instance Ord RzValue where
  compare (RzValue _ f) (RzValue _ g) = compare f g

instance Enum RzValue where
  toEnum i = error "RzValue: toEnum" -- NOTE: We don't know the size here
  fromEnum (RzValue _ f) = fromEnum f

rzSubtract :: HasCallStack => RzValue -> RzValue -> RzValue
rzSubtract = (-)

-- rzSubtract :: HasCallStack => RzValue -> RzValue -> RzValue
-- rzSubtract a b
--   | b > a = error "rzSubtract: b > a"
--   | otherwise = a - b

instance Num RzValue where
  (+) = liftNaturalBinOp (+)
  -- (-) = liftNaturalBinOp (-)
  (*) = liftNaturalBinOp (*)
  -- negate = error "negate called" -- TODO: This is for debugging purposes
  negate = liftNaturalUnaryOp negate

  RzValue sz1 f - RzValue sz2 g = 
    if g > f
    then error "RzValue.-: negative result"
    else RzValue (max sz1 sz2) (f - g)

  -- TODO: Is this okay?
  signum :: RzValue -> RzValue
  signum = liftNaturalUnaryOp signum

  -- TODO: Is this okay?
  abs :: RzValue -> RzValue
  abs = liftNaturalUnaryOp abs

  -- TODO: Is this okay?
  fromInteger i | i < 0 = error "RzValue.fromInteger: negative argument"
  fromInteger i = mkRzValue' i

instance Real RzValue where
  toRational (RzValue _ f) = toRational f

instance Integral RzValue where
-- TODO: Is this right?
  quotRem x y = (quot x y, rem x y)
  quot = liftNaturalBinOp quot
  rem = liftNaturalBinOp rem
  toInteger (RzValue _ f) = toInteger f
    

-- TODO: Is this right?
-- TODO: Don't export this
liftNaturalBinOp :: (Natural -> Natural -> Natural) -> RzValue -> RzValue -> RzValue
liftNaturalBinOp op (RzValue sz1 f) (RzValue sz2 g) =
  let newSz = max sz1 sz2
  in
  RzValue newSz (op f g `mod` fromIntegral newSz)

-- TODO: Don't export this
liftNaturalUnaryOp :: (Natural -> Natural) -> RzValue -> RzValue
liftNaturalUnaryOp op (RzValue sz f) =
  RzValue sz (op f `mod` fromIntegral sz)

rzValueToBools :: RzValue -> [Bool]
rzValueToBools val@(RzValue count _) =
  map (\i -> val ! i) [0..count-1]

boolsToRzValue :: [Bool] -> RzValue
boolsToRzValue xs0 = go 0 xs0
  where
    len = length xs0

    go i [] = RzValue (intToNatural len) 0
    go i (True:xs) =
      let rest = go (i+1) xs
      in
      rzSetBit rest i True
    go i (False:xs) = go (i+1) xs

-- TODO: Use a fast implementation
rotate :: Natural -> RzValue -> RzValue
rotate i = boolsToRzValue . go i . rzValueToBools
  where
    go :: Natural -> [a] -> [a]
    go n xs = drop (fromIntegral n) xs <> take (fromIntegral n) xs

rzValue :: MonadReader (QEnv a) m => Natural -> m RzValue
rzValue val = do
  QEnv xs <- ask
  pure (RzValue (intToNatural (length xs)) val)

(!) :: RzValue -> Natural -> Bool
(!) (RzValue _ v) i = testBit v (fromIntegral i)

rzSetBit :: RzValue -> Natural -> Bool -> RzValue
rzSetBit (RzValue sz f) i b = RzValue sz $
  if b
  then setBit f (fromIntegral i)
  else clearBit f (fromIntegral i)

nOnes :: Natural -> QSym RzValue
nOnes n | n < 0 = error "nOnes: negative argument"
nOnes n = rzValue ((1 `shiftL` (fromIntegral n)) - 1)

-- Left shift
-- TODO: Should we update the bit size?
shiftLeft :: RzValue -> Natural -> RzValue
shiftLeft (RzValue sz f) n =
  RzValue sz (f `shiftL` (fromIntegral n))

complementBit :: RzValue -> Natural -> RzValue
complementBit (RzValue sz f) i =
  RzValue sz (f `Bits.complementBit` (fromIntegral i))

toRzValue :: Integral a => Natural -> a -> RzValue
toRzValue size = RzValue size . fromIntegral

-- Apply the function to bits below the given index
mapBitsBelow :: Natural -> RzValue -> (Natural -> Bool) -> RzValue
mapBitsBelow i0 v0 f = go i0 v0
  where
    go i v
      | i < 0     = v
      | otherwise = rzSetBit (go (i - 1) v) i (f i)

bool2RzValue :: MonadReader (QEnv a) m => Bool -> m RzValue
bool2RzValue False = rzValue 0
bool2RzValue True = rzValue 1

data Value
  = NVal RzValue RzValue -- nor type (state, amplitude)
  | QVal RzValue RzValue -- phi type
  deriving (Eq, Show)
  
allFalse :: MonadReader (QEnv a) m => m RzValue
allFalse = rzValue 0

-- basisVal :: Bool -> Value
-- basisVal b = NVal b allFalse

newtype QEnv a = QEnv [(Var, a)] --(Var -> a)
  deriving (Show)

type QEnv' = QEnv Natural

envGet' :: QEnv a -> Var -> a
envGet' (QEnv xs) v =
  let Just r = lookup v xs
  in
  r

qenvSize :: QEnv a -> Natural
qenvSize (QEnv xs) = intToNatural (length xs)

newtype QState a = QState (Var -> a)

-- |showQState returns a string representation of a QState given the state 
--  and a list of variables
--  where:
--    st of type `QState` is the state to convert to a string
--    vars of type `[Var]` is a list of the variables that should be examined
--  return of type `String`: the String representation of the QState and variables
showQState :: Show a => QState a -> [Var] -> String
showQState st vars = "QState " ++ show (enumVars vars)
  where
    enumVars vars = zip vars (map (stateGet' st) vars)

type QState' = QState Value

stateGet' :: QState a -> Var -> a
stateGet' (QState f) = f

update' :: QState a -> Var -> a -> QState a
update' st i new = QState $
  \j ->
    if j == i
    then new
    else stateGet' st j

-- updateVar' :: QState Value -> Posi -> Bvector -> QState Value
-- updateVar' st x vec =
--   case unconsBvector vec of
--     Nothing -> st
--     Just (b, vec') ->
--       update (updateVar' st (nextPos x) vec') x (basisVal b)

-- updateVar :: QState Value -> Var -> Bvector -> QState Value
-- updateVar st x = updateVar' st (Posi x 0)

mkQEnv :: [(Var, a)] -> QEnv a
mkQEnv = QEnv

emptyState :: QEnv a -> QState Value
emptyState env = QState $ \_ -> liftM2 NVal allFalse allFalse env

mkState :: QEnv a -> [(Var, Value)] -> QState Value
mkState env [] = emptyState env
mkState env ((p, v):rest) = update' (mkState env rest) p v

stEquiv :: [Var] -> QEnv Natural -> QState Value -> QState Value -> Property
stEquiv vars env st1 st2 =
    conjoin (map go vars)
  where
    go v =
      lookup v st1 === lookup v st2

    lookup v (QState s) = s v

-- |getSizeInBits
-- returns the number of bits as a natural number that an Integral type takes up.
getSizeInBits :: (Integral a) => a -> Natural
getSizeInBits n = intToNatural $ integerLog2 (fromIntegral n) + 1

-- TODO: Is this reasonable?
mkRzValue' :: (HasCallStack, Show a, Integral a) => a -> RzValue
mkRzValue' 0 = RzValue 1 0
mkRzValue' i =
  let sz = getSizeInBits i
  in
  RzValue sz (fromIntegral i)


-- stateFromVars :: [(Var, Bvector)] -> QState Value
-- stateFromVars [] = emptyState
-- stateFromVars ((x, vec) : rest) =
--   updateVar (stateFromVars rest) x vec

-- envUpdate :: QEnv a -> Var -> a -> QEnv a
-- envUpdate env i new = QEnv $
--   \j ->
--     if j == i
--     then new
--     else atVar env j

-- stEquiv :: [Var] -> QEnv Natural -> QState Value -> QState Value -> Property
-- stEquiv vars env st st' =
--   forAll (elements vars) $ \x ->
--     counterexample (show (showVar st x, showVar st' x)) $
--     varEquiv st st' x (atVar env x)

-- showVar :: QState Value -> Var -> String
-- showVar st x = go 0
--   where
--     go n | n >= 5 = ""
--     go n =
--       showValue (atPosi st (Posi x n)) ++ ", " ++ go (n + 1)

-- varEquiv :: QState Value -> QState Value -> Var -> Natural -> Property
-- varEquiv st st' var n =
--   n /= 0 ==>
--     let n' = n - 1
--         p = Posi var n'
--     in
--     (counterexample (show (p, showValue (atPosi st p), showValue (atPosi st' p)))
--       (valueEqualUpToCutOff (atPosi st p) (atPosi st' p)))
--       .&.
--     varEquiv st st' var n'

-- showValue :: Value -> String
-- showValue (NVal b v) =
--   "NVal " ++ show b ++ " " ++ show (toInt v)
-- showValue (QVal v1 v2) =
--   "QVal " ++ show (toInt v1) ++ show (toInt v2)

-- upToCutoff :: RzValue -> [Bool]
-- upToCutoff = zipWith (flip (!)) [0..bitCheckCutoff] . repeat

-- toInt :: RzValue -> Natural
-- toInt = go 0 . upToCutoff
--   where
--     go i [] = 0
--     go i (False : xs) =           go (i+1) xs
--     go i (True  : xs) = (2 ^ i) + go (i+1) xs

-- equalUpToCutoff :: RzValue -> RzValue -> Bool
-- equalUpToCutoff f g = all go [0..bitCheckCutoff]
--   where
--     go x = (f ! x) == (g ! x)

-- valueEqualUpToCutOff :: Value -> Value -> Property
-- valueEqualUpToCutOff (NVal b v) (NVal b' v') =
--   b === b' .&&. upToCutoff v === upToCutoff v'
-- valueEqualUpToCutOff (QVal v1 v2) (QVal v1' v2') = upToCutoff v1 == upToCutoff v1' .&&. upToCutoff v2 === upToCutoff v2'
-- valueEqualUpToCutOff _ _ = counterexample "QVal /= NVal" (False === True)
--
-- mkEnv :: Show a => [(Var, a)] -> QEnv a
-- mkEnv xs = QEnv $ \x ->
--   case lookup x xs of
--     Nothing -> error $ "Cannot find " ++ show x ++ " in " ++ show xs
--     Just y -> y
--


intToNatural :: Int -> Natural
intToNatural = fromIntegral