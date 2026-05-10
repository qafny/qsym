{-# LANGUAGE
    DeriveFoldable
  , DeriveFunctor
  , DeriveGeneric
  , DeriveTraversable
  , FlexibleContexts
  , FlexibleInstances
  , NamedFieldPuns
  , PatternSynonyms
  , StandaloneDeriving
  , TemplateHaskell
  , TupleSections
  , TypeFamilies
  , TypeOperators
  , StrictData
  , UndecidableInstances
  #-}

module Qafny.Syntax.AST where

import           Qafny.TTG

--------------------------------------------------------------------------------

-- import           Data.Data
import           Data.Functor.Foldable
    (Base, Corecursive, Recursive)
import           Data.Functor.Identity
import           Data.List.NonEmpty
    (NonEmpty (..))
import           Data.Sum
import           GHC.Generics          hiding
    ((:+:))
import           Text.Printf
    (printf)
--------------------------------------------------------------------------------

data AExp
  = ANat Int
  | AVar Var
  deriving (Show, Eq, Ord)

aexpToExp :: AExp -> Exp ()
aexpToExp (ANat i) = ENum i
aexpToExp (AVar v) = EVar v

-- | The good thing about this design is that I don't need to modify the
-- emitState when creating a new phaseRef.
--
-- The only bad thing is that everytime
-- I want to get the pointer to the phase, I need to resolve through `sSt`,
-- which is not too bad because phase are designed to live with partitiions
-- instead of with ranges :)
--
-- TODO: move this into the proposal
--
data PhaseRef = PhaseRef
  { prBase :: Var -- | pointer to the base
  , prRepr :: Var -- | pointer to its representation
  }
  deriving (Show, Eq, Ord)

data Ty
  = TNat
  | TReal
  | TInt
  | TBool
  | TSeq Ty
  | TArrow [Ty] Ty
  | TMeasured
  | TQReg AExp
  -- | TMethod [Ty] [Ty] -- parameter and return types
  | TEmit EmitTy
  deriving (Show, Eq, Ord)

pattern TSeqNat :: Ty
pattern TSeqNat = TSeq TNat

pattern TSeqSeqNat :: Ty
pattern TSeqSeqNat = TSeq TSeqNat

-- pattern TReal :: Ty
-- pattern TReal = TEmit (TAny "real")

pattern TSeqReal :: Ty
pattern TSeqReal = TSeq TReal

-- | EmitExp : Unchecked Types for Codegen Only
newtype EmitTy = TAny String
  deriving (Show, Eq, Ord)

data QTy
  = TNor
  | THad
  | TEn
  | TEn01
  | TQft
  deriving (Show, Eq, Ord)

type Var = String

data Binding x = Binding (XRec x Var) Ty

deriving instance (Show (XRec x Var), Show (XRec x Ty)) => Show (Binding x)
deriving instance (Eq (XRec x Var), Eq (XRec x Ty)) => Eq (Binding x)
deriving instance (Ord (XRec x Var), Ord (XRec x Ty)) => Ord (Binding x)

type Bindings x = [XRec x (Binding x)]

-- type EBinds = QTy :+: PhaseTy :+: Ty


data Op2
  = OAnd
  | OOr
  | OAdd
  | ODiv
  | OSub
  | OMul
  | OMod
  | ONor
  | OLt
  | OLe
  | OGt
  | OGe
  | OEq
  | OXor
  deriving (Show, Eq, Ord-- , Data, Typeable
           )

data Op1
  = ONot
  | ONeg
  | OSin
  | OCos
  | OSqrt
  deriving (Show, Eq, Ord-- , Data, Typeable
           )


data GuardExp
  = GEPartition Partition (Maybe (Exp ())) -- guard partition with a split at
  | EmptyGE
  deriving (Show, Eq)

-- the exp is not reversible
data Exp x
  = ENum Int
  | EVar Var
  | ELen Var
  | EInd Var Var
  | EWildcard
  | EHad
  | EQft Bool
  | EMeasure Partition
  | EBool Bool
  | EApp Var [XRec x (Exp x)]
  | EOp1 Op1 (XRec x (Exp x))
  | EOp2 Op2 (XRec x (Exp x)) (XRec x (Exp x))
  | EForall (Binding x) (Maybe (XRec x (Exp x))) (XRec x (Exp x))
  | ECPec (Maybe (XRec x (Exp x))) (XRec x (Exp x))
  | EDafny String
  | EEmit EmitExp
  | ERange Range
  | ESpec Partition QTy [SpecExpF (XRec x (Exp x))]
  | ERepr Range
  | ELambda (LambdaF (XRec x (Exp x)))

-- data LamdaExpF f
--   = { bPhase :: PhaseBinder
--     ,
--     }

