{-# LANGUAGE LambdaCase #-}

{-# OPTIONS_GHC -Wincomplete-patterns #-}

module QSym.Interpret
  where

import Prelude hiding (reverse)

import QSym.Syntax
-- import QSym.QState
import QSym.Utils
import QSym.Monad

import Data.Bits (countLeadingZeros, bitSizeMaybe, FiniteBits)

import qualified Data.Bits as Bits

import Numeric.Natural


-- need to add an other map, one is a function map, mapping from fvar to closure
-- modify env from var to C / Q (int), 
-- there are two types, C type or Q (int) types,
--

interpret :: Expr -> QSym ()
interpret expr =
  case expr of
    SKIP -> pure ()

    X p -> do
      v <- stateGet (posiVar p)
      update (posiVar p) (exchange v (posiInt p))

    CU p e' -> do
      v <- stateGet (posiVar p)
      if getCUA v (posiInt p)
      then interpret e'
      else pure ()

    RZ q p0 -> do
      p <- stateGet (posiVar p0)
      n <- envGet (posiVar p0)
      update (posiVar p0) =<< timesRotate p n q

    RRZ q p0 -> do
      p <- stateGet (posiVar p0)
      n <- envGet (posiVar p0)
      update (posiVar p0) =<< timesRotateR p n q

    SR n x -> do
      size <- envGet x
      v <- stateGet x
      update x (srRotate v n size)

    SRR n x -> do
      size <- envGet x
      v <- stateGet x
      update x (srrRotate v n size)

    QFT x b -> do
      size <- envGet x
      v <- stateGet x
      update x (turnQFT v (size - b)) 

    RQFT x b -> do
      size <- envGet x
      v <- stateGet x
      update x (turnRQFT v (size - b)) 

    Rev x -> do
      v <- stateGet x
      update x =<< reverse v x

    Lshift x -> do
      v <- stateGet x
      update x =<< lshift v x

    Rshift x -> do
      v <- stateGet x
      update x =<< rshift v x

    Seq e1 e2 -> do
      interpret e1
      interpret e2

-- inverses an `Expr` syntax tree. Equivalent to inv_exp in the VQO code.
invExpr :: Expr -> Expr
invExpr e0 =
  case e0 of
    SKIP -> SKIP
    X n -> X n
    CU n p -> CU n (invExpr p)
    SR n x -> SRR n x
    SRR n x -> SR n x
    Lshift x -> Rshift x
    Rshift x -> Lshift x
    Rev x -> Rev x
    RZ q p -> RRZ q p
    RRZ q p -> RZ q p
    QFT x b -> RQFT x b
    RQFT x b -> QFT x b
    Seq p1 p2 -> Seq (invExpr p2) (invExpr p1)

-- Controlled NOT gate on the second posi by the first.
cnot :: Posi -> Posi -> Expr
cnot x y = CU x (X y)

ccx :: Posi -> Posi -> Posi -> Expr
ccx x y z = CU x (cnot y z)

exchange :: Value -> Natural -> Value
exchange (NVal b r) p = NVal (complementBit b p) r
exchange v _ = v

srRotate :: Value -> Natural -> Natural -> Value
srRotate (NVal b  r) _ _ = (NVal b r)
srRotate (QVal rc r) q n = QVal rc (r+(2^(n-1-q)))

srrRotate :: Value -> Natural -> Natural -> Value
srrRotate (NVal b r) q _ = (NVal b r)
srrRotate (QVal rc r) q n = QVal rc (r `rzSubtract` (2^(n-1-q)))

getCUA :: Value -> Natural -> Bool
getCUA (NVal b _) p = b ! p
getCUA (QVal {}) p = False

timesRotate :: Value -> Natural -> Natural -> QSym Value
timesRotate (NVal b r) n q = do
  if b ! n
    then pure $ NVal b (rotate q r) --(r+(2^(n-1-q)))
    else pure $ NVal b r

timesRotate (QVal rc r) n q = do
  pure $ QVal rc (r+(2^(n-1-q)))

-- timesRotateR :: Value -> Natural -> Natural -> QSym Value
-- timesRotateR (NVal b r) n q = pure $ if b ! n then NVal b (r `rzSubtract` (2^(n-1-q))) else NVal b r
-- timesRotateR (QVal rc r) n q = pure $ QVal rc (r `rzSubtract` (2^(n-1-q)))


timesRotateR :: Value -> Natural -> Natural -> QSym Value
timesRotateR (NVal b r) n q = pure $ if b ! n then NVal b (if r > (2^(n-1-q)) then r - (2^(n-1-q)) else r + 2^n - (2^(n-1-q))) else NVal b r
timesRotateR (QVal rc r) n q = pure $ QVal rc (if r > (2^(n-1-q)) then r - (2^(n-1-q)) else r + 2^n - (2^(n-1-q)))


cutN :: RzValue -> Natural -> RzValue
cutN (RzValue _sz f) newSz = RzValue newSz f

-- RzValue $ \i ->
--   if i < n
--   then r ! i
--   else False

-- -- fbrev :: Natural -> RzValue -> RzValue
-- -- fbrev n r =
-- --  mapBitsBelow n r $ \i ->
--     -- r ! (n - 1 - i)
-- -- RzValue $ \x ->
-- --   if x < n
-- --   then r ! (n - 1 - x)
-- --   else r ! x
--
-- -- sumfb :: Bool -> RzValue -> RzValue -> RzValue
-- -- sumfb b f g = undefined -- TODO: Implement
-- -- RzValue $ \x ->
-- --   carry b x f g `xor` (f ! x) `xor` (g ! x)
--
-- -- carry :: Bool -> Natural -> RzValue -> RzValue -> Bool
-- -- carry b n f g =
-- --  case n of
-- --    0 -> b
-- --    _ ->
-- --      let n' = n - 1
-- --          c = carry b n' f g
-- --          a = f ! n'
-- --          b = g ! n'
-- --      in
-- --      (a && b) `xor` (b && c) `xor` (a && c)
--
-- --xor :: Bool -> Bool -> Bool
-- --xor = (/=)

lshift :: Value -> Var -> QSym Value
lshift (NVal v r) x = do
  n <- envGet x
  pure $ NVal (shiftLeft v n) r

lshift (QVal v r) x = do
  pure $ QVal v r

rshift :: Value -> Var -> QSym Value
rshift (NVal v r) x = do
  n <- envGet x
  pure $ NVal (rotate n v) r

rshift (QVal v r) x = pure $ QVal v r

reverse :: Value -> Var -> QSym Value
reverse (NVal v r) x = do
  n <- envGet x
  pure $ NVal (complementBit v n) r
reverse (QVal v r) x = pure (QVal v r)

-- TODO:maybe fix, its ok for now
turnQFT :: Value -> Natural -> Value
turnQFT (NVal v r) n = QVal r (rotate n v)
turnQFT (QVal v r) n = QVal v r

turnRQFT :: Value -> Natural -> Value
turnRQFT (NVal v r) n = NVal v r
turnRQFT (QVal rc r) n = NVal (shiftLeft r n) rc
--
-- assignSeq :: Var -> RzValue -> Natural -> QSym ()
-- assignSeq x vals 0 = pure ()
-- assignSeq x vals n = do
--   let m = n - 1
--       p = Posi x m
--
--   r <- getR <$> atPosi p
--   assignSeq x vals m
--   update p (NVal (vals ! m) r)
--
-- -- A function to get the rotation angle of a state.
-- getR :: Value -> RzValue
-- getR (NVal _ r) = r
-- getR (QVal rc _) = rc
--
-- assignHR :: Var -> Natural -> Natural -> QSym ()
-- assignHR = assignH -- TODO: Is this right?
--
-- getRQFT :: Var -> QSym RzValue
-- getRQFT st x =
--   case atPosi st (Posi x 0) of
--     QVal rc g -> g
--     NVal {} -> allFalse
--
-- assignR :: Var -> RzValue -> Natural -> QSym ()
-- assignR _x _r 0 = pure ()
-- assignR x r n = do
--   let m = n - 1
--       p = Posi x m
--
--   assignR x r m
--
--   y <- atPosi p
--
--   update p (upQFT y (lshiftFun r m))
--
-- assignH :: Var -> Natural -> Natural -> QSym ()
-- assignH f _x _n 0 = f
-- assignH f x n i = do
--   let m = n - 1
--       p = Posi x (n+m)
--
--   y <- atPosi f p
--   assignH f x n m
--
--   update p (upH y)
--
-- upH :: Value -> Value
-- upH (NVal True r) = QVal r (rotate allFalse 1)
-- upH (NVal False r) = QVal r allFalse
-- upH (QVal r f) = NVal (f ! 0) r
--
-- lshiftFun :: RzValue -> Natural -> RzValue
-- lshiftFun = shiftR
-- -- lshiftFun f n = f `shiftL` n --RzValue $ \i -> f ! (i+n)
--
-- upQFT :: Value -> RzValue -> Value
-- upQFT (NVal b r) f = QVal r f
-- upQFT a          _ = a
--
-- negatem :: Natural -> RzValue -> RzValue
-- negatem i f =
--   mapBitsBelow i f $ \x ->
--     not (f ! x)
-- -- RzValue $ \x ->
-- --   if x < i
-- --   then not (f ! x)
-- --   else f ! x

-- nat2fb :: Natural -> RzValue
-- nat2fb 0 = allFalse
-- nat2fb p | p > 0 = pos2fb p
-- nat2fb p = error $ "nat2fb: got negative argument: " ++ show p

-- -- | Precondition: Argument must be positive
-- pos2fb :: Natural -> RzValue
-- pos2fb 1 = fbPush True allFalse
-- pos2fb n =
--   let (b, n') = unconsBit n
--   in
--   fbPush b (pos2fb n')
--
-- fbPush :: Bool -> RzValue -> RzValue
-- fbPush b v = rzSetBit (v `shiftL` 1) 0 b
-- -- RzValue $ \case
-- --   0 -> b
-- --   n -> f ! (n - 1)
--
--
--
-- -- move the following to test, they are test cases
-- cnot :: Posi -> Posi -> Expr
-- cnot p1 p2 = CU p1 (X p2)
--
-- ccx :: Posi -> Posi -> Posi -> Expr
-- ccx p1 p2 p3 = CU p1 (cnot p2 p3)
--
-- maj a b c = Seq (cnot c b) (Seq (cnot c a) (ccx a b c))
--
-- uma a b c = Seq (ccx a b c) (Seq (cnot c a) (cnot a b))
--
-- majseq' = Fix (Var 0) (Var 1) [(Var 2), (Var 3), (Var 4)] (IFExp (BEq (AVar (Var 1)) (ANum 0))
--     (maj (Var 4) (Posi {posiVar = (Var 2), posiInt = (ANum 0)}) (Posi {posiVar = (Var 3), posiInt = (ANum 0)}))
--      (Seq (App (Var 0) [Minus (AVar (Var 1)) (ANum 1),(AVar (Var 2)),(AVar (Var 3)), (AVar (Var 4))])
--        (maj (Posi {posiVar = (Var 2), posiInt = (Minus (AVar (Var 1)) (ANum 1))}) (Posi {posiVar = (Var 3), posiInt = (AVar (Var 1))})
--           (Posi {posiVar = (Var 2), posiInt = (AVar (Var 1))}))))
--
-- umaseq' = Fix (Var 5) (Var 1) [(Var 2), (Var 3), (Var 4)] (IFExp (BEq (AVar (Var 1)) (ANum 0))
--     (uma (Var 4) (Posi {posiVar = (Var 3), posiInt = (ANum 0)}) (Posi {posiVar = (Var 2), posiInt = (ANum 0)}))
--      (Seq (uma (Posi {posiVar = (Var 2), posiInt = (Minus (AVar (Var 1)) (ANum 1))}) (Posi {posiVar = (Var 3), posiInt = (AVar (Var 1))})
--           (Posi {posiVar = (Var 2), posiInt = (AVar (Var 1))}))
--           (App (Var 5) [Minus (AVar (Var 1)) (ANum 1),(AVar (Var 2)),(AVar (Var 3)), (AVar (Var 4))])))
--           
-- adder n x y c = Seq (App (Var 0) [Minus (AVar x) (ANum 1), (AVar y), AVar c]) (App (Var 5) [Minus (AVar x) (ANum 1), (AVar y), AVar c])
--
-- rz_adder' x n size m = Fix (Var 6) (AVar n) [AVar x, AVar size, AVar m] 
--    (IFExp (BEq (AVar (Var 1)) (ANum 0)) 
--       (SKIP (Posi {posiVar = x, posiInt = (ANum 0)}))
--           (Seq (App (Var 6) [Minus (AVar n) (ANum 1),(AVar x),(AVar size), (AVar m)])
--             (IFExp (GBit (AVar m) (Minus (AVar n) (ANum 1))) (SR (Minus (AVar size) (AVar n)) x) (SKIP (Posi {posiVar = x, posiInt = (AVar Minus (AVar n) (ANum 1))})))))
--
-- rz_adder x n m = adder n x n n m
--
--
--
--
--
--
--
--
--
--
--
--
--
--
