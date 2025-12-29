module Main where

import Test.Tasty
import Test.Tasty.QuickCheck

import Test.QuickCheck

import QSym.Monad
import QSym.Interpret
import QSym.Syntax

import QSym.Tests.Arithmetic

main :: IO ()
main = defaultMain (testGroup "Arithmetic" [ 
  testProperty "initV" checkInitV, 
  testProperty "flipBits" checkFlipBits,
  testProperty "notIsHighBitSet" checkNotIsHighBitSet,
  testProperty "comparator" checkComparator
  --testProperty "rzDivMod" checkrzDivMod,
  --testProperty "rzSub" checkrzSub,
  --testProperty "adder" checkAdder,
  --testProperty "rzAdder" checkrzAdder
  ])