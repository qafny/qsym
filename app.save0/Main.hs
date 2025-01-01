module Main where

import QSym.Tests.Arithmetic
import QSym.Syntax
import QSym.Utils
import QSym.Interpret
import Test.QuickCheck

main :: IO ()
main = pure () --do
  -- -- let size = 1
  -- --     m = 1
  -- --
  -- --     n = size+1
  -- --     i = findNum m (n-1)
  -- -- -- putStrLn $ pprExpr $ rzModer' (i + 1) n xVar yVar (nat2fb ((2^i) * m))
  -- -- -- putStrLn $ pprExpr $ rzSub (Var 0) 5 (RzValue (==3))
  -- -- putStrLn $ pprExpr $ rzDivModOut 1 1
  -- quickCheck bvectorIntTest
  -- quickCheck intBvectorTest
  -- quickCheck checkDivMod
