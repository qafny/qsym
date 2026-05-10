{-# OPTIONS_GHC -w #-}
{-# LANGUAGE
    TypeFamilies
  , FlexibleContexts
  , FlexibleInstances
  , NamedFieldPuns

  #-}


module Qafny.Syntax.Parser(scanAndParse) where
import qualified Qafny.Syntax.Lexer as L
import           Qafny.Syntax.ParserUtils
import           Qafny.Syntax.AST
import           Control.Monad
import           Data.Sum
import           Data.Maybe
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.20.1.1

data HappyAbsSyn t4 t5 t10 t11 t13 t15 t16 t21 t25 t26 t29 t30 t33 t34 t37 t41 t46 t47 t48 t49 t50 t51 t52 t53 t54 t55 t56 t57 t58 t59 t60 t61 t62 t63 t64 t65 t66 t67 t68 t69 t70 t71 t72 t73 t74 t75 t76 t77 t78 t79 t80 t81 t82
	= HappyTerminal (L.SToken)
	| HappyErrorToken Prelude.Int
	| HappyAbsSyn4 t4
	| HappyAbsSyn5 t5
	| HappyAbsSyn6 (Toplevel')
	| HappyAbsSyn7 ([Binding'])
	| HappyAbsSyn8 ([ Conds ])
	| HappyAbsSyn9 (Conds)
	| HappyAbsSyn10 t10
	| HappyAbsSyn11 t11
	| HappyAbsSyn12 (Ty)
	| HappyAbsSyn13 t13
	| HappyAbsSyn14 (QTy)
	| HappyAbsSyn15 t15
	| HappyAbsSyn16 t16
	| HappyAbsSyn17 (Stmt')
	| HappyAbsSyn18 (Exp')
	| HappyAbsSyn19 (GuardExp)
	| HappyAbsSyn20 (Partition)
	| HappyAbsSyn21 t21
	| HappyAbsSyn23 (Var)
	| HappyAbsSyn24 (Intv)
	| HappyAbsSyn25 t25
	| HappyAbsSyn26 t26
	| HappyAbsSyn27 (SpecExp)
	| HappyAbsSyn28 (AmpExp)
	| HappyAbsSyn29 t29
	| HappyAbsSyn30 t30
	| HappyAbsSyn31 (PhaseExp)
	| HappyAbsSyn32 (PhaseBinder)
	| HappyAbsSyn33 t33
	| HappyAbsSyn34 t34
	| HappyAbsSyn36 ((PhaseBinder, [Var]))
	| HappyAbsSyn37 t37
	| HappyAbsSyn41 t41
	| HappyAbsSyn42 (Op2)
	| HappyAbsSyn46 t46
	| HappyAbsSyn47 t47
	| HappyAbsSyn48 t48
	| HappyAbsSyn49 t49
	| HappyAbsSyn50 t50
	| HappyAbsSyn51 t51
	| HappyAbsSyn52 t52
	| HappyAbsSyn53 t53
	| HappyAbsSyn54 t54
	| HappyAbsSyn55 t55
	| HappyAbsSyn56 t56
	| HappyAbsSyn57 t57
	| HappyAbsSyn58 t58
	| HappyAbsSyn59 t59
	| HappyAbsSyn60 t60
	| HappyAbsSyn61 t61
	| HappyAbsSyn62 t62
	| HappyAbsSyn63 t63
	| HappyAbsSyn64 t64
	| HappyAbsSyn65 t65
	| HappyAbsSyn66 t66
	| HappyAbsSyn67 t67
	| HappyAbsSyn68 t68
	| HappyAbsSyn69 t69
	| HappyAbsSyn70 t70
	| HappyAbsSyn71 t71
	| HappyAbsSyn72 t72
	| HappyAbsSyn73 t73
	| HappyAbsSyn74 t74
	| HappyAbsSyn75 t75
	| HappyAbsSyn76 t76
	| HappyAbsSyn77 t77
	| HappyAbsSyn78 t78
	| HappyAbsSyn79 t79
	| HappyAbsSyn80 t80
	| HappyAbsSyn81 t81
	| HappyAbsSyn82 t82

happyExpList :: Happy_Data_Array.Array Prelude.Int Prelude.Int
happyExpList = Happy_Data_Array.listArray (0,942) ([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,32791,0,4352,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,5888,128,0,17,0,0,0,0,0,0,49152,8197,0,1088,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8256,512,125,513,1286,0,0,0,0,0,4096,32776,8000,32832,16768,1,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,33024,2048,500,2052,5144,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,513,24576,1024,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,496,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,6144,16,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,3072,0,0,384,16448,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,4096,32776,8000,32832,16768,1,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,272,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,128,0,0,0,16,0,0,0,0,0,0,23552,512,0,68,0,0,0,0,0,0,0,32791,0,4352,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,49152,8197,0,1088,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,32776,8000,32832,16768,1,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,32,32002,256,1538,5,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,12288,0,0,1536,256,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,2,0,0,16480,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,384,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,48,49,0,0,0,0,0,8,0,0,384,1,0,0,0,0,0,512,0,0,24576,64,0,0,0,0,0,32768,0,0,0,4120,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,16384,32,32002,256,1538,5,0,0,0,0,0,0,0,0,0,17,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,8256,512,125,513,1286,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,512,0,0,24576,64,0,0,0,0,0,0,0,0,0,0,258,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,1024,8194,2000,8208,20576,0,0,0,0,0,0,129,62472,1025,6152,20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,1536,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,32768,12,0,6144,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,49152,8197,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16576,1,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,32,32002,256,1538,5,0,0,0,0,0,2064,16512,16415,32896,321,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,800,0,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,129,62472,1025,6152,20,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,272,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,516,53280,4103,24608,80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,32,32002,256,1538,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,15,0,0,256,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,516,53280,4103,24608,80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,129,62472,1025,6152,20,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,16384,32,32002,256,1538,5,0,0,0,0,0,2048,0,0,32768,257,0,0,0,0,0,13312,0,0,96,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,208,0,32768,1,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,32776,8000,32832,16768,1,0,0,0,0,0,0,0,0,16384,12,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,8194,2000,8208,20576,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8256,512,125,513,1286,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,516,53280,4103,24608,80,0,0,0,0,0,33024,2048,500,2052,5144,0,0,0,0,0,0,32,0,0,1536,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,13,0,6144,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,8256,512,125,513,1286,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,16384,32,32002,256,1538,5,0,0,0,0,0,2064,16512,16415,38016,321,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,56,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,2048,0,0,32768,257,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,8192,3,0,1536,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1024,8194,2000,8208,20576,0,0,0,0,0,0,129,62472,1025,6152,20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,16384,32,32002,256,1538,5,0,0,0,0,0,2064,16512,16415,32896,321,0,0,0,0,0,1024,8194,2000,8208,20576,0,0,0,0,0,0,8,0,4096,4096,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,2064,16512,16415,32896,321,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8256,512,125,513,1286,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2064,16512,16415,32896,321,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_runParser","AST","toplevels","toplevel","returns","conds","cond","bindings","binding","ty","baseTy","qty","block","stmts","stmt","splitAt","guardExpr","partition","range","spec","nullableId","intv","symT","symS","qspec","ampExp","symo","symO","pspec","pbinder","expr","argExpr","lamExpr","lamBinder","qops","logicOrExp","logicAndExp","cmpExpr","cmpPartial","cmp","arithExpr","aritha","arith","atomic","alt__\"\931\"__'S'__","alt__\"\937\"__'O'__","alt__\"\969\"__'o'__","alt__\"\8855\"__'T'__","list__qspec__","many__cmpPartial__","many__cond__","many__stmt__","many__toplevel__","manyComma__binding__","manyComma__id__","manyComma__range__","mayket__expr__","opt__block__","opt__splitAt__","parens__bindings__","parens__range__","tuple__argExpr__","tuple__expr__","tuple__id__","tuple__ty__","manyComma__argExpr__","manyComma__expr__","manyComma__qspec__","manyComma__ty__","manyComma___binding__","manyComma___id__","manyComma___range__","many___cmpPartial__","many___cond__","many___stmt__","many___toplevel__","manyComma___argExpr__","manyComma___expr__","manyComma___qspec__","manyComma___ty__","'_'","'1'","'S'","'T'","'o'","'O'","namedW","digits","dafny","\"method\"","\"ensures\"","\"requires\"","\"separates\"","\"invariant\"","\"with\"","\"at\"","\"split\"","\"for\"","\"returns\"","\"not\"","\"nat\"","\"real\"","\"int\"","\"in\"","\"bool\"","\"seq\"","\"nor\"","\"had\"","\"H\"","\"Qft\"","\"iQft\"","\"repr\"","\"measure\"","\"measured\"","\"en\"","\"Q\"","\"ena\"","\"var\"","\"if\"","\"isqrt\"","\"sin\"","\"cos\"","\"\955\"","\"\931\"","\"\8855\"","\"\969\"","\"\937\"","\"\8712\"","\"\10217\"","\"\8614\"","\"assert\"","\"forall\"","\"||\"","\"&&\"","'+'","'/'","'-'","'*'","'\\%'","'|'","'('","')'","'<'","'>'","'['","']'","'{'","'}'","id","','","\"::\"","':'","'.'","';'","\"==\"","'->'","\"=>\"","\"==>\"","\">=\"","\"<=\"","\":=\"","\"*=\"","'~'","%eof"]
        bit_start = st Prelude.* 166
        bit_end = (st Prelude.+ 1) Prelude.* 166
        read_bit = readArrayBit happyExpList
        bits = Prelude.map read_bit [bit_start..bit_end Prelude.- 1]
        bits_indexed = Prelude.zip bits [0..165]
        token_strs_expected = Prelude.concatMap f bits_indexed
        f (Prelude.False, _) = []
        f (Prelude.True, nr) = [token_strs Prelude.!! nr]

action_0 (4) = happyGoto action_5
action_0 (5) = happyGoto action_2
action_0 (55) = happyGoto action_3
action_0 (78) = happyGoto action_4
action_0 _ = happyReduce_168

action_1 (5) = happyGoto action_2
action_1 (55) = happyGoto action_3
action_1 (78) = happyGoto action_4
action_1 _ = happyFail (happyExpListPerState 1)

action_2 _ = happyReduce_1

action_3 _ = happyReduce_2

action_4 (91) = happyShift action_7
action_4 (92) = happyShift action_8
action_4 (6) = happyGoto action_6
action_4 _ = happyReduce_129

action_5 (166) = happyAccept
action_5 _ = happyFail (happyExpListPerState 5)

action_6 _ = happyReduce_169

action_7 _ = happyReduce_3

action_8 (151) = happyShift action_9
action_8 _ = happyFail (happyExpListPerState 8)

action_9 (143) = happyShift action_11
action_9 (62) = happyGoto action_10
action_9 _ = happyFail (happyExpListPerState 9)

action_10 (101) = happyShift action_18
action_10 (7) = happyGoto action_17
action_10 _ = happyReduce_5

action_11 (151) = happyShift action_16
action_11 (10) = happyGoto action_12
action_11 (11) = happyGoto action_13
action_11 (56) = happyGoto action_14
action_11 (72) = happyGoto action_15
action_11 _ = happyReduce_131

action_12 (144) = happyShift action_25
action_12 _ = happyFail (happyExpListPerState 12)

action_13 _ = happyReduce_157

action_14 _ = happyReduce_12

action_15 (144) = happyReduce_130
action_15 (152) = happyShift action_24
action_15 _ = happyReduce_130

action_16 (154) = happyShift action_23
action_16 _ = happyFail (happyExpListPerState 16)

action_17 (8) = happyGoto action_20
action_17 (53) = happyGoto action_21
action_17 (76) = happyGoto action_22
action_17 _ = happyReduce_164

action_18 (143) = happyShift action_19
action_18 _ = happyFail (happyExpListPerState 18)

action_19 (151) = happyShift action_16
action_19 (10) = happyGoto action_45
action_19 (11) = happyGoto action_13
action_19 (56) = happyGoto action_14
action_19 (72) = happyGoto action_15
action_19 _ = happyReduce_131

action_20 (149) = happyShift action_44
action_20 (15) = happyGoto action_42
action_20 (60) = happyGoto action_43
action_20 _ = happyReduce_138

action_21 _ = happyReduce_7

action_22 (93) = happyShift action_38
action_22 (94) = happyShift action_39
action_22 (95) = happyShift action_40
action_22 (96) = happyShift action_41
action_22 (9) = happyGoto action_37
action_22 _ = happyReduce_127

action_23 (103) = happyShift action_30
action_23 (104) = happyShift action_31
action_23 (105) = happyShift action_32
action_23 (107) = happyShift action_33
action_23 (118) = happyShift action_34
action_23 (143) = happyShift action_35
action_23 (147) = happyShift action_36
action_23 (12) = happyGoto action_27
action_23 (13) = happyGoto action_28
action_23 (67) = happyGoto action_29
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (151) = happyShift action_16
action_24 (11) = happyGoto action_26
action_24 _ = happyFail (happyExpListPerState 24)

action_25 _ = happyReduce_142

action_26 _ = happyReduce_156

action_27 _ = happyReduce_13

action_28 (158) = happyShift action_87
action_28 _ = happyReduce_14

action_29 (158) = happyShift action_86
action_29 _ = happyFail (happyExpListPerState 29)

action_30 _ = happyReduce_17

action_31 _ = happyReduce_18

action_32 _ = happyReduce_19

action_33 _ = happyReduce_20

action_34 (147) = happyShift action_85
action_34 _ = happyFail (happyExpListPerState 34)

action_35 (103) = happyShift action_30
action_35 (104) = happyShift action_31
action_35 (105) = happyShift action_32
action_35 (107) = happyShift action_33
action_35 (118) = happyShift action_34
action_35 (143) = happyShift action_35
action_35 (147) = happyShift action_36
action_35 (12) = happyGoto action_82
action_35 (13) = happyGoto action_28
action_35 (67) = happyGoto action_29
action_35 (71) = happyGoto action_83
action_35 (82) = happyGoto action_84
action_35 _ = happyReduce_155

action_36 (103) = happyShift action_30
action_36 (104) = happyShift action_31
action_36 (105) = happyShift action_32
action_36 (107) = happyShift action_33
action_36 (118) = happyShift action_34
action_36 (143) = happyShift action_35
action_36 (147) = happyShift action_36
action_36 (12) = happyGoto action_81
action_36 (13) = happyGoto action_28
action_36 (67) = happyGoto action_29
action_36 _ = happyFail (happyExpListPerState 36)

action_37 _ = happyReduce_165

action_38 (83) = happyShift action_59
action_38 (90) = happyShift action_60
action_38 (102) = happyShift action_61
action_38 (109) = happyShift action_62
action_38 (111) = happyShift action_63
action_38 (112) = happyShift action_64
action_38 (113) = happyShift action_65
action_38 (114) = happyShift action_66
action_38 (115) = happyShift action_67
action_38 (125) = happyShift action_68
action_38 (134) = happyShift action_69
action_38 (142) = happyShift action_70
action_38 (143) = happyShift action_71
action_38 (149) = happyShift action_72
action_38 (151) = happyShift action_73
action_38 (22) = happyGoto action_50
action_38 (33) = happyGoto action_80
action_38 (35) = happyGoto action_52
action_38 (37) = happyGoto action_53
action_38 (38) = happyGoto action_54
action_38 (39) = happyGoto action_55
action_38 (40) = happyGoto action_56
action_38 (43) = happyGoto action_57
action_38 (46) = happyGoto action_58
action_38 _ = happyFail (happyExpListPerState 38)

action_39 (83) = happyShift action_59
action_39 (90) = happyShift action_60
action_39 (102) = happyShift action_61
action_39 (109) = happyShift action_62
action_39 (111) = happyShift action_63
action_39 (112) = happyShift action_64
action_39 (113) = happyShift action_65
action_39 (114) = happyShift action_66
action_39 (115) = happyShift action_67
action_39 (125) = happyShift action_68
action_39 (134) = happyShift action_69
action_39 (142) = happyShift action_70
action_39 (143) = happyShift action_71
action_39 (149) = happyShift action_72
action_39 (151) = happyShift action_73
action_39 (22) = happyGoto action_50
action_39 (33) = happyGoto action_79
action_39 (35) = happyGoto action_52
action_39 (37) = happyGoto action_53
action_39 (38) = happyGoto action_54
action_39 (39) = happyGoto action_55
action_39 (40) = happyGoto action_56
action_39 (43) = happyGoto action_57
action_39 (46) = happyGoto action_58
action_39 _ = happyFail (happyExpListPerState 39)

action_40 (151) = happyShift action_78
action_40 (20) = happyGoto action_74
action_40 (21) = happyGoto action_75
action_40 (58) = happyGoto action_76
action_40 (74) = happyGoto action_77
action_40 _ = happyReduce_135

action_41 (83) = happyShift action_59
action_41 (90) = happyShift action_60
action_41 (102) = happyShift action_61
action_41 (109) = happyShift action_62
action_41 (111) = happyShift action_63
action_41 (112) = happyShift action_64
action_41 (113) = happyShift action_65
action_41 (114) = happyShift action_66
action_41 (115) = happyShift action_67
action_41 (125) = happyShift action_68
action_41 (134) = happyShift action_69
action_41 (142) = happyShift action_70
action_41 (143) = happyShift action_71
action_41 (149) = happyShift action_72
action_41 (151) = happyShift action_73
action_41 (22) = happyGoto action_50
action_41 (33) = happyGoto action_51
action_41 (35) = happyGoto action_52
action_41 (37) = happyGoto action_53
action_41 (38) = happyGoto action_54
action_41 (39) = happyGoto action_55
action_41 (40) = happyGoto action_56
action_41 (43) = happyGoto action_57
action_41 (46) = happyGoto action_58
action_41 _ = happyFail (happyExpListPerState 41)

action_42 _ = happyReduce_139

action_43 _ = happyReduce_4

action_44 (16) = happyGoto action_47
action_44 (54) = happyGoto action_48
action_44 (77) = happyGoto action_49
action_44 _ = happyReduce_166

action_45 (144) = happyShift action_46
action_45 _ = happyFail (happyExpListPerState 45)

action_46 _ = happyReduce_6

action_47 (150) = happyShift action_140
action_47 _ = happyFail (happyExpListPerState 47)

action_48 _ = happyReduce_29

action_49 (91) = happyShift action_134
action_49 (100) = happyShift action_135
action_49 (120) = happyShift action_136
action_49 (121) = happyShift action_137
action_49 (133) = happyShift action_138
action_49 (151) = happyShift action_139
action_49 (163) = happyReduce_133
action_49 (164) = happyReduce_135
action_49 (17) = happyGoto action_130
action_49 (20) = happyGoto action_131
action_49 (21) = happyGoto action_75
action_49 (57) = happyGoto action_132
action_49 (58) = happyGoto action_76
action_49 (73) = happyGoto action_133
action_49 (74) = happyGoto action_77
action_49 _ = happyReduce_128

action_50 _ = happyReduce_76

action_51 _ = happyReduce_10

action_52 _ = happyReduce_82

action_53 _ = happyReduce_77

action_54 (160) = happyShift action_129
action_54 _ = happyFail (happyExpListPerState 54)

action_55 (135) = happyShift action_128
action_55 _ = happyReduce_93

action_56 (136) = happyShift action_127
action_56 _ = happyReduce_95

action_57 (52) = happyGoto action_125
action_57 (75) = happyGoto action_126
action_57 _ = happyReduce_162

action_58 (137) = happyShift action_120
action_58 (138) = happyShift action_121
action_58 (139) = happyShift action_122
action_58 (140) = happyShift action_123
action_58 (141) = happyShift action_124
action_58 (44) = happyGoto action_118
action_58 (45) = happyGoto action_119
action_58 _ = happyReduce_104

action_59 _ = happyReduce_75

action_60 _ = happyReduce_111

action_61 (90) = happyShift action_60
action_61 (142) = happyShift action_70
action_61 (143) = happyShift action_71
action_61 (151) = happyShift action_73
action_61 (46) = happyGoto action_117
action_61 _ = happyFail (happyExpListPerState 61)

action_62 (143) = happyShift action_116
action_62 _ = happyFail (happyExpListPerState 62)

action_63 _ = happyReduce_89

action_64 _ = happyReduce_90

action_65 _ = happyReduce_91

action_66 (143) = happyShift action_115
action_66 (63) = happyGoto action_114
action_66 _ = happyFail (happyExpListPerState 66)

action_67 (143) = happyShift action_113
action_67 _ = happyFail (happyExpListPerState 67)

action_68 (83) = happyShift action_107
action_68 (84) = happyShift action_108
action_68 (128) = happyShift action_109
action_68 (129) = happyShift action_110
action_68 (143) = happyShift action_111
action_68 (151) = happyShift action_112
action_68 (32) = happyGoto action_104
action_68 (36) = happyGoto action_105
action_68 (66) = happyGoto action_106
action_68 _ = happyFail (happyExpListPerState 68)

action_69 (151) = happyShift action_103
action_69 _ = happyFail (happyExpListPerState 69)

action_70 (151) = happyShift action_102
action_70 _ = happyFail (happyExpListPerState 70)

action_71 (83) = happyShift action_59
action_71 (90) = happyShift action_60
action_71 (102) = happyShift action_61
action_71 (109) = happyShift action_62
action_71 (111) = happyShift action_63
action_71 (112) = happyShift action_64
action_71 (113) = happyShift action_65
action_71 (114) = happyShift action_66
action_71 (115) = happyShift action_67
action_71 (125) = happyShift action_68
action_71 (134) = happyShift action_69
action_71 (142) = happyShift action_70
action_71 (143) = happyShift action_71
action_71 (149) = happyShift action_72
action_71 (151) = happyShift action_73
action_71 (22) = happyGoto action_50
action_71 (33) = happyGoto action_101
action_71 (35) = happyGoto action_52
action_71 (37) = happyGoto action_53
action_71 (38) = happyGoto action_54
action_71 (39) = happyGoto action_55
action_71 (40) = happyGoto action_56
action_71 (43) = happyGoto action_57
action_71 (46) = happyGoto action_58
action_71 _ = happyFail (happyExpListPerState 71)

action_72 (151) = happyShift action_78
action_72 (20) = happyGoto action_100
action_72 (21) = happyGoto action_75
action_72 (58) = happyGoto action_76
action_72 (74) = happyGoto action_77
action_72 _ = happyReduce_135

action_73 (143) = happyShift action_98
action_73 (147) = happyShift action_99
action_73 (65) = happyGoto action_97
action_73 _ = happyReduce_113

action_74 _ = happyReduce_11

action_75 _ = happyReduce_161

action_76 _ = happyReduce_43

action_77 (91) = happyReduce_134
action_77 (92) = happyReduce_134
action_77 (93) = happyReduce_134
action_77 (94) = happyReduce_134
action_77 (95) = happyReduce_134
action_77 (96) = happyReduce_134
action_77 (99) = happyReduce_134
action_77 (144) = happyReduce_134
action_77 (149) = happyReduce_134
action_77 (152) = happyShift action_96
action_77 (154) = happyReduce_134
action_77 (164) = happyReduce_134
action_77 (166) = happyReduce_134
action_77 _ = happyReduce_134

action_78 (147) = happyShift action_95
action_78 _ = happyFail (happyExpListPerState 78)

action_79 _ = happyReduce_8

action_80 _ = happyReduce_9

action_81 (148) = happyShift action_94
action_81 _ = happyFail (happyExpListPerState 81)

action_82 _ = happyReduce_177

action_83 (144) = happyShift action_93
action_83 _ = happyFail (happyExpListPerState 83)

action_84 (144) = happyReduce_154
action_84 (152) = happyShift action_92
action_84 _ = happyReduce_154

action_85 (90) = happyShift action_90
action_85 (151) = happyShift action_91
action_85 _ = happyFail (happyExpListPerState 85)

action_86 (103) = happyShift action_30
action_86 (104) = happyShift action_31
action_86 (105) = happyShift action_32
action_86 (107) = happyShift action_33
action_86 (118) = happyShift action_34
action_86 (143) = happyShift action_35
action_86 (147) = happyShift action_36
action_86 (12) = happyGoto action_89
action_86 (13) = happyGoto action_28
action_86 (67) = happyGoto action_29
action_86 _ = happyFail (happyExpListPerState 86)

action_87 (103) = happyShift action_30
action_87 (104) = happyShift action_31
action_87 (105) = happyShift action_32
action_87 (107) = happyShift action_33
action_87 (118) = happyShift action_34
action_87 (143) = happyShift action_35
action_87 (147) = happyShift action_36
action_87 (12) = happyGoto action_88
action_87 (13) = happyGoto action_28
action_87 (67) = happyGoto action_29
action_87 _ = happyFail (happyExpListPerState 87)

action_88 _ = happyReduce_15

action_89 (144) = happyReduce_16
action_89 (148) = happyReduce_16
action_89 (152) = happyReduce_16
action_89 (156) = happyReduce_16
action_89 (163) = happyReduce_16
action_89 _ = happyReduce_16

action_90 (148) = happyShift action_184
action_90 _ = happyFail (happyExpListPerState 90)

action_91 (148) = happyShift action_183
action_91 _ = happyFail (happyExpListPerState 91)

action_92 (103) = happyShift action_30
action_92 (104) = happyShift action_31
action_92 (105) = happyShift action_32
action_92 (107) = happyShift action_33
action_92 (118) = happyShift action_34
action_92 (143) = happyShift action_35
action_92 (147) = happyShift action_36
action_92 (12) = happyGoto action_182
action_92 (13) = happyGoto action_28
action_92 (67) = happyGoto action_29
action_92 _ = happyFail (happyExpListPerState 92)

action_93 _ = happyReduce_147

action_94 _ = happyReduce_21

action_95 (83) = happyShift action_59
action_95 (90) = happyShift action_60
action_95 (102) = happyShift action_61
action_95 (109) = happyShift action_62
action_95 (111) = happyShift action_63
action_95 (112) = happyShift action_64
action_95 (113) = happyShift action_65
action_95 (114) = happyShift action_66
action_95 (115) = happyShift action_67
action_95 (125) = happyShift action_68
action_95 (134) = happyShift action_69
action_95 (142) = happyShift action_70
action_95 (143) = happyShift action_71
action_95 (149) = happyShift action_72
action_95 (151) = happyShift action_73
action_95 (22) = happyGoto action_50
action_95 (33) = happyGoto action_181
action_95 (35) = happyGoto action_52
action_95 (37) = happyGoto action_53
action_95 (38) = happyGoto action_54
action_95 (39) = happyGoto action_55
action_95 (40) = happyGoto action_56
action_95 (43) = happyGoto action_57
action_95 (46) = happyGoto action_58
action_95 _ = happyFail (happyExpListPerState 95)

action_96 (151) = happyShift action_78
action_96 (21) = happyGoto action_180
action_96 _ = happyFail (happyExpListPerState 96)

action_97 _ = happyReduce_112

action_98 (83) = happyShift action_59
action_98 (90) = happyShift action_60
action_98 (102) = happyShift action_61
action_98 (109) = happyShift action_62
action_98 (111) = happyShift action_63
action_98 (112) = happyShift action_64
action_98 (113) = happyShift action_65
action_98 (114) = happyShift action_66
action_98 (115) = happyShift action_67
action_98 (125) = happyShift action_68
action_98 (134) = happyShift action_69
action_98 (142) = happyShift action_70
action_98 (143) = happyShift action_71
action_98 (149) = happyShift action_72
action_98 (151) = happyShift action_73
action_98 (22) = happyGoto action_50
action_98 (33) = happyGoto action_177
action_98 (35) = happyGoto action_52
action_98 (37) = happyGoto action_53
action_98 (38) = happyGoto action_54
action_98 (39) = happyGoto action_55
action_98 (40) = happyGoto action_56
action_98 (43) = happyGoto action_57
action_98 (46) = happyGoto action_58
action_98 (69) = happyGoto action_178
action_98 (80) = happyGoto action_179
action_98 _ = happyReduce_151

action_99 (151) = happyShift action_176
action_99 _ = happyFail (happyExpListPerState 99)

action_100 (154) = happyShift action_175
action_100 _ = happyFail (happyExpListPerState 100)

action_101 (144) = happyShift action_174
action_101 _ = happyFail (happyExpListPerState 101)

action_102 (142) = happyShift action_173
action_102 _ = happyFail (happyExpListPerState 102)

action_103 (154) = happyShift action_172
action_103 _ = happyFail (happyExpListPerState 103)

action_104 (165) = happyShift action_171
action_104 _ = happyFail (happyExpListPerState 104)

action_105 (159) = happyShift action_170
action_105 _ = happyFail (happyExpListPerState 105)

action_106 _ = happyReduce_87

action_107 _ = happyReduce_71

action_108 _ = happyReduce_72

action_109 (143) = happyShift action_169
action_109 _ = happyFail (happyExpListPerState 109)

action_110 (151) = happyShift action_168
action_110 _ = happyFail (happyExpListPerState 110)

action_111 (83) = happyShift action_107
action_111 (84) = happyShift action_108
action_111 (128) = happyShift action_109
action_111 (129) = happyShift action_110
action_111 (143) = happyShift action_166
action_111 (151) = happyShift action_167
action_111 (32) = happyGoto action_104
action_111 (36) = happyGoto action_164
action_111 (57) = happyGoto action_165
action_111 (66) = happyGoto action_106
action_111 (73) = happyGoto action_133
action_111 _ = happyReduce_133

action_112 _ = happyReduce_88

action_113 (151) = happyShift action_78
action_113 (20) = happyGoto action_163
action_113 (21) = happyGoto action_75
action_113 (58) = happyGoto action_76
action_113 (74) = happyGoto action_77
action_113 _ = happyReduce_135

action_114 _ = happyReduce_81

action_115 (151) = happyShift action_78
action_115 (21) = happyGoto action_162
action_115 _ = happyFail (happyExpListPerState 115)

action_116 (90) = happyShift action_60
action_116 (142) = happyShift action_70
action_116 (143) = happyShift action_71
action_116 (151) = happyShift action_73
action_116 (46) = happyGoto action_161
action_116 _ = happyFail (happyExpListPerState 116)

action_117 _ = happyReduce_79

action_118 _ = happyReduce_107

action_119 (90) = happyShift action_60
action_119 (142) = happyShift action_70
action_119 (143) = happyShift action_71
action_119 (151) = happyShift action_73
action_119 (43) = happyGoto action_160
action_119 (46) = happyGoto action_58
action_119 _ = happyFail (happyExpListPerState 119)

action_120 _ = happyReduce_105

action_121 _ = happyReduce_108

action_122 _ = happyReduce_106

action_123 _ = happyReduce_109

action_124 _ = happyReduce_110

action_125 _ = happyReduce_96

action_126 (145) = happyShift action_155
action_126 (146) = happyShift action_156
action_126 (157) = happyShift action_157
action_126 (161) = happyShift action_158
action_126 (162) = happyShift action_159
action_126 (41) = happyGoto action_153
action_126 (42) = happyGoto action_154
action_126 _ = happyReduce_126

action_127 (90) = happyShift action_60
action_127 (142) = happyShift action_70
action_127 (143) = happyShift action_71
action_127 (151) = happyShift action_73
action_127 (39) = happyGoto action_152
action_127 (40) = happyGoto action_56
action_127 (43) = happyGoto action_57
action_127 (46) = happyGoto action_58
action_127 _ = happyFail (happyExpListPerState 127)

action_128 (90) = happyShift action_60
action_128 (142) = happyShift action_70
action_128 (143) = happyShift action_71
action_128 (151) = happyShift action_73
action_128 (38) = happyGoto action_151
action_128 (39) = happyGoto action_55
action_128 (40) = happyGoto action_56
action_128 (43) = happyGoto action_57
action_128 (46) = happyGoto action_58
action_128 _ = happyFail (happyExpListPerState 128)

action_129 (90) = happyShift action_60
action_129 (142) = happyShift action_70
action_129 (143) = happyShift action_71
action_129 (151) = happyShift action_73
action_129 (38) = happyGoto action_150
action_129 (39) = happyGoto action_55
action_129 (40) = happyGoto action_56
action_129 (43) = happyGoto action_57
action_129 (46) = happyGoto action_58
action_129 _ = happyFail (happyExpListPerState 129)

action_130 _ = happyReduce_167

action_131 (164) = happyShift action_149
action_131 _ = happyFail (happyExpListPerState 131)

action_132 (163) = happyShift action_148
action_132 _ = happyFail (happyExpListPerState 132)

action_133 (144) = happyReduce_132
action_133 (152) = happyShift action_147
action_133 (163) = happyReduce_132
action_133 _ = happyReduce_132

action_134 _ = happyReduce_30

action_135 (151) = happyShift action_146
action_135 _ = happyFail (happyExpListPerState 135)

action_136 (151) = happyShift action_16
action_136 (11) = happyGoto action_145
action_136 _ = happyFail (happyExpListPerState 136)

action_137 (143) = happyShift action_144
action_137 _ = happyFail (happyExpListPerState 137)

action_138 (83) = happyShift action_59
action_138 (90) = happyShift action_60
action_138 (102) = happyShift action_61
action_138 (109) = happyShift action_62
action_138 (111) = happyShift action_63
action_138 (112) = happyShift action_64
action_138 (113) = happyShift action_65
action_138 (114) = happyShift action_66
action_138 (115) = happyShift action_67
action_138 (125) = happyShift action_68
action_138 (134) = happyShift action_69
action_138 (142) = happyShift action_70
action_138 (143) = happyShift action_71
action_138 (149) = happyShift action_72
action_138 (151) = happyShift action_73
action_138 (22) = happyGoto action_50
action_138 (33) = happyGoto action_143
action_138 (35) = happyGoto action_52
action_138 (37) = happyGoto action_53
action_138 (38) = happyGoto action_54
action_138 (39) = happyGoto action_55
action_138 (40) = happyGoto action_56
action_138 (43) = happyGoto action_57
action_138 (46) = happyGoto action_58
action_138 _ = happyFail (happyExpListPerState 138)

action_139 (143) = happyShift action_142
action_139 (147) = happyShift action_95
action_139 (64) = happyGoto action_141
action_139 _ = happyReduce_159

action_140 _ = happyReduce_28

action_141 (156) = happyShift action_231
action_141 _ = happyFail (happyExpListPerState 141)

action_142 (83) = happyShift action_59
action_142 (90) = happyShift action_60
action_142 (102) = happyShift action_61
action_142 (109) = happyShift action_62
action_142 (111) = happyShift action_63
action_142 (112) = happyShift action_64
action_142 (113) = happyShift action_65
action_142 (114) = happyShift action_66
action_142 (115) = happyShift action_67
action_142 (125) = happyShift action_68
action_142 (134) = happyShift action_69
action_142 (142) = happyShift action_70
action_142 (143) = happyShift action_71
action_142 (149) = happyShift action_72
action_142 (151) = happyShift action_73
action_142 (22) = happyGoto action_50
action_142 (33) = happyGoto action_227
action_142 (34) = happyGoto action_228
action_142 (35) = happyGoto action_52
action_142 (37) = happyGoto action_53
action_142 (38) = happyGoto action_54
action_142 (39) = happyGoto action_55
action_142 (40) = happyGoto action_56
action_142 (43) = happyGoto action_57
action_142 (46) = happyGoto action_58
action_142 (68) = happyGoto action_229
action_142 (79) = happyGoto action_230
action_142 _ = happyReduce_149

action_143 (156) = happyShift action_226
action_143 _ = happyFail (happyExpListPerState 143)

action_144 (90) = happyShift action_60
action_144 (142) = happyShift action_70
action_144 (143) = happyShift action_71
action_144 (151) = happyShift action_225
action_144 (19) = happyGoto action_222
action_144 (20) = happyGoto action_223
action_144 (21) = happyGoto action_75
action_144 (38) = happyGoto action_224
action_144 (39) = happyGoto action_55
action_144 (40) = happyGoto action_56
action_144 (43) = happyGoto action_57
action_144 (46) = happyGoto action_58
action_144 (58) = happyGoto action_76
action_144 (74) = happyGoto action_77
action_144 _ = happyReduce_135

action_145 (156) = happyShift action_220
action_145 (163) = happyShift action_221
action_145 _ = happyFail (happyExpListPerState 145)

action_146 (106) = happyShift action_219
action_146 _ = happyFail (happyExpListPerState 146)

action_147 (151) = happyShift action_218
action_147 _ = happyFail (happyExpListPerState 147)

action_148 (83) = happyShift action_59
action_148 (90) = happyShift action_60
action_148 (102) = happyShift action_61
action_148 (109) = happyShift action_62
action_148 (111) = happyShift action_63
action_148 (112) = happyShift action_64
action_148 (113) = happyShift action_65
action_148 (114) = happyShift action_66
action_148 (115) = happyShift action_67
action_148 (125) = happyShift action_68
action_148 (134) = happyShift action_69
action_148 (142) = happyShift action_70
action_148 (143) = happyShift action_71
action_148 (149) = happyShift action_72
action_148 (151) = happyShift action_73
action_148 (22) = happyGoto action_50
action_148 (33) = happyGoto action_217
action_148 (35) = happyGoto action_52
action_148 (37) = happyGoto action_53
action_148 (38) = happyGoto action_54
action_148 (39) = happyGoto action_55
action_148 (40) = happyGoto action_56
action_148 (43) = happyGoto action_57
action_148 (46) = happyGoto action_58
action_148 _ = happyFail (happyExpListPerState 148)

action_149 (83) = happyShift action_59
action_149 (90) = happyShift action_60
action_149 (102) = happyShift action_61
action_149 (109) = happyShift action_62
action_149 (111) = happyShift action_63
action_149 (112) = happyShift action_64
action_149 (113) = happyShift action_65
action_149 (114) = happyShift action_66
action_149 (115) = happyShift action_67
action_149 (125) = happyShift action_68
action_149 (134) = happyShift action_69
action_149 (142) = happyShift action_70
action_149 (143) = happyShift action_71
action_149 (149) = happyShift action_72
action_149 (151) = happyShift action_73
action_149 (22) = happyGoto action_50
action_149 (33) = happyGoto action_216
action_149 (35) = happyGoto action_52
action_149 (37) = happyGoto action_53
action_149 (38) = happyGoto action_54
action_149 (39) = happyGoto action_55
action_149 (40) = happyGoto action_56
action_149 (43) = happyGoto action_57
action_149 (46) = happyGoto action_58
action_149 _ = happyFail (happyExpListPerState 149)

action_150 _ = happyReduce_49

action_151 _ = happyReduce_92

action_152 _ = happyReduce_94

action_153 _ = happyReduce_163

action_154 (90) = happyShift action_60
action_154 (142) = happyShift action_70
action_154 (143) = happyShift action_71
action_154 (151) = happyShift action_73
action_154 (43) = happyGoto action_215
action_154 (46) = happyGoto action_58
action_154 _ = happyFail (happyExpListPerState 154)

action_155 _ = happyReduce_99

action_156 _ = happyReduce_98

action_157 _ = happyReduce_102

action_158 _ = happyReduce_100

action_159 _ = happyReduce_101

action_160 _ = happyReduce_103

action_161 (152) = happyShift action_214
action_161 _ = happyFail (happyExpListPerState 161)

action_162 (144) = happyShift action_213
action_162 _ = happyFail (happyExpListPerState 162)

action_163 (144) = happyShift action_212
action_163 _ = happyFail (happyExpListPerState 163)

action_164 (159) = happyShift action_211
action_164 _ = happyFail (happyExpListPerState 164)

action_165 (144) = happyShift action_210
action_165 _ = happyFail (happyExpListPerState 165)

action_166 (151) = happyShift action_209
action_166 (57) = happyGoto action_165
action_166 (73) = happyGoto action_133
action_166 _ = happyReduce_133

action_167 (159) = happyReduce_88
action_167 _ = happyReduce_159

action_168 (130) = happyShift action_208
action_168 _ = happyFail (happyExpListPerState 168)

action_169 (151) = happyShift action_207
action_169 _ = happyFail (happyExpListPerState 169)

action_170 (84) = happyShift action_202
action_170 (87) = happyShift action_203
action_170 (88) = happyShift action_204
action_170 (128) = happyShift action_205
action_170 (129) = happyShift action_206
action_170 (29) = happyGoto action_197
action_170 (30) = happyGoto action_198
action_170 (31) = happyGoto action_199
action_170 (48) = happyGoto action_200
action_170 (49) = happyGoto action_201
action_170 _ = happyReduce_67

action_171 (143) = happyShift action_166
action_171 (66) = happyGoto action_196
action_171 _ = happyFail (happyExpListPerState 171)

action_172 (103) = happyShift action_30
action_172 (104) = happyShift action_31
action_172 (105) = happyShift action_32
action_172 (107) = happyShift action_33
action_172 (118) = happyShift action_34
action_172 (147) = happyShift action_36
action_172 (13) = happyGoto action_195
action_172 _ = happyFail (happyExpListPerState 172)

action_173 _ = happyReduce_114

action_174 _ = happyReduce_116

action_175 (109) = happyShift action_191
action_175 (110) = happyShift action_192
action_175 (117) = happyShift action_193
action_175 (119) = happyShift action_194
action_175 (14) = happyGoto action_190
action_175 _ = happyFail (happyExpListPerState 175)

action_176 (148) = happyShift action_189
action_176 _ = happyFail (happyExpListPerState 176)

action_177 _ = happyReduce_173

action_178 (144) = happyShift action_188
action_178 _ = happyFail (happyExpListPerState 178)

action_179 (144) = happyReduce_150
action_179 (152) = happyShift action_187
action_179 _ = happyReduce_150

action_180 _ = happyReduce_160

action_181 (148) = happyShift action_185
action_181 (152) = happyShift action_186
action_181 _ = happyFail (happyExpListPerState 181)

action_182 _ = happyReduce_176

action_183 _ = happyReduce_23

action_184 _ = happyReduce_22

action_185 _ = happyReduce_45

action_186 (83) = happyShift action_59
action_186 (90) = happyShift action_60
action_186 (102) = happyShift action_61
action_186 (109) = happyShift action_62
action_186 (111) = happyShift action_63
action_186 (112) = happyShift action_64
action_186 (113) = happyShift action_65
action_186 (114) = happyShift action_66
action_186 (115) = happyShift action_67
action_186 (125) = happyShift action_68
action_186 (134) = happyShift action_69
action_186 (142) = happyShift action_70
action_186 (143) = happyShift action_71
action_186 (149) = happyShift action_72
action_186 (151) = happyShift action_73
action_186 (22) = happyGoto action_50
action_186 (33) = happyGoto action_254
action_186 (35) = happyGoto action_52
action_186 (37) = happyGoto action_53
action_186 (38) = happyGoto action_54
action_186 (39) = happyGoto action_55
action_186 (40) = happyGoto action_56
action_186 (43) = happyGoto action_57
action_186 (46) = happyGoto action_58
action_186 _ = happyFail (happyExpListPerState 186)

action_187 (83) = happyShift action_59
action_187 (90) = happyShift action_60
action_187 (102) = happyShift action_61
action_187 (109) = happyShift action_62
action_187 (111) = happyShift action_63
action_187 (112) = happyShift action_64
action_187 (113) = happyShift action_65
action_187 (114) = happyShift action_66
action_187 (115) = happyShift action_67
action_187 (125) = happyShift action_68
action_187 (134) = happyShift action_69
action_187 (142) = happyShift action_70
action_187 (143) = happyShift action_71
action_187 (149) = happyShift action_72
action_187 (151) = happyShift action_73
action_187 (22) = happyGoto action_50
action_187 (33) = happyGoto action_253
action_187 (35) = happyGoto action_52
action_187 (37) = happyGoto action_53
action_187 (38) = happyGoto action_54
action_187 (39) = happyGoto action_55
action_187 (40) = happyGoto action_56
action_187 (43) = happyGoto action_57
action_187 (46) = happyGoto action_58
action_187 _ = happyFail (happyExpListPerState 187)

action_188 _ = happyReduce_145

action_189 _ = happyReduce_115

action_190 (132) = happyShift action_252
action_190 _ = happyFail (happyExpListPerState 190)

action_191 _ = happyReduce_24

action_192 _ = happyReduce_25

action_193 _ = happyReduce_26

action_194 _ = happyReduce_27

action_195 (153) = happyShift action_251
action_195 _ = happyFail (happyExpListPerState 195)

action_196 _ = happyReduce_86

action_197 (143) = happyShift action_250
action_197 _ = happyFail (happyExpListPerState 197)

action_198 (151) = happyShift action_249
action_198 _ = happyFail (happyExpListPerState 198)

action_199 (143) = happyShift action_98
action_199 (65) = happyGoto action_248
action_199 _ = happyFail (happyExpListPerState 199)

action_200 _ = happyReduce_66

action_201 _ = happyReduce_65

action_202 (165) = happyShift action_247
action_202 _ = happyFail (happyExpListPerState 202)

action_203 _ = happyReduce_122

action_204 _ = happyReduce_120

action_205 _ = happyReduce_121

action_206 _ = happyReduce_119

action_207 (152) = happyShift action_246
action_207 _ = happyFail (happyExpListPerState 207)

action_208 (147) = happyShift action_245
action_208 _ = happyFail (happyExpListPerState 208)

action_209 _ = happyReduce_159

action_210 _ = happyReduce_146

action_211 (84) = happyShift action_202
action_211 (87) = happyShift action_203
action_211 (88) = happyShift action_204
action_211 (128) = happyShift action_205
action_211 (129) = happyShift action_206
action_211 (29) = happyGoto action_197
action_211 (30) = happyGoto action_198
action_211 (31) = happyGoto action_244
action_211 (48) = happyGoto action_200
action_211 (49) = happyGoto action_201
action_211 _ = happyReduce_67

action_212 _ = happyReduce_78

action_213 _ = happyReduce_143

action_214 (90) = happyShift action_243
action_214 _ = happyFail (happyExpListPerState 214)

action_215 _ = happyReduce_97

action_216 (156) = happyShift action_242
action_216 _ = happyFail (happyExpListPerState 216)

action_217 (156) = happyShift action_241
action_217 _ = happyFail (happyExpListPerState 217)

action_218 _ = happyReduce_158

action_219 (147) = happyShift action_240
action_219 _ = happyFail (happyExpListPerState 219)

action_220 _ = happyReduce_32

action_221 (83) = happyShift action_59
action_221 (90) = happyShift action_60
action_221 (102) = happyShift action_61
action_221 (109) = happyShift action_62
action_221 (111) = happyShift action_63
action_221 (112) = happyShift action_64
action_221 (113) = happyShift action_65
action_221 (114) = happyShift action_66
action_221 (115) = happyShift action_67
action_221 (125) = happyShift action_68
action_221 (134) = happyShift action_69
action_221 (142) = happyShift action_70
action_221 (143) = happyShift action_71
action_221 (149) = happyShift action_72
action_221 (151) = happyShift action_73
action_221 (22) = happyGoto action_50
action_221 (33) = happyGoto action_239
action_221 (35) = happyGoto action_52
action_221 (37) = happyGoto action_53
action_221 (38) = happyGoto action_54
action_221 (39) = happyGoto action_55
action_221 (40) = happyGoto action_56
action_221 (43) = happyGoto action_57
action_221 (46) = happyGoto action_58
action_221 _ = happyFail (happyExpListPerState 221)

action_222 (144) = happyShift action_238
action_222 _ = happyFail (happyExpListPerState 222)

action_223 (99) = happyShift action_237
action_223 (18) = happyGoto action_235
action_223 (61) = happyGoto action_236
action_223 _ = happyReduce_140

action_224 _ = happyReduce_42

action_225 (143) = happyShift action_98
action_225 (147) = happyShift action_234
action_225 (65) = happyGoto action_97
action_225 _ = happyReduce_113

action_226 _ = happyReduce_31

action_227 _ = happyReduce_83

action_228 _ = happyReduce_171

action_229 (144) = happyShift action_233
action_229 _ = happyFail (happyExpListPerState 229)

action_230 (144) = happyReduce_148
action_230 (152) = happyShift action_232
action_230 _ = happyReduce_148

action_231 _ = happyReduce_39

action_232 (83) = happyShift action_59
action_232 (90) = happyShift action_60
action_232 (102) = happyShift action_61
action_232 (109) = happyShift action_62
action_232 (111) = happyShift action_63
action_232 (112) = happyShift action_64
action_232 (113) = happyShift action_65
action_232 (114) = happyShift action_66
action_232 (115) = happyShift action_67
action_232 (125) = happyShift action_68
action_232 (134) = happyShift action_69
action_232 (142) = happyShift action_70
action_232 (143) = happyShift action_71
action_232 (149) = happyShift action_72
action_232 (151) = happyShift action_73
action_232 (22) = happyGoto action_50
action_232 (33) = happyGoto action_227
action_232 (34) = happyGoto action_281
action_232 (35) = happyGoto action_52
action_232 (37) = happyGoto action_53
action_232 (38) = happyGoto action_54
action_232 (39) = happyGoto action_55
action_232 (40) = happyGoto action_56
action_232 (43) = happyGoto action_57
action_232 (46) = happyGoto action_58
action_232 _ = happyFail (happyExpListPerState 232)

action_233 _ = happyReduce_144

action_234 (83) = happyShift action_59
action_234 (90) = happyShift action_60
action_234 (102) = happyShift action_61
action_234 (109) = happyShift action_62
action_234 (111) = happyShift action_63
action_234 (112) = happyShift action_64
action_234 (113) = happyShift action_65
action_234 (114) = happyShift action_66
action_234 (115) = happyShift action_67
action_234 (125) = happyShift action_68
action_234 (134) = happyShift action_69
action_234 (142) = happyShift action_70
action_234 (143) = happyShift action_71
action_234 (149) = happyShift action_72
action_234 (151) = happyShift action_280
action_234 (22) = happyGoto action_50
action_234 (33) = happyGoto action_181
action_234 (35) = happyGoto action_52
action_234 (37) = happyGoto action_53
action_234 (38) = happyGoto action_54
action_234 (39) = happyGoto action_55
action_234 (40) = happyGoto action_56
action_234 (43) = happyGoto action_57
action_234 (46) = happyGoto action_58
action_234 _ = happyFail (happyExpListPerState 234)

action_235 _ = happyReduce_141

action_236 _ = happyReduce_41

action_237 (98) = happyShift action_279
action_237 _ = happyFail (happyExpListPerState 237)

action_238 (93) = happyShift action_38
action_238 (94) = happyShift action_39
action_238 (95) = happyShift action_40
action_238 (96) = happyShift action_41
action_238 (149) = happyShift action_44
action_238 (9) = happyGoto action_277
action_238 (15) = happyGoto action_278
action_238 _ = happyFail (happyExpListPerState 238)

action_239 (156) = happyShift action_276
action_239 _ = happyFail (happyExpListPerState 239)

action_240 (83) = happyShift action_59
action_240 (90) = happyShift action_60
action_240 (102) = happyShift action_61
action_240 (109) = happyShift action_62
action_240 (111) = happyShift action_63
action_240 (112) = happyShift action_64
action_240 (113) = happyShift action_65
action_240 (114) = happyShift action_66
action_240 (115) = happyShift action_67
action_240 (125) = happyShift action_68
action_240 (134) = happyShift action_69
action_240 (142) = happyShift action_70
action_240 (143) = happyShift action_71
action_240 (149) = happyShift action_72
action_240 (151) = happyShift action_73
action_240 (22) = happyGoto action_50
action_240 (33) = happyGoto action_275
action_240 (35) = happyGoto action_52
action_240 (37) = happyGoto action_53
action_240 (38) = happyGoto action_54
action_240 (39) = happyGoto action_55
action_240 (40) = happyGoto action_56
action_240 (43) = happyGoto action_57
action_240 (46) = happyGoto action_58
action_240 _ = happyFail (happyExpListPerState 240)

action_241 _ = happyReduce_34

action_242 _ = happyReduce_35

action_243 (144) = happyShift action_274
action_243 _ = happyFail (happyExpListPerState 243)

action_244 (143) = happyShift action_98
action_244 (65) = happyGoto action_273
action_244 _ = happyFail (happyExpListPerState 244)

action_245 (83) = happyShift action_59
action_245 (90) = happyShift action_60
action_245 (102) = happyShift action_61
action_245 (109) = happyShift action_62
action_245 (111) = happyShift action_63
action_245 (112) = happyShift action_64
action_245 (113) = happyShift action_65
action_245 (114) = happyShift action_66
action_245 (115) = happyShift action_67
action_245 (125) = happyShift action_68
action_245 (134) = happyShift action_69
action_245 (142) = happyShift action_70
action_245 (143) = happyShift action_71
action_245 (149) = happyShift action_72
action_245 (151) = happyShift action_73
action_245 (22) = happyGoto action_50
action_245 (33) = happyGoto action_272
action_245 (35) = happyGoto action_52
action_245 (37) = happyGoto action_53
action_245 (38) = happyGoto action_54
action_245 (39) = happyGoto action_55
action_245 (40) = happyGoto action_56
action_245 (43) = happyGoto action_57
action_245 (46) = happyGoto action_58
action_245 _ = happyFail (happyExpListPerState 245)

action_246 (151) = happyShift action_271
action_246 _ = happyFail (happyExpListPerState 246)

action_247 _ = happyReduce_68

action_248 _ = happyReduce_84

action_249 (130) = happyShift action_270
action_249 _ = happyFail (happyExpListPerState 249)

action_250 (83) = happyShift action_59
action_250 (90) = happyShift action_60
action_250 (102) = happyShift action_61
action_250 (109) = happyShift action_62
action_250 (111) = happyShift action_63
action_250 (112) = happyShift action_64
action_250 (113) = happyShift action_65
action_250 (114) = happyShift action_66
action_250 (115) = happyShift action_67
action_250 (125) = happyShift action_68
action_250 (134) = happyShift action_69
action_250 (142) = happyShift action_70
action_250 (143) = happyShift action_71
action_250 (149) = happyShift action_72
action_250 (151) = happyShift action_73
action_250 (22) = happyGoto action_50
action_250 (33) = happyGoto action_269
action_250 (35) = happyGoto action_52
action_250 (37) = happyGoto action_53
action_250 (38) = happyGoto action_54
action_250 (39) = happyGoto action_55
action_250 (40) = happyGoto action_56
action_250 (43) = happyGoto action_57
action_250 (46) = happyGoto action_58
action_250 _ = happyFail (happyExpListPerState 250)

action_251 (90) = happyShift action_60
action_251 (142) = happyShift action_70
action_251 (143) = happyShift action_71
action_251 (151) = happyShift action_73
action_251 (38) = happyGoto action_268
action_251 (39) = happyGoto action_55
action_251 (40) = happyGoto action_56
action_251 (43) = happyGoto action_57
action_251 (46) = happyGoto action_58
action_251 _ = happyFail (happyExpListPerState 251)

action_252 (83) = happyShift action_262
action_252 (85) = happyShift action_263
action_252 (86) = happyShift action_264
action_252 (126) = happyShift action_265
action_252 (127) = happyShift action_266
action_252 (147) = happyShift action_267
action_252 (25) = happyGoto action_256
action_252 (26) = happyGoto action_257
action_252 (27) = happyGoto action_258
action_252 (47) = happyGoto action_259
action_252 (50) = happyGoto action_260
action_252 (51) = happyGoto action_261
action_252 _ = happyFail (happyExpListPerState 252)

action_253 _ = happyReduce_172

action_254 (144) = happyShift action_255
action_254 _ = happyFail (happyExpListPerState 254)

action_255 _ = happyReduce_44

action_256 (151) = happyShift action_298
action_256 (23) = happyGoto action_297
action_256 _ = happyReduce_51

action_257 (151) = happyShift action_296
action_257 _ = happyFail (happyExpListPerState 257)

action_258 (150) = happyShift action_295
action_258 _ = happyFail (happyExpListPerState 258)

action_259 _ = happyReduce_54

action_260 _ = happyReduce_53

action_261 (150) = happyShift action_294
action_261 _ = happyFail (happyExpListPerState 261)

action_262 _ = happyReduce_60

action_263 _ = happyReduce_118

action_264 _ = happyReduce_124

action_265 _ = happyReduce_117

action_266 _ = happyReduce_123

action_267 (83) = happyShift action_262
action_267 (85) = happyShift action_263
action_267 (86) = happyShift action_264
action_267 (126) = happyShift action_265
action_267 (127) = happyShift action_266
action_267 (25) = happyGoto action_256
action_267 (26) = happyGoto action_257
action_267 (27) = happyGoto action_291
action_267 (47) = happyGoto action_259
action_267 (50) = happyGoto action_260
action_267 (70) = happyGoto action_292
action_267 (81) = happyGoto action_293
action_267 _ = happyReduce_153

action_268 (160) = happyShift action_290
action_268 _ = happyFail (happyExpListPerState 268)

action_269 (152) = happyShift action_289
action_269 _ = happyFail (happyExpListPerState 269)

action_270 (147) = happyShift action_288
action_270 _ = happyFail (happyExpListPerState 270)

action_271 (144) = happyShift action_287
action_271 _ = happyFail (happyExpListPerState 271)

action_272 (152) = happyShift action_286
action_272 _ = happyFail (happyExpListPerState 272)

action_273 (144) = happyShift action_285
action_273 _ = happyFail (happyExpListPerState 273)

action_274 _ = happyReduce_80

action_275 (152) = happyShift action_284
action_275 _ = happyFail (happyExpListPerState 275)

action_276 _ = happyReduce_33

action_277 (149) = happyShift action_44
action_277 (15) = happyGoto action_283
action_277 _ = happyFail (happyExpListPerState 277)

action_278 _ = happyReduce_36

action_279 (83) = happyShift action_59
action_279 (90) = happyShift action_60
action_279 (102) = happyShift action_61
action_279 (109) = happyShift action_62
action_279 (111) = happyShift action_63
action_279 (112) = happyShift action_64
action_279 (113) = happyShift action_65
action_279 (114) = happyShift action_66
action_279 (115) = happyShift action_67
action_279 (125) = happyShift action_68
action_279 (134) = happyShift action_69
action_279 (142) = happyShift action_70
action_279 (143) = happyShift action_71
action_279 (149) = happyShift action_72
action_279 (151) = happyShift action_73
action_279 (22) = happyGoto action_50
action_279 (33) = happyGoto action_282
action_279 (35) = happyGoto action_52
action_279 (37) = happyGoto action_53
action_279 (38) = happyGoto action_54
action_279 (39) = happyGoto action_55
action_279 (40) = happyGoto action_56
action_279 (43) = happyGoto action_57
action_279 (46) = happyGoto action_58
action_279 _ = happyFail (happyExpListPerState 279)

action_280 (143) = happyShift action_98
action_280 (147) = happyShift action_99
action_280 (148) = happyShift action_189
action_280 (65) = happyGoto action_97
action_280 _ = happyReduce_113

action_281 _ = happyReduce_170

action_282 _ = happyReduce_40

action_283 _ = happyReduce_37

action_284 (83) = happyShift action_59
action_284 (90) = happyShift action_60
action_284 (102) = happyShift action_61
action_284 (109) = happyShift action_62
action_284 (111) = happyShift action_63
action_284 (112) = happyShift action_64
action_284 (113) = happyShift action_65
action_284 (114) = happyShift action_66
action_284 (115) = happyShift action_67
action_284 (125) = happyShift action_68
action_284 (134) = happyShift action_69
action_284 (142) = happyShift action_70
action_284 (143) = happyShift action_71
action_284 (149) = happyShift action_72
action_284 (151) = happyShift action_73
action_284 (22) = happyGoto action_50
action_284 (33) = happyGoto action_307
action_284 (35) = happyGoto action_52
action_284 (37) = happyGoto action_53
action_284 (38) = happyGoto action_54
action_284 (39) = happyGoto action_55
action_284 (40) = happyGoto action_56
action_284 (43) = happyGoto action_57
action_284 (46) = happyGoto action_58
action_284 _ = happyFail (happyExpListPerState 284)

action_285 _ = happyReduce_85

action_286 (83) = happyShift action_59
action_286 (90) = happyShift action_60
action_286 (102) = happyShift action_61
action_286 (109) = happyShift action_62
action_286 (111) = happyShift action_63
action_286 (112) = happyShift action_64
action_286 (113) = happyShift action_65
action_286 (114) = happyShift action_66
action_286 (115) = happyShift action_67
action_286 (125) = happyShift action_68
action_286 (134) = happyShift action_69
action_286 (142) = happyShift action_70
action_286 (143) = happyShift action_71
action_286 (149) = happyShift action_72
action_286 (151) = happyShift action_73
action_286 (22) = happyGoto action_50
action_286 (33) = happyGoto action_306
action_286 (35) = happyGoto action_52
action_286 (37) = happyGoto action_53
action_286 (38) = happyGoto action_54
action_286 (39) = happyGoto action_55
action_286 (40) = happyGoto action_56
action_286 (43) = happyGoto action_57
action_286 (46) = happyGoto action_58
action_286 _ = happyFail (happyExpListPerState 286)

action_287 _ = happyReduce_73

action_288 (83) = happyShift action_59
action_288 (90) = happyShift action_60
action_288 (102) = happyShift action_61
action_288 (109) = happyShift action_62
action_288 (111) = happyShift action_63
action_288 (112) = happyShift action_64
action_288 (113) = happyShift action_65
action_288 (114) = happyShift action_66
action_288 (115) = happyShift action_67
action_288 (125) = happyShift action_68
action_288 (134) = happyShift action_69
action_288 (142) = happyShift action_70
action_288 (143) = happyShift action_71
action_288 (149) = happyShift action_72
action_288 (151) = happyShift action_73
action_288 (22) = happyGoto action_50
action_288 (33) = happyGoto action_305
action_288 (35) = happyGoto action_52
action_288 (37) = happyGoto action_53
action_288 (38) = happyGoto action_54
action_288 (39) = happyGoto action_55
action_288 (40) = happyGoto action_56
action_288 (43) = happyGoto action_57
action_288 (46) = happyGoto action_58
action_288 _ = happyFail (happyExpListPerState 288)

action_289 (83) = happyShift action_59
action_289 (90) = happyShift action_60
action_289 (102) = happyShift action_61
action_289 (109) = happyShift action_62
action_289 (111) = happyShift action_63
action_289 (112) = happyShift action_64
action_289 (113) = happyShift action_65
action_289 (114) = happyShift action_66
action_289 (115) = happyShift action_67
action_289 (125) = happyShift action_68
action_289 (134) = happyShift action_69
action_289 (142) = happyShift action_70
action_289 (143) = happyShift action_71
action_289 (149) = happyShift action_72
action_289 (151) = happyShift action_73
action_289 (22) = happyGoto action_50
action_289 (33) = happyGoto action_304
action_289 (35) = happyGoto action_52
action_289 (37) = happyGoto action_53
action_289 (38) = happyGoto action_54
action_289 (39) = happyGoto action_55
action_289 (40) = happyGoto action_56
action_289 (43) = happyGoto action_57
action_289 (46) = happyGoto action_58
action_289 _ = happyFail (happyExpListPerState 289)

action_290 (90) = happyShift action_60
action_290 (142) = happyShift action_70
action_290 (143) = happyShift action_71
action_290 (151) = happyShift action_73
action_290 (38) = happyGoto action_303
action_290 (39) = happyGoto action_55
action_290 (40) = happyGoto action_56
action_290 (43) = happyGoto action_57
action_290 (46) = happyGoto action_58
action_290 _ = happyFail (happyExpListPerState 290)

action_291 _ = happyReduce_175

action_292 (148) = happyShift action_302
action_292 _ = happyFail (happyExpListPerState 292)

action_293 (148) = happyReduce_152
action_293 (152) = happyShift action_301
action_293 _ = happyReduce_152

action_294 _ = happyReduce_46

action_295 _ = happyReduce_47

action_296 (130) = happyShift action_300
action_296 _ = happyFail (happyExpListPerState 296)

action_297 (155) = happyShift action_299
action_297 _ = happyFail (happyExpListPerState 297)

action_298 _ = happyReduce_50

action_299 (142) = happyShift action_315
action_299 _ = happyFail (happyExpListPerState 299)

action_300 (147) = happyShift action_314
action_300 (24) = happyGoto action_313
action_300 _ = happyFail (happyExpListPerState 300)

action_301 (83) = happyShift action_262
action_301 (85) = happyShift action_263
action_301 (86) = happyShift action_264
action_301 (126) = happyShift action_265
action_301 (127) = happyShift action_266
action_301 (25) = happyGoto action_256
action_301 (26) = happyGoto action_257
action_301 (27) = happyGoto action_312
action_301 (47) = happyGoto action_259
action_301 (50) = happyGoto action_260
action_301 _ = happyFail (happyExpListPerState 301)

action_302 _ = happyReduce_125

action_303 _ = happyReduce_48

action_304 (144) = happyShift action_311
action_304 _ = happyFail (happyExpListPerState 304)

action_305 (152) = happyShift action_310
action_305 _ = happyFail (happyExpListPerState 305)

action_306 (144) = happyShift action_309
action_306 _ = happyFail (happyExpListPerState 306)

action_307 (144) = happyShift action_308
action_307 _ = happyFail (happyExpListPerState 307)

action_308 (97) = happyShift action_323
action_308 _ = happyFail (happyExpListPerState 308)

action_309 (155) = happyShift action_322
action_309 _ = happyFail (happyExpListPerState 309)

action_310 (83) = happyShift action_59
action_310 (90) = happyShift action_60
action_310 (102) = happyShift action_61
action_310 (109) = happyShift action_62
action_310 (111) = happyShift action_63
action_310 (112) = happyShift action_64
action_310 (113) = happyShift action_65
action_310 (114) = happyShift action_66
action_310 (115) = happyShift action_67
action_310 (125) = happyShift action_68
action_310 (134) = happyShift action_69
action_310 (142) = happyShift action_70
action_310 (143) = happyShift action_71
action_310 (149) = happyShift action_72
action_310 (151) = happyShift action_73
action_310 (22) = happyGoto action_50
action_310 (33) = happyGoto action_321
action_310 (35) = happyGoto action_52
action_310 (37) = happyGoto action_53
action_310 (38) = happyGoto action_54
action_310 (39) = happyGoto action_55
action_310 (40) = happyGoto action_56
action_310 (43) = happyGoto action_57
action_310 (46) = happyGoto action_58
action_310 _ = happyFail (happyExpListPerState 310)

action_311 (165) = happyShift action_320
action_311 _ = happyFail (happyExpListPerState 311)

action_312 _ = happyReduce_174

action_313 (155) = happyShift action_319
action_313 _ = happyFail (happyExpListPerState 313)

action_314 (83) = happyShift action_59
action_314 (90) = happyShift action_60
action_314 (102) = happyShift action_61
action_314 (109) = happyShift action_62
action_314 (111) = happyShift action_63
action_314 (112) = happyShift action_64
action_314 (113) = happyShift action_65
action_314 (114) = happyShift action_66
action_314 (115) = happyShift action_67
action_314 (125) = happyShift action_68
action_314 (134) = happyShift action_69
action_314 (142) = happyShift action_70
action_314 (143) = happyShift action_71
action_314 (149) = happyShift action_72
action_314 (151) = happyShift action_73
action_314 (22) = happyGoto action_50
action_314 (33) = happyGoto action_318
action_314 (35) = happyGoto action_52
action_314 (37) = happyGoto action_53
action_314 (38) = happyGoto action_54
action_314 (39) = happyGoto action_55
action_314 (40) = happyGoto action_56
action_314 (43) = happyGoto action_57
action_314 (46) = happyGoto action_58
action_314 _ = happyFail (happyExpListPerState 314)

action_315 (83) = happyShift action_59
action_315 (90) = happyShift action_60
action_315 (102) = happyShift action_61
action_315 (109) = happyShift action_62
action_315 (111) = happyShift action_63
action_315 (112) = happyShift action_64
action_315 (113) = happyShift action_65
action_315 (114) = happyShift action_66
action_315 (115) = happyShift action_67
action_315 (125) = happyShift action_68
action_315 (134) = happyShift action_69
action_315 (137) = happyShift action_120
action_315 (139) = happyShift action_122
action_315 (142) = happyShift action_70
action_315 (143) = happyShift action_71
action_315 (149) = happyShift action_72
action_315 (151) = happyShift action_73
action_315 (22) = happyGoto action_50
action_315 (33) = happyGoto action_316
action_315 (35) = happyGoto action_52
action_315 (37) = happyGoto action_53
action_315 (38) = happyGoto action_54
action_315 (39) = happyGoto action_55
action_315 (40) = happyGoto action_56
action_315 (43) = happyGoto action_57
action_315 (44) = happyGoto action_317
action_315 (46) = happyGoto action_58
action_315 _ = happyFail (happyExpListPerState 315)

action_316 (131) = happyShift action_335
action_316 _ = happyFail (happyExpListPerState 316)

action_317 (131) = happyShift action_334
action_317 _ = happyFail (happyExpListPerState 317)

action_318 (152) = happyShift action_333
action_318 _ = happyFail (happyExpListPerState 318)

action_319 (122) = happyShift action_329
action_319 (123) = happyShift action_330
action_319 (124) = happyShift action_331
action_319 (142) = happyShift action_332
action_319 (28) = happyGoto action_327
action_319 (59) = happyGoto action_328
action_319 _ = happyReduce_61

action_320 _ = happyReduce_69

action_321 (144) = happyShift action_326
action_321 _ = happyFail (happyExpListPerState 321)

action_322 (143) = happyShift action_325
action_322 _ = happyFail (happyExpListPerState 322)

action_323 (90) = happyShift action_60
action_323 (142) = happyShift action_70
action_323 (143) = happyShift action_71
action_323 (151) = happyShift action_225
action_323 (19) = happyGoto action_324
action_323 (20) = happyGoto action_223
action_323 (21) = happyGoto action_75
action_323 (38) = happyGoto action_224
action_323 (39) = happyGoto action_55
action_323 (40) = happyGoto action_56
action_323 (43) = happyGoto action_57
action_323 (46) = happyGoto action_58
action_323 (58) = happyGoto action_76
action_323 (74) = happyGoto action_77
action_323 _ = happyReduce_135

action_324 (8) = happyGoto action_344
action_324 (53) = happyGoto action_21
action_324 (76) = happyGoto action_22
action_324 _ = happyReduce_164

action_325 (151) = happyShift action_343
action_325 _ = happyFail (happyExpListPerState 325)

action_326 (155) = happyShift action_342
action_326 _ = happyFail (happyExpListPerState 326)

action_327 (84) = happyShift action_202
action_327 (87) = happyShift action_203
action_327 (88) = happyShift action_204
action_327 (128) = happyShift action_205
action_327 (129) = happyShift action_206
action_327 (29) = happyGoto action_197
action_327 (30) = happyGoto action_198
action_327 (31) = happyGoto action_341
action_327 (48) = happyGoto action_200
action_327 (49) = happyGoto action_201
action_327 _ = happyReduce_67

action_328 _ = happyReduce_59

action_329 (143) = happyShift action_340
action_329 _ = happyFail (happyExpListPerState 329)

action_330 (143) = happyShift action_339
action_330 _ = happyFail (happyExpListPerState 330)

action_331 (143) = happyShift action_338
action_331 _ = happyFail (happyExpListPerState 331)

action_332 (83) = happyShift action_59
action_332 (90) = happyShift action_60
action_332 (102) = happyShift action_61
action_332 (109) = happyShift action_62
action_332 (111) = happyShift action_63
action_332 (112) = happyShift action_64
action_332 (113) = happyShift action_65
action_332 (114) = happyShift action_66
action_332 (115) = happyShift action_67
action_332 (125) = happyShift action_68
action_332 (134) = happyShift action_69
action_332 (142) = happyShift action_70
action_332 (143) = happyShift action_71
action_332 (149) = happyShift action_72
action_332 (151) = happyShift action_73
action_332 (22) = happyGoto action_50
action_332 (33) = happyGoto action_337
action_332 (35) = happyGoto action_52
action_332 (37) = happyGoto action_53
action_332 (38) = happyGoto action_54
action_332 (39) = happyGoto action_55
action_332 (40) = happyGoto action_56
action_332 (43) = happyGoto action_57
action_332 (46) = happyGoto action_58
action_332 _ = happyFail (happyExpListPerState 332)

action_333 (83) = happyShift action_59
action_333 (90) = happyShift action_60
action_333 (102) = happyShift action_61
action_333 (109) = happyShift action_62
action_333 (111) = happyShift action_63
action_333 (112) = happyShift action_64
action_333 (113) = happyShift action_65
action_333 (114) = happyShift action_66
action_333 (115) = happyShift action_67
action_333 (125) = happyShift action_68
action_333 (134) = happyShift action_69
action_333 (142) = happyShift action_70
action_333 (143) = happyShift action_71
action_333 (149) = happyShift action_72
action_333 (151) = happyShift action_73
action_333 (22) = happyGoto action_50
action_333 (33) = happyGoto action_336
action_333 (35) = happyGoto action_52
action_333 (37) = happyGoto action_53
action_333 (38) = happyGoto action_54
action_333 (39) = happyGoto action_55
action_333 (40) = happyGoto action_56
action_333 (43) = happyGoto action_57
action_333 (46) = happyGoto action_58
action_333 _ = happyFail (happyExpListPerState 333)

action_334 _ = happyReduce_55

action_335 _ = happyReduce_56

action_336 (144) = happyShift action_354
action_336 _ = happyFail (happyExpListPerState 336)

action_337 (131) = happyShift action_353
action_337 _ = happyFail (happyExpListPerState 337)

action_338 (83) = happyShift action_59
action_338 (90) = happyShift action_60
action_338 (102) = happyShift action_61
action_338 (109) = happyShift action_62
action_338 (111) = happyShift action_63
action_338 (112) = happyShift action_64
action_338 (113) = happyShift action_65
action_338 (114) = happyShift action_66
action_338 (115) = happyShift action_67
action_338 (125) = happyShift action_68
action_338 (134) = happyShift action_69
action_338 (142) = happyShift action_70
action_338 (143) = happyShift action_71
action_338 (149) = happyShift action_72
action_338 (151) = happyShift action_73
action_338 (22) = happyGoto action_50
action_338 (33) = happyGoto action_352
action_338 (35) = happyGoto action_52
action_338 (37) = happyGoto action_53
action_338 (38) = happyGoto action_54
action_338 (39) = happyGoto action_55
action_338 (40) = happyGoto action_56
action_338 (43) = happyGoto action_57
action_338 (46) = happyGoto action_58
action_338 _ = happyFail (happyExpListPerState 338)

action_339 (83) = happyShift action_59
action_339 (90) = happyShift action_60
action_339 (102) = happyShift action_61
action_339 (109) = happyShift action_62
action_339 (111) = happyShift action_63
action_339 (112) = happyShift action_64
action_339 (113) = happyShift action_65
action_339 (114) = happyShift action_66
action_339 (115) = happyShift action_67
action_339 (125) = happyShift action_68
action_339 (134) = happyShift action_69
action_339 (142) = happyShift action_70
action_339 (143) = happyShift action_71
action_339 (149) = happyShift action_72
action_339 (151) = happyShift action_73
action_339 (22) = happyGoto action_50
action_339 (33) = happyGoto action_351
action_339 (35) = happyGoto action_52
action_339 (37) = happyGoto action_53
action_339 (38) = happyGoto action_54
action_339 (39) = happyGoto action_55
action_339 (40) = happyGoto action_56
action_339 (43) = happyGoto action_57
action_339 (46) = happyGoto action_58
action_339 _ = happyFail (happyExpListPerState 339)

action_340 (83) = happyShift action_59
action_340 (90) = happyShift action_60
action_340 (102) = happyShift action_61
action_340 (109) = happyShift action_62
action_340 (111) = happyShift action_63
action_340 (112) = happyShift action_64
action_340 (113) = happyShift action_65
action_340 (114) = happyShift action_66
action_340 (115) = happyShift action_67
action_340 (125) = happyShift action_68
action_340 (134) = happyShift action_69
action_340 (142) = happyShift action_70
action_340 (143) = happyShift action_71
action_340 (149) = happyShift action_72
action_340 (151) = happyShift action_73
action_340 (22) = happyGoto action_50
action_340 (33) = happyGoto action_350
action_340 (35) = happyGoto action_52
action_340 (37) = happyGoto action_53
action_340 (38) = happyGoto action_54
action_340 (39) = happyGoto action_55
action_340 (40) = happyGoto action_56
action_340 (43) = happyGoto action_57
action_340 (46) = happyGoto action_58
action_340 _ = happyFail (happyExpListPerState 340)

action_341 (86) = happyShift action_264
action_341 (127) = happyShift action_266
action_341 (143) = happyShift action_98
action_341 (25) = happyGoto action_348
action_341 (50) = happyGoto action_260
action_341 (65) = happyGoto action_349
action_341 _ = happyFail (happyExpListPerState 341)

action_342 (143) = happyShift action_347
action_342 _ = happyFail (happyExpListPerState 342)

action_343 (152) = happyShift action_346
action_343 _ = happyFail (happyExpListPerState 343)

action_344 (149) = happyShift action_44
action_344 (15) = happyGoto action_345
action_344 _ = happyFail (happyExpListPerState 344)

action_345 _ = happyReduce_38

action_346 (151) = happyShift action_361
action_346 _ = happyFail (happyExpListPerState 346)

action_347 (83) = happyShift action_59
action_347 (90) = happyShift action_60
action_347 (102) = happyShift action_61
action_347 (109) = happyShift action_62
action_347 (111) = happyShift action_63
action_347 (112) = happyShift action_64
action_347 (113) = happyShift action_65
action_347 (114) = happyShift action_66
action_347 (115) = happyShift action_67
action_347 (125) = happyShift action_68
action_347 (134) = happyShift action_69
action_347 (142) = happyShift action_70
action_347 (143) = happyShift action_71
action_347 (149) = happyShift action_72
action_347 (151) = happyShift action_73
action_347 (22) = happyGoto action_50
action_347 (33) = happyGoto action_360
action_347 (35) = happyGoto action_52
action_347 (37) = happyGoto action_53
action_347 (38) = happyGoto action_54
action_347 (39) = happyGoto action_55
action_347 (40) = happyGoto action_56
action_347 (43) = happyGoto action_57
action_347 (46) = happyGoto action_58
action_347 _ = happyFail (happyExpListPerState 347)

action_348 (151) = happyShift action_359
action_348 _ = happyFail (happyExpListPerState 348)

action_349 _ = happyReduce_57

action_350 (152) = happyShift action_358
action_350 _ = happyFail (happyExpListPerState 350)

action_351 (144) = happyShift action_357
action_351 _ = happyFail (happyExpListPerState 351)

action_352 (144) = happyShift action_356
action_352 _ = happyFail (happyExpListPerState 352)

action_353 (142) = happyShift action_332
action_353 (59) = happyGoto action_355
action_353 _ = happyReduce_136

action_354 _ = happyReduce_52

action_355 _ = happyReduce_137

action_356 _ = happyReduce_64

action_357 _ = happyReduce_63

action_358 (83) = happyShift action_59
action_358 (90) = happyShift action_60
action_358 (102) = happyShift action_61
action_358 (109) = happyShift action_62
action_358 (111) = happyShift action_63
action_358 (112) = happyShift action_64
action_358 (113) = happyShift action_65
action_358 (114) = happyShift action_66
action_358 (115) = happyShift action_67
action_358 (125) = happyShift action_68
action_358 (134) = happyShift action_69
action_358 (142) = happyShift action_70
action_358 (143) = happyShift action_71
action_358 (149) = happyShift action_72
action_358 (151) = happyShift action_73
action_358 (22) = happyGoto action_50
action_358 (33) = happyGoto action_365
action_358 (35) = happyGoto action_52
action_358 (37) = happyGoto action_53
action_358 (38) = happyGoto action_54
action_358 (39) = happyGoto action_55
action_358 (40) = happyGoto action_56
action_358 (43) = happyGoto action_57
action_358 (46) = happyGoto action_58
action_358 _ = happyFail (happyExpListPerState 358)

action_359 (130) = happyShift action_364
action_359 _ = happyFail (happyExpListPerState 359)

action_360 (152) = happyShift action_363
action_360 _ = happyFail (happyExpListPerState 360)

action_361 (144) = happyShift action_362
action_361 _ = happyFail (happyExpListPerState 361)

action_362 _ = happyReduce_74

action_363 (83) = happyShift action_59
action_363 (90) = happyShift action_60
action_363 (102) = happyShift action_61
action_363 (109) = happyShift action_62
action_363 (111) = happyShift action_63
action_363 (112) = happyShift action_64
action_363 (113) = happyShift action_65
action_363 (114) = happyShift action_66
action_363 (115) = happyShift action_67
action_363 (125) = happyShift action_68
action_363 (134) = happyShift action_69
action_363 (142) = happyShift action_70
action_363 (143) = happyShift action_71
action_363 (149) = happyShift action_72
action_363 (151) = happyShift action_73
action_363 (22) = happyGoto action_50
action_363 (33) = happyGoto action_368
action_363 (35) = happyGoto action_52
action_363 (37) = happyGoto action_53
action_363 (38) = happyGoto action_54
action_363 (39) = happyGoto action_55
action_363 (40) = happyGoto action_56
action_363 (43) = happyGoto action_57
action_363 (46) = happyGoto action_58
action_363 _ = happyFail (happyExpListPerState 363)

action_364 (147) = happyShift action_314
action_364 (24) = happyGoto action_367
action_364 _ = happyFail (happyExpListPerState 364)

action_365 (144) = happyShift action_366
action_365 _ = happyFail (happyExpListPerState 365)

action_366 _ = happyReduce_62

action_367 (155) = happyShift action_370
action_367 _ = happyFail (happyExpListPerState 367)

action_368 (144) = happyShift action_369
action_368 _ = happyFail (happyExpListPerState 368)

action_369 (165) = happyShift action_372
action_369 _ = happyFail (happyExpListPerState 369)

action_370 (143) = happyShift action_98
action_370 (65) = happyGoto action_371
action_370 _ = happyFail (happyExpListPerState 370)

action_371 _ = happyReduce_58

action_372 _ = happyReduce_70

happyReduce_1 = happySpecReduce_1  4 happyReduction_1
happyReduction_1 (HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn4
		 (happy_var_1
	)
happyReduction_1 _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_1  5 happyReduction_2
happyReduction_2 (HappyAbsSyn55  happy_var_1)
	 =  HappyAbsSyn5
		 (happy_var_1
	)
happyReduction_2 _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_1  6 happyReduction_3
happyReduction_3 (HappyTerminal (( _, L.TDafny happy_var_1  )))
	 =  HappyAbsSyn6
		 (inj (QDafny happy_var_1)
	)
happyReduction_3 _  = notHappyAtAll 

happyReduce_4 = happyMonadReduce 6 6 happyReduction_4
happyReduction_4 ((HappyAbsSyn60  happy_var_6) `HappyStk`
	(HappyAbsSyn8  happy_var_5) `HappyStk`
	(HappyAbsSyn7  happy_var_4) `HappyStk`
	(HappyAbsSyn62  happy_var_3) `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_2     ))) `HappyStk`
	_ `HappyStk`
	happyRest) tk
	 = happyThen (((  ((\(rs, es) -> inj (QMethod happy_var_2 happy_var_3 happy_var_4 rs es happy_var_6)) `fmap` (requireEnsures happy_var_5))))
	) (\r -> happyReturn (HappyAbsSyn6 r))

happyReduce_5 = happySpecReduce_0  7 happyReduction_5
happyReduction_5  =  HappyAbsSyn7
		 ([]
	)

happyReduce_6 = happyReduce 4 7 happyReduction_6
happyReduction_6 (_ `HappyStk`
	(HappyAbsSyn10  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn7
		 (happy_var_3
	) `HappyStk` happyRest

happyReduce_7 = happySpecReduce_1  8 happyReduction_7
happyReduction_7 (HappyAbsSyn53  happy_var_1)
	 =  HappyAbsSyn8
		 (happy_var_1
	)
happyReduction_7 _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_2  9 happyReduction_8
happyReduction_8 (HappyAbsSyn33  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (Requires happy_var_2
	)
happyReduction_8 _ _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_2  9 happyReduction_9
happyReduction_9 (HappyAbsSyn33  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (Ensures happy_var_2
	)
happyReduction_9 _ _  = notHappyAtAll 

happyReduce_10 = happySpecReduce_2  9 happyReduction_10
happyReduction_10 (HappyAbsSyn33  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (Invariants happy_var_2
	)
happyReduction_10 _ _  = notHappyAtAll 

happyReduce_11 = happySpecReduce_2  9 happyReduction_11
happyReduction_11 (HappyAbsSyn20  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (Separates happy_var_2
	)
happyReduction_11 _ _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_1  10 happyReduction_12
happyReduction_12 (HappyAbsSyn56  happy_var_1)
	 =  HappyAbsSyn10
		 (happy_var_1
	)
happyReduction_12 _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_3  11 happyReduction_13
happyReduction_13 (HappyAbsSyn12  happy_var_3)
	_
	(HappyTerminal (( _, L.TId happy_var_1     )))
	 =  HappyAbsSyn11
		 (Binding happy_var_1 happy_var_3
	)
happyReduction_13 _ _ _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_1  12 happyReduction_14
happyReduction_14 (HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn12
		 (happy_var_1
	)
happyReduction_14 _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_3  12 happyReduction_15
happyReduction_15 (HappyAbsSyn12  happy_var_3)
	_
	(HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn12
		 (TArrow [happy_var_1] happy_var_3
	)
happyReduction_15 _ _ _  = notHappyAtAll 

happyReduce_16 = happySpecReduce_3  12 happyReduction_16
happyReduction_16 (HappyAbsSyn12  happy_var_3)
	_
	(HappyAbsSyn67  happy_var_1)
	 =  HappyAbsSyn12
		 (TArrow happy_var_1   happy_var_3
	)
happyReduction_16 _ _ _  = notHappyAtAll 

happyReduce_17 = happySpecReduce_1  13 happyReduction_17
happyReduction_17 _
	 =  HappyAbsSyn13
		 (TNat
	)

happyReduce_18 = happySpecReduce_1  13 happyReduction_18
happyReduction_18 _
	 =  HappyAbsSyn13
		 (TReal
	)

happyReduce_19 = happySpecReduce_1  13 happyReduction_19
happyReduction_19 _
	 =  HappyAbsSyn13
		 (TInt
	)

happyReduce_20 = happySpecReduce_1  13 happyReduction_20
happyReduction_20 _
	 =  HappyAbsSyn13
		 (TBool
	)

happyReduce_21 = happySpecReduce_3  13 happyReduction_21
happyReduction_21 _
	(HappyAbsSyn12  happy_var_2)
	_
	 =  HappyAbsSyn13
		 (TSeq happy_var_2
	)
happyReduction_21 _ _ _  = notHappyAtAll 

happyReduce_22 = happyReduce 4 13 happyReduction_22
happyReduction_22 (_ `HappyStk`
	(HappyTerminal (( _, L.TLitInt happy_var_3 ))) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn13
		 (TQReg (ANat happy_var_3)
	) `HappyStk` happyRest

happyReduce_23 = happyReduce 4 13 happyReduction_23
happyReduction_23 (_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_3     ))) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn13
		 (TQReg (AVar happy_var_3)
	) `HappyStk` happyRest

happyReduce_24 = happySpecReduce_1  14 happyReduction_24
happyReduction_24 _
	 =  HappyAbsSyn14
		 (TNor
	)

happyReduce_25 = happySpecReduce_1  14 happyReduction_25
happyReduction_25 _
	 =  HappyAbsSyn14
		 (THad
	)

happyReduce_26 = happySpecReduce_1  14 happyReduction_26
happyReduction_26 _
	 =  HappyAbsSyn14
		 (TEn
	)

happyReduce_27 = happySpecReduce_1  14 happyReduction_27
happyReduction_27 _
	 =  HappyAbsSyn14
		 (TEn01
	)

happyReduce_28 = happySpecReduce_3  15 happyReduction_28
happyReduction_28 _
	(HappyAbsSyn16  happy_var_2)
	_
	 =  HappyAbsSyn15
		 (Block happy_var_2
	)
happyReduction_28 _ _ _  = notHappyAtAll 

happyReduce_29 = happySpecReduce_1  16 happyReduction_29
happyReduction_29 (HappyAbsSyn54  happy_var_1)
	 =  HappyAbsSyn16
		 (happy_var_1
	)
happyReduction_29 _  = notHappyAtAll 

happyReduce_30 = happySpecReduce_1  17 happyReduction_30
happyReduction_30 (HappyTerminal (( _, L.TDafny happy_var_1  )))
	 =  HappyAbsSyn17
		 (SDafny happy_var_1
	)
happyReduction_30 _  = notHappyAtAll 

happyReduce_31 = happySpecReduce_3  17 happyReduction_31
happyReduction_31 _
	(HappyAbsSyn33  happy_var_2)
	_
	 =  HappyAbsSyn17
		 (SAssert happy_var_2
	)
happyReduction_31 _ _ _  = notHappyAtAll 

happyReduce_32 = happySpecReduce_3  17 happyReduction_32
happyReduction_32 _
	(HappyAbsSyn11  happy_var_2)
	_
	 =  HappyAbsSyn17
		 (SVar happy_var_2 Nothing
	)
happyReduction_32 _ _ _  = notHappyAtAll 

happyReduce_33 = happyReduce 5 17 happyReduction_33
happyReduction_33 (_ `HappyStk`
	(HappyAbsSyn33  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn11  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 (SVar happy_var_2 (Just happy_var_4)
	) `HappyStk` happyRest

happyReduce_34 = happyReduce 4 17 happyReduction_34
happyReduction_34 (_ `HappyStk`
	(HappyAbsSyn33  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn57  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 (happy_var_1 ::=: happy_var_3
	) `HappyStk` happyRest

happyReduce_35 = happyReduce 4 17 happyReduction_35
happyReduction_35 (_ `HappyStk`
	(HappyAbsSyn33  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn20  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 (happy_var_1 :*=: happy_var_3
	) `HappyStk` happyRest

happyReduce_36 = happyReduce 5 17 happyReduction_36
happyReduction_36 ((HappyAbsSyn15  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn19  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 (SIf happy_var_3 (Partition {ranges = []}) happy_var_5
	) `HappyStk` happyRest

happyReduce_37 = happyMonadReduce 6 17 happyReduction_37
happyReduction_37 ((HappyAbsSyn15  happy_var_6) `HappyStk`
	(HappyAbsSyn9  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn19  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest) tk
	 = happyThen ((( do sep <- separatesOnly happy_var_5; return $ SIf happy_var_3 sep happy_var_6))
	) (\r -> happyReturn (HappyAbsSyn17 r))

happyReduce_38 = happyMonadReduce 12 17 happyReduction_38
happyReduction_38 ((HappyAbsSyn15  happy_var_12) `HappyStk`
	(HappyAbsSyn8  happy_var_11) `HappyStk`
	(HappyAbsSyn19  happy_var_10) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_7) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_5) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_2     ))) `HappyStk`
	_ `HappyStk`
	happyRest) tk
	 = happyThen ((( do (invs, sep) <- invariantSeperates happy_var_11; return $ SFor happy_var_2 happy_var_5 happy_var_7 happy_var_10 invs sep happy_var_12))
	) (\r -> happyReturn (HappyAbsSyn17 r))

happyReduce_39 = happySpecReduce_3  17 happyReduction_39
happyReduction_39 _
	(HappyAbsSyn64  happy_var_2)
	(HappyTerminal (( _, L.TId happy_var_1     )))
	 =  HappyAbsSyn17
		 (SCall happy_var_1 happy_var_2
	)
happyReduction_39 _ _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_3  18 happyReduction_40
happyReduction_40 (HappyAbsSyn33  happy_var_3)
	_
	_
	 =  HappyAbsSyn18
		 (happy_var_3
	)
happyReduction_40 _ _ _  = notHappyAtAll 

happyReduce_41 = happySpecReduce_2  19 happyReduction_41
happyReduction_41 (HappyAbsSyn61  happy_var_2)
	(HappyAbsSyn20  happy_var_1)
	 =  HappyAbsSyn19
		 (GEPartition happy_var_1 happy_var_2
	)
happyReduction_41 _ _  = notHappyAtAll 

happyReduce_42 = happySpecReduce_1  19 happyReduction_42
happyReduction_42 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn19
		 (GClass happy_var_1
	)
happyReduction_42 _  = notHappyAtAll 

happyReduce_43 = happySpecReduce_1  20 happyReduction_43
happyReduction_43 (HappyAbsSyn58  happy_var_1)
	 =  HappyAbsSyn20
		 (Partition $ happy_var_1
	)
happyReduction_43 _  = notHappyAtAll 

happyReduce_44 = happyReduce 6 21 happyReduction_44
happyReduction_44 (_ `HappyStk`
	(HappyAbsSyn33  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_1     ))) `HappyStk`
	happyRest)
	 = HappyAbsSyn21
		 (Range happy_var_1 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_45 = happyReduce 4 21 happyReduction_45
happyReduction_45 (_ `HappyStk`
	(HappyAbsSyn33  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_1     ))) `HappyStk`
	happyRest)
	 = HappyAbsSyn21
		 (Range happy_var_1 happy_var_3 (EOp2 OAdd happy_var_3 (ENum 1))
	) `HappyStk` happyRest

happyReduce_46 = happyReduce 7 22 happyReduction_46
happyReduction_46 (_ `HappyStk`
	(HappyAbsSyn51  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn14  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn20  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn18
		 (ESpec happy_var_2 happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_47 = happyReduce 7 22 happyReduction_47
happyReduction_47 (_ `HappyStk`
	(HappyAbsSyn27  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn14  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn20  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn18
		 (ESpec happy_var_2 happy_var_4 [happy_var_6]
	) `HappyStk` happyRest

happyReduce_48 = happyReduce 8 22 happyReduction_48
happyReduction_48 ((HappyAbsSyn18  happy_var_8) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn18  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn13  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_2     ))) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn18
		 (EForall (Binding happy_var_2 happy_var_4) (Just happy_var_6) happy_var_8
	) `HappyStk` happyRest

happyReduce_49 = happySpecReduce_3  22 happyReduction_49
happyReduction_49 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (ECPec (Just happy_var_1) happy_var_3
	)
happyReduction_49 _ _ _  = notHappyAtAll 

happyReduce_50 = happySpecReduce_1  23 happyReduction_50
happyReduction_50 (HappyTerminal (( _, L.TId happy_var_1     )))
	 =  HappyAbsSyn23
		 (happy_var_1
	)
happyReduction_50 _  = notHappyAtAll 

happyReduce_51 = happySpecReduce_0  23 happyReduction_51
happyReduction_51  =  HappyAbsSyn23
		 ("_"
	)

happyReduce_52 = happyReduce 5 24 happyReduction_52
happyReduction_52 (_ `HappyStk`
	(HappyAbsSyn33  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn24
		 (Intv happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_53 = happySpecReduce_1  25 happyReduction_53
happyReduction_53 (HappyAbsSyn50  happy_var_1)
	 =  HappyAbsSyn25
		 (happy_var_1
	)
happyReduction_53 _  = notHappyAtAll 

happyReduce_54 = happySpecReduce_1  26 happyReduction_54
happyReduction_54 (HappyAbsSyn47  happy_var_1)
	 =  HappyAbsSyn26
		 (happy_var_1
	)
happyReduction_54 _  = notHappyAtAll 

happyReduce_55 = happyReduce 6 27 happyReduction_55
happyReduction_55 (_ `HappyStk`
	(HappyAbsSyn42  happy_var_5) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn23  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn27
		 (SESpecHad (SpecHadF happy_var_2 (if happy_var_5 == OAdd then (PhaseOmega (ENum 0) (ENum 2)) else (PhaseOmega (ENum 1) (ENum 2))))
	) `HappyStk` happyRest

happyReduce_56 = happyReduce 6 27 happyReduction_56
happyReduction_56 (_ `HappyStk`
	(HappyAbsSyn33  happy_var_5) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn23  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn27
		 (SESpecNor (SpecNorF happy_var_2 happy_var_5)
	) `HappyStk` happyRest

happyReduce_57 = happyReduce 8 27 happyReduction_57
happyReduction_57 ((HappyAbsSyn65  happy_var_8) `HappyStk`
	(HappyAbsSyn31  happy_var_7) `HappyStk`
	(HappyAbsSyn28  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn24  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_2     ))) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn27
		 (SESpecEn (SpecEnF happy_var_2 happy_var_4 happy_var_6 happy_var_7 happy_var_8)
	) `HappyStk` happyRest

happyReduce_58 = happyReduce 13 27 happyReduction_58
happyReduction_58 ((HappyAbsSyn65  happy_var_13) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn24  happy_var_11) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_9     ))) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn31  happy_var_7) `HappyStk`
	(HappyAbsSyn28  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn24  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_2     ))) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn27
		 (SESpecEn01 (SpecEn01F happy_var_2 happy_var_4 happy_var_6 happy_var_7 happy_var_9 happy_var_11 happy_var_13)
	) `HappyStk` happyRest

happyReduce_59 = happyReduce 6 27 happyReduction_59
happyReduction_59 ((HappyAbsSyn59  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn24  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_2     ))) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn27
		 (SESpecEn (SpecEnF happy_var_2 happy_var_4 ADefault (PhaseOmega (ENum 0) (ENum 1)) happy_var_6)
	) `HappyStk` happyRest

happyReduce_60 = happySpecReduce_1  27 happyReduction_60
happyReduction_60 _
	 =  HappyAbsSyn27
		 (SEWildcard
	)

happyReduce_61 = happySpecReduce_0  28 happyReduction_61
happyReduction_61  =  HappyAbsSyn28
		 (ADefault
	)

happyReduce_62 = happyReduce 6 28 happyReduction_62
happyReduction_62 (_ `HappyStk`
	(HappyAbsSyn33  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (AISqrt happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_63 = happyReduce 4 28 happyReduction_63
happyReduction_63 (_ `HappyStk`
	(HappyAbsSyn33  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (ASin happy_var_3
	) `HappyStk` happyRest

happyReduce_64 = happyReduce 4 28 happyReduction_64
happyReduction_64 (_ `HappyStk`
	(HappyAbsSyn33  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (ACos happy_var_3
	) `HappyStk` happyRest

happyReduce_65 = happySpecReduce_1  29 happyReduction_65
happyReduction_65 (HappyAbsSyn49  happy_var_1)
	 =  HappyAbsSyn29
		 (happy_var_1
	)
happyReduction_65 _  = notHappyAtAll 

happyReduce_66 = happySpecReduce_1  30 happyReduction_66
happyReduction_66 (HappyAbsSyn48  happy_var_1)
	 =  HappyAbsSyn30
		 (happy_var_1
	)
happyReduction_66 _  = notHappyAtAll 

happyReduce_67 = happySpecReduce_0  31 happyReduction_67
happyReduction_67  =  HappyAbsSyn31
		 (PhaseWildCard
	)

happyReduce_68 = happySpecReduce_2  31 happyReduction_68
happyReduction_68 _
	_
	 =  HappyAbsSyn31
		 (PhaseZ
	)

happyReduce_69 = happyReduce 7 31 happyReduction_69
happyReduction_69 (_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn31
		 (PhaseOmega happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_70 = happyReduce 15 31 happyReduction_70
happyReduction_70 (_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_13) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_11) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_7) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_5) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_2     ))) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn31
		 (PhaseSumOmega (Range happy_var_2 happy_var_5 happy_var_7) happy_var_11 happy_var_13
	) `HappyStk` happyRest

happyReduce_71 = happySpecReduce_1  32 happyReduction_71
happyReduction_71 _
	 =  HappyAbsSyn32
		 (PhaseWildCard
	)

happyReduce_72 = happySpecReduce_1  32 happyReduction_72
happyReduction_72 _
	 =  HappyAbsSyn32
		 (PhaseZ
	)

happyReduce_73 = happyReduce 6 32 happyReduction_73
happyReduction_73 (_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_5     ))) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_3     ))) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn32
		 (PhaseOmega happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_74 = happyReduce 14 32 happyReduction_74
happyReduction_74 (_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_13     ))) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_11     ))) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_7) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_5) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_2     ))) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn32
		 (PhaseSumOmega (Range happy_var_2 happy_var_5 happy_var_7) happy_var_11 happy_var_13
	) `HappyStk` happyRest

happyReduce_75 = happySpecReduce_1  33 happyReduction_75
happyReduction_75 _
	 =  HappyAbsSyn33
		 (EWildcard
	)

happyReduce_76 = happySpecReduce_1  33 happyReduction_76
happyReduction_76 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn33
		 (happy_var_1
	)
happyReduction_76 _  = notHappyAtAll 

happyReduce_77 = happySpecReduce_1  33 happyReduction_77
happyReduction_77 (HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn33
		 (happy_var_1
	)
happyReduction_77 _  = notHappyAtAll 

happyReduce_78 = happyReduce 4 33 happyReduction_78
happyReduction_78 (_ `HappyStk`
	(HappyAbsSyn20  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn33
		 (EMeasure happy_var_3
	) `HappyStk` happyRest

happyReduce_79 = happySpecReduce_2  33 happyReduction_79
happyReduction_79 (HappyAbsSyn46  happy_var_2)
	_
	 =  HappyAbsSyn33
		 (EOp1 ONot happy_var_2
	)
happyReduction_79 _ _  = notHappyAtAll 

happyReduce_80 = happyReduce 6 33 happyReduction_80
happyReduction_80 (_ `HappyStk`
	(HappyTerminal (( _, L.TLitInt happy_var_5 ))) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn46  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn33
		 (EOp2 ONor happy_var_3 (ENum happy_var_5)
	) `HappyStk` happyRest

happyReduce_81 = happySpecReduce_2  33 happyReduction_81
happyReduction_81 (HappyAbsSyn63  happy_var_2)
	_
	 =  HappyAbsSyn33
		 (ERepr happy_var_2
	)
happyReduction_81 _ _  = notHappyAtAll 

happyReduce_82 = happySpecReduce_1  33 happyReduction_82
happyReduction_82 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn33
		 (happy_var_1
	)
happyReduction_82 _  = notHappyAtAll 

happyReduce_83 = happySpecReduce_1  34 happyReduction_83
happyReduction_83 (HappyAbsSyn33  happy_var_1)
	 =  HappyAbsSyn34
		 (happy_var_1
	)
happyReduction_83 _  = notHappyAtAll 

happyReduce_84 = happyReduce 5 35 happyReduction_84
happyReduction_84 ((HappyAbsSyn65  happy_var_5) `HappyStk`
	(HappyAbsSyn31  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn36  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn18
		 (let (bPhase, bBases) = happy_var_2
      in ELambda (LambdaF { bPhase, bBases, ePhase = happy_var_4, eBases = happy_var_5 })
	) `HappyStk` happyRest

happyReduce_85 = happyReduce 7 35 happyReduction_85
happyReduction_85 (_ `HappyStk`
	(HappyAbsSyn65  happy_var_6) `HappyStk`
	(HappyAbsSyn31  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn36  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn18
		 (let (bPhase, bBases) = happy_var_3
      in ELambda (LambdaF { bPhase, bBases, ePhase = happy_var_5, eBases = happy_var_6 })
	) `HappyStk` happyRest

happyReduce_86 = happySpecReduce_3  36 happyReduction_86
happyReduction_86 (HappyAbsSyn66  happy_var_3)
	_
	(HappyAbsSyn32  happy_var_1)
	 =  HappyAbsSyn36
		 ((happy_var_1, happy_var_3)
	)
happyReduction_86 _ _ _  = notHappyAtAll 

happyReduce_87 = happySpecReduce_1  36 happyReduction_87
happyReduction_87 (HappyAbsSyn66  happy_var_1)
	 =  HappyAbsSyn36
		 ((PhaseWildCard, happy_var_1)
	)
happyReduction_87 _  = notHappyAtAll 

happyReduce_88 = happySpecReduce_1  36 happyReduction_88
happyReduction_88 (HappyTerminal (( _, L.TId happy_var_1     )))
	 =  HappyAbsSyn36
		 ((PhaseWildCard, [happy_var_1])
	)
happyReduction_88 _  = notHappyAtAll 

happyReduce_89 = happySpecReduce_1  37 happyReduction_89
happyReduction_89 _
	 =  HappyAbsSyn37
		 (EHad
	)

happyReduce_90 = happySpecReduce_1  37 happyReduction_90
happyReduction_90 _
	 =  HappyAbsSyn37
		 (EQft False
	)

happyReduce_91 = happySpecReduce_1  37 happyReduction_91
happyReduction_91 _
	 =  HappyAbsSyn37
		 (EQft True
	)

happyReduce_92 = happySpecReduce_3  38 happyReduction_92
happyReduction_92 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (EOp2 OOr happy_var_1 happy_var_3
	)
happyReduction_92 _ _ _  = notHappyAtAll 

happyReduce_93 = happySpecReduce_1  38 happyReduction_93
happyReduction_93 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_93 _  = notHappyAtAll 

happyReduce_94 = happySpecReduce_3  39 happyReduction_94
happyReduction_94 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (EOp2 OAnd happy_var_1 happy_var_3
	)
happyReduction_94 _ _ _  = notHappyAtAll 

happyReduce_95 = happySpecReduce_1  39 happyReduction_95
happyReduction_95 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_95 _  = notHappyAtAll 

happyReduce_96 = happySpecReduce_2  40 happyReduction_96
happyReduction_96 (HappyAbsSyn52  happy_var_2)
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (unchainExps happy_var_1 happy_var_2
	)
happyReduction_96 _ _  = notHappyAtAll 

happyReduce_97 = happySpecReduce_2  41 happyReduction_97
happyReduction_97 (HappyAbsSyn18  happy_var_2)
	(HappyAbsSyn42  happy_var_1)
	 =  HappyAbsSyn41
		 ((happy_var_1, happy_var_2)
	)
happyReduction_97 _ _  = notHappyAtAll 

happyReduce_98 = happySpecReduce_1  42 happyReduction_98
happyReduction_98 _
	 =  HappyAbsSyn42
		 (OGt
	)

happyReduce_99 = happySpecReduce_1  42 happyReduction_99
happyReduction_99 _
	 =  HappyAbsSyn42
		 (OLt
	)

happyReduce_100 = happySpecReduce_1  42 happyReduction_100
happyReduction_100 _
	 =  HappyAbsSyn42
		 (OGe
	)

happyReduce_101 = happySpecReduce_1  42 happyReduction_101
happyReduction_101 _
	 =  HappyAbsSyn42
		 (OLe
	)

happyReduce_102 = happySpecReduce_1  42 happyReduction_102
happyReduction_102 _
	 =  HappyAbsSyn42
		 (QEq
	)

happyReduce_103 = happySpecReduce_3  43 happyReduction_103
happyReduction_103 (HappyAbsSyn18  happy_var_3)
	(HappyAbsSyn42  happy_var_2)
	(HappyAbsSyn46  happy_var_1)
	 =  HappyAbsSyn18
		 (EOp2 happy_var_2 happy_var_1 happy_var_3
	)
happyReduction_103 _ _ _  = notHappyAtAll 

happyReduce_104 = happySpecReduce_1  43 happyReduction_104
happyReduction_104 (HappyAbsSyn46  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_104 _  = notHappyAtAll 

happyReduce_105 = happySpecReduce_1  44 happyReduction_105
happyReduction_105 _
	 =  HappyAbsSyn42
		 (OAdd
	)

happyReduce_106 = happySpecReduce_1  44 happyReduction_106
happyReduction_106 _
	 =  HappyAbsSyn42
		 (OSub
	)

happyReduce_107 = happySpecReduce_1  45 happyReduction_107
happyReduction_107 (HappyAbsSyn42  happy_var_1)
	 =  HappyAbsSyn42
		 (happy_var_1
	)
happyReduction_107 _  = notHappyAtAll 

happyReduce_108 = happySpecReduce_1  45 happyReduction_108
happyReduction_108 _
	 =  HappyAbsSyn42
		 (ODiv
	)

happyReduce_109 = happySpecReduce_1  45 happyReduction_109
happyReduction_109 _
	 =  HappyAbsSyn42
		 (OMul
	)

happyReduce_110 = happySpecReduce_1  45 happyReduction_110
happyReduction_110 _
	 =  HappyAbsSyn42
		 (OMod
	)

happyReduce_111 = happySpecReduce_1  46 happyReduction_111
happyReduction_111 (HappyTerminal (( _, L.TLitInt happy_var_1 )))
	 =  HappyAbsSyn46
		 (ENum happy_var_1
	)
happyReduction_111 _  = notHappyAtAll 

happyReduce_112 = happySpecReduce_2  46 happyReduction_112
happyReduction_112 (HappyAbsSyn65  happy_var_2)
	(HappyTerminal (( _, L.TId happy_var_1     )))
	 =  HappyAbsSyn46
		 (EApp happy_var_1 happy_var_2
	)
happyReduction_112 _ _  = notHappyAtAll 

happyReduce_113 = happySpecReduce_1  46 happyReduction_113
happyReduction_113 (HappyTerminal (( _, L.TId happy_var_1     )))
	 =  HappyAbsSyn46
		 (EVar happy_var_1
	)
happyReduction_113 _  = notHappyAtAll 

happyReduce_114 = happySpecReduce_3  46 happyReduction_114
happyReduction_114 _
	(HappyTerminal (( _, L.TId happy_var_2     )))
	_
	 =  HappyAbsSyn46
		 (ELen happy_var_2
	)
happyReduction_114 _ _ _  = notHappyAtAll 

happyReduce_115 = happyReduce 4 46 happyReduction_115
happyReduction_115 (_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_3     ))) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (( _, L.TId happy_var_1     ))) `HappyStk`
	happyRest)
	 = HappyAbsSyn46
		 (EInd happy_var_1 happy_var_3
	) `HappyStk` happyRest

happyReduce_116 = happySpecReduce_3  46 happyReduction_116
happyReduction_116 _
	(HappyAbsSyn33  happy_var_2)
	_
	 =  HappyAbsSyn46
		 (happy_var_2
	)
happyReduction_116 _ _ _  = notHappyAtAll 

happyReduce_117 = happySpecReduce_1  47 happyReduction_117
happyReduction_117 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn47
		 (happy_var_1
	)
happyReduction_117 _  = notHappyAtAll 

happyReduce_118 = happySpecReduce_1  47 happyReduction_118
happyReduction_118 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn47
		 (happy_var_1
	)
happyReduction_118 _  = notHappyAtAll 

happyReduce_119 = happySpecReduce_1  48 happyReduction_119
happyReduction_119 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn48
		 (happy_var_1
	)
happyReduction_119 _  = notHappyAtAll 

happyReduce_120 = happySpecReduce_1  48 happyReduction_120
happyReduction_120 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn48
		 (happy_var_1
	)
happyReduction_120 _  = notHappyAtAll 

happyReduce_121 = happySpecReduce_1  49 happyReduction_121
happyReduction_121 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn49
		 (happy_var_1
	)
happyReduction_121 _  = notHappyAtAll 

happyReduce_122 = happySpecReduce_1  49 happyReduction_122
happyReduction_122 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn49
		 (happy_var_1
	)
happyReduction_122 _  = notHappyAtAll 

happyReduce_123 = happySpecReduce_1  50 happyReduction_123
happyReduction_123 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn50
		 (happy_var_1
	)
happyReduction_123 _  = notHappyAtAll 

happyReduce_124 = happySpecReduce_1  50 happyReduction_124
happyReduction_124 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn50
		 (happy_var_1
	)
happyReduction_124 _  = notHappyAtAll 

happyReduce_125 = happySpecReduce_3  51 happyReduction_125
happyReduction_125 _
	(HappyAbsSyn70  happy_var_2)
	_
	 =  HappyAbsSyn51
		 (happy_var_2
	)
happyReduction_125 _ _ _  = notHappyAtAll 

happyReduce_126 = happySpecReduce_1  52 happyReduction_126
happyReduction_126 (HappyAbsSyn75  happy_var_1)
	 =  HappyAbsSyn52
		 (reverse happy_var_1
	)
happyReduction_126 _  = notHappyAtAll 

happyReduce_127 = happySpecReduce_1  53 happyReduction_127
happyReduction_127 (HappyAbsSyn76  happy_var_1)
	 =  HappyAbsSyn53
		 (reverse happy_var_1
	)
happyReduction_127 _  = notHappyAtAll 

happyReduce_128 = happySpecReduce_1  54 happyReduction_128
happyReduction_128 (HappyAbsSyn77  happy_var_1)
	 =  HappyAbsSyn54
		 (reverse happy_var_1
	)
happyReduction_128 _  = notHappyAtAll 

happyReduce_129 = happySpecReduce_1  55 happyReduction_129
happyReduction_129 (HappyAbsSyn78  happy_var_1)
	 =  HappyAbsSyn55
		 (reverse happy_var_1
	)
happyReduction_129 _  = notHappyAtAll 

happyReduce_130 = happySpecReduce_1  56 happyReduction_130
happyReduction_130 (HappyAbsSyn72  happy_var_1)
	 =  HappyAbsSyn56
		 (reverse happy_var_1
	)
happyReduction_130 _  = notHappyAtAll 

happyReduce_131 = happySpecReduce_0  56 happyReduction_131
happyReduction_131  =  HappyAbsSyn56
		 ([]
	)

happyReduce_132 = happySpecReduce_1  57 happyReduction_132
happyReduction_132 (HappyAbsSyn73  happy_var_1)
	 =  HappyAbsSyn57
		 (reverse happy_var_1
	)
happyReduction_132 _  = notHappyAtAll 

happyReduce_133 = happySpecReduce_0  57 happyReduction_133
happyReduction_133  =  HappyAbsSyn57
		 ([]
	)

happyReduce_134 = happySpecReduce_1  58 happyReduction_134
happyReduction_134 (HappyAbsSyn74  happy_var_1)
	 =  HappyAbsSyn58
		 (reverse happy_var_1
	)
happyReduction_134 _  = notHappyAtAll 

happyReduce_135 = happySpecReduce_0  58 happyReduction_135
happyReduction_135  =  HappyAbsSyn58
		 ([]
	)

happyReduce_136 = happySpecReduce_3  59 happyReduction_136
happyReduction_136 _
	(HappyAbsSyn33  happy_var_2)
	_
	 =  HappyAbsSyn59
		 ([happy_var_2]
	)
happyReduction_136 _ _ _  = notHappyAtAll 

happyReduce_137 = happyReduce 4 59 happyReduction_137
happyReduction_137 ((HappyAbsSyn59  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn59
		 (happy_var_2 : happy_var_4
	) `HappyStk` happyRest

happyReduce_138 = happySpecReduce_0  60 happyReduction_138
happyReduction_138  =  HappyAbsSyn60
		 (Nothing
	)

happyReduce_139 = happySpecReduce_1  60 happyReduction_139
happyReduction_139 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn60
		 (Just happy_var_1
	)
happyReduction_139 _  = notHappyAtAll 

happyReduce_140 = happySpecReduce_0  61 happyReduction_140
happyReduction_140  =  HappyAbsSyn61
		 (Nothing
	)

happyReduce_141 = happySpecReduce_1  61 happyReduction_141
happyReduction_141 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn61
		 (Just happy_var_1
	)
happyReduction_141 _  = notHappyAtAll 

happyReduce_142 = happySpecReduce_3  62 happyReduction_142
happyReduction_142 _
	(HappyAbsSyn10  happy_var_2)
	_
	 =  HappyAbsSyn62
		 (happy_var_2
	)
happyReduction_142 _ _ _  = notHappyAtAll 

happyReduce_143 = happySpecReduce_3  63 happyReduction_143
happyReduction_143 _
	(HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn63
		 (happy_var_2
	)
happyReduction_143 _ _ _  = notHappyAtAll 

happyReduce_144 = happySpecReduce_3  64 happyReduction_144
happyReduction_144 _
	(HappyAbsSyn68  happy_var_2)
	_
	 =  HappyAbsSyn64
		 (happy_var_2
	)
happyReduction_144 _ _ _  = notHappyAtAll 

happyReduce_145 = happySpecReduce_3  65 happyReduction_145
happyReduction_145 _
	(HappyAbsSyn69  happy_var_2)
	_
	 =  HappyAbsSyn65
		 (happy_var_2
	)
happyReduction_145 _ _ _  = notHappyAtAll 

happyReduce_146 = happySpecReduce_3  66 happyReduction_146
happyReduction_146 _
	(HappyAbsSyn57  happy_var_2)
	_
	 =  HappyAbsSyn66
		 (happy_var_2
	)
happyReduction_146 _ _ _  = notHappyAtAll 

happyReduce_147 = happySpecReduce_3  67 happyReduction_147
happyReduction_147 _
	(HappyAbsSyn71  happy_var_2)
	_
	 =  HappyAbsSyn67
		 (happy_var_2
	)
happyReduction_147 _ _ _  = notHappyAtAll 

happyReduce_148 = happySpecReduce_1  68 happyReduction_148
happyReduction_148 (HappyAbsSyn79  happy_var_1)
	 =  HappyAbsSyn68
		 (reverse happy_var_1
	)
happyReduction_148 _  = notHappyAtAll 

happyReduce_149 = happySpecReduce_0  68 happyReduction_149
happyReduction_149  =  HappyAbsSyn68
		 ([]
	)

happyReduce_150 = happySpecReduce_1  69 happyReduction_150
happyReduction_150 (HappyAbsSyn80  happy_var_1)
	 =  HappyAbsSyn69
		 (reverse happy_var_1
	)
happyReduction_150 _  = notHappyAtAll 

happyReduce_151 = happySpecReduce_0  69 happyReduction_151
happyReduction_151  =  HappyAbsSyn69
		 ([]
	)

happyReduce_152 = happySpecReduce_1  70 happyReduction_152
happyReduction_152 (HappyAbsSyn81  happy_var_1)
	 =  HappyAbsSyn70
		 (reverse happy_var_1
	)
happyReduction_152 _  = notHappyAtAll 

happyReduce_153 = happySpecReduce_0  70 happyReduction_153
happyReduction_153  =  HappyAbsSyn70
		 ([]
	)

happyReduce_154 = happySpecReduce_1  71 happyReduction_154
happyReduction_154 (HappyAbsSyn82  happy_var_1)
	 =  HappyAbsSyn71
		 (reverse happy_var_1
	)
happyReduction_154 _  = notHappyAtAll 

happyReduce_155 = happySpecReduce_0  71 happyReduction_155
happyReduction_155  =  HappyAbsSyn71
		 ([]
	)

happyReduce_156 = happySpecReduce_3  72 happyReduction_156
happyReduction_156 (HappyAbsSyn11  happy_var_3)
	_
	(HappyAbsSyn72  happy_var_1)
	 =  HappyAbsSyn72
		 (happy_var_3 : happy_var_1
	)
happyReduction_156 _ _ _  = notHappyAtAll 

happyReduce_157 = happySpecReduce_1  72 happyReduction_157
happyReduction_157 (HappyAbsSyn11  happy_var_1)
	 =  HappyAbsSyn72
		 ([happy_var_1]
	)
happyReduction_157 _  = notHappyAtAll 

happyReduce_158 = happySpecReduce_3  73 happyReduction_158
happyReduction_158 (HappyTerminal (( _, L.TId happy_var_3     )))
	_
	(HappyAbsSyn73  happy_var_1)
	 =  HappyAbsSyn73
		 (happy_var_3 : happy_var_1
	)
happyReduction_158 _ _ _  = notHappyAtAll 

happyReduce_159 = happySpecReduce_1  73 happyReduction_159
happyReduction_159 (HappyTerminal (( _, L.TId happy_var_1     )))
	 =  HappyAbsSyn73
		 ([happy_var_1]
	)
happyReduction_159 _  = notHappyAtAll 

happyReduce_160 = happySpecReduce_3  74 happyReduction_160
happyReduction_160 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn74  happy_var_1)
	 =  HappyAbsSyn74
		 (happy_var_3 : happy_var_1
	)
happyReduction_160 _ _ _  = notHappyAtAll 

happyReduce_161 = happySpecReduce_1  74 happyReduction_161
happyReduction_161 (HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn74
		 ([happy_var_1]
	)
happyReduction_161 _  = notHappyAtAll 

happyReduce_162 = happySpecReduce_0  75 happyReduction_162
happyReduction_162  =  HappyAbsSyn75
		 ([]
	)

happyReduce_163 = happySpecReduce_2  75 happyReduction_163
happyReduction_163 (HappyAbsSyn41  happy_var_2)
	(HappyAbsSyn75  happy_var_1)
	 =  HappyAbsSyn75
		 (happy_var_2 : happy_var_1
	)
happyReduction_163 _ _  = notHappyAtAll 

happyReduce_164 = happySpecReduce_0  76 happyReduction_164
happyReduction_164  =  HappyAbsSyn76
		 ([]
	)

happyReduce_165 = happySpecReduce_2  76 happyReduction_165
happyReduction_165 (HappyAbsSyn9  happy_var_2)
	(HappyAbsSyn76  happy_var_1)
	 =  HappyAbsSyn76
		 (happy_var_2 : happy_var_1
	)
happyReduction_165 _ _  = notHappyAtAll 

happyReduce_166 = happySpecReduce_0  77 happyReduction_166
happyReduction_166  =  HappyAbsSyn77
		 ([]
	)

happyReduce_167 = happySpecReduce_2  77 happyReduction_167
happyReduction_167 (HappyAbsSyn17  happy_var_2)
	(HappyAbsSyn77  happy_var_1)
	 =  HappyAbsSyn77
		 (happy_var_2 : happy_var_1
	)
happyReduction_167 _ _  = notHappyAtAll 

happyReduce_168 = happySpecReduce_0  78 happyReduction_168
happyReduction_168  =  HappyAbsSyn78
		 ([]
	)

happyReduce_169 = happySpecReduce_2  78 happyReduction_169
happyReduction_169 (HappyAbsSyn6  happy_var_2)
	(HappyAbsSyn78  happy_var_1)
	 =  HappyAbsSyn78
		 (happy_var_2 : happy_var_1
	)
happyReduction_169 _ _  = notHappyAtAll 

happyReduce_170 = happySpecReduce_3  79 happyReduction_170
happyReduction_170 (HappyAbsSyn34  happy_var_3)
	_
	(HappyAbsSyn79  happy_var_1)
	 =  HappyAbsSyn79
		 (happy_var_3 : happy_var_1
	)
happyReduction_170 _ _ _  = notHappyAtAll 

happyReduce_171 = happySpecReduce_1  79 happyReduction_171
happyReduction_171 (HappyAbsSyn34  happy_var_1)
	 =  HappyAbsSyn79
		 ([happy_var_1]
	)
happyReduction_171 _  = notHappyAtAll 

happyReduce_172 = happySpecReduce_3  80 happyReduction_172
happyReduction_172 (HappyAbsSyn33  happy_var_3)
	_
	(HappyAbsSyn80  happy_var_1)
	 =  HappyAbsSyn80
		 (happy_var_3 : happy_var_1
	)
happyReduction_172 _ _ _  = notHappyAtAll 

happyReduce_173 = happySpecReduce_1  80 happyReduction_173
happyReduction_173 (HappyAbsSyn33  happy_var_1)
	 =  HappyAbsSyn80
		 ([happy_var_1]
	)
happyReduction_173 _  = notHappyAtAll 

happyReduce_174 = happySpecReduce_3  81 happyReduction_174
happyReduction_174 (HappyAbsSyn27  happy_var_3)
	_
	(HappyAbsSyn81  happy_var_1)
	 =  HappyAbsSyn81
		 (happy_var_3 : happy_var_1
	)
happyReduction_174 _ _ _  = notHappyAtAll 

happyReduce_175 = happySpecReduce_1  81 happyReduction_175
happyReduction_175 (HappyAbsSyn27  happy_var_1)
	 =  HappyAbsSyn81
		 ([happy_var_1]
	)
happyReduction_175 _  = notHappyAtAll 

happyReduce_176 = happySpecReduce_3  82 happyReduction_176
happyReduction_176 (HappyAbsSyn12  happy_var_3)
	_
	(HappyAbsSyn82  happy_var_1)
	 =  HappyAbsSyn82
		 (happy_var_3 : happy_var_1
	)
happyReduction_176 _ _ _  = notHappyAtAll 

happyReduce_177 = happySpecReduce_1  82 happyReduction_177
happyReduction_177 (HappyAbsSyn12  happy_var_1)
	 =  HappyAbsSyn82
		 ([happy_var_1]
	)
happyReduction_177 _  = notHappyAtAll 

happyNewToken action sts stk [] =
	action 166 166 notHappyAtAll (HappyState action) sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = action i i tk (HappyState action) sts stk tks in
	case tk of {
	( _, L.TWildcardName ""  ) -> cont 83;
	( _, L.TWildcardName "1" ) -> cont 84;
	( _, L.TWildcardName "_S" ) -> cont 85;
	( _, L.TWildcardName "_T" ) -> cont 86;
	( _, L.TWildcardName "_o" ) -> cont 87;
	( _, L.TWildcardName "_O" ) -> cont 88;
	( _, L.TWildcardName happy_dollar_dollar ) -> cont 89;
	( _, L.TLitInt happy_dollar_dollar ) -> cont 90;
	( _, L.TDafny happy_dollar_dollar  ) -> cont 91;
	( _, L.TMethod    ) -> cont 92;
	( _, L.TEnsures   ) -> cont 93;
	( _, L.TRequires  ) -> cont 94;
	( _, L.TSeparates ) -> cont 95;
	( _, L.TInv       ) -> cont 96;
	( _, L.TWith      ) -> cont 97;
	( _, L.TAt        ) -> cont 98;
	( _, L.TSplit     ) -> cont 99;
	( _, L.TFor       ) -> cont 100;
	( _, L.TReturns   ) -> cont 101;
	( _, L.TNot       ) -> cont 102;
	( _, L.TNat       ) -> cont 103;
	( _, L.TReal      ) -> cont 104;
	( _, L.TInt       ) -> cont 105;
	( _, L.TIn        ) -> cont 106;
	( _, L.TBool      ) -> cont 107;
	( _, L.TSeq       ) -> cont 108;
	( _, L.TNor       ) -> cont 109;
	( _, L.THad       ) -> cont 110;
	( _, L.THApp      ) -> cont 111;
	( _, L.TQFT       ) -> cont 112;
	( _, L.TRQFT      ) -> cont 113;
	( _, L.TRepr      ) -> cont 114;
	( _, L.TMeasure   ) -> cont 115;
	( _, L.TMeasured  ) -> cont 116;
	( _, L.TEn        ) -> cont 117;
	( _, L.TQReg      ) -> cont 118;
	( _, L.TEn01      ) -> cont 119;
	( _, L.TVar       ) -> cont 120;
	( _, L.TIf        ) -> cont 121;
	( _, L.TISqrt     ) -> cont 122;
	( _, L.TSin       ) -> cont 123;
	( _, L.TCos       ) -> cont 124;
	( _, L.TCl            ) -> cont 125;
	( _, L.TUnicodeSum    ) -> cont 126;
	( _, L.TUnicodeTensor ) -> cont 127;
	( _, L.TUnicodeOmega  ) -> cont 128;
	( _, L.TUnicodeSumOmega ) -> cont 129;
	( _, L.TUnicodeIn     ) -> cont 130;
	( _, L.TKet     ) -> cont 131;
	( _, L.TUnicodeMap    ) -> cont 132;
	( _, L.TAssert    ) -> cont 133;
	( _, L.TForall    ) -> cont 134;
	( _, L.TOr        ) -> cont 135;
	( _, L.TAnd       ) -> cont 136;
	( _, L.TAdd       ) -> cont 137;
	( _, L.TDiv       ) -> cont 138;
	( _, L.TSub       ) -> cont 139;
	( _, L.TMul       ) -> cont 140;
	( _, L.TMod       ) -> cont 141;
	( _, L.TBar       ) -> cont 142;
	( _, L.TLPar      ) -> cont 143;
	( _, L.TRPar      ) -> cont 144;
	( _, L.TLAng      ) -> cont 145;
	( _, L.TRAng      ) -> cont 146;
	( _, L.TLBracket  ) -> cont 147;
	( _, L.TRBracket  ) -> cont 148;
	( _, L.TLBrace    ) -> cont 149;
	( _, L.TRBrace    ) -> cont 150;
	( _, L.TId happy_dollar_dollar     ) -> cont 151;
	( _, L.TComma     ) -> cont 152;
	( _, L.TDColon     ) -> cont 153;
	( _, L.TColon     ) -> cont 154;
	( _, L.TDot       ) -> cont 155;
	( _, L.TSemi      ) -> cont 156;
	( _, L.TEq        ) -> cont 157;
	( _, L.TTyArrow   ) -> cont 158;
	( _, L.TArrow     ) -> cont 159;
	( _, L.TImply     ) -> cont 160;
	( _, L.TGe        ) -> cont 161;
	( _, L.TLe        ) -> cont 162;
	( _, L.TAssign    ) -> cont 163;
	( _, L.TApply     ) -> cont 164;
	( _, L.TTilde     ) -> cont 165;
	_ -> happyError' ((tk:tks), [])
	}

happyError_ explist 166 tk tks = happyError' (tks, explist)
happyError_ explist _ tk tks = happyError' ((tk:tks), explist)

happyThen :: () => Parser a -> (a -> Parser b) -> Parser b
happyThen = (>>=)
happyReturn :: () => a -> Parser a
happyReturn = (return)
happyThen1 m k tks = (>>=) m (\a -> k a tks)
happyReturn1 :: () => a -> b -> Parser a
happyReturn1 = \a tks -> (return) a
happyError' :: () => ([(L.SToken)], [Prelude.String]) -> Parser a
happyError' = parseError
runParser tks = happySomeParser where
 happySomeParser = happyThen (happyParse action_0 tks) (\x -> case x of {HappyAbsSyn4 z -> happyReturn z; _other -> notHappyAtAll })

happySeq = happyDontSeq


scanAndParse :: String -> Parser AST
scanAndParse = runParser <=< L.runScanner
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- $Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp $










































data Happy_IntList = HappyCons Prelude.Int Happy_IntList








































infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is ERROR_TOK, it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept (1) tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
         (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action









































indexShortOffAddr arr off = arr Happy_Data_Array.! off


{-# INLINE happyLt #-}
happyLt x y = (x Prelude.< y)






readArrayBit arr bit =
    Bits.testBit (indexShortOffAddr arr (bit `Prelude.div` 16)) (bit `Prelude.mod` 16)






-----------------------------------------------------------------------------
-- HappyState data type (not arrays)



newtype HappyState b c = HappyState
        (Prelude.Int ->                    -- token number
         Prelude.Int ->                    -- token number (yes, again)
         b ->                           -- token semantic value
         HappyState b c ->              -- current state
         [HappyState b c] ->            -- state stack
         c)



-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state (1) tk st sts stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--     trace "shifting the error token" $
     new_state i i tk (HappyState (new_state)) ((st):(sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state ((st):(sts)) ((HappyTerminal (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_0 nt fn j tk st@((HappyState (action))) sts stk
     = action nt j tk st ((st):(sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@(((st@(HappyState (action))):(_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_2 nt fn j tk _ ((_):(sts@(((st@(HappyState (action))):(_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_3 nt fn j tk _ ((_):(((_):(sts@(((st@(HappyState (action))):(_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k Prelude.- ((1) :: Prelude.Int)) sts of
         sts1@(((st1@(HappyState (action))):(_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (action nt j tk st1 sts1 r)

happyMonadReduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> action nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
         let drop_stk = happyDropStk k stk





             _ = nt :: Prelude.Int
             new_state = action

          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop (0) l = l
happyDrop n ((_):(t)) = happyDrop (n Prelude.- ((1) :: Prelude.Int)) t

happyDropStk (0) l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n Prelude.- ((1)::Prelude.Int)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction









happyGoto action j tk st = action j j tk (HappyState action)


-----------------------------------------------------------------------------
-- Error recovery (ERROR_TOK is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist (1) tk old_st _ stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  ERROR_TOK tk old_st CONS(HAPPYSTATE(action),sts) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        DO_ACTION(action,ERROR_TOK,tk,sts,(saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (HappyState (action)) sts stk =
--      trace "entering error recovery" $
        action (1) (1) tk (HappyState (action)) sts ((HappyErrorToken (i)) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = Prelude.error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions







-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `Prelude.seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.









{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.
