module QSym.Logic.Name
  where

import QSym.Logic.SMT
import QSym.Logic.Syntax
import Qafny.Syntax.AST hiding (Range (..), Block)

import Data.String

import Prettyprinter

data Name = LocusName SteppedLocus | VarName (Stepped Var) | BuiltinName String
  deriving (Show)

instance Pretty Name where
  pretty (LocusName x) = pretty x
  pretty (VarName x) = pretty x
  pretty (BuiltinName x) = pretty x

instance IsString Name where
  fromString = BuiltinName

instance Steppable Name where
  step (LocusName x) = LocusName (step x)
  step (VarName x) = VarName (step x)
  step (BuiltinName x) = BuiltinName x

currentVar :: Var -> Name
currentVar x = VarName (Current x)

type HighLevelSMT = SMT Name

getSteppedVar :: Var -> [Name] -> [Stepped Var]
getSteppedVar x [] = []
getSteppedVar x (VarName y:ys)
  | getSteppedName y == x = y : getSteppedVar x ys
getSteppedVar x (_:ys) = getSteppedVar x ys

