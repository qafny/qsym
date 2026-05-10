module QSym.Logic.Gen
  where

import Qafny.Syntax.AST hiding (Range (..), Block)
import qualified Qafny.Syntax.AST as Qafny
import Qafny.Syntax.Subst

import QSym.Logic.SMT
import QSym.Logic.Syntax
import QSym.Logic.Name

import QSym.Logic.Memory

import Data.String
import Control.Monad.Reader
import Control.Monad.State

import Data.List
import Data.Function
import Data.Foldable (fold)

import GHC.Stack

import Prettyprinter

newtype Gen a = Gen { getGen :: ReaderT Env (State Memory) a }
  deriving (Functor, Applicative, Monad, MonadReader Env, MonadState Memory)

data Env =
  Env
  { envInputs :: Bindings ()
  , envOutputs :: Bindings ()
  , envBitSize :: Int
  , envVarAssignment :: [(String, Int)] -- | Loci variable -> bit vector (base) index
  }

getVarBaseIndex :: String -> Gen Int
getVarBaseIndex v = do
  asn <- fmap envVarAssignment ask
  let Just i = lookup v asn
  pure i

rangeToPhysicalIndices :: Qafny.Range -> Gen (Int, Int)
rangeToPhysicalIndices (Qafny.Range x start0 end0) = do
  let start = toInt start0
      end = toInt end0

  base <- getVarBaseIndex x
  pure (start + base, end + base)

varProbabilitiesToPhysical :: [(String, [a])] -> Gen [(Int, a)]
varProbabilitiesToPhysical varProbs = undefined
  where
    go :: [(a, [b])] -> [(a, Int, b)]
    go = map (\(x, (y, z)) -> (x, y, z)) . go2 . go1

    go1 :: [(a, [b])] -> [(a, [(Int, b)])]
    go1 = map (fmap (zip [0..]))

    go2 :: [(a, [(Int, b)])] -> [(a, (Int, b))]
    go2 = concatMap sequence

varProbabilityToPhysical :: String -> Int -> a -> Gen (Int, a)
varProbabilityToPhysical var varIx prob = do
  base <- getVarBaseIndex var
  pure (base + varIx, prob)

-- | Maximum size associated to a variable name, given by the loci
newtype LociSizes = LociSizes [(String, Int)]
  deriving (Show)

oneLociSize :: String -> Int -> LociSizes
oneLociSize v i = LociSizes [(v, i)]

instance Semigroup LociSizes where
  LociSizes a0 <> LociSizes b0 = LociSizes $ go a0 b0
    where
      go a [] = a
      go xs (y@(v, i):ys) =
        case lookup v xs of
          Nothing -> y : (go xs ys)
          Just j -> (v, max i j) : go (deleteBy ((==) `on` fst) y xs) ys

instance Monoid LociSizes where
  mempty = LociSizes mempty

getOtherInputs :: [Int] -> Gen [Int]
getOtherInputs usedInputs = do
  env <- ask

  let allInputs = zipWith const [0..] $ envInputs env

  pure $ filter (`notElem` usedInputs) allInputs

-- |allBindings returns a list of both the inputs and the outputs from the environment
allBindings :: Env -> Bindings ()
allBindings env = envInputs env ++ envOutputs env

buildEnv :: Int -> QMethod () -> Env
buildEnv bitSize qm = Env (qmInputs qm) (qmOutputs qm) bitSize (allocateIndices (getLociSizes qm))

allocateIndices :: LociSizes -> [(String, Int)]
allocateIndices (LociSizes xs0) = go 0 xs0
  where
    go _ [] = []
    go currIndex ((v, size) : xs) =
      (v, currIndex) : go (currIndex + size) xs

-- For now, we just get loci where the range is given by integer
-- literals
-- TODO: Generalize this to work with indexing expressions that have
-- variables in them
getLociSizes :: QMethod () -> LociSizes
getLociSizes x =
  case qmBody x of
    Nothing -> mempty
    Just body -> mconcat $ map getLociSizesStmt $ inBlock body

getLociSizesStmt :: Stmt () -> LociSizes
getLociSizesStmt (SAssert {}) = mempty
getLociSizesStmt (SCall _ xs) = mconcat $ map getLociSizesExp xs
getLociSizesStmt (SVar _ x) = fold $ fmap getLociSizesExp x
getLociSizesStmt (lhs ::=: rhs) = getLociSizesExp rhs
getLociSizesStmt (SIf (GEPartition part Nothing) part' (Qafny.Block xs)) =
  toLociSizes part
    <> toLociSizes part'
    <> mconcat (map getLociSizesStmt xs)
getLociSizesStmt (SIf (GClass boolExp) part (Qafny.Block xs)) =
  getLociSizesExp boolExp
    <> toLociSizes part
    <> mconcat (map getLociSizesStmt xs)
getLociSizesStmt (lhs :*=: rhs) = toLociSizes lhs <> getLociSizesExp rhs
getLociSizesStmt s = error $ show s

toLociSizes :: Partition -> LociSizes
toLociSizes (Partition xs) = mconcat (map rangeToLociSizes xs)

rangeToLociSizes :: Qafny.Range -> LociSizes
rangeToLociSizes (Qafny.Range x _start end) = fold $ do
  endNum <- toInt_maybe end
  Just (oneLociSize x endNum)

-- TODO: Finish
getLociSizesExp :: Exp () -> LociSizes
getLociSizesExp (ENum _) = mempty
getLociSizesExp (EVar x) = mempty
getLociSizesExp (EOp2 _ x y) = getLociSizesExp x <> getLociSizesExp y
getLociSizesExp (ELambda (LambdaF { eBases = xs })) = mconcat $ map getLociSizesExp xs
getLociSizesExp EHad = mempty
getLociSizesExp (EMeasure x) = toLociSizes x
getLociSizesExp e = error $ show e

toLocus :: Partition -> Locus
toLocus (Partition xs) = Locus $ map convertRange xs

convertRange :: Qafny.Range -> Range
convertRange (Qafny.Range x start end) = Range x (convertSimpleExpr start) (convertSimpleExpr end)

toInt :: HasCallStack => Exp () -> Int
toInt x =
  let Just r = toInt_maybe x
  in
  r

toInt_maybe :: Exp () -> Maybe Int
toInt_maybe (ENum i) = Just i
toInt_maybe (EOp2 op x y) = liftA2 (interp op) (toInt_maybe x) (toInt_maybe y)
  where
    interp OAdd = (+)

getNum :: Exp () -> Maybe Int
getNum (ENum i) = Just i
getNum _ = Nothing

convertSimpleExpr :: Exp () -> SimpleExpr
convertSimpleExpr (ENum i) = Lit i
convertSimpleExpr (EVar x) = Var x
convertSimpleExpr (EOp2 OAdd x y) = Add (convertSimpleExpr x) (convertSimpleExpr y)

runGen :: Gen a -> Env -> Memory -> a
runGen (Gen g) env = evalState (runReaderT g env)

