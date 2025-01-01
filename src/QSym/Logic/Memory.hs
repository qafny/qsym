{-# LANGUAGE TupleSections #-}
{-# LANGUAGE DataKinds #-}

module QSym.Logic.Memory
  (MemType (..)
  ,Memory
  ,memType
  ,memAmpName
  ,memPhaseName
  ,memBitVecName
  ,mkMemory
  ,declareMemory
  ,MemEntry (..)
  ,forEach
  ,existsIx
  ,memTypeSize
  ,indexMemoryByList
  ,setToMemEntry
  ,extendMemory
  ,mkIndexVars
  )
  where

import QSym.Logic.Name
import QSym.Logic.SMT

import GHC.Stack

import Data.String

import Debug.Trace

newtype MemType = EN [Int] -- Contains the dimensions. If the list is size n, then it represents the type EN(n)
  deriving (Show, Eq, Ord, Semigroup)

data Memory =
  Memory
    { memType :: MemType
    , memBitVecSize :: Int
    , memAmpName :: Name
    , memPhaseName :: Name
    , memBitVecName :: Name
    }
  deriving (Show)

data MemEntry =
  MemEntry
    { memEntryAmp :: SMT Name Int
    , memEntryPhase :: SMT Name Int
    , memEntryBitVec :: BitVector Name
    }

memTypeSize :: MemType -> Int
memTypeSize (EN xs) = length xs

mkMemory :: MemType -> Int -> Name -> Name -> Name -> Memory
mkMemory = Memory

-- | Extend with more dimensions of given size. We also update the names.
extendMemory :: Memory -> MemType -> (Name -> Name) -> Memory
extendMemory mem newDims updateName =
  mem
    { memType = memType mem <> newDims
    , memAmpName = updateName $ memAmpName mem
    , memPhaseName = updateName $ memPhaseName mem
    , memBitVecName = updateName $ memBitVecName mem
    }

declareMemory :: Int -> Memory -> Block Name
declareMemory bitSize mem =
    traceShow (memAmpName mem) $
    smtBlock
      [ declare "Int" memAmpName
      , declare "Int" memPhaseName
      , declare ("(_ BitVec " ++ show bitSize ++ ")") memBitVecName
      ]
  where
    declare baseTy f = 
      declareConst (f mem) (fromString (buildType baseTy (memTypeSize (memType mem))))

    buildType baseTy 0 = baseTy
    buildType baseTy n = "(Array Int " ++ buildType baseTy (n-1) ++ ")"

mkBounds :: MemType -> [String] -> SMT Name Bool
mkBounds (EN uppers) vs =
    and' (map mkLowerBound vs ++ zipWith mkUpperBound uppers vs)
  where
    mkLowerBound v = gte (var v) (int 0)
    mkUpperBound upper v = lt (var v) (int upper)

-- TODO: Make sure that these names are always appropriately fresh
mkIndexVars :: MemType -> SomeIxs Name Int Int
mkIndexVars (EN xs) = go xs names
  where
    go :: [Int] -> [String] -> SomeIxs Name Int Int
    go [_] (name:_) = SomeIxs (OneIx name)
    go (_:restDims) (name:restNames) =
      case go restDims restNames of
        SomeIxs r -> SomeIxs (ConsIx name r)

    baseNames = ["i", "j", "k"]

    names = baseNames ++ map extraNameToString extraNames

    extraNameToString (str, i) = str ++ show i

    extraNames :: [(String, Int)]
    extraNames = zip baseNames [0..] ++ map (fmap (+1)) extraNames

indexMemory :: Memory -> Ixs Name (Array Int a) Int Int -> MemEntry
indexMemory mem ixs
  | length (ixsToList ixs) /= memTypeSize (memType mem) = error $ "indexMemory: Wrong number of dimensions. Memory has " ++ show (memTypeSize (memType mem)) ++ ", expected " ++ show (length (ixsToList ixs))
  | otherwise =
      -- TODO: Find a nicer way
      case retagIxs_unsafe ixs :: SomeIxs Name Int (Array Int Int) of
        SomeIxs bitVecIxs ->
          MemEntry
            { memEntryAmp = selects ampArr ixs
            , memEntryPhase = selects phaseArr ixs
            , memEntryBitVec = mkBitVectorOfSize (memBitVecSize mem) $ selects bitVecArr bitVecIxs
            }
      where
        ampArr = symbol (memAmpName mem)
        phaseArr = symbol (memPhaseName mem)
        bitVecArr = symbol (memBitVecName mem)

indexMemoryByList :: Memory -> [String] -> MemEntry
indexMemoryByList mem ixs =
    case ixsFromList ixs of
      SomeIxs is -> indexMemory mem is
  where
    ixsFromList :: [String] -> SomeIxs Name Int Int
    ixsFromList [i] = SomeIxs (OneIx i)
    ixsFromList (i:is) = 
      case ixsFromList is of
        SomeIxs is' -> SomeIxs (ConsIx i is')

quantifiedBy ::
  ([(String, String)] -> SMT Name Bool -> SMT Name Bool) ->
  (SMT Name Bool -> SMT Name Bool -> SMT Name Bool) ->
  Memory -> ([String] -> SMT Name Bool) -> SMT Name Bool
quantifiedBy quantifier connective mem f =
  case mkIndexVars (memType mem) of
    SomeIxs ixs ->
      let namesList = ixsToNames_unsafe ixs
      in
      quantifier (map (, "Int") namesList) $
        connective (mkBounds (memType mem) namesList)
          (f (ixsToList ixs))

forEach :: Memory -> ([String] -> SMT Name Bool) -> SMT Name Bool
forEach = quantifiedBy forAll implies

existsIx :: Memory -> ([String] -> SMT Name Bool) -> SMT Name Bool
existsIx = quantifiedBy exists (\_ y -> y) --(^&&^)

setToMemEntry :: Memory -> [String] -> MemEntry -> SMT Name Bool
setToMemEntry mem ixs entry =
  and'
    [ eq (selectWithList (symbol (memAmpName mem)) (map var ixs))
         (memEntryAmp entry)

    , eq (selectWithList (symbol (memPhaseName mem)) (map var ixs))
         (memEntryPhase entry)

    , eq (selectWithList (symbol (memBitVecName mem)) (map var ixs))
         (bvSMT (memEntryBitVec entry))
    ]

ensureMemType :: HasCallStack => Memory -> Int -> Memory
ensureMemType mem size = ensureType mem (memType mem) size

ensureType :: HasCallStack => a -> MemType -> Int -> a
ensureType r mty@(EN ty) size
  | length ty >= size = r -- TODO: Is '>=' right?
  | otherwise = error $ "Expected EN(" <> show (length ty) <> "), got EN(" <> show size <> ")"

