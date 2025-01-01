{-# LANGUAGE OverloadedStrings #-}

module QSym.Logic.GenConstraint
  (Name
  ,Verify (..)
  ,VerifySatisfies
  ,astSMT
  ,toplevelEnv
  ,toplevelSmt
  ,sumsToSmt
  )
  where

import Prelude hiding (div)

import QSym.Logic.Syntax
import QSym.Logic.SMT
import QSym.Logic.Name
import QSym.Logic.Gen
import QSym.Logic.Memory
import QSym.Logic.Builtins
import QSym.Logic.IR as IR
-- import QSym.Logic.Operation
-- import QSym.Logic.Builtins
-- import QSym.Logic.Linear

import Qafny.Syntax.AST hiding (Range (..), Block)
import qualified Qafny.Syntax.AST as Qafny
import Qafny.Syntax.Subst

import Data.Sum

import Data.Ord

import Control.Monad
import Control.Monad.Reader
import Control.Monad.State
import Data.String
import Data.List

import Prettyprinter

import Debug.Trace

astSMT :: Verify -> Int -> AST -> ([Sum], Block Name)
astSMT verify bitSize ast =
  (sums, smtPreamble <> mkDeclarations block <> block <> smtCheck)
     -- <> smtBlock [symbol "(get-info :reason-unknown)", checkSAT, symbol "(get-unsat-core)"]
  where
    (sums, block) = astConstraints verifyEqs bitSize ast

    smtCheck =
      smtBlock
        [checkSAT
        ,symbol "(get-info :reason-unknown)"
        ,getModel
        -- ,symbol "(get-unsat-core)"
        ]

    verifyEqs :: VerifySatisfies
    verifyEqs =
      case verify of
            -- TODO: Implement this for testing specific values
        -- ExactValues initialState -> mconcat $ zipWith toMemEq [0..] initialState
        Satisfies prop -> prop --(currentVar "mem") $ getLastMem block 
        _ -> \_ _ -> pure mempty

    toMemEq :: Int -> SMT Name Int -> Block Name
    toMemEq i v =
      smtBlock
        [assert $ eq (select (symbol (currentVar "mem")) (mkLoc i)) v]

-- getQubit :: String -> Int -> Gen (SMT Name Int)
-- getQubit var varIx = undefined

-- getTotalProbForVar :: String -> Int -> BitVector Name -> SMT Name (Array Int Int) -> Gen (SMT Name Int)
-- getTotalProbForVar var shift bitVec mem = do
--   totalBits <- fmap envBitSize ask
--
--   base <- getVarBaseIndex var
--
--   let prefixSize = shift + base
--       postfixSize = totalBits - prefixSize - bitVectorSize bitVec
--
--       allPrefixes = allPossibleBitVectors prefixSize
--       allPostfixes = allPossibleBitVectors postfixSize
--       allCircumfixes = do
--         prefix <- allPrefixes
--         postfix <- allPostfixes
--         pure (prefix, postfix)
--
--       paste (pre, post) = bvConcat [pre, bitVec, post]
--
--       allPossibilities = map paste allCircumfixes
--
--   pure $ sum (map (selectWithBitVector mem) allPossibilities)

astConstraints :: VerifySatisfies -> Int -> AST -> ([Sum], Block Name)
astConstraints verify bitSize =
  mconcat . map (toplevelSmt verify bitSize)

initialMemory :: Int -> Memory
initialMemory bitSize =
  mkMemory
    (EN [2 ^ bitSize])
    bitSize
    (currentVar "mem-amp")
    (currentVar "mem-phase")
    (currentVar "mem-bit-vec")

sumsToSmt :: VerifySatisfies -> Env -> [Sum] -> Block Name
sumsToSmt verify env sums =
  let bitSize = envBitSize env
      initialMem = initialMemory bitSize
  in
  runGen (sumsToSmtM verify env sums) env initialMem

sumsToSmtM :: VerifySatisfies -> Env -> [Sum] -> Gen (Block Name)
sumsToSmtM verify env sums = do
  let bitSize = envBitSize env
      initialMem = initialMemory bitSize
      initialDecls = declareMemory bitSize initialMem
  mainPart <- traverse (sumToSMTGen bitSize) sums
  lastMem <- get
  fmap ((initialDecls <> mconcat mainPart) <>) (verify initialMem lastMem)

toplevelEnv :: Int -> Toplevel () -> Env
toplevelEnv bitSize (Toplevel (Inl qm)) = buildEnv bitSize qm

toplevelSmtM :: VerifySatisfies -> Int -> Toplevel () -> Gen ([Sum], Block Name)
toplevelSmtM verify bitSize toplevel@(Toplevel (Inl qm)) =
  case qmBody qm of
    Just block -> do
      sums <- blockListConstraints (inBlock block)
      block <- sumsToSmtM verify (toplevelEnv bitSize toplevel) sums
      pure (sums, block)

toplevelSmt :: VerifySatisfies -> Int -> Toplevel () -> ([Sum], Block Name)
toplevelSmt satisfies bitSize toplevel =
  let env = toplevelEnv bitSize toplevel
      initialMem = initialMemory bitSize
  in
  runGen (toplevelSmtM satisfies bitSize toplevel) env initialMem

blockListConstraints :: [Stmt ()] -> Gen [Sum]
-- blockListConstraints [] = pure mempty
blockListConstraints xs = mconcat <$> traverse blockConstraints xs

-- TODO: Separate out the `State` part from `Gen` and use the part without
-- it here.
blockConstraints :: Stmt () -> Gen [Sum]
blockConstraints (SAssert {}) = pure mempty -- TODO: Should we handle this?
blockConstraints (SCall f xs) = error "SCall"
blockConstraints (SVar {}) = error "SVar: unimplemented" -- TODO: Implement
blockConstraints (_ ::=: EMeasure _) = pure mempty -- TODO: Implement

blockConstraints (_ ::=: _) = error "::=: unimplemented" -- TODO: Implement

-- TODO: Generalize to applying Hadamard to more than one location
blockConstraints (Partition [lhs] :*=: EHad) = do
  (physStart, physEnd) <- rangeToPhysicalIndices lhs
  pure [hadamard physStart]

  -- genOperationBlock (hadamard physStart)
blockConstraints (SDafny _) = pure mempty

-- TODO: Generalize this
blockConstraints (SIf guardExp@(GEPartition part Nothing) part' (Qafny.Block body)) = do
  bodyConstraints <- blockListConstraints body

  let Partition [controlRange] = part
  (physStartControl, physEndControl) <- rangeToPhysicalIndices controlRange

  pure $ map (withControlBit physStartControl) bodyConstraints

blockConstraints (x :*=: ELambda (LambdaF { bBases = [param], ePhase = phase, eBases = [lambdaBody] })) = do
  let Partition [bodyRange] = x
  (physStartBody, physEndBody) <- rangeToPhysicalIndices bodyRange

  let bodySum = convertLambda param physStartBody physEndBody lambdaBody
      updatedPhaseSum = withPhaseFunction (convertPhaseExp param phase) bodySum

  pure [bodySum]

blockConstraints (SIf (GClass boolExp) part (Qafny.Block body)) =
    -- TODO: Implement the control here
  blockListConstraints body

blockConstraints s = error $ "unimplemented: " ++ show s

convertPhaseExp :: Var -> PhaseExp -> (Expr Int -> Expr Int)
convertPhaseExp param PhaseWildCard e = e
convertPhaseExp param PhaseZ e = e
convertPhaseExp param (PhaseOmega x y) e =
  trace ("PhaseOmega " ++ show (x, y)) e

convertLambda :: Var -> Int -> Int -> Exp () -> Sum
convertLambda param startQubit endQubit body =
  unaryIntOp (convertLambdaBody param body) startQubit endQubit

convertLambdaBody :: Var -> Exp () -> (Expr Int -> Expr Int)
convertLambdaBody param (ENum i) _ = intLit i
convertLambdaBody param (EVar v) arg
  | v == param = arg
  | otherwise = error $ "convertLambdaBody: EVar " ++ show v
convertLambdaBody param (EOp1 op x) arg = convertOp1 param op x arg
convertLambdaBody param (EOp2 op x y) arg = convertOp2 param op x y arg

convertOp1 :: Var -> Op1 -> Exp () -> (Expr Int -> Expr Int)
convertOp1 param ONeg x arg = neg (convertLambdaBody param x arg)

convertOp2 :: Var -> Op2 -> Exp () -> Exp () -> (Expr Int -> Expr Int)
convertOp2 param op x y arg =
  case op of
    OAdd -> go IR.add
    OSub -> go IR.sub
    OMul -> go IR.mul
    OMod -> go IR.modulo
  where
    go f = f (convertLambdaBody param x arg) (convertLambdaBody param y arg)

-- smtBinOp ::
--   (BitVector Name -> BitVector Name -> BitVector Name) ->
-- smtBinOp op = undefined


-- TODO: Move to another module --

toMemEntry :: Expr EVec -> MemEntry
toMemEntry vec =
  let (x, y, z) = unMkVec vec
  in
  MemEntry
    (realToSMT x)
    (realToSMT y)
    (bitVecToSMT z)

fromMemEntry :: MemEntry -> Expr EVec
fromMemEntry (MemEntry x y z) =
  mkVec (IR.mkSMT x)
        (IR.mkSMT y)
        (IR.mkSMT z)

sumToSMTGen :: Int -> Sum -> Gen (Block Name)
sumToSMTGen bitSize sum = do
  mem <- get
  let (mem', smt) = sumToSMT mem sum
  let memDecl = declareMemory bitSize mem'
  put mem'
  pure (memDecl <> one (assert smt))

sumToSMT :: Memory -> Sum -> (Memory, SMT Name Bool)
sumToSMT mem (Sum bounds f) =
  (mem', smt)
  where
    mem' = extendMemory mem (EN bounds) step

    smt =
      forEach mem' $ \ixs ->
        let (oldIxs, newIxs) = splitAt (memTypeSize (memType mem)) ixs
            oldEntry = indexMemoryByList mem oldIxs
            Controlled fControl fBody = f (fromMemEntry oldEntry) (map IR.var newIxs)
        in
        setToMemEntry mem' ixs (toMemEntry fBody)

-- allPossibleBitVectors :: IsString a => Int -> [BitVector a]
-- allPossibleBitVectors size = map (int2bv size . int) [0 .. 2 ^ size]
--
-- -- TODO: Generalize to partitions with more than one element
-- interpretGuardExp :: String -> GuardExp -> Gen (SMT Name Int -> SMT Name Bool)
-- interpretGuardExp paramName (GEPartition (Partition [range]) expMaybe) = do
--   (physStart, physEnd) <- rangeToPhysicalIndices range
--   totalBits <- fmap envBitSize ask
--   let bitCount = physEnd - physStart
--   let partPredicate arg =
--           not' (eq (bv2nat (bvGetRange (int2bv totalBits arg) (bvPosition physStart) (bvPosition physEnd)))
--                (int 0))
--
--   let expPredicate arg =
--         case expMaybe of
--           Nothing -> true
--           Just exp -> interpretBoolFn paramName exp arg
--
--   trace ("range = " ++ show (physStart, physEnd)) $ pure $ \arg -> partPredicate arg ^&&^ expPredicate arg
--
-- interpretIntFn :: String -> Exp () -> (SMT Name Int -> SMT Name Int)
-- interpretIntFn paramName = go
--   where
--     go (ENum i) = \_ -> int i
--     go (EVar v)
--       | v /= paramName = error $ "Unknown variable: " ++ show v
--       | otherwise = \arg -> arg
--     go (EOp1 op x) = \arg -> interpretIntOp1 op (go x arg)
--     go (EOp2 op x y) = \arg -> interpretIntOp2 op (go x arg) (go y arg)
--
-- interpretBoolFn :: String -> Exp () -> (SMT Name Int -> SMT Name Bool)
-- interpretBoolFn paramName = go
--   where
--     go (EBool True) = \_ -> true
--     go (EBool False) = \_ -> false
--     go (EOp1 op x) = \arg -> interpretBoolOp1 op (go x arg)
--     go (EOp2 op x y) =
--       case op2ArgType op of
--         IntType -> \arg -> interpretIntBoolOp2 op (interpretIntFn paramName x arg) (interpretIntFn paramName y arg)
--         BoolType -> \arg -> interpretBoolBoolOp2 op (go x arg) (go y arg)
--
-- interpretInt :: Exp () -> SMT Name Int
-- interpretInt (ENum i) = int i
-- interpretInt (EVar v) = symbol $ mangleName v
-- interpretInt (EOp1 op x) = interpretIntOp1 op (interpretInt x)
-- interpretInt (EOp2 op x y) = interpretIntOp2 op (interpretInt x) (interpretInt y)
--
-- interpretBool :: Exp () -> SMT Name Bool
-- interpretBool (EBool True) = true
-- interpretBool (EBool False) = false
-- interpretBool (EOp1 op x) = interpretBoolOp1 op (interpretBool x)
-- interpretBool (EOp2 op x y) =
--   case op2ArgType op of
--     IntType -> interpretIntBoolOp2 op (interpretInt x) (interpretInt y)
--     BoolType -> interpretBoolBoolOp2 op (interpretBool x) (interpretBool y)
--
-- interpretBoolOp1 :: Op1 -> (SMT Name Bool -> SMT Name Bool)
-- interpretBoolOp1 ONot = not'
--
-- interpretIntOp1 :: Op1 -> (SMT Name Int -> SMT Name Int)
-- interpretIntOp1 ONeg = negate
--
-- data ArgType = IntType | BoolType
--
-- op2ArgType :: Op2 -> ArgType
-- op2ArgType OAdd = IntType
-- op2ArgType ODiv = IntType
-- op2ArgType OSub = IntType
-- op2ArgType OMul = IntType
-- op2ArgType OMod = IntType
-- op2ArgType OAnd = BoolType
-- op2ArgType OOr = BoolType
-- op2ArgType OLt = IntType
-- op2ArgType OLe = IntType
-- op2ArgType OGt = IntType
-- op2ArgType OGe = IntType
-- op2ArgType OEq = IntType
--
-- interpretIntOp2 :: Op2 -> (SMT Name Int -> SMT Name Int -> SMT Name Int)
-- interpretIntOp2 OAdd = add
-- interpretIntOp2 ODiv = div
-- interpretIntOp2 OSub = sub
-- interpretIntOp2 OMul = mul
-- interpretIntOp2 OMod = mod'
--
-- interpretBoolBoolOp2 :: Op2 -> (SMT Name Bool -> SMT Name Bool -> SMT Name Bool)
-- interpretBoolBoolOp2 OAnd = (^&&^)
-- interpretBoolBoolOp2 OOr = (^||^)
-- interpretBoolBoolOp2 ONor = \x y -> not' (x ^||^ y)
--
-- interpretIntBoolOp2 :: Op2 -> (SMT Name Int -> SMT Name Int -> SMT Name Bool)
-- interpretIntBoolOp2 OLt = lt
-- interpretIntBoolOp2 OLe = lte
-- interpretIntBoolOp2 OGt = gt
-- interpretIntBoolOp2 OGe = gte
-- interpretIntBoolOp2 OEq = eq
--
-- mangleName :: String -> Name
-- mangleName = BuiltinName . (<>"_")
--
-- applyLambda :: LambdaF (Exp ()) -> Exp () -> Exp ()
-- applyLambda (LambdaF { bBases = [paramVar], eBases = [body] }) arg =
--   subst [(paramVar, arg)] body

type VerifySatisfies =
  Memory -> -- Input
  Memory -> -- Output
  Gen (Block Name)

data Verify
  = ExactValues [(String, [SMT Name Int])]
  | Satisfies VerifySatisfies

heapType :: String
heapType = "(Array Int Real)"
-- heapType = "(Array Int (Array Int Real))"

bitVecSize :: Int
bitVecSize = 4

bitVecType :: String
bitVecType = "(_ BitVec " ++ show bitVecSize ++ ")"

bitVecArrayType :: String
bitVecArrayType = "(Array Int " ++ bitVecType ++ ")"

bitVecLit :: String -> SMT Name Int
bitVecLit i = fromString $ "(_ bv" ++ i ++ " " ++ show bitVecSize ++ ")"

mkLoc :: Int -> SMT Name a
mkLoc i = fromString (show i) --fromString $ "q" ++ show i

mkDeclarations :: Block Name -> Block Name
mkDeclarations block =
  let blockNames = getBlockNames block
      memNames = map VarName . nub $ getSteppedVar "mem" blockNames
      memVecNames = map VarName . nub $ getSteppedVar "mem-vecs" blockNames
  in
  declareConstList (zip memNames (repeat (fromString heapType)))
    <>
  declareConstList (zip memVecNames (repeat (fromString (fromString bitVecArrayType))))

