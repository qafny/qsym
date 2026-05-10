{-# LANGUAGE CPP, AllowAmbiguousTypes #-}

module Main where

import Prelude hiding (div)

-- required for utf-8 text file enforcement
import qualified Data.Text.IO.Utf8 as Utf8
import qualified Data.Text as Text

import QSym.Monad
import QSym.Interpret
import QSym.Syntax
import QSym.Logic.GenConstraint (Verify (..), VerifySatisfies, astSMT, Name)
import QSym.Logic.Gen (Gen)
import QSym.Logic.SMTBackend
import QSym.Logic.Memory
import QSym.Logic.SMT as SMT --(int, SMT, Decl)

import Qafny.Syntax.Parser
import Qafny.Syntax.AST hiding (Block)
import qualified Qafny.Syntax.AST as AST
import Qafny.TTG

import Data.String

import Data.Sum

import Data.List (find)

import Prettyprinter

import qualified QSym.Syntax as QSym

import Debug.Trace

-- Bell pair example:
--
--
-- q[0] ---> [H] --+------->
--                 |
--                 |
--                 v
-- q[1] --------> (+) ----->


-- TODO: Support for non-unit lists
interpretQafny :: AST -> QSym.Expr
interpretQafny [Toplevel (Inl x)] =
  let Just body = qmBody x
  in
  interpretBlock body

interpretBlock :: AST.Block () -> QSym.Expr
interpretBlock (AST.Block xs) = foldr1 QSym.Seq (map interpretStmt xs)

interpretStmt :: Stmt () -> QSym.Expr
interpretStmt (x :*=: y) = undefined
interpretStmt (SIf cond partition block) = undefined

interpretExpr :: Exp () -> QSym.Expr
interpretExpr EHad = undefined
interpretExpr (EOp2 OAdd x y) = undefined

data Test =
  Test
    { testName :: String
    , testFile :: String
    , testQubitCount :: Int
    , testVerify :: VerifySatisfies
    }

lookupTest :: [Test] -> String -> Test
lookupTest tests name =
  let Just r = find ((== name) . testName) tests
  in
  r

allTests :: [Test]
allTests =
  [ Test
      { testName = "Teleportation"
      , testFile = "tests/Teleportation.qfy"
      , testQubitCount = 3
      , testVerify = \_ _ -> pure $ smtBlock [assert true] -- TODO
      }

  , Test
      { testName = "BellPair"
      , testFile = "tests/BellPair.qfy"
      , testQubitCount = 2
      , testVerify = verifyBellPair 2
      }
  ]

main :: IO ()
main = do
  -- let test = lookupTest allTests "BellPair"
  let test = lookupTest allTests "Teleportation"

  -- TODO: read filename in from the command line

  -- file_text <- Utf8.readFile "tests/BellPair.qfy"
  file_text <- Utf8.readFile (testFile test)

  -- read in the qafny code and convert into an AST
  -- unpack converts Data.Text.Text (from Utf8.readFile) to a String
  let qafny_ast = (scanAndParse . Text.unpack) file_text 

  print qafny_ast
  -- TODO: potentially add more context to this error message such as filename

  -- let smt = either error (astSMT [[int 1, int 0], [int 1, int 0]] 3) qafny_ast
  -- let smt = either error (astSMT (ExactValues [int 1, int 0, int 1, int 0]) 3) qafny_ast
  let (sums, smt) = either error (astSMT (Satisfies (testVerify test)) (testQubitCount test)) qafny_ast

  print $ pretty sums

  -- either error (print . pretty) smt

  -- print $ pretty smt
  executeSMTLoudly z3Config smt
  pure ()

vectorExactlyEqual :: Int -> Memory -> Int -> Maybe (SMT Name Int) -> Maybe (SMT Name Int) -> SMT Name Decl
vectorExactlyEqual bitSize mem bitVec0 amp phase =
  let bitVec = int bitVec0
  in
  assert $ forEach mem $ \ixs ->
    let entry = indexMemoryByList mem ixs
    in
    implies (eq (bvSMT (memEntryBitVec entry)) (bvSMT (int2bv bitSize bitVec)))
            (and' $ concat
              [eqMaybe (memEntryAmp entry) amp
              ,eqMaybe (memEntryPhase entry) phase
              ])
  where
    eqMaybe x (Just y) = [eq x y]
    eqMaybe _ Nothing = []

verifyBellPair :: Int -> VerifySatisfies
verifyBellPair bitSize input output = do
  pure $ smtBlock
    [ -- Input
      -- vectorExactlyEqual bitSize input 0x0 (Just 1) Nothing


    --   -- Output
    -- , vectorExactlyEqual bitSize output 0x0 (Just (ampFactor 1)) Nothing
    -- , vectorExactlyEqual bitSize output 0x3 (Just (ampFactor 1)) Nothing


      -- assert $ existsIx input $ \ixs ->
      --   let entry = indexMemoryByList input ixs
      --   in
      --   eq (bvSMT (memEntryBitVec entry))
      --      (bvSMT (int2bv 2 0x0))
      --   
      -- -- assert $ setToMemEntry input [int 0]
      -- --           $ MemEntry
      -- --               { memEntryAmp = 1
      -- --               , memEntryPhase = 1
      -- --               , memEntryBitVec = int2bv 2 0x0
      -- --               }

      -- Output
      -- TODO: Improve the interface used here

    -- , assert $ existsIx input $ \ixs ->
    --     let entry = indexMemoryByList input ixs
    --     in
    --     eq (bvSMT (memEntryBitVec entry))
    --               (bvSMT (int2bv 2 0x0))

    -- , assert $ existsIx output $ \ixs ->
    --     let entry = indexMemoryByList output ixs
    --     in
    --     eq (bvSMT (memEntryBitVec entry))
    --               (bvSMT (int2bv 2 0x3))

    -- , assert $ forEach output $ \ixs ->
    --     let entry = indexMemoryByList output ixs
    --     in
    --     implies (eq (bvSMT (memEntryBitVec entry))
    --                 (bvSMT (int2bv 2 0x0)))
    --
    --             (eq (memEntryPhase entry)
    --                 invSqrt2)
    --
    -- , assert $ forEach output $ \ixs ->
    --     let entry = indexMemoryByList output ixs
    --     in
    --     implies (eq (bvSMT (memEntryBitVec entry))
    --                 (bvSMT (int2bv 2 0x3)))
    --
    --             (eq (memEntryPhase entry)
    --                 invSqrt2)
    ]