-- Amplitude expression
data AmpExpF f
  = ADefault
  | AmpExpr f
 -- | ASin f
 -- | ACos f
  deriving (Functor, Traversable, Foldable)

deriving instance Generic (AmpExpF f)
deriving instance Show f => Show (AmpExpF f)
deriving instance Eq f => Eq (AmpExpF f)
deriving instance Ord f => Ord (AmpExpF f)

type AmpExp = AmpExpF Exp'

data PhaseExpF f
  = PhaseZ                  -- 1
  | PhaseOmega    f f       -- e / N
  | PhaseSumOmega Range f f -- sum (x i j) e / N
  | PhaseWildCard           -- _
  deriving (Functor, Traversable, Foldable)

type PhaseExp = PhaseExpF Exp'
type PhaseBinder = PhaseExpF Var

deriving instance Generic (PhaseExpF f)
deriving instance Show f => Show (PhaseExpF f)
deriving instance Eq f => Eq (PhaseExpF f)
deriving instance Ord f => Ord (PhaseExpF f)

deriving instance (Generic (Exp ()))
deriving instance (Generic (Exp Source))
deriving instance (Show (Exp ()))
deriving instance (Show (Exp Source))
deriving instance (Eq (Exp ()))
deriving instance (Eq (Exp Source))
deriving instance (Ord (Exp ()))
deriving instance (Ord (Exp Source))

data SpecExpF f
  = SESpecNor (SpecNorF f)
    -- ^ `⊗ id . e`
  | SESpecHad (SpecHadF f)
    -- ^ `⊗ id . ω`
  | SESpecEn (SpecEnF f)
    -- ^ `Σ id ∈ intv . ω ~ e`
  | SESpecEn01 (SpecEn01F f)
    -- ^ `Σ id1 ∈ intv1 . ⊗ id2 . ω ~ e`
  | SEWildcard
    -- ^ `_`
  deriving (Functor, Foldable, Traversable)

deriving instance Generic (SpecExpF f)
deriving instance (Show f) => Show (SpecExpF f)
deriving instance (Eq f) => Eq (SpecExpF f)
deriving instance (Ord f) => Ord (SpecExpF f)
type SpecExp = SpecExpF Exp'

data SpecNorF f =
  SpecNorF { norVar :: Var -- ^ enumerator for each qubit
           , norKet :: f   -- ^ basis ket for each qubit
           }
  deriving (Functor, Foldable, Traversable)

deriving instance Generic (SpecNorF f)
deriving instance (Show f) => Show (SpecNorF f)
deriving instance (Eq f) => Eq (SpecNorF f)
deriving instance (Ord f) => Ord (SpecNorF f)

type SpecNor = SpecNorF Exp'

data SpecHadF f =
  SpecHadF { hadVar   :: Var           -- ^ enumerator for each qubit
           , hadPhase :: PhaseExpF f   -- ^ phase attached to |1> per qubit
           }
  deriving (Functor, Foldable, Traversable)

deriving instance Generic (SpecHadF f)
deriving instance (Show f) => Show (SpecHadF f)
deriving instance (Eq f) => Eq (SpecHadF f)
deriving instance (Ord f) => Ord (SpecHadF f)

type SpecHad = SpecHadF Exp'

data SpecEnF f =
  SpecEnF { enVarSup    :: Var         -- ^ enumerator for superposition
          , enIntvSup   :: Intv        -- ^ scope of the enumerator
          , enAmpCoef   :: AmpExpF f   -- ^ amplitude coef
          , enPhaseCoef :: PhaseExpF f -- ^ phase coef
          , enKets      :: [f]         -- ^ basis ket for each range
          }
  deriving (Functor, Foldable, Traversable)

deriving instance Generic (SpecEnF f)
deriving instance (Show f) => Show (SpecEnF f)
deriving instance (Eq f) => Eq (SpecEnF f)
deriving instance (Ord f) => Ord (SpecEnF f)

type SpecEn = SpecEnF Exp'

data SpecEn01F f =
  SpecEn01F { en01VarSup    :: Var
            , en01IntvSup   :: Intv
            , en01AmpCoef   :: AmpExpF f
            , en01PhaseCoef :: PhaseExpF f
            , en01VarQbit   :: Var
            , en01IntvQbit  :: Intv
            , en01Kets      :: [f]
            }
  deriving (Functor, Foldable, Traversable)

deriving instance Generic (SpecEn01F f)
deriving instance (Show f) => Show (SpecEn01F f)
deriving instance (Eq f) => Eq (SpecEn01F f)
deriving instance (Ord f) => Ord (SpecEn01F f)

type SpecEn01 = SpecEn01F Exp'

