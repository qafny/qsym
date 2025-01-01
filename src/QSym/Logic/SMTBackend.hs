-- a small wrapper over SMTLIB.Backends
{-# LANGUAGE OverloadedStrings #-} -- necessary for pretty printing SMT symbols
{-# OPTIONS_HADDOCK show-extensions #-}
{-|
Module      : QSym.Logic.SMTBackend
Description : Runs SMT Block statments
Portability : POSIX

= SMTBackend

This module is reponsible for managing the backend SMT Solver process. 
Whether this be cvc5, z3, or a different, external, solver.

== Getting Started

An example of using this backend to solve the first part of [this](https://cvc5.github.io/docs/cvc5-1.1.2/examples/quickstart.html) problem is below:

@
  import QSym.Logic.SMT
  import QSym.Logic.SMTBackend

  smt_block = smtBlock [setLogic "ALL"
  ,setOption ":produce-models" "true"
  ,setOption ":incremental" "true"
  ,setOption ":produce-unsat-cores" "true"
  ,setOption ":print-cores-full" "true"
  ,declareConst "x" "Real"
  ,declareConst "y" "Real"
  ,assert $ lt (int 0) (symbol "x")
  ,assert $ lt (int 0) (symbol "y")
  ,assert $ lt ((add (symbol "x") (symbol "y"))) (int 1)
  ,assert $ lte (symbol "x") (symbol "y")
  ,checkSAT]
  
  main = fmap print (executeSMT smt_block)
@
-}
module QSym.Logic.SMTBackend
  (
  -- helper data structures
   SATResult (..)
  ,getFirstResult
  ,isSatisfiable
  ,isUnsatisfiable
  ,isUnknown
  ,didError
  ,didErrorAt
  ,getErrorAt

  ,cvc5Config
  ,z3Config

  ,SMTResult -- you should not need to construct this type
  -- execution functions
  ,executeSMT
  ,executeSMTLoudly)
  where

-- modules necessary for interacting with QSym.Logic.SMT
import QSym.Logic.SMT (Block)
import Prettyprinter (pretty, Pretty, layoutCompact)
import Prettyprinter.Render.String (renderString)

import Data.String (IsString)

-- modules necessary for interacting with the backend solver
import qualified SMTLIB.Backends as Solver
import qualified SMTLIB.Backends.Process as SMTProcess -- we will be using the process backend, as cvc5 is still experimental

import Control.Monad (forM)

import Data.ByteString.Lazy.Char8 (unpack)
import qualified Data.ByteString.Lazy.Char8 as ByteString
import Data.ByteString.Builder (stringUtf8)

-- modules necessary for the implementation
import Text.Regex.TDFA

import QSym.Utils (indexed)

import Data.Map (Map)
import qualified Data.Map as Map

import Debug.Trace

{- Design:
   What might one want from an API?
    => submit all commands at once
      => swallow output, return results: `executeSMT`
      => stdout output, return results: `executeSMTLoudly`
    => Monadically submit commands and query their result
       This would allow you to check the results of each 
       command and react accordingly (i.e. get-unsat-cores 
       or get-value)

   ### Results from the SMT Solver:
   State after "(check-sat)": sat, unsat, or unknown 
   sat => 
     results of get-value
     results of get-assignment
   unsat => 
     results of get-proof
     results of get-unsat-cores
   potential errors/echo statements
     errors: (error "message")
     echo => "message"
   queries: 
     (1) get-assertions
     (2) get-option
     (3) get-info                                           -}

-----------------------------------------------------
-- Public API
-----------------------------------------------------

-- |SATResult corresponds to the three results that the SMTLIB v2 command "(check-sat)" can return
--  and serves as a return type for `executeSMT`
data SATResult = Satisfiable | Unsatisfiable | Unknown
    deriving (Read, Show, Enum, Eq, Ord)

-- |SMTResult represents the results of executing a block smt statement
-- Information includes:
--
--   * if any of the commands errored
--   * the results of check-sat, echo, get-value, get-assignment, get-proof, get-unsat-cores, get-assertions, get-option and get-info commands
data SMTResult = SMTResult { errors :: Map Int String -- ^ errors represents the errors returned from executing a block of smt statments as a map of the command's number (starting at 0) mapped to its error (as a string)
                           , satResults :: [SATResult] -- ^ satResults represents a list of all the results of the "check-sat" command, in the order in which it was called. Note: if a check-sat command fails, it will not be included in this list
                           }
    deriving (Read, Show, Eq)

-- |getFirstResult returns the first `SATResult` in the satResults array of an `SMTResult`.
-- Typically used for executions where only one check-sat command was run.
getFirstResult :: SMTResult -> SATResult
getFirstResult smt_result = (satResults smt_result)!!0

-- |isSatisfiable returns True if the first `SATResult` in the satResults array of an `SMTResult` is `Satisfiable`.
-- Typically used for executions where only one check-sat command was run.
isSatisfiable :: SMTResult -> Bool
isSatisfiable smt_result = (getFirstResult smt_result) == Satisfiable

-- |isUnsatisfiable returns True if the first `SATResult` in the satResults array of an `SMTResult` is `Unsatisfiable`.
-- Typically used for executions where only one check-sat command was run.
isUnsatisfiable :: SMTResult -> Bool
isUnsatisfiable smt_result = (getFirstResult smt_result) == Unsatisfiable

-- |isUnknown returns true if the first `SATResult` in the satResults array of an `SMTResult` is `Unknown`.
-- Typically used for executions where only one check-sat command was run.
isUnknown :: SMTResult -> Bool
isUnknown smt_result = (getFirstResult smt_result) == Unknown

-- |didError returns True if an error occured whilst executing the SMT commands.
didError :: SMTResult -> Bool
didError smt_result = Map.size (errors smt_result) > 0

-- |didErrorAt returns True if an error occured at the specified command number.
didErrorAt :: SMTResult -> Int -> Bool
didErrorAt smt_result index = Map.member index (errors smt_result)

-- |getError returns a `Maybe String` value given a command index that an error may have occured at.
getErrorAt :: SMTResult -> Int -> Maybe String
getErrorAt smt_result index = Map.lookup index (errors smt_result)

-- |executeSMT executes a block of SMT statments and returns information about its results. 
-- It will silently swallow any output from the SMT solver process. see its sibling: `executeSMTLoudly` if 
-- you want the output from the SMT solver to be printed to the command line.
-- It takes one argument, of type `Block`
-- It returns a value of type `SMTResult` 
executeSMT :: (IsString a, Pretty a) => SMTProcess.Config -> Block a -> IO SMTResult
executeSMT config smt_code = executeSMTWithHandler config smt_code executeSMTStatement

-- |executeSMTLoudly performs exactly the same as `executeSMT` but it also outputs any response from the solver to standard out.
executeSMTLoudly :: (IsString a, Pretty a) => SMTProcess.Config -> Block a -> IO SMTResult
executeSMTLoudly config smt_code = executeSMTWithHandler config smt_code executeSMTStatementLoudly

-----------------------------------------------------
-- Private Details
-----------------------------------------------------

-- |cvc5Config returns an `SMTLIB.Backends.Process.Config` that represents the settings for the cvc5 SMT solver. 
cvc5Config :: SMTProcess.Config
cvc5Config = SMTProcess.defaultConfig { SMTProcess.exe = "cvc5", SMTProcess.args = [] } -- defaultConfig for now, consider handling log messages in the future

z3Config :: SMTProcess.Config
z3Config = SMTProcess.defaultConfig

-- |CommandResult is an internal data type representing the value that a Solver.command can return
data CommandResult 
  = Success 
  | SAT SATResult 
  | Error String
  | Other String
  deriving (Read, Show, Eq)

-- |resultFromString converts from program output to `CommandResult`
resultFromString :: String -> CommandResult
resultFromString str
  | str =~ ("\\`success" :: String) :: Bool = Success
  | str =~ ("\\`sat" :: String) :: Bool     = SAT Satisfiable
  | str =~ ("\\`unsat" :: String) :: Bool   = SAT Unsatisfiable
  | str =~ ("\\`unknown" :: String) :: Bool = SAT Unknown
  | otherwise = let
      errorRegex = "\\(error \"([^\"]+)\"\\)" :: String
      (_, _, _, matches) = str =~ errorRegex :: (String, String, String, [String])
    in
      if (length matches) > 0 then
        Error (matches!!0)
      else
        Other str

-- |returns true if this command result is an error
isError :: CommandResult -> Bool
isError (Error _) = True
isError _ = False

-- |returns true if this command result is a SAT
isSat :: CommandResult -> Bool
isSat (SAT _) = True
isSat _ = False

-- |returns the string from the error message
getErrorMessage :: CommandResult -> String
getErrorMessage (Error msg) = msg
getErrorMessage _ = undefined

-- |returns the `SATResult` from a `SAT`
getSat :: CommandResult -> SATResult
getSat (SAT result) = result
getSat _ = undefined

-- |getErrors returns a map of the integer command number (starting at 0) to the string errors.
getErrors :: [CommandResult] -> Map Int String
getErrors results = Map.fromList $ map (\x -> (fst x, getErrorMessage (snd x))) $ filter (\x -> isError (snd x)) (indexed results)

-- |sats returns a list of the `SATResult`s in an array of `CommandResult`s
sats :: [CommandResult] -> [SATResult]
sats results = map (\x -> getSat x) $ filter (\x -> isSat x) results

-- |fromCommandResults returns an SMTResult from a list of CommandResult
fromCommandResults :: [CommandResult] -> SMTResult
fromCommandResults results = SMTResult (getErrors results) (sats results)

-- |executeSMTStatement executes a single statement (as a `String`) on an SMT solver and returns it's result of type `CommandResult`
executeSMTStatement :: Solver.Solver -> String -> IO CommandResult
executeSMTStatement solver statement = fmap (resultFromString . unpack) (Solver.command solver (stringUtf8 statement))

-- |executeSMTStatementLoudly performs the same as `executeSMTStatement` but also outputs the solver's stdout to the command line.
executeSMTStatementLoudly :: Solver.Solver -> String -> IO CommandResult
executeSMTStatementLoudly solver statement = do
  response <- Solver.command solver (stringUtf8 statement)
  ByteString.putStrLn response
  return $ resultFromString $ unpack response

-- |executeSMTWithHandler pulls the main grunt work of executeSMT and executeSMTLoudly, allowing them to pass in the specific method that either prints the smt results or doens't
executeSMTWithHandler :: (IsString a, Pretty a) => SMTProcess.Config -> Block a -> (Solver.Solver -> String -> IO CommandResult) -> IO SMTResult
executeSMTWithHandler config smt_code smt_handler =
  let
    -- split the block statement into its lines (to be used by the solver one at a time)
    statements = lines $ renderString $ layoutCompact $ pretty smt_code
  in
  -- runs a new computation using the 'Process' backend and returns an IO monad
  trace (unlines statements) $ SMTProcess.with
    config
    $ \handle -> do
      -- convert the process handle to an actual backend
      let backend = SMTProcess.toBackend handle
      -- create a solver (w/o queuing because it doesn't work with commands that have no output) from the backend
      solver <- Solver.initSolver Solver.NoQueuing backend
      -- iterate through all the statements and collect their results into one big SMTResult
      fmap fromCommandResults (forM statements (smt_handler solver))
