module QSym.Logic.Heap
  (Heap
  ,heapEntangled
  ,heapMapping
  ,emptyHeap
  ,updateHeapMapping
  ,entangle
  )
  where

import QSym.Logic.SMT

import Data.List
import Data.Function

type Loc = String

data Heap =
  Heap
    { heapEntangled :: [[Loc]]
    , heapMapping :: [(Loc, SMT String Int)]
    }
  deriving (Show)

emptyHeap :: Heap
emptyHeap = Heap mempty mempty

updateHeapMapping :: Heap -> Loc -> SMT String Int -> Heap
updateHeapMapping heap loc newVal =
  heap
    { heapMapping = (loc, newVal) : deleteBy ((==) `on` fst) (loc, undefined) (heapMapping heap)
    }

-- TODO: Improve efficiency if necessary
entangle :: Heap -> Loc -> Loc -> Heap
entangle heap x y =
  let entangled = [x, y] : heapEntangled heap
  in
  heap
    { heapEntangled = filter (not . null) (nub (concat (go <$> entangled <*> entangled)))
    }
  where
    go as bs
      | x `elem` as && y `elem` bs = [as ++ bs, []]
      | otherwise = [as, bs]