--------------------------------------------------------------------------------
showExp :: Exp () -> String
showExp (ENum n) = show n
showExp (EVar v) = v
showExp (EOp2 op e1 e2) = showExp e1 ++ sop ++ showExp e2
  where
    sop =
      case op of
        OAdd -> " + "
        ODiv -> " / "
        OSub -> " - "
        OMul -> " * "
        _    -> undefined
showExp e = show e

infixl 5 :@@:
infixl 5 :@:
infixr 1 `ECall`
-- | EmitExp : Unsafe Expressions for Codegen Only
data EmitExp
  = EMtSeq
  | EMakeSeq Ty Exp' Exp'
  | ECard (Exp ())
  | ECall Var [Exp ()]
  | (Exp ()) :@: (Exp ())
  | (Exp ()) :@@: (Exp (), Exp ())
  | EDafnyVar Var
  | EMultiLambda [Var] (Exp ())
  | EOpChained (Exp ()) [(Op2, Exp ())]
  | EAsReal (Exp ())
  deriving  (Show, Eq, Ord-- , Data, Typeable
            )

data Conds
  = Requires (Exp ())
  | Ensures (Exp ())
  | Invariants (Exp ())
  | Separates Partition
  deriving Show

newtype Block x = Block { inBlock :: [XRec x (Stmt x)] }

deriving instance (Show (XRec x (Stmt x))) => Show (Block x)
deriving instance (Eq (XRec x (Stmt x))) => Eq (Block x)
deriving instance (Ord (XRec x (Stmt x))) => Ord (Block x)


-- TODO: refactor into record
data QMethod x
  = QMethod { qmName     :: Var
            , qmInputs   :: Bindings x
            , qmOutputs  :: Bindings x
            , qmRequires :: [XRec x (Exp x)]
            , qmEnsures  :: [XRec x (Exp x)]
            , qmBody     :: Maybe (Block x)
            }

deriving instance Show (QMethod ())
deriving instance Show (QMethod Source)
deriving instance Eq (QMethod ())

newtype QDafny = QDafny String
  deriving (Eq, Show)

newtype Toplevel x = Toplevel { unTop :: (QMethod x) :+: QDafny }

deriving instance Show (Toplevel ())
deriving instance Show (Toplevel Source)
deriving instance Eq (Toplevel ())

instance (Injection q (QMethod x :+: QDafny)) => Injection q (Toplevel x) where
  inj = Toplevel . inj

data Intv = Intv (Exp ()) (Exp ())
  deriving (Eq, Show, Ord-- , Data, Typeable
           )

-- Range includes the left but exclude the right
data Range = Range Var (Exp ()) (Exp ())
  deriving (Eq, Ord-- , Data, Typeable
           )

getRangeName :: Range -> Var
getRangeName (Range n _ _) = n

instance Show Range where
  show (Range x y z) = printf "%s[%s .. %s]" x (showExp y) (showExp z)

newtype Loc = Loc { deref :: Var }
  deriving (Eq, Ord)

instance Show Loc where
  show = deref

newtype PartitionT t = Partition { ranges :: t Range }
type Partition = PartitionT []

deriving instance Eq Partition
deriving instance Ord Partition


unpackPart :: Partition -> [Range]
unpackPart = ranges

infixl 5 ::=:
infixl 5 :*=:
instance Show Partition where
  show = showPP . unpackPart
    where
      showPP []       = "∅"
      showPP (r : rs) = foldr (\r' s -> show r' ++ " ⊎ " ++ s) (show r) rs

data Stmt x where
  SAssert :: (XRec x (Exp x)) -> Stmt x
  SCall :: Var -> [(XRec x (Exp x))] -> Stmt x
  SVar :: (XRec x (Binding x)) -> (Maybe (XRec x (Exp x))) -> Stmt x
  (::=:) :: Var -> (XRec x (Exp x)) -> Stmt x
  (:*=:) :: Partition -> (XRec x (Exp x)) -> Stmt x
  SMea :: Var -> Var -> (XRec x (Exp x)) -> Stmt x
  SDafny :: String -> Stmt x
  SIf :: GuardExp -> Partition -> (Block x) -> Stmt x
  -- TODO: Refactor 'For' with a record
  --     id      left                right               guard       invarants             separates Body
  SFor :: Var -> (XRec x (Exp x)) -> (XRec x (Exp x)) -> GuardExp -> [(XRec x (Exp x))] -> Maybe Partition -> (Block x) -> Stmt x
  SEmit :: EmitStmt -> Stmt x

deriving instance Show (Stmt ())
deriving instance Show (Stmt Source)
deriving instance Eq (Stmt ())
deriving instance Eq (Stmt Source)

