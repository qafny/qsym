--
-- Linear transformations, and tensor products of them
--

{-# LANGUAGE ScopedTypeVariables #-}

module QSym.Logic.Linear 
  where

import Data.List

type Vector a = [a]
newtype Matrix f a = Matrix (f (Vector a))

dot :: Num a => Vector a -> Vector a -> a
dot u = sum . zipWith (*) u

class Equate m a where
  equate :: a -> a -> m

-- columns :: Matrix f a -> Matrix f a
-- columns = transpose

columns :: Matrix f a -> Matrix f a
columns = id

multColumn :: Num a => Matrix f a -> Vector a -> Vector a
multColumn m v =
  fmap sum $
  columns $
  zipWith (\x -> map (*x))
          v
          (columns m)

-- multRow :: Num a => Vector a -> Matrix f a -> Vector a
-- multRow v m = multColumn (transpose m) v

matMult :: Num a => Matrix f a -> Matrix f a -> Matrix f a
matMult m n =
  columns $
  [ multColumn m u
  | u <- columns n
  ]

-- scalarMult :: Num a => a -> Matrix a -> Matrix a
-- scalarMult a = map (map (*a))
--
-- --     [[ [a, b, c], [d, e, f] ], [ [1,2,3], [4,5,6] ]]
-- -- --> [[a, b, c, 1, 2, 3], [d, e, f, 4, 5, 6]]
-- flattenMatrix :: Matrix (Matrix a) -> Matrix a
-- flattenMatrix = map concat . transpose . (map concat) . transpose
--
-- -- Kronecker product of two matrices
-- tensor :: forall a. Num a => Matrix a -> Matrix a -> Matrix a
-- tensor m n = flattenMatrix r
--   where
--     r :: Matrix (Matrix a)
--     r = map (map (`scalarMult` n)) m
--
-- identity :: Num a => Int -> Matrix a
-- identity size | size < 0 = error $ "identity: negative size " ++ show size
-- identity size = go size
--   where
--     go 0 = []
--     go i = mkRow size i : go (i-1)
--
--     mkRow 0 _ = []
--     mkRow n i =
--       if n == i
--       then 1 : mkRow (n-1) i
--       else 0 : mkRow (n-1) i
--
-- zeroes :: Num a => Int -> Matrix a
-- zeroes size | size < 0 = error $ "zeroes: negative size " ++ show size
-- zeroes size = replicate size (replicate size 0)
--