data EmitStmt
  = SIfDafny (Exp ()) (Block ())
  | SBlock (Block ())
  | SForEmit Var (Exp ()) (Exp ()) [Exp ()] (Block ())
  | SVars [Binding ()] (Exp ())
  | (:*:=:) [Var] [Exp']
  deriving (Show, Eq)

type AST = [Toplevel ()]
type LAST = [Toplevel Source]

typeTag :: Ty -> String
typeTag TNat              = "nat"
typeTag TReal              = "real"
typeTag TInt              = "int"
typeTag TBool             = "bool"
typeTag (TSeq t)          = "_seqL_" ++ typeTag t ++ "_R_"
typeTag (TArrow _ _)      = "_fun_"
typeTag TMeasured         = "_measured_"
typeTag (TQReg _)         = "_qreg_"
typeTag (TEmit (TAny s))  = "_"++s++"_"

--------------------------------------------------------------------------------
-- * Partition Utils
--------------------------------------------------------------------------------

range1 :: Var -> Range
range1 v = Range v (ENum 0) (ENum 1)


partition1 :: Range -> PartitionT Identity
partition1 =  Partition . pure


-- | Extract all variables for each range in a partition
varFromPartition :: Partition -> [Var]
varFromPartition (Partition s) = [ x | (Range x _ _) <- s ]


-- | Compute all free partitions/ranges mentioned in the LHS of application
leftPartitions :: [Stmt x] -> [Partition]
leftPartitions =
  concatMap perStmt
  where
    perStmt ((:*=:) s _) = [s]
    -- TODO: query If and For recursively
    perStmt _            = []


(.:) :: (c -> d) -> (a -> b -> c) -> (a -> b -> d)
(.:) = (.) . (.)

--------------------------------------------------------------------------------
-- * Recursion Schemes
--------------------------------------------------------------------------------
data ExpF f
  = ENumF Int
  | EVarF Var
  | ELenF Var
  | EIndF Var Var
  | EWildcardF
  | EHadF
  | EQftF Bool
  | EMeasureF Partition
  | EBoolF Bool
  | EAppF Var [f]
  | EOp1F Op1 f
  | EOp2F Op2 f f
  | EForallF (Binding ()) (Maybe f) f
  | ECPecF (Maybe f) f
  | EDafnyF String
  | EEmitF EmitExp
  | ERangeF Range
  | ESpecF Partition QTy [SpecExpF f]
  | EReprF Range
  | ELambdaF (LambdaF f)
  deriving (Functor, Foldable, Traversable, Show, Generic)

type instance Base (Exp ()) = ExpF
instance Recursive (Exp ())
instance Corecursive (Exp ())


-- Each locus can only have one phase term
data LambdaF f
  = LambdaF { bPhase :: PhaseBinder
            , bBases :: [Var]
            , ePhase :: PhaseExp
            , eBases :: [f]
            }
  deriving (Functor, Foldable, Traversable)

deriving instance Generic (LambdaF f)
deriving instance Show f => Show (LambdaF f)
deriving instance Eq f => Eq (LambdaF f)
deriving instance Ord f => Ord (LambdaF f)
type Lambda = LambdaF Exp'

--------------------------------------------------------------------------------
-- * Exp Utils
--------------------------------------------------------------------------------
instance Num (Exp ()) where
  e1 + e2 = EOp2 OAdd e1 e2
  e1 - e2 = EOp2 OSub e1 e2
  e1 * e2 = EOp2 OMul e1 e2
  negate = (0 -)
  abs = undefined
  signum = undefined
  fromInteger a = ENum (fromInteger a)

-- | Constraints where each variable has only one assignment.
type AEnv = [(Var, Exp ())]

-- | Constraints where each variable can be associated with many assignments.
type IEnv = [(Var, NonEmpty (Exp ()))]

-- | Remove from 'IEnv' variables that are not in the free variable list
filterIEnv :: [Var] -> IEnv -> IEnv
filterIEnv fvs = filter (\(v, _) -> v `elem` fvs)

-- | Compute all `AEnv` permutations from an `IEnv`
nondetIEnv :: IEnv -> NonEmpty AEnv
nondetIEnv = traverse (\(v, ne) -> (v,) <$> ne)

initAEnv :: AEnv
initAEnv = []

initIEnv :: IEnv
initIEnv = []

--------------------------------------------------------------------------------
-- * Vanilla Types

type Stmt' = Stmt ()
type Exp' = Exp ()
type Binding' = Binding ()
type Block' = Block ()
type Toplevel' = Toplevel ()
-- type QSpec' = QSpecF ()

-- * Annotated Types
type LExp = XRec Source (Exp Source)
type LStmt = XRec Source (Stmt Source)
