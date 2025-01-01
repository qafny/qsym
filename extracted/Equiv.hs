{-# LANGUAGE CPP, MagicHash #-}
-- {-# OPTIONS_GHC -cpp -XMagicHash #-}
{- For Hugs, use the Maybe -F"cpp -P -traditional" -}

module Equiv (st_equivb, Tree (..), Tree0 (..), State) where

import Numeric.Natural


import qualified Prelude
import Prelude (Bool (..), Natural, Maybe (..), min, max, succ, Eq (..), Num (..), (&&), (||), mod, Ord ((<), (>), (>=), (<=)), Show)
import Data.Bits (shiftR)

import Common

#ifdef __GLASGOW_HASKELL__
import qualified GHC.Base
import qualified Unsafe.Coerce
#else
-- HUGS
import qualified IOExts
#endif

#ifdef __GLASGOW_HASKELL__
unsafeCoerce :: a -> b
unsafeCoerce = Unsafe.Coerce.unsafeCoerce#
#else
-- HUGS
unsafeCoerce :: a -> b
unsafeCoerce = IOExts.unsafeCoerce
#endif

(~-) :: a -> a
(~-) = Prelude.id

__ :: any
__ = Prelude.error "Logical or arity value used"

and_rect :: (() -> () -> a1) -> a1
and_rect f =
  f __ __

and_rec :: (() -> () -> a1) -> a1
and_rec =
  and_rect

eq_rect :: a1 -> a2 -> a1 -> a2
eq_rect _ f _ =
  f

eq_rec :: a1 -> a2 -> a1 -> a2
eq_rec =
  eq_rect

eq_rec_r :: a1 -> a2 -> a1 -> a2
eq_rec_r =
  eq_rec

eq_rect_r :: a1 -> a2 -> a1 -> a2
eq_rect_r =
  eq_rect

bool_rect :: a1 -> a1 -> Bool -> a1
bool_rect f f0 b =
  case b of {
   True -> f;
   False -> f0}

bool_rec :: a1 -> a1 -> Bool -> a1
bool_rec =
  bool_rect

fst :: (( , ) a1 a2) -> a1
fst p =
  case p of {
    (x, _) -> x}

snd :: (( , ) a1 a2) -> a2
snd p =
  case p of {
    (_, y) -> y}

app :: ([] a1) -> ([] a1) -> [] a1
app l m =
  case l of {
   [] -> m;
   ( : ) a l1 -> ( : ) a (app l1 m)}

data Comparison =
   Eq
 | Lt
 | Gt

data CompareSpecT =
   CompEqT
 | CompLtT
 | CompGtT

compareSpec2Type :: Comparison -> CompareSpecT
compareSpec2Type c =
  case c of {
   Eq -> CompEqT;
   Lt -> CompLtT;
   Gt -> CompGtT}

type CompSpecT a = CompareSpecT

compSpec2Type :: a1 -> a1 -> Comparison -> CompSpecT a1
compSpec2Type _ _ =
  compareSpec2Type

add :: Natural -> Natural -> Natural
add = (+)

bool_dec :: Bool -> Bool -> Bool
bool_dec b1 b2 =
  bool_rec (\x -> case x of {
                   True -> True;
                   False -> False}) (\x ->
    case x of {
     True -> False;
     False -> True}) b1 b2

data Reflect =
   ReflectT
 | ReflectF

iff_reflect :: Bool -> Reflect
iff_reflect b =
  case b of {
   True -> and_rec (\_ _ -> ReflectT);
   False -> and_rec (\_ _ -> ReflectF)}

eqb :: Natural -> Natural -> Bool
eqb = (==)

compare :: Natural -> Natural -> Comparison
compare = \ n m -> if n==m then Eq else if n<m then Lt else Gt

-- succ :: Natural -> Natural
-- succ = Pervasives.succ

add0 :: Natural -> Natural -> Natural
add0 = (+)

add_carry :: Natural -> Natural -> Natural
add_carry x y =
  (\ f2p1 f2p f1 p -> if p==1 then f1 () else if p `mod` 2 == 0 then f2p (p `shiftR` 1) else f2p1 (p `shiftR` 1))
    (\p ->
    (\ f2p1 f2p f1 p -> if p==1 then f1 () else if p `mod` 2 == 0 then f2p (p `shiftR` 1) else f2p1 (p `shiftR` 1))
      (\q -> (\ p->1+2*p) (add_carry p q))
      (\q -> (\ p->2*p) (add_carry p q))
      (\_ -> (\ p->1+2*p) (succ p))
      y)
    (\p ->
    (\ f2p1 f2p f1 p -> if p==1 then f1 () else if p `mod` 2 == 0 then f2p (p `shiftR` 1) else f2p1 (p `shiftR` 1))
      (\q -> (\ p->2*p) (add_carry p q))
      (\q -> (\ p->1+2*p) (add0 p q))
      (\_ -> (\ p->2*p) (succ p))
      y)
    (\_ ->
    (\ f2p1 f2p f1 p -> if p==1 then f1 () else if p `mod` 2 == 0 then f2p (p `shiftR` 1) else f2p1 (p `shiftR` 1))
      (\q -> (\ p->1+2*p) (succ q))
      (\q -> (\ p->2*p) (succ q))
      (\_ -> (\ p->1+2*p) 1)
      y)
    x

pred_double :: Natural -> Natural
pred_double x =
  (\ f2p1 f2p f1 p -> if p==1 then f1 () else if p `mod` 2 == 0 then f2p (p `shiftR` 1) else f2p1 (p `shiftR` 1))
    (\p -> (\ p->1+2*p) ((\ p->2*p) p))
    (\p -> (\ p->1+2*p) (pred_double p))
    (\_ -> 1)
    x

compare_cont :: Comparison -> Natural -> Natural -> Comparison
compare_cont = \ c x y -> if x==y then c else if x<y then Lt else Gt

compare0 :: Natural -> Natural -> Comparison
compare0 = \ x y -> if x==y then Eq else if x<y then Lt else Gt

fold_right :: (a2 -> a1 -> a1) -> a1 -> ([] a2) -> a1
fold_right f a0 l =
  case l of {
   [] -> a0;
   ( : ) b t -> f b (fold_right f a0 t)}

double :: Natural -> Natural
double x =
  (\ f0 fp fn z -> if z==0 then f0 () else if z>0 then fp z else fn (-z))
    (\_ -> 0)
    (\p ->  ((\ p->2*p) p))
    (\p -> (~-) ((\ p->2*p) p))
    x

succ_double :: Natural -> Natural
succ_double x =
  (\ f0 fp fn z -> if z==0 then f0 () else if z>0 then fp z else fn (-z))
    (\_ ->  1)
    (\p ->  ((\ p->1+2*p) p))
    (\p -> (~-) (pred_double p))
    x

pred_double0 :: Natural -> Natural
pred_double0 x =
  (\ f0 fp fn z -> if z==0 then f0 () else if z>0 then fp z else fn (-z))
    (\_ -> (~-) 1)
    (\p ->  (pred_double p))
    (\p -> (~-) ((\ p->1+2*p) p))
    x

pos_sub :: Natural -> Natural -> Natural
pos_sub x y =
  (\ f2p1 f2p f1 p -> if p==1 then f1 () else if p `mod` 2 == 0 then f2p (p `shiftR` 1) else f2p1 (p `shiftR` 1))
    (\p ->
    (\ f2p1 f2p f1 p -> if p==1 then f1 () else if p `mod` 2 == 0 then f2p (p `shiftR` 1) else f2p1 (p `shiftR` 1))
      (\q -> double (pos_sub p q))
      (\q -> succ_double (pos_sub p q))
      (\_ ->  ((\ p->2*p) p))
      y)
    (\p ->
    (\ f2p1 f2p f1 p -> if p==1 then f1 () else if p `mod` 2 == 0 then f2p (p `shiftR` 1) else f2p1 (p `shiftR` 1))
      (\q -> pred_double0 (pos_sub p q))
      (\q -> double (pos_sub p q))
      (\_ ->  (pred_double p))
      y)
    (\_ ->
    (\ f2p1 f2p f1 p -> if p==1 then f1 () else if p `mod` 2 == 0 then f2p (p `shiftR` 1) else f2p1 (p `shiftR` 1))
      (\q -> (~-) ((\ p->2*p) q))
      (\q -> (~-) (pred_double q))
      (\_ -> 0)
      y)
    x

add1 :: Natural -> Natural -> Natural
add1 = (+)

compare1 :: Natural -> Natural -> Comparison
compare1 = \ x y -> if x==y then Eq else if x<y then Lt else Gt

leb :: Natural -> Natural -> Bool
leb x y =
  case compare1 x y of {
   Gt -> False;
   _ -> True}

ltb :: Natural -> Natural -> Bool
ltb x y =
  case compare1 x y of {
   Lt -> True;
   _ -> False}

-- max :: Natural -> Natural -> Natural
-- max = Pervasives.max

type Decidable = Bool

data Compare x =
   LT
 | EQ
 | GT

compare_rect :: a1 -> a1 -> (() -> a2) -> (() -> a2) -> (() -> a2) ->
                (Compare a1) -> a2
compare_rect _ _ f f0 f1 c =
  case c of {
   LT -> f __;
   EQ -> f0 __;
   GT -> f1 __}

compare_rec :: a1 -> a1 -> (() -> a2) -> (() -> a2) -> (() -> a2) -> (Compare
               a1) -> a2
compare_rec =
  compare_rect

type T = Natural

_0 :: Natural
_0 =
  0

_1 :: Natural
_1 =
   1

_2 :: Natural
_2 =
   ((\ p->2*p) 1)

add2 :: Natural -> Natural -> Natural
add2 =
  add1

max0 :: Natural -> Natural -> Natural
max0 =
  max

ltb0 :: Natural -> Natural -> Bool
ltb0 =
  ltb

leb0 :: Natural -> Natural -> Bool
leb0 =
  leb

gt_le_dec :: Natural -> Natural -> Bool
gt_le_dec i j =
  let {b = ltb j i} in case b of {
                        True -> True;
                        False -> False}

ge_lt_dec :: Natural -> Natural -> Bool
ge_lt_dec i j =
  let {b = ltb i j} in case b of {
                        True -> False;
                        False -> True}

type Dec = Decidable
  -- singleton inductive, whose constructor was Build_Dec

dec :: Dec -> Decidable
dec dec0 =
  dec0

beq_reflect :: Natural -> Natural -> Reflect
beq_reflect x y =
  iff_reflect (eqb x y)

compare2 :: Natural -> Natural -> Compare Natural
compare2 x y =
  case compare x y of {
   Eq -> EQ;
   Lt -> LT;
   Gt -> GT}

eq_dec :: Natural -> Natural -> Bool
eq_dec =
  (==)

type T0 = Natural

eq_dec0 :: Natural -> Natural -> Bool
eq_dec0 =
  eq_dec

lt_dec :: Natural -> Natural -> Bool
lt_dec x y =
  compare_rec x y (\_ -> True) (\_ -> False) (\_ -> False) (compare2 x y)

eqb0 :: Natural -> Natural -> Bool
eqb0 x y =
  case eq_dec0 x y of {
   True -> True;
   False -> False}

type T1 = Natural

eq_dec1 :: Natural -> Natural -> Bool
eq_dec1 =
  eq_dec

lt_dec0 :: Natural -> Natural -> Bool
lt_dec0 x y =
  compare_rec x y (\_ -> True) (\_ -> False) (\_ -> False) (compare2 x y)

eqb1 :: Natural -> Natural -> Bool
eqb1 x y =
  case eq_dec1 x y of {
   True -> True;
   False -> False}

type T2 = ( , ) Natural Natural

compare3 :: T2 -> T2 -> Compare (( , ) Natural Natural)
compare3 x y =
  case x of {
    (x1, x2) ->
    case y of {
      (y1, y2) ->
      let {c = compare2 x1 y1} in
      case c of {
       LT -> LT;
       EQ ->
        let {c0 = compare2 x2 y2} in
        case c0 of {
         LT -> LT;
         EQ -> EQ;
         GT -> GT};
       GT -> GT}}}

eq_dec2 :: T2 -> T2 -> Bool
eq_dec2 x y =
  compare_rec x y (\_ -> False) (\_ -> True) (\_ -> False) (compare3 x y)

type T3 = Natural

eq_dec3 :: Natural -> Natural -> Bool
eq_dec3 =
  eq_dec

lt_dec1 :: Natural -> Natural -> Bool
lt_dec1 x y =
  compare_rec x y (\_ -> True) (\_ -> False) (\_ -> False) (compare2 x y)

eqb2 :: Natural -> Natural -> Bool
eqb2 x y =
  case eq_dec3 x y of {
   True -> True;
   False -> False}

type T4 = Natural

eq_dec4 :: Natural -> Natural -> Bool
eq_dec4 =
  eq_dec

lt_dec2 :: Natural -> Natural -> Bool
lt_dec2 x y =
  compare_rec x y (\_ -> True) (\_ -> False) (\_ -> False) (compare2 x y)

eqb3 :: Natural -> Natural -> Bool
eqb3 x y =
  case eq_dec4 x y of {
   True -> True;
   False -> False}

type T5 = ( , ) Natural Natural

compare4 :: T5 -> T5 -> Compare (( , ) Natural Natural)
compare4 x y =
  case x of {
    (x1, x2) ->
    case y of {
      (y1, y2) ->
      let {c = compare2 x1 y1} in
      case c of {
       LT -> LT;
       EQ ->
        let {c0 = compare2 x2 y2} in
        case c0 of {
         LT -> LT;
         EQ -> EQ;
         GT -> GT};
       GT -> GT}}}

eq_dec5 :: T5 -> T5 -> Bool
eq_dec5 x y =
  compare_rec x y (\_ -> False) (\_ -> True) (\_ -> False) (compare4 x y)

type Key = ( , ) Natural Natural

data Tree elt =
   Leaf
 | Node (Tree elt) Key elt (Tree elt) T
 deriving (Show)

tree_rect :: a2 -> ((Tree a1) -> a2 -> Key -> a1 -> (Tree a1) -> a2 -> T ->
             a2) -> (Tree a1) -> a2
tree_rect f f0 t =
  case t of {
   Leaf -> f;
   Node t0 k y t1 t2 ->
    f0 t0 (tree_rect f f0 t0) k y t1 (tree_rect f f0 t1) t2}

tree_rec :: a2 -> ((Tree a1) -> a2 -> Key -> a1 -> (Tree a1) -> a2 -> T ->
            a2) -> (Tree a1) -> a2
tree_rec =
  tree_rect

height :: (Tree a1) -> T
height m =
  case m of {
   Leaf -> _0;
   Node _ _ _ _ h -> h}

cardinal :: (Tree a1) -> Natural
cardinal m =
  case m of {
   Leaf -> 0;
   Node l _ _ r _ -> succ (add (cardinal l) (cardinal r))}

empty :: Tree a1
empty =
  Leaf

is_empty :: (Tree a1) -> Bool
is_empty m =
  case m of {
   Leaf -> True;
   Node _ _ _ _ _ -> False}

mem :: (( , ) Natural Natural) -> (Tree a1) -> Bool
mem x m =
  case m of {
   Leaf -> False;
   Node l y _ r _ ->
    case compare3 x y of {
     LT -> mem x l;
     EQ -> True;
     GT -> mem x r}}

find :: (( , ) Natural Natural) -> (Tree a1) -> Maybe a1
find x m =
  case m of {
   Leaf -> Nothing;
   Node l y d r _ ->
    case compare3 x y of {
     LT -> find x l;
     EQ -> Just d;
     GT -> find x r}}

create :: (Tree a1) -> Key -> a1 -> (Tree a1) -> Tree a1
create l x e r =
  Node l x e r (add2 (max0 (height l) (height r)) _1)

assert_false :: (Tree a1) -> Key -> a1 -> (Tree a1) -> Tree a1
assert_false =
  create

bal :: (Tree a1) -> Key -> a1 -> (Tree a1) -> Tree a1
bal l x d r =
  let {hl = height l} in
  let {hr = height r} in
  case gt_le_dec hl (add2 hr _2) of {
   True ->
    case l of {
     Leaf -> assert_false l x d r;
     Node ll lx ld lr _ ->
      case ge_lt_dec (height ll) (height lr) of {
       True -> create ll lx ld (create lr x d r);
       False ->
        case lr of {
         Leaf -> assert_false l x d r;
         Node lrl lrx lrd lrr _ ->
          create (create ll lx ld lrl) lrx lrd (create lrr x d r)}}};
   False ->
    case gt_le_dec hr (add2 hl _2) of {
     True ->
      case r of {
       Leaf -> assert_false l x d r;
       Node rl rx rd rr _ ->
        case ge_lt_dec (height rr) (height rl) of {
         True -> create (create l x d rl) rx rd rr;
         False ->
          case rl of {
           Leaf -> assert_false l x d r;
           Node rll rlx rld rlr _ ->
            create (create l x d rll) rlx rld (create rlr rx rd rr)}}};
     False -> create l x d r}}

add3 :: Key -> a1 -> (Tree a1) -> Tree a1
add3 x d m =
  case m of {
   Leaf -> Node Leaf x d Leaf _1;
   Node l y d' r h ->
    case compare3 x y of {
     LT -> bal (add3 x d l) y d' r;
     EQ -> Node l y d r h;
     GT -> bal l y d' (add3 x d r)}}

remove_min :: (Tree a1) -> Key -> a1 -> (Tree a1) -> ( , ) (Tree a1)
              (( , ) Key a1)
remove_min l x d r =
  case l of {
   Leaf -> (,) r ((,) x d);
   Node ll lx ld lr _ ->
    case remove_min ll lx ld lr of {
      (l', m) -> (,) (bal l' x d r) m}}

merge :: (Tree a1) -> (Tree a1) -> Tree a1
merge s1 s2 =
  case s1 of {
   Leaf -> s2;
   Node _ _ _ _ _ ->
    case s2 of {
     Leaf -> s1;
     Node l2 x2 d2 r2 _ ->
      case remove_min l2 x2 d2 r2 of {
        (s2', p) -> case p of {
                   (x, d) -> bal s1 x d s2'}}}}

remove :: (( , ) Natural Natural) -> (Tree a1) -> Tree a1
remove x m =
  case m of {
   Leaf -> Leaf;
   Node l y d r _ ->
    case compare3 x y of {
     LT -> bal (remove x l) y d r;
     EQ -> merge l r;
     GT -> bal l y d (remove x r)}}

join :: (Tree a1) -> Key -> a1 -> (Tree a1) -> Tree a1
join l =
  case l of {
   Leaf -> add3;
   Node ll lx ld lr lh -> (\x d ->
    let {
     join_aux r =
       case r of {
        Leaf -> add3 x d l;
        Node rl rx rd rr rh ->
         case gt_le_dec lh (add2 rh _2) of {
          True -> bal ll lx ld (join lr x d r);
          False ->
           case gt_le_dec rh (add2 lh _2) of {
            True -> bal (join_aux rl) rx rd rr;
            False -> create l x d r}}}}
    in join_aux)}

data Triple elt =
   Mktriple (Tree elt) (Maybe elt) (Tree elt)

t_left :: (Triple a1) -> Tree a1
t_left t =
  case t of {
   Mktriple t_left1 _ _ -> t_left1}

t_opt :: (Triple a1) -> Maybe a1
t_opt t =
  case t of {
   Mktriple _ t_opt0 _ -> t_opt0}

t_right :: (Triple a1) -> Tree a1
t_right t =
  case t of {
   Mktriple _ _ t_right1 -> t_right1}

split :: (( , ) Natural Natural) -> (Tree a1) -> Triple a1
split x m =
  case m of {
   Leaf -> Mktriple Leaf Nothing Leaf;
   Node l y d r _ ->
    case compare3 x y of {
     LT ->
      case split x l of {
       Mktriple ll o rl -> Mktriple ll o (join rl y d r)};
     EQ -> Mktriple l (Just d) r;
     GT ->
      case split x r of {
       Mktriple rl o rr -> Mktriple (join l y d rl) o rr}}}

concat :: (Tree a1) -> (Tree a1) -> Tree a1
concat m1 m2 =
  case m1 of {
   Leaf -> m2;
   Node _ _ _ _ _ ->
    case m2 of {
     Leaf -> m1;
     Node l2 x2 d2 r2 _ ->
      case remove_min l2 x2 d2 r2 of {
        (m2', xd) -> join m1 (fst xd) (snd xd) m2'}}}

elements_aux :: ([] (( , ) Key a1)) -> (Tree a1) -> [] (( , ) Key a1)
elements_aux acc m =
  case m of {
   Leaf -> acc;
   Node l x d r _ -> elements_aux (( : ) ((,) x d) (elements_aux acc r)) l}

elements :: (Tree a1) -> [] (( , ) Key a1)
elements =
  elements_aux []

fold :: (Key -> a1 -> a2 -> a2) -> (Tree a1) -> a2 -> a2
fold f m a =
  case m of {
   Leaf -> a;
   Node l x d r _ -> fold f r (f x d (fold f l a))}

data Enumeration elt =
   End
 | More Key elt (Tree elt) (Enumeration elt)

enumeration_rect :: a2 -> (Key -> a1 -> (Tree a1) -> (Enumeration a1) -> a2
                    -> a2) -> (Enumeration a1) -> a2
enumeration_rect f f0 e =
  case e of {
   End -> f;
   More k e0 t e1 -> f0 k e0 t e1 (enumeration_rect f f0 e1)}

enumeration_rec :: a2 -> (Key -> a1 -> (Tree a1) -> (Enumeration a1) -> a2 ->
                   a2) -> (Enumeration a1) -> a2
enumeration_rec =
  enumeration_rect

cons :: (Tree a1) -> (Enumeration a1) -> Enumeration a1
cons m e =
  case m of {
   Leaf -> e;
   Node l x d r _ -> cons l (More x d r e)}

equal_more :: (a1 -> a1 -> Bool) -> (( , ) Natural Natural) -> a1 -> ((Enumeration
              a1) -> Bool) -> (Enumeration a1) -> Bool
equal_more cmp x1 d1 cont e2 =
  case e2 of {
   End -> False;
   More x2 d2 r2 e3 ->
    case compare3 x1 x2 of {
     EQ -> case cmp d1 d2 of {
            True -> cont (cons r2 e3);
            False -> False};
     _ -> False}}

equal_cont :: (a1 -> a1 -> Bool) -> (Tree a1) -> ((Enumeration a1) -> Bool)
              -> (Enumeration a1) -> Bool
equal_cont cmp m1 cont e2 =
  case m1 of {
   Leaf -> cont e2;
   Node l1 x1 d1 r1 _ ->
    equal_cont cmp l1 (equal_more cmp x1 d1 (equal_cont cmp r1 cont)) e2}

equal_end :: (Enumeration a1) -> Bool
equal_end e2 =
  case e2 of {
   End -> True;
   More _ _ _ _ -> False}

equal :: (a1 -> a1 -> Bool) -> (Tree a1) -> (Tree a1) -> Bool
equal cmp m1 m2 =
  equal_cont cmp m1 equal_end (cons m2 End)

map :: (a1 -> a2) -> (Tree a1) -> Tree a2
map f m =
  case m of {
   Leaf -> Leaf;
   Node l x d r h -> Node (map f l) x (f d) (map f r) h}

mapi :: (Key -> a1 -> a2) -> (Tree a1) -> Tree a2
mapi f m =
  case m of {
   Leaf -> Leaf;
   Node l x d r h -> Node (mapi f l) x (f x d) (mapi f r) h}

map_option :: (Key -> a1 -> Maybe a2) -> (Tree a1) -> Tree a2
map_option f m =
  case m of {
   Leaf -> Leaf;
   Node l x d r _ ->
    case f x d of {
     Just d' -> join (map_option f l) x d' (map_option f r);
     Nothing -> concat (map_option f l) (map_option f r)}}

map2_opt :: (Key -> a1 -> (Maybe a2) -> Maybe a3) -> ((Tree a1) -> Tree
            a3) -> ((Tree a2) -> Tree a3) -> (Tree a1) -> (Tree a2) -> Tree
            a3
map2_opt f mapl mapr m1 m2 =
  case m1 of {
   Leaf -> mapr m2;
   Node l1 x1 d1 r1 _ ->
    case m2 of {
     Leaf -> mapl m1;
     Node _ _ _ _ _ ->
      case split x1 m2 of {
       Mktriple l2' o2 r2' ->
        case f x1 d1 o2 of {
         Just e ->
          join (map2_opt f mapl mapr l1 l2') x1 e
            (map2_opt f mapl mapr r1 r2');
         Nothing ->
          concat (map2_opt f mapl mapr l1 l2') (map2_opt f mapl mapr r1 r2')}}}}

map2 :: ((Maybe a1) -> (Maybe a2) -> Maybe a3) -> (Tree a1) -> (Tree
        a2) -> Tree a3
map2 f =
  map2_opt (\_ d o -> f (Just d) o) (map_option (\_ d -> f (Just d) Nothing))
    (map_option (\_ d' -> f Nothing (Just d')))

type T6 = ( , ) Natural Natural

eq_dec6 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eq_dec6 =
  eq_dec2

lt_dec3 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
lt_dec3 x y =
  compare_rec x y (\_ -> True) (\_ -> False) (\_ -> False) (compare3 x y)

eqb4 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eqb4 x y =
  case eq_dec6 x y of {
   True -> True;
   False -> False}

type T7 = ( , ) Natural Natural

eq_dec7 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eq_dec7 =
  eq_dec2

lt_dec4 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
lt_dec4 x y =
  compare_rec x y (\_ -> True) (\_ -> False) (\_ -> False) (compare3 x y)

eqb5 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eqb5 x y =
  case eq_dec7 x y of {
   True -> True;
   False -> False}

type T8 = ( , ) Natural Natural

eq_dec8 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eq_dec8 =
  eq_dec2

lt_dec5 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
lt_dec5 x y =
  compare_rec x y (\_ -> True) (\_ -> False) (\_ -> False) (compare3 x y)

eqb6 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eqb6 x y =
  case eq_dec8 x y of {
   True -> True;
   False -> False}

type T9 = ( , ) Natural Natural

eq_dec9 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eq_dec9 =
  eq_dec2

lt_dec6 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
lt_dec6 x y =
  compare_rec x y (\_ -> True) (\_ -> False) (\_ -> False) (compare3 x y)

eqb7 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eqb7 x y =
  case eq_dec9 x y of {
   True -> True;
   False -> False}

type Key0 = ( , ) Natural Natural

type T10 elt = [] (( , ) (( , ) Natural Natural) elt)

empty0 :: T10 a1
empty0 =
  []

is_empty0 :: (T10 a1) -> Bool
is_empty0 l =
  case l of {
   [] -> True;
   ( : ) _ _ -> False}

mem0 :: Key0 -> (T10 a1) -> Bool
mem0 k s =
  case s of {
   [] -> False;
   ( : ) p l ->
    case p of {
      (k', _) ->
      case compare3 k k' of {
       LT -> False;
       EQ -> True;
       GT -> mem0 k l}}}

data R_mem elt =
   R_mem_0 (T10 elt)
 | R_mem_1 (T10 elt) (( , ) Natural Natural) elt ([] (( , ) (( , ) Natural Natural) elt))
 | R_mem_2 (T10 elt) (( , ) Natural Natural) elt ([] (( , ) (( , ) Natural Natural) elt))
 | R_mem_3 (T10 elt) (( , ) Natural Natural) elt ([] (( , ) (( , ) Natural Natural) elt))
 Bool (R_mem elt)

r_mem_rect :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , ) Natural
              Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () ->
              () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
              a1) -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> Bool -> (R_mem
              a1) -> a2 -> a2) -> (T10 a1) -> Bool -> (R_mem a1) -> a2
r_mem_rect k f f0 f1 f2 _ _ r =
  case r of {
   R_mem_0 s -> f s __;
   R_mem_1 s k' _x l -> f0 s k' _x l __ __ __;
   R_mem_2 s k' _x l -> f1 s k' _x l __ __ __;
   R_mem_3 s k' _x l _res r0 ->
    f2 s k' _x l __ __ __ _res r0 (r_mem_rect k f f0 f1 f2 l _res r0)}

r_mem_rec :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , ) Natural
             Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () ->
             () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
             (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
             a1) -> (( , ) Natural Natural) -> a1 -> ([]
             (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> Bool -> (R_mem
             a1) -> a2 -> a2) -> (T10 a1) -> Bool -> (R_mem a1) -> a2
r_mem_rec =
  r_mem_rect

mem_rect :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , ) Natural
            Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () -> ()
            -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
            (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
            a1) -> (( , ) Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1))
            -> () -> () -> () -> a2 -> a2) -> (T10 a1) -> a2
mem_rect k f2 f1 f0 f s =
  eq_rect_r
    (case s of {
      [] -> False;
      ( : ) p l ->
       case p of {
         (k', _) ->
         case compare3 k k' of {
          LT -> False;
          EQ -> True;
          GT -> mem0 k l}}})
    (let {f3 = f2 s} in
     let {f4 = f1 s} in
     let {f5 = f0 s} in
     let {f6 = f s} in
     case s of {
      [] -> f3 __;
      ( : ) p l ->
       case p of {
         (t0, e) ->
         let {f7 = f6 t0 e l __} in
         let {
          f8 = \_ _ -> let {hrec = mem_rect k f2 f1 f0 f l} in f7 __ __ hrec}
         in
         let {f9 = f5 t0 e l __} in
         let {f10 = f4 t0 e l __} in
         case compare3 k t0 of {
          LT -> f10 __ __;
          EQ -> f9 __ __;
          GT -> f8 __ __}}}) (mem0 k s)

mem_rec :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , ) Natural
           Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () -> ()
           -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
           (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
           a1) -> (( , ) Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1))
           -> () -> () -> () -> a2 -> a2) -> (T10 a1) -> a2
mem_rec =
  mem_rect

r_mem_correct :: Key0 -> (T10 a1) -> Bool -> R_mem a1
r_mem_correct k s _res =
  unsafeCoerce mem_rect k (\y _ z _ -> eq_rect_r False (R_mem_0 y) z)
    (\y y0 y1 y2 _ _ _ z _ -> eq_rect_r False (R_mem_1 y y0 y1 y2) z)
    (\y y0 y1 y2 _ _ _ z _ -> eq_rect_r True (R_mem_2 y y0 y1 y2) z)
    (\y y0 y1 y2 _ _ _ y6 z _ ->
    eq_rect_r (mem0 k y2) (R_mem_3 y y0 y1 y2 (mem0 k y2)
      (y6 (mem0 k y2) __)) z) s _res __

find0 :: Key0 -> (T10 a1) -> Maybe a1
find0 k s =
  case s of {
   [] -> Nothing;
   ( : ) p s' ->
    case p of {
      (k', x) ->
      case compare3 k k' of {
       LT -> Nothing;
       EQ -> Just x;
       GT -> find0 k s'}}}

data R_find elt =
   R_find_0 (T10 elt)
 | R_find_1 (T10 elt) (( , ) Natural Natural) elt ([] (( , ) (( , ) Natural Natural) elt))
 | R_find_2 (T10 elt) (( , ) Natural Natural) elt ([] (( , ) (( , ) Natural Natural) elt))
 | R_find_3 (T10 elt) (( , ) Natural Natural) elt ([] (( , ) (( , ) Natural Natural) elt))
 (Maybe elt) (R_find elt)

r_find_rect :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , )
               Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () ->
               () -> () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
               (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
               a1) -> (( , ) Natural Natural) -> a1 -> ([]
               (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> (Maybe
               a1) -> (R_find a1) -> a2 -> a2) -> (T10 a1) -> (Maybe
               a1) -> (R_find a1) -> a2
r_find_rect k f f0 f1 f2 _ _ r =
  case r of {
   R_find_0 s -> f s __;
   R_find_1 s k' x s' -> f0 s k' x s' __ __ __;
   R_find_2 s k' x s' -> f1 s k' x s' __ __ __;
   R_find_3 s k' x s' _res r0 ->
    f2 s k' x s' __ __ __ _res r0 (r_find_rect k f f0 f1 f2 s' _res r0)}

r_find_rec :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , ) Natural
              Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () ->
              () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
              a1) -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> (Maybe
              a1) -> (R_find a1) -> a2 -> a2) -> (T10 a1) -> (Maybe
              a1) -> (R_find a1) -> a2
r_find_rec =
  r_find_rect

find_rect :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , ) Natural
             Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () ->
             () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
             (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
             a1) -> (( , ) Natural Natural) -> a1 -> ([]
             (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2 -> a2) ->
             (T10 a1) -> a2
find_rect k f2 f1 f0 f s =
  eq_rect_r
    (case s of {
      [] -> Nothing;
      ( : ) p s' ->
       case p of {
         (k', x) ->
         case compare3 k k' of {
          LT -> Nothing;
          EQ -> Just x;
          GT -> find0 k s'}}})
    (let {f3 = f2 s} in
     let {f4 = f1 s} in
     let {f5 = f0 s} in
     let {f6 = f s} in
     case s of {
      [] -> f3 __;
      ( : ) p l ->
       case p of {
         (t0, e) ->
         let {f7 = f6 t0 e l __} in
         let {
          f8 = \_ _ ->
           let {hrec = find_rect k f2 f1 f0 f l} in f7 __ __ hrec}
         in
         let {f9 = f5 t0 e l __} in
         let {f10 = f4 t0 e l __} in
         case compare3 k t0 of {
          LT -> f10 __ __;
          EQ -> f9 __ __;
          GT -> f8 __ __}}}) (find0 k s)

find_rec :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , ) Natural
            Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () -> ()
            -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
            (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
            a1) -> (( , ) Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1))
            -> () -> () -> () -> a2 -> a2) -> (T10 a1) -> a2
find_rec =
  find_rect

r_find_correct :: Key0 -> (T10 a1) -> (Maybe a1) -> R_find a1
r_find_correct k s _res =
  unsafeCoerce find_rect k (\y _ z _ -> eq_rect_r Nothing (R_find_0 y) z)
    (\y y0 y1 y2 _ _ _ z _ -> eq_rect_r Nothing (R_find_1 y y0 y1 y2) z)
    (\y y0 y1 y2 _ _ _ z _ -> eq_rect_r (Just y1) (R_find_2 y y0 y1 y2) z)
    (\y y0 y1 y2 _ _ _ y6 z _ ->
    eq_rect_r (find0 k y2) (R_find_3 y y0 y1 y2 (find0 k y2)
      (y6 (find0 k y2) __)) z) s _res __

add4 :: Key0 -> a1 -> (T10 a1) -> T10 a1
add4 k x s =
  case s of {
   [] -> ( : ) ((,) k x) [];
   ( : ) p l ->
    case p of {
      (k', y) ->
      case compare3 k k' of {
       LT -> ( : ) ((,) k x) s;
       EQ -> ( : ) ((,) k x) l;
       GT -> ( : ) ((,) k' y) (add4 k x l)}}}

data R_add elt =
   R_add_0 (T10 elt)
 | R_add_1 (T10 elt) (( , ) Natural Natural) elt ([] (( , ) (( , ) Natural Natural) elt))
 | R_add_2 (T10 elt) (( , ) Natural Natural) elt ([] (( , ) (( , ) Natural Natural) elt))
 | R_add_3 (T10 elt) (( , ) Natural Natural) elt ([] (( , ) (( , ) Natural Natural) elt))
 (T10 elt) (R_add elt)

r_add_rect :: Key0 -> a1 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , )
              Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> ()
              -> () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
              a1) -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> (T10 a1) ->
              (R_add a1) -> a2 -> a2) -> (T10 a1) -> (T10 a1) -> (R_add
              a1) -> a2
r_add_rect k x f f0 f1 f2 _ _ r =
  case r of {
   R_add_0 s -> f s __;
   R_add_1 s k' y l -> f0 s k' y l __ __ __;
   R_add_2 s k' y l -> f1 s k' y l __ __ __;
   R_add_3 s k' y l _res r0 ->
    f2 s k' y l __ __ __ _res r0 (r_add_rect k x f f0 f1 f2 l _res r0)}

r_add_rec :: Key0 -> a1 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , )
             Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> ()
             -> () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
             (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
             a1) -> (( , ) Natural Natural) -> a1 -> ([]
             (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> (T10 a1) ->
             (R_add a1) -> a2 -> a2) -> (T10 a1) -> (T10 a1) -> (R_add
             a1) -> a2
r_add_rec =
  r_add_rect

add_rect :: Key0 -> a1 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , )
            Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> ()
            -> () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
            (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
            a1) -> (( , ) Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1))
            -> () -> () -> () -> a2 -> a2) -> (T10 a1) -> a2
add_rect k x f2 f1 f0 f s =
  eq_rect_r
    (case s of {
      [] -> ( : ) ((,) k x) [];
      ( : ) p l ->
       case p of {
         (k', y) ->
         case compare3 k k' of {
          LT -> ( : ) ((,) k x) s;
          EQ -> ( : ) ((,) k x) l;
          GT -> ( : ) ((,) k' y) (add4 k x l)}}})
    (let {f3 = f2 s} in
     let {f4 = f1 s} in
     let {f5 = f0 s} in
     let {f6 = f s} in
     case s of {
      [] -> f3 __;
      ( : ) p l ->
       case p of {
         (t0, e) ->
         let {f7 = f6 t0 e l __} in
         let {
          f8 = \_ _ ->
           let {hrec = add_rect k x f2 f1 f0 f l} in f7 __ __ hrec}
         in
         let {f9 = f5 t0 e l __} in
         let {f10 = f4 t0 e l __} in
         case compare3 k t0 of {
          LT -> f10 __ __;
          EQ -> f9 __ __;
          GT -> f8 __ __}}}) (add4 k x s)

add_rec :: Key0 -> a1 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , )
           Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () ->
           () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
           (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
           a1) -> (( , ) Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1))
           -> () -> () -> () -> a2 -> a2) -> (T10 a1) -> a2
add_rec =
  add_rect

r_add_correct :: Key0 -> a1 -> (T10 a1) -> (T10 a1) -> R_add a1
r_add_correct k x s _res =
  add_rect k x (\y _ z _ -> eq_rect_r (( : ) ((,) k x) []) (R_add_0 y) z)
    (\y y0 y1 y2 _ _ _ z _ ->
    eq_rect_r (( : ) ((,) k x) y) (R_add_1 y y0 y1 y2) z)
    (\y y0 y1 y2 _ _ _ z _ ->
    eq_rect_r (( : ) ((,) k x) y2) (R_add_2 y y0 y1 y2) z)
    (\y y0 y1 y2 _ _ _ y6 z _ ->
    eq_rect_r (( : ) ((,) y0 y1) (add4 k x y2)) (R_add_3 y y0 y1 y2
      (add4 k x y2) (y6 (add4 k x y2) __)) z) s _res __

remove0 :: Key0 -> (T10 a1) -> T10 a1
remove0 k s =
  case s of {
   [] -> [];
   ( : ) p l ->
    case p of {
      (k', x) ->
      case compare3 k k' of {
       LT -> s;
       EQ -> l;
       GT -> ( : ) ((,) k' x) (remove0 k l)}}}

data R_remove elt =
   R_remove_0 (T10 elt)
 | R_remove_1 (T10 elt) (( , ) Natural Natural) elt ([]
                                            (( , ) (( , ) Natural Natural) elt))
 | R_remove_2 (T10 elt) (( , ) Natural Natural) elt ([]
                                            (( , ) (( , ) Natural Natural) elt))
 | R_remove_3 (T10 elt) (( , ) Natural Natural) elt ([]
                                            (( , ) (( , ) Natural Natural) elt))
 (T10 elt) (R_remove elt)

r_remove_rect :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , )
                 Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () ->
                 () -> () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 ->
                 ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2)
                 -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
                 (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> (T10
                 a1) -> (R_remove a1) -> a2 -> a2) -> (T10 a1) -> (T10
                 a1) -> (R_remove a1) -> a2
r_remove_rect k f f0 f1 f2 _ _ r =
  case r of {
   R_remove_0 s -> f s __;
   R_remove_1 s k' x l -> f0 s k' x l __ __ __;
   R_remove_2 s k' x l -> f1 s k' x l __ __ __;
   R_remove_3 s k' x l _res r0 ->
    f2 s k' x l __ __ __ _res r0 (r_remove_rect k f f0 f1 f2 l _res r0)}

r_remove_rec :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , )
                Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () ->
                () -> () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 ->
                ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) ->
                ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
                (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> (T10
                a1) -> (R_remove a1) -> a2 -> a2) -> (T10 a1) -> (T10
                a1) -> (R_remove a1) -> a2
r_remove_rec =
  r_remove_rect

remove_rect :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , )
               Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () ->
               () -> () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
               (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
               a1) -> (( , ) Natural Natural) -> a1 -> ([]
               (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2 -> a2) ->
               (T10 a1) -> a2
remove_rect k f2 f1 f0 f s =
  eq_rect_r
    (case s of {
      [] -> [];
      ( : ) p l ->
       case p of {
         (k', x) ->
         case compare3 k k' of {
          LT -> s;
          EQ -> l;
          GT -> ( : ) ((,) k' x) (remove0 k l)}}})
    (let {f3 = f2 s} in
     let {f4 = f1 s} in
     let {f5 = f0 s} in
     let {f6 = f s} in
     case s of {
      [] -> f3 __;
      ( : ) p l ->
       case p of {
         (t0, e) ->
         let {f7 = f6 t0 e l __} in
         let {
          f8 = \_ _ ->
           let {hrec = remove_rect k f2 f1 f0 f l} in f7 __ __ hrec}
         in
         let {f9 = f5 t0 e l __} in
         let {f10 = f4 t0 e l __} in
         case compare3 k t0 of {
          LT -> f10 __ __;
          EQ -> f9 __ __;
          GT -> f8 __ __}}}) (remove0 k s)

remove_rec :: Key0 -> ((T10 a1) -> () -> a2) -> ((T10 a1) -> (( , ) Natural
              Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () ->
              () -> a2) -> ((T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2) -> ((T10
              a1) -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2 -> a2) ->
              (T10 a1) -> a2
remove_rec =
  remove_rect

r_remove_correct :: Key0 -> (T10 a1) -> (T10 a1) -> R_remove a1
r_remove_correct k s _res =
  unsafeCoerce remove_rect k (\y _ z _ -> eq_rect_r [] (R_remove_0 y) z)
    (\y y0 y1 y2 _ _ _ z _ -> eq_rect_r y (R_remove_1 y y0 y1 y2) z)
    (\y y0 y1 y2 _ _ _ z _ -> eq_rect_r y2 (R_remove_2 y y0 y1 y2) z)
    (\y y0 y1 y2 _ _ _ y6 z _ ->
    eq_rect_r (( : ) ((,) y0 y1) (remove0 k y2)) (R_remove_3 y y0 y1 y2
      (remove0 k y2) (y6 (remove0 k y2) __)) z) s _res __

elements0 :: (T10 a1) -> T10 a1
elements0 m =
  m

fold0 :: (Key0 -> a1 -> a2 -> a2) -> (T10 a1) -> a2 -> a2
fold0 f m acc =
  case m of {
   [] -> acc;
   ( : ) p m' -> case p of {
                    (k, e) -> fold0 f m' (f k e acc)}}

data R_fold elt a =
   R_fold_0 (T10 elt) a
 | R_fold_1 (T10 elt) a (( , ) Natural Natural) elt ([]
                                            (( , ) (( , ) Natural Natural) elt))
 a (R_fold elt a)

r_fold_rect :: (Key0 -> a1 -> a2 -> a2) -> ((T10 a1) -> a2 -> () -> a3) ->
               ((T10 a1) -> a2 -> (( , ) Natural Natural) -> a1 -> ([]
               (( , ) (( , ) Natural Natural) a1)) -> () -> a2 -> (R_fold a1
               a2) -> a3 -> a3) -> (T10 a1) -> a2 -> a2 -> (R_fold a1
               a2) -> a3
r_fold_rect f f0 f1 _ _ _ r =
  case r of {
   R_fold_0 m acc -> f0 m acc __;
   R_fold_1 m acc k e m' _res r0 ->
    f1 m acc k e m' __ _res r0 (r_fold_rect f f0 f1 m' (f k e acc) _res r0)}

r_fold_rec :: (Key0 -> a1 -> a2 -> a2) -> ((T10 a1) -> a2 -> () -> a3) ->
              ((T10 a1) -> a2 -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> a2 -> (R_fold a1 a2) -> a3
              -> a3) -> (T10 a1) -> a2 -> a2 -> (R_fold a1 a2) -> a3
r_fold_rec =
  r_fold_rect

fold_rect :: (Key0 -> a1 -> a2 -> a2) -> ((T10 a1) -> a2 -> () -> a3) ->
             ((T10 a1) -> a2 -> (( , ) Natural Natural) -> a1 -> ([]
             (( , ) (( , ) Natural Natural) a1)) -> () -> a3 -> a3) -> (T10 a1) -> a2
             -> a3
fold_rect f1 f0 f m acc =
  eq_rect_r
    (case m of {
      [] -> acc;
      ( : ) p m' -> case p of {
                       (k, e) -> fold0 f1 m' (f1 k e acc)}})
    (let {f2 = f0 m acc} in
     let {f3 = f m acc} in
     case m of {
      [] -> f2 __;
      ( : ) p l ->
       case p of {
         (t0, e) ->
         let {f4 = f3 t0 e l __} in
         let {hrec = fold_rect f1 f0 f l (f1 t0 e acc)} in f4 hrec}})
    (fold0 f1 m acc)

fold_rec :: (Key0 -> a1 -> a2 -> a2) -> ((T10 a1) -> a2 -> () -> a3) -> ((T10
            a1) -> a2 -> (( , ) Natural Natural) -> a1 -> ([]
            (( , ) (( , ) Natural Natural) a1)) -> () -> a3 -> a3) -> (T10 a1) -> a2
            -> a3
fold_rec =
  fold_rect

r_fold_correct :: (Key0 -> a1 -> a2 -> a2) -> (T10 a1) -> a2 -> a2 -> R_fold
                  a1 a2
r_fold_correct f m acc _res =
  fold_rect f (\y y0 _ z _ -> eq_rect_r y0 (R_fold_0 y y0) z)
    (\y y0 y1 y2 y3 _ y5 z _ ->
    eq_rect_r (fold0 f y3 (f y1 y2 y0)) (R_fold_1 y y0 y1 y2 y3
      (fold0 f y3 (f y1 y2 y0)) (y5 (fold0 f y3 (f y1 y2 y0)) __)) z) m acc
    _res __

equal0 :: (a1 -> a1 -> Bool) -> (T10 a1) -> (T10 a1) -> Bool
equal0 cmp m m' =
  case m of {
   [] -> case m' of {
          [] -> True;
          ( : ) _ _ -> False};
   ( : ) p l ->
    case p of {
      (x, e) ->
      case m' of {
       [] -> False;
       ( : ) p0 l' ->
        case p0 of {
          (x', e') ->
          case compare3 x x' of {
           EQ -> (&&) (cmp e e') (equal0 cmp l l');
           _ -> False}}}}}

data R_equal elt =
   R_equal_0 (T10 elt) (T10 elt)
 | R_equal_1 (T10 elt) (T10 elt) (( , ) Natural Natural) elt ([]
                                                     (( , ) (( , ) Natural Natural)
                                                     elt)) (( , ) Natural Natural)
 elt ([] (( , ) (( , ) Natural Natural) elt)) Bool (R_equal elt)
 | R_equal_2 (T10 elt) (T10 elt) (( , ) Natural Natural) elt ([]
                                                     (( , ) (( , ) Natural Natural)
                                                     elt)) (( , ) Natural Natural)
 elt ([] (( , ) (( , ) Natural Natural) elt)) (Compare (( , ) Natural Natural))
 | R_equal_3 (T10 elt) (T10 elt) (T10 elt) (T10 elt)

r_equal_rect :: (a1 -> a1 -> Bool) -> ((T10 a1) -> (T10 a1) -> () -> () ->
                a2) -> ((T10 a1) -> (T10 a1) -> (( , ) Natural Natural) -> a1 ->
                ([] (( , ) (( , ) Natural Natural) a1)) -> () -> (( , ) Natural
                Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () -> ()
                -> () -> Bool -> (R_equal a1) -> a2 -> a2) -> ((T10 a1) ->
                (T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
                (( , ) (( , ) Natural Natural) a1)) -> () -> (( , ) Natural Natural) -> a1 ->
                ([] (( , ) (( , ) Natural Natural) a1)) -> () -> (Compare
                (( , ) Natural Natural)) -> () -> () -> a2) -> ((T10 a1) -> (T10
                a1) -> (T10 a1) -> () -> (T10 a1) -> () -> () -> a2) -> (T10
                a1) -> (T10 a1) -> Bool -> (R_equal a1) -> a2
r_equal_rect cmp f f0 f1 f2 _ _ _ r =
  case r of {
   R_equal_0 m m' -> f m m' __ __;
   R_equal_1 m m' x e l x' e' l' _res r0 ->
    f0 m m' x e l __ x' e' l' __ __ __ _res r0
      (r_equal_rect cmp f f0 f1 f2 l l' _res r0);
   R_equal_2 m m' x e l x' e' l' _x -> f1 m m' x e l __ x' e' l' __ _x __ __;
   R_equal_3 m m' _x _x0 -> f2 m m' _x __ _x0 __ __}

r_equal_rec :: (a1 -> a1 -> Bool) -> ((T10 a1) -> (T10 a1) -> () -> () -> a2)
               -> ((T10 a1) -> (T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
               (( , ) (( , ) Natural Natural) a1)) -> () -> (( , ) Natural Natural) -> a1 ->
               ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> Bool ->
               (R_equal a1) -> a2 -> a2) -> ((T10 a1) -> (T10 a1) -> (( , )
               Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) -> () ->
               (( , ) Natural Natural) -> a1 -> ([] (( , ) (( , ) Natural Natural) a1)) ->
               () -> (Compare (( , ) Natural Natural)) -> () -> () -> a2) -> ((T10
               a1) -> (T10 a1) -> (T10 a1) -> () -> (T10 a1) -> () -> () ->
               a2) -> (T10 a1) -> (T10 a1) -> Bool -> (R_equal a1) -> a2
r_equal_rec =
  r_equal_rect

equal_rect :: (a1 -> a1 -> Bool) -> ((T10 a1) -> (T10 a1) -> () -> () -> a2)
              -> ((T10 a1) -> (T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> (( , ) Natural Natural) -> a1 ->
              ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2 ->
              a2) -> ((T10 a1) -> (T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
              (( , ) (( , ) Natural Natural) a1)) -> () -> (( , ) Natural Natural) -> a1 ->
              ([] (( , ) (( , ) Natural Natural) a1)) -> () -> (Compare
              (( , ) Natural Natural)) -> () -> () -> a2) -> ((T10 a1) -> (T10
              a1) -> (T10 a1) -> () -> (T10 a1) -> () -> () -> a2) -> (T10
              a1) -> (T10 a1) -> a2
equal_rect cmp f2 f1 f0 f m m' =
  eq_rect_r
    (case m of {
      [] -> case m' of {
             [] -> True;
             ( : ) _ _ -> False};
      ( : ) p l ->
       case p of {
         (x, e) ->
         case m' of {
          [] -> False;
          ( : ) p0 l' ->
           case p0 of {
             (x', e') ->
             case compare3 x x' of {
              EQ -> (&&) (cmp e e') (equal0 cmp l l');
              _ -> False}}}}})
    (let {f3 = f2 m m'} in
     let {f4 = f1 m m'} in
     let {f5 = f0 m m'} in
     let {f6 = f m m'} in
     let {f7 = f6 m __} in
     let {f8 = f7 m' __} in
     case m of {
      [] ->
       let {f9 = f3 __} in case m' of {
                            [] -> f9 __;
                            ( : ) _ _ -> f8 __};
      ( : ) p l ->
       case p of {
         (t0, e) ->
         let {f9 = f5 t0 e l __} in
         let {f10 = f4 t0 e l __} in
         case m' of {
          [] -> f8 __;
          ( : ) p0 l0 ->
           case p0 of {
             (t1, e0) ->
             let {f11 = f9 t1 e0 l0 __} in
             let {f12 = let {_x = compare3 t0 t1} in f11 _x __} in
             let {f13 = f10 t1 e0 l0 __} in
             let {
              f14 = \_ _ ->
               let {hrec = equal_rect cmp f2 f1 f0 f l l0} in f13 __ __ hrec}
             in
             case compare3 t0 t1 of {
              EQ -> f14 __ __;
              _ -> f12 __}}}}}) (equal0 cmp m m')

equal_rec :: (a1 -> a1 -> Bool) -> ((T10 a1) -> (T10 a1) -> () -> () -> a2)
             -> ((T10 a1) -> (T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
             (( , ) (( , ) Natural Natural) a1)) -> () -> (( , ) Natural Natural) -> a1 ->
             ([] (( , ) (( , ) Natural Natural) a1)) -> () -> () -> () -> a2 -> a2)
             -> ((T10 a1) -> (T10 a1) -> (( , ) Natural Natural) -> a1 -> ([]
             (( , ) (( , ) Natural Natural) a1)) -> () -> (( , ) Natural Natural) -> a1 ->
             ([] (( , ) (( , ) Natural Natural) a1)) -> () -> (Compare
             (( , ) Natural Natural)) -> () -> () -> a2) -> ((T10 a1) -> (T10
             a1) -> (T10 a1) -> () -> (T10 a1) -> () -> () -> a2) -> (T10
             a1) -> (T10 a1) -> a2
equal_rec =
  equal_rect

r_equal_correct :: (a1 -> a1 -> Bool) -> (T10 a1) -> (T10 a1) -> Bool ->
                   R_equal a1
r_equal_correct cmp m m' _res =
  equal_rect cmp (\y y0 _ _ z _ -> eq_rect_r True (R_equal_0 y y0) z)
    (\y y0 y1 y2 y3 _ y5 y6 y7 _ _ _ y11 z _ ->
    eq_rect_r ((&&) (cmp y2 y6) (equal0 cmp y3 y7)) (R_equal_1 y y0 y1 y2 y3
      y5 y6 y7 (equal0 cmp y3 y7) (y11 (equal0 cmp y3 y7) __)) z)
    (\y y0 y1 y2 y3 _ y5 y6 y7 _ y9 _ _ z _ ->
    eq_rect_r False (R_equal_2 y y0 y1 y2 y3 y5 y6 y7 y9) z)
    (\y y0 y1 _ y3 _ _ z _ -> eq_rect_r False (R_equal_3 y y0 y1 y3) z) m m'
    _res __

map0 :: (a1 -> a2) -> (T10 a1) -> T10 a2
map0 f m =
  case m of {
   [] -> [];
   ( : ) p m' -> case p of {
                    (k, e) -> ( : ) ((,) k (f e)) (map0 f m')}}

mapi0 :: (Key0 -> a1 -> a2) -> (T10 a1) -> T10 a2
mapi0 f m =
  case m of {
   [] -> [];
   ( : ) p m' -> case p of {
                    (k, e) -> ( : ) ((,) k (f k e)) (mapi0 f m')}}

option_cons :: Key0 -> (Maybe a1) -> ([] (( , ) Key0 a1)) -> []
               (( , ) Key0 a1)
option_cons k o l =
  case o of {
   Just e -> ( : ) ((,) k e) l;
   Nothing -> l}

map2_l :: ((Maybe a1) -> (Maybe a2) -> Maybe a3) -> (T10 a1) -> T10 a3
map2_l f m =
  case m of {
   [] -> [];
   ( : ) p l ->
    case p of {
      (k, e) -> option_cons k (f (Just e) Nothing) (map2_l f l)}}

map2_r :: ((Maybe a1) -> (Maybe a2) -> Maybe a3) -> (T10 a2) -> T10 a3
map2_r f m' =
  case m' of {
   [] -> [];
   ( : ) p l' ->
    case p of {
      (k, e') -> option_cons k (f Nothing (Just e')) (map2_r f l')}}

map1 :: ((Maybe a1) -> (Maybe a2) -> Maybe a3) -> (T10 a1) -> (T10
        a2) -> T10 a3
map1 f m =
  case m of {
   [] -> map2_r f;
   ( : ) p l ->
    case p of {
      (k, e) ->
      let {
       map2_aux m' =
         case m' of {
          [] -> map2_l f m;
          ( : ) p0 l' ->
           case p0 of {
             (k', e') ->
             case compare3 k k' of {
              LT -> option_cons k (f (Just e) Nothing) (map1 f l m');
              EQ -> option_cons k (f (Just e) (Just e')) (map1 f l l');
              GT -> option_cons k' (f Nothing (Just e')) (map2_aux l')}}}}
      in map2_aux}}

combine :: (T10 a1) -> (T10 a2) -> T10 (( , ) (Maybe a1) (Maybe a2))
combine m =
  case m of {
   [] -> map0 (\e' -> (,) Nothing (Just e'));
   ( : ) p l ->
    case p of {
      (k, e) ->
      let {
       combine_aux m' =
         case m' of {
          [] -> map0 (\e0 -> (,) (Just e0) Nothing) m;
          ( : ) p0 l' ->
           case p0 of {
             (k', e') ->
             case compare3 k k' of {
              LT -> ( : ) ((,) k ((,) (Just e) Nothing)) (combine l m');
              EQ -> ( : ) ((,) k ((,) (Just e) (Just e'))) (combine l l');
              GT -> ( : ) ((,) k' ((,) Nothing (Just e'))) (combine_aux l')}}}}
      in combine_aux}}

fold_right_pair :: (a1 -> a2 -> a3 -> a3) -> ([] (( , ) a1 a2)) -> a3 -> a3
fold_right_pair f l i =
  fold_right (\p -> f (fst p) (snd p)) i l

map2_alt :: ((Maybe a1) -> (Maybe a2) -> Maybe a3) -> (T10 a1) -> (T10
            a2) -> [] (( , ) Key0 a3)
map2_alt f m m' =
  let {m0 = combine m m'} in
  let {m1 = map0 (\p -> f (fst p) (snd p)) m0} in
  fold_right_pair option_cons m1 []

at_least_one :: (Maybe a1) -> (Maybe a2) -> Maybe
                (( , ) (Maybe a1) (Maybe a2))
at_least_one o o' =
  case o of {
   Just _ -> Just ((,) o o');
   Nothing -> case o' of {
            Just _ -> Just ((,) o o');
            Nothing -> Nothing}}

at_least_one_then_f :: ((Maybe a1) -> (Maybe a2) -> Maybe a3) -> (Maybe
                       a1) -> (Maybe a2) -> Maybe a3
at_least_one_then_f f o o' =
  case o of {
   Just _ -> f o o';
   Nothing -> case o' of {
            Just _ -> f o o';
            Nothing -> Nothing}}

data R_mem0 elt =
   R_mem_4 (Tree elt)
 | R_mem_5 (Tree elt) (Tree elt) Key elt (Tree elt) T Bool (R_mem0 elt)
 | R_mem_6 (Tree elt) (Tree elt) Key elt (Tree elt) T
 | R_mem_7 (Tree elt) (Tree elt) Key elt (Tree elt) T Bool (R_mem0 elt)

r_mem_rect0 :: (( , ) Natural Natural) -> ((Tree a1) -> () -> a2) -> ((Tree a1) ->
               (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () ->
               Bool -> (R_mem0 a1) -> a2 -> a2) -> ((Tree a1) -> (Tree
               a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> a2) ->
               ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> ()
               -> () -> () -> Bool -> (R_mem0 a1) -> a2 -> a2) -> (Tree
               a1) -> Bool -> (R_mem0 a1) -> a2
r_mem_rect0 x f f0 f1 f2 _ _ r =
  case r of {
   R_mem_4 m -> f m __;
   R_mem_5 m l y _x r0 _x0 _res r1 ->
    f0 m l y _x r0 _x0 __ __ __ _res r1 (r_mem_rect0 x f f0 f1 f2 l _res r1);
   R_mem_6 m l y _x r0 _x0 -> f1 m l y _x r0 _x0 __ __ __;
   R_mem_7 m l y _x r0 _x0 _res r1 ->
    f2 m l y _x r0 _x0 __ __ __ _res r1 (r_mem_rect0 x f f0 f1 f2 r0 _res r1)}

r_mem_rec0 :: (( , ) Natural Natural) -> ((Tree a1) -> () -> a2) -> ((Tree a1) ->
              (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () ->
              Bool -> (R_mem0 a1) -> a2 -> a2) -> ((Tree a1) -> (Tree
              a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> a2) ->
              ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () ->
              () -> () -> Bool -> (R_mem0 a1) -> a2 -> a2) -> (Tree a1) ->
              Bool -> (R_mem0 a1) -> a2
r_mem_rec0 =
  r_mem_rect0

data R_find0 elt =
   R_find_4 (Tree elt)
 | R_find_5 (Tree elt) (Tree elt) Key elt (Tree elt) T (Maybe elt) (R_find0
                                                                    elt)
 | R_find_6 (Tree elt) (Tree elt) Key elt (Tree elt) T
 | R_find_7 (Tree elt) (Tree elt) Key elt (Tree elt) T (Maybe elt) (R_find0
                                                                    elt)

r_find_rect0 :: (( , ) Natural Natural) -> ((Tree a1) -> () -> a2) -> ((Tree
                a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
                -> () -> (Maybe a1) -> (R_find0 a1) -> a2 -> a2) -> ((Tree
                a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
                -> () -> a2) -> ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree
                a1) -> T -> () -> () -> () -> (Maybe a1) -> (R_find0
                a1) -> a2 -> a2) -> (Tree a1) -> (Maybe a1) -> (R_find0
                a1) -> a2
r_find_rect0 x f f0 f1 f2 _ _ r =
  case r of {
   R_find_4 m -> f m __;
   R_find_5 m l y d r0 _x _res r1 ->
    f0 m l y d r0 _x __ __ __ _res r1 (r_find_rect0 x f f0 f1 f2 l _res r1);
   R_find_6 m l y d r0 _x -> f1 m l y d r0 _x __ __ __;
   R_find_7 m l y d r0 _x _res r1 ->
    f2 m l y d r0 _x __ __ __ _res r1 (r_find_rect0 x f f0 f1 f2 r0 _res r1)}

r_find_rec0 :: (( , ) Natural Natural) -> ((Tree a1) -> () -> a2) -> ((Tree a1) ->
               (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () ->
               (Maybe a1) -> (R_find0 a1) -> a2 -> a2) -> ((Tree a1) ->
               (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () ->
               a2) -> ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T
               -> () -> () -> () -> (Maybe a1) -> (R_find0 a1) -> a2 -> a2)
               -> (Tree a1) -> (Maybe a1) -> (R_find0 a1) -> a2
r_find_rec0 =
  r_find_rect0

data R_bal elt =
   R_bal_0 (Tree elt) Key elt (Tree elt)
 | R_bal_1 (Tree elt) Key elt (Tree elt) (Tree elt) Key elt (Tree elt)
 T
 | R_bal_2 (Tree elt) Key elt (Tree elt) (Tree elt) Key elt (Tree elt)
 T
 | R_bal_3 (Tree elt) Key elt (Tree elt) (Tree elt) Key elt (Tree elt)
 T (Tree elt) Key elt (Tree elt) T
 | R_bal_4 (Tree elt) Key elt (Tree elt)
 | R_bal_5 (Tree elt) Key elt (Tree elt) (Tree elt) Key elt (Tree elt)
 T
 | R_bal_6 (Tree elt) Key elt (Tree elt) (Tree elt) Key elt (Tree elt)
 T
 | R_bal_7 (Tree elt) Key elt (Tree elt) (Tree elt) Key elt (Tree elt)
 T (Tree elt) Key elt (Tree elt) T
 | R_bal_8 (Tree elt) Key elt (Tree elt)

r_bal_rect :: ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> () -> a2)
              -> ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> (Tree
              a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> a2) ->
              ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> (Tree
              a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> () ->
              a2) -> ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () ->
              (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () ->
              (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> a2) -> ((Tree
              a1) -> Key -> a1 -> (Tree a1) -> () -> () -> () -> () -> () ->
              a2) -> ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> ()
              -> () -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
              -> () -> a2) -> ((Tree a1) -> Key -> a1 -> (Tree a1) -> () ->
              () -> () -> () -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T ->
              () -> () -> () -> () -> a2) -> ((Tree a1) -> Key -> a1 -> (Tree
              a1) -> () -> () -> () -> () -> (Tree a1) -> Key -> a1 -> (Tree
              a1) -> T -> () -> () -> () -> (Tree a1) -> Key -> a1 -> (Tree
              a1) -> T -> () -> a2) -> ((Tree a1) -> Key -> a1 -> (Tree
              a1) -> () -> () -> () -> () -> a2) -> (Tree a1) -> Key -> a1 ->
              (Tree a1) -> (Tree a1) -> (R_bal a1) -> a2
r_bal_rect f f0 f1 f2 f3 f4 f5 f6 f7 _ _ _ _ _ r =
  case r of {
   R_bal_0 x x0 x1 x2 -> f x x0 x1 x2 __ __ __;
   R_bal_1 x x0 x1 x2 x3 x4 x5 x6 x7 ->
    f0 x x0 x1 x2 __ __ x3 x4 x5 x6 x7 __ __ __;
   R_bal_2 x x0 x1 x2 x3 x4 x5 x6 x7 ->
    f1 x x0 x1 x2 __ __ x3 x4 x5 x6 x7 __ __ __ __;
   R_bal_3 x x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 ->
    f2 x x0 x1 x2 __ __ x3 x4 x5 x6 x7 __ __ __ x8 x9 x10 x11 x12 __;
   R_bal_4 x x0 x1 x2 -> f3 x x0 x1 x2 __ __ __ __ __;
   R_bal_5 x x0 x1 x2 x3 x4 x5 x6 x7 ->
    f4 x x0 x1 x2 __ __ __ __ x3 x4 x5 x6 x7 __ __ __;
   R_bal_6 x x0 x1 x2 x3 x4 x5 x6 x7 ->
    f5 x x0 x1 x2 __ __ __ __ x3 x4 x5 x6 x7 __ __ __ __;
   R_bal_7 x x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 ->
    f6 x x0 x1 x2 __ __ __ __ x3 x4 x5 x6 x7 __ __ __ x8 x9 x10 x11 x12 __;
   R_bal_8 x x0 x1 x2 -> f7 x x0 x1 x2 __ __ __ __}

r_bal_rec :: ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> () -> a2) ->
             ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> (Tree
             a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> a2) ->
             ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> (Tree
             a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> () ->
             a2) -> ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> (Tree
             a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> (Tree
             a1) -> Key -> a1 -> (Tree a1) -> T -> () -> a2) -> ((Tree
             a1) -> Key -> a1 -> (Tree a1) -> () -> () -> () -> () -> () ->
             a2) -> ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> () ->
             () -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> ()
             -> a2) -> ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> ()
             -> () -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () ->
             () -> () -> a2) -> ((Tree a1) -> Key -> a1 -> (Tree a1) -> () ->
             () -> () -> () -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> ()
             -> () -> () -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () ->
             a2) -> ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> () -> () ->
             () -> a2) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> (Tree
             a1) -> (R_bal a1) -> a2
r_bal_rec =
  r_bal_rect

data R_add0 elt =
   R_add_4 (Tree elt)
 | R_add_5 (Tree elt) (Tree elt) Key elt (Tree elt) T (Tree elt) (R_add0 elt)
 | R_add_6 (Tree elt) (Tree elt) Key elt (Tree elt) T
 | R_add_7 (Tree elt) (Tree elt) Key elt (Tree elt) T (Tree elt) (R_add0 elt)

r_add_rect0 :: Key -> a1 -> ((Tree a1) -> () -> a2) -> ((Tree a1) -> (Tree
               a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> (Tree
               a1) -> (R_add0 a1) -> a2 -> a2) -> ((Tree a1) -> (Tree
               a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> a2) ->
               ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> ()
               -> () -> () -> (Tree a1) -> (R_add0 a1) -> a2 -> a2) -> (Tree
               a1) -> (Tree a1) -> (R_add0 a1) -> a2
r_add_rect0 x d f f0 f1 f2 _ _ r =
  case r of {
   R_add_4 m -> f m __;
   R_add_5 m l y d' r0 h _res r1 ->
    f0 m l y d' r0 h __ __ __ _res r1 (r_add_rect0 x d f f0 f1 f2 l _res r1);
   R_add_6 m l y d' r0 h -> f1 m l y d' r0 h __ __ __;
   R_add_7 m l y d' r0 h _res r1 ->
    f2 m l y d' r0 h __ __ __ _res r1 (r_add_rect0 x d f f0 f1 f2 r0 _res r1)}

r_add_rec0 :: Key -> a1 -> ((Tree a1) -> () -> a2) -> ((Tree a1) -> (Tree
              a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> (Tree
              a1) -> (R_add0 a1) -> a2 -> a2) -> ((Tree a1) -> (Tree
              a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> a2) ->
              ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () ->
              () -> () -> (Tree a1) -> (R_add0 a1) -> a2 -> a2) -> (Tree
              a1) -> (Tree a1) -> (R_add0 a1) -> a2
r_add_rec0 =
  r_add_rect0

data R_remove_min elt =
   R_remove_min_0 (Tree elt) Key elt (Tree elt)
 | R_remove_min_1 (Tree elt) Key elt (Tree elt) (Tree elt) Key elt (Tree elt)
 T (( , ) (Tree elt) (( , ) Key elt)) (R_remove_min elt) (Tree elt) (( , )
                                                                    Key
                                                                    elt)

r_remove_min_rect :: ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> a2) ->
                     ((Tree a1) -> Key -> a1 -> (Tree a1) -> (Tree a1) -> Key
                     -> a1 -> (Tree a1) -> T -> () -> (( , ) (Tree a1)
                     (( , ) Key a1)) -> (R_remove_min a1) -> a2 -> (Tree
                     a1) -> (( , ) Key a1) -> () -> a2) -> (Tree a1) -> Key
                     -> a1 -> (Tree a1) -> (( , ) (Tree a1) (( , ) Key a1))
                     -> (R_remove_min a1) -> a2
r_remove_min_rect f f0 _ _ _ _ _ r =
  case r of {
   R_remove_min_0 l x d r0 -> f l x d r0 __;
   R_remove_min_1 l x d r0 ll lx ld lr _x _res r1 l' m ->
    f0 l x d r0 ll lx ld lr _x __ _res r1
      (r_remove_min_rect f f0 ll lx ld lr _res r1) l' m __}

r_remove_min_rec :: ((Tree a1) -> Key -> a1 -> (Tree a1) -> () -> a2) ->
                    ((Tree a1) -> Key -> a1 -> (Tree a1) -> (Tree a1) -> Key
                    -> a1 -> (Tree a1) -> T -> () -> (( , ) (Tree a1)
                    (( , ) Key a1)) -> (R_remove_min a1) -> a2 -> (Tree
                    a1) -> (( , ) Key a1) -> () -> a2) -> (Tree a1) -> Key ->
                    a1 -> (Tree a1) -> (( , ) (Tree a1) (( , ) Key a1)) ->
                    (R_remove_min a1) -> a2
r_remove_min_rec =
  r_remove_min_rect

data R_merge elt =
   R_merge_0 (Tree elt) (Tree elt)
 | R_merge_1 (Tree elt) (Tree elt) (Tree elt) Key elt (Tree elt) T
 | R_merge_2 (Tree elt) (Tree elt) (Tree elt) Key elt (Tree elt) T (Tree elt)
 Key elt (Tree elt) T (Tree elt) (( , ) Key elt) Key elt

r_merge_rect :: ((Tree a1) -> (Tree a1) -> () -> a2) -> ((Tree a1) -> (Tree
                a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
                -> a2) -> ((Tree a1) -> (Tree a1) -> (Tree a1) -> Key -> a1
                -> (Tree a1) -> T -> () -> (Tree a1) -> Key -> a1 -> (Tree
                a1) -> T -> () -> (Tree a1) -> (( , ) Key a1) -> () -> Key ->
                a1 -> () -> a2) -> (Tree a1) -> (Tree a1) -> (Tree a1) ->
                (R_merge a1) -> a2
r_merge_rect f f0 f1 _ _ _ r =
  case r of {
   R_merge_0 x x0 -> f x x0 __;
   R_merge_1 x x0 x1 x2 x3 x4 x5 -> f0 x x0 x1 x2 x3 x4 x5 __ __;
   R_merge_2 x x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 ->
    f1 x x0 x1 x2 x3 x4 x5 __ x6 x7 x8 x9 x10 __ x11 x12 __ x13 x14 __}

r_merge_rec :: ((Tree a1) -> (Tree a1) -> () -> a2) -> ((Tree a1) -> (Tree
               a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () ->
               a2) -> ((Tree a1) -> (Tree a1) -> (Tree a1) -> Key -> a1 ->
               (Tree a1) -> T -> () -> (Tree a1) -> Key -> a1 -> (Tree
               a1) -> T -> () -> (Tree a1) -> (( , ) Key a1) -> () -> Key ->
               a1 -> () -> a2) -> (Tree a1) -> (Tree a1) -> (Tree a1) ->
               (R_merge a1) -> a2
r_merge_rec =
  r_merge_rect

data R_remove0 elt =
   R_remove_4 (Tree elt)
 | R_remove_5 (Tree elt) (Tree elt) Key elt (Tree elt) T (Tree elt) (R_remove0
                                                                    elt)
 | R_remove_6 (Tree elt) (Tree elt) Key elt (Tree elt) T
 | R_remove_7 (Tree elt) (Tree elt) Key elt (Tree elt) T (Tree elt) (R_remove0
                                                                    elt)

r_remove_rect0 :: (( , ) Natural Natural) -> ((Tree a1) -> () -> a2) -> ((Tree
                  a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
                  -> () -> (Tree a1) -> (R_remove0 a1) -> a2 -> a2) -> ((Tree
                  a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
                  -> () -> a2) -> ((Tree a1) -> (Tree a1) -> Key -> a1 ->
                  (Tree a1) -> T -> () -> () -> () -> (Tree a1) -> (R_remove0
                  a1) -> a2 -> a2) -> (Tree a1) -> (Tree a1) -> (R_remove0
                  a1) -> a2
r_remove_rect0 x f f0 f1 f2 _ _ r =
  case r of {
   R_remove_4 m -> f m __;
   R_remove_5 m l y d r0 _x _res r1 ->
    f0 m l y d r0 _x __ __ __ _res r1 (r_remove_rect0 x f f0 f1 f2 l _res r1);
   R_remove_6 m l y d r0 _x -> f1 m l y d r0 _x __ __ __;
   R_remove_7 m l y d r0 _x _res r1 ->
    f2 m l y d r0 _x __ __ __ _res r1
      (r_remove_rect0 x f f0 f1 f2 r0 _res r1)}

r_remove_rec0 :: (( , ) Natural Natural) -> ((Tree a1) -> () -> a2) -> ((Tree
                 a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
                 -> () -> (Tree a1) -> (R_remove0 a1) -> a2 -> a2) -> ((Tree
                 a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
                 -> () -> a2) -> ((Tree a1) -> (Tree a1) -> Key -> a1 ->
                 (Tree a1) -> T -> () -> () -> () -> (Tree a1) -> (R_remove0
                 a1) -> a2 -> a2) -> (Tree a1) -> (Tree a1) -> (R_remove0
                 a1) -> a2
r_remove_rec0 =
  r_remove_rect0

data R_concat elt =
   R_concat_0 (Tree elt) (Tree elt)
 | R_concat_1 (Tree elt) (Tree elt) (Tree elt) Key elt (Tree elt) T
 | R_concat_2 (Tree elt) (Tree elt) (Tree elt) Key elt (Tree elt) T (Tree
                                                                    elt)
 Key elt (Tree elt) T (Tree elt) (( , ) Key elt)

r_concat_rect :: ((Tree a1) -> (Tree a1) -> () -> a2) -> ((Tree a1) -> (Tree
                 a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
                 -> a2) -> ((Tree a1) -> (Tree a1) -> (Tree a1) -> Key -> a1
                 -> (Tree a1) -> T -> () -> (Tree a1) -> Key -> a1 -> (Tree
                 a1) -> T -> () -> (Tree a1) -> (( , ) Key a1) -> () -> a2)
                 -> (Tree a1) -> (Tree a1) -> (Tree a1) -> (R_concat
                 a1) -> a2
r_concat_rect f f0 f1 _ _ _ r =
  case r of {
   R_concat_0 x x0 -> f x x0 __;
   R_concat_1 x x0 x1 x2 x3 x4 x5 -> f0 x x0 x1 x2 x3 x4 x5 __ __;
   R_concat_2 x x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 ->
    f1 x x0 x1 x2 x3 x4 x5 __ x6 x7 x8 x9 x10 __ x11 x12 __}

r_concat_rec :: ((Tree a1) -> (Tree a1) -> () -> a2) -> ((Tree a1) -> (Tree
                a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
                -> a2) -> ((Tree a1) -> (Tree a1) -> (Tree a1) -> Key -> a1
                -> (Tree a1) -> T -> () -> (Tree a1) -> Key -> a1 -> (Tree
                a1) -> T -> () -> (Tree a1) -> (( , ) Key a1) -> () -> a2) ->
                (Tree a1) -> (Tree a1) -> (Tree a1) -> (R_concat a1) -> a2
r_concat_rec =
  r_concat_rect

data R_split elt =
   R_split_0 (Tree elt)
 | R_split_1 (Tree elt) (Tree elt) Key elt (Tree elt) T (Triple elt)
 (R_split elt) (Tree elt) (Maybe elt) (Tree elt)
 | R_split_2 (Tree elt) (Tree elt) Key elt (Tree elt) T
 | R_split_3 (Tree elt) (Tree elt) Key elt (Tree elt) T (Triple elt)
 (R_split elt) (Tree elt) (Maybe elt) (Tree elt)

r_split_rect :: (( , ) Natural Natural) -> ((Tree a1) -> () -> a2) -> ((Tree
                a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> ()
                -> () -> (Triple a1) -> (R_split a1) -> a2 -> (Tree a1) ->
                (Maybe a1) -> (Tree a1) -> () -> a2) -> ((Tree a1) -> (Tree
                a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> a2)
                -> ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T ->
                () -> () -> () -> (Triple a1) -> (R_split a1) -> a2 -> (Tree
                a1) -> (Maybe a1) -> (Tree a1) -> () -> a2) -> (Tree
                a1) -> (Triple a1) -> (R_split a1) -> a2
r_split_rect x f f0 f1 f2 _ _ r =
  case r of {
   R_split_0 m -> f m __;
   R_split_1 m l y d r0 _x _res r1 ll o rl ->
    f0 m l y d r0 _x __ __ __ _res r1 (r_split_rect x f f0 f1 f2 l _res r1)
      ll o rl __;
   R_split_2 m l y d r0 _x -> f1 m l y d r0 _x __ __ __;
   R_split_3 m l y d r0 _x _res r1 rl o rr ->
    f2 m l y d r0 _x __ __ __ _res r1 (r_split_rect x f f0 f1 f2 r0 _res r1)
      rl o rr __}

r_split_rec :: (( , ) Natural Natural) -> ((Tree a1) -> () -> a2) -> ((Tree a1) ->
               (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> () ->
               (Triple a1) -> (R_split a1) -> a2 -> (Tree a1) -> (Maybe
               a1) -> (Tree a1) -> () -> a2) -> ((Tree a1) -> (Tree a1) ->
               Key -> a1 -> (Tree a1) -> T -> () -> () -> () -> a2) -> ((Tree
               a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () ->
               () -> (Triple a1) -> (R_split a1) -> a2 -> (Tree a1) ->
               (Maybe a1) -> (Tree a1) -> () -> a2) -> (Tree a1) -> (Triple
               a1) -> (R_split a1) -> a2
r_split_rec =
  r_split_rect

data R_map_option elt x =
   R_map_option_0 (Tree elt)
 | R_map_option_1 (Tree elt) (Tree elt) Key elt (Tree elt) T x (Tree x)
 (R_map_option elt x) (Tree x) (R_map_option elt x)
 | R_map_option_2 (Tree elt) (Tree elt) Key elt (Tree elt) T (Tree x)
 (R_map_option elt x) (Tree x) (R_map_option elt x)

r_map_option_rect :: (Key -> a1 -> Maybe a2) -> ((Tree a1) -> () -> a3) ->
                     ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T
                     -> () -> a2 -> () -> (Tree a2) -> (R_map_option
                     a1 a2) -> a3 -> (Tree a2) -> (R_map_option a1 a2) -> a3
                     -> a3) -> ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree
                     a1) -> T -> () -> () -> (Tree a2) -> (R_map_option
                     a1 a2) -> a3 -> (Tree a2) -> (R_map_option a1 a2) -> a3
                     -> a3) -> (Tree a1) -> (Tree a2) -> (R_map_option
                     a1 a2) -> a3
r_map_option_rect f f0 f1 f2 _ _ r =
  case r of {
   R_map_option_0 m -> f0 m __;
   R_map_option_1 m l x d r0 _x d' _res0 r1 _res r2 ->
    f1 m l x d r0 _x __ d' __ _res0 r1
      (r_map_option_rect f f0 f1 f2 l _res0 r1) _res r2
      (r_map_option_rect f f0 f1 f2 r0 _res r2);
   R_map_option_2 m l x d r0 _x _res0 r1 _res r2 ->
    f2 m l x d r0 _x __ __ _res0 r1 (r_map_option_rect f f0 f1 f2 l _res0 r1)
      _res r2 (r_map_option_rect f f0 f1 f2 r0 _res r2)}

r_map_option_rec :: (Key -> a1 -> Maybe a2) -> ((Tree a1) -> () -> a3) ->
                    ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T ->
                    () -> a2 -> () -> (Tree a2) -> (R_map_option a1 a2) -> a3
                    -> (Tree a2) -> (R_map_option a1 a2) -> a3 -> a3) ->
                    ((Tree a1) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T ->
                    () -> () -> (Tree a2) -> (R_map_option a1 a2) -> a3 ->
                    (Tree a2) -> (R_map_option a1 a2) -> a3 -> a3) -> (Tree
                    a1) -> (Tree a2) -> (R_map_option a1 a2) -> a3
r_map_option_rec =
  r_map_option_rect

data R_map2_opt elt x0 x =
   R_map2_opt_0 (Tree elt) (Tree x0)
 | R_map2_opt_1 (Tree elt) (Tree x0) (Tree elt) Key elt (Tree elt) T
 | R_map2_opt_2 (Tree elt) (Tree x0) (Tree elt) Key elt (Tree elt) T
 (Tree x0) Key x0 (Tree x0) T (Tree x0) (Maybe x0) (Tree x0) x (Tree x)
 (R_map2_opt elt x0 x) (Tree x) (R_map2_opt elt x0 x)
 | R_map2_opt_3 (Tree elt) (Tree x0) (Tree elt) Key elt (Tree elt) T
 (Tree x0) Key x0 (Tree x0) T (Tree x0) (Maybe x0) (Tree x0) (Tree x)
 (R_map2_opt elt x0 x) (Tree x) (R_map2_opt elt x0 x)

r_map2_opt_rect :: (Key -> a1 -> (Maybe a2) -> Maybe a3) -> ((Tree
                   a1) -> Tree a3) -> ((Tree a2) -> Tree a3) -> ((Tree
                   a1) -> (Tree a2) -> () -> a4) -> ((Tree a1) -> (Tree
                   a2) -> (Tree a1) -> Key -> a1 -> (Tree a1) -> T -> () ->
                   () -> a4) -> ((Tree a1) -> (Tree a2) -> (Tree a1) -> Key
                   -> a1 -> (Tree a1) -> T -> () -> (Tree a2) -> Key -> a2 ->
                   (Tree a2) -> T -> () -> (Tree a2) -> (Maybe a2) -> (Tree
                   a2) -> () -> a3 -> () -> (Tree a3) -> (R_map2_opt
                   a1 a2 a3) -> a4 -> (Tree a3) -> (R_map2_opt a1 a2
                   a3) -> a4 -> a4) -> ((Tree a1) -> (Tree a2) -> (Tree
                   a1) -> Key -> a1 -> (Tree a1) -> T -> () -> (Tree
                   a2) -> Key -> a2 -> (Tree a2) -> T -> () -> (Tree
                   a2) -> (Maybe a2) -> (Tree a2) -> () -> () -> (Tree
                   a3) -> (R_map2_opt a1 a2 a3) -> a4 -> (Tree a3) ->
                   (R_map2_opt a1 a2 a3) -> a4 -> a4) -> (Tree a1) -> (Tree
                   a2) -> (Tree a3) -> (R_map2_opt a1 a2 a3) -> a4
r_map2_opt_rect f mapl mapr f0 f1 f2 f3 _ _ _ r =
  case r of {
   R_map2_opt_0 m1 m2 -> f0 m1 m2 __;
   R_map2_opt_1 m1 m2 l1 x1 d1 r1 _x -> f1 m1 m2 l1 x1 d1 r1 _x __ __;
   R_map2_opt_2 m1 m2 l1 x1 d1 r1 _x _x0 _x1 _x2 _x3 _x4 l2' o2 r2' e _res0
    r0 _res r2 ->
    f2 m1 m2 l1 x1 d1 r1 _x __ _x0 _x1 _x2 _x3 _x4 __ l2' o2 r2' __ e __
      _res0 r0 (r_map2_opt_rect f mapl mapr f0 f1 f2 f3 l1 l2' _res0 r0) _res
      r2 (r_map2_opt_rect f mapl mapr f0 f1 f2 f3 r1 r2' _res r2);
   R_map2_opt_3 m1 m2 l1 x1 d1 r1 _x _x0 _x1 _x2 _x3 _x4 l2' o2 r2' _res0 r0
    _res r2 ->
    f3 m1 m2 l1 x1 d1 r1 _x __ _x0 _x1 _x2 _x3 _x4 __ l2' o2 r2' __ __ _res0
      r0 (r_map2_opt_rect f mapl mapr f0 f1 f2 f3 l1 l2' _res0 r0) _res r2
      (r_map2_opt_rect f mapl mapr f0 f1 f2 f3 r1 r2' _res r2)}

r_map2_opt_rec :: (Key -> a1 -> (Maybe a2) -> Maybe a3) -> ((Tree a1) ->
                  Tree a3) -> ((Tree a2) -> Tree a3) -> ((Tree a1) -> (Tree
                  a2) -> () -> a4) -> ((Tree a1) -> (Tree a2) -> (Tree
                  a1) -> Key -> a1 -> (Tree a1) -> T -> () -> () -> a4) ->
                  ((Tree a1) -> (Tree a2) -> (Tree a1) -> Key -> a1 -> (Tree
                  a1) -> T -> () -> (Tree a2) -> Key -> a2 -> (Tree a2) -> T
                  -> () -> (Tree a2) -> (Maybe a2) -> (Tree a2) -> () -> a3
                  -> () -> (Tree a3) -> (R_map2_opt a1 a2 a3) -> a4 -> (Tree
                  a3) -> (R_map2_opt a1 a2 a3) -> a4 -> a4) -> ((Tree
                  a1) -> (Tree a2) -> (Tree a1) -> Key -> a1 -> (Tree
                  a1) -> T -> () -> (Tree a2) -> Key -> a2 -> (Tree a2) -> T
                  -> () -> (Tree a2) -> (Maybe a2) -> (Tree a2) -> () -> ()
                  -> (Tree a3) -> (R_map2_opt a1 a2 a3) -> a4 -> (Tree
                  a3) -> (R_map2_opt a1 a2 a3) -> a4 -> a4) -> (Tree
                  a1) -> (Tree a2) -> (Tree a3) -> (R_map2_opt a1 a2
                  a3) -> a4
r_map2_opt_rec =
  r_map2_opt_rect

fold' :: (Key -> a1 -> a2 -> a2) -> (Tree a1) -> a2 -> a2
fold' f s =
  fold0 f (elements s)

flatten_e :: (Enumeration a1) -> [] (( , ) Key a1)
flatten_e e =
  case e of {
   End -> [];
   More x e0 t r -> ( : ) ((,) x e0) (app (elements t) (flatten_e r))}

type Bst elt = Tree elt
  -- singleton inductive, whose constructor was Bst

this :: (Bst a1) -> Tree a1
this b =
  b

type T11 elt = Bst elt

type Key1 = ( , ) Natural Natural

empty1 :: T11 a1
empty1 =
  empty

is_empty1 :: (T11 a1) -> Bool
is_empty1 m =
  is_empty (this m)

add5 :: Key1 -> a1 -> (T11 a1) -> T11 a1
add5 x e m =
  add3 x e (this m)

remove1 :: Key1 -> (T11 a1) -> T11 a1
remove1 x m =
  remove x (this m)

mem1 :: Key1 -> (T11 a1) -> Bool
mem1 x m =
  mem x (this m)

find1 :: Key1 -> (T11 a1) -> Maybe a1
find1 x m =
  find x (this m)

map3 :: (a1 -> a2) -> (T11 a1) -> T11 a2
map3 f m =
  map f (this m)

mapi1 :: (Key1 -> a1 -> a2) -> (T11 a1) -> T11 a2
mapi1 f m =
  mapi f (this m)

map4 :: ((Maybe a1) -> (Maybe a2) -> Maybe a3) -> (T11 a1) -> (T11
        a2) -> T11 a3
map4 f m m' =
  map2 f (this m) (this m')

elements1 :: (T11 a1) -> [] (( , ) Key1 a1)
elements1 m =
  elements (this m)

cardinal0 :: (T11 a1) -> Natural
cardinal0 m =
  cardinal (this m)

fold1 :: (Key1 -> a1 -> a2 -> a2) -> (T11 a1) -> a2 -> a2
fold1 f m i =
  fold f (this m) i

equal1 :: (a1 -> a1 -> Bool) -> (T11 a1) -> (T11 a1) -> Bool
equal1 cmp m m' =
  equal cmp (this m) (this m')

type T12 = Natural

eq_dec10 :: Natural -> Natural -> Bool
eq_dec10 =
  eq_dec

compare5 :: Natural -> Natural -> Comparison
compare5 x y =
  case compare2 x y of {
   LT -> Lt;
   EQ -> Eq;
   GT -> Gt}

type Elt = Natural

data Tree0 =
   Leaf0
 | Node0 T Tree0 Natural Tree0
 deriving (Show)

empty2 :: Tree0
empty2 =
  Leaf0

is_empty2 :: Tree0 -> Bool
is_empty2 t =
  case t of {
   Leaf0 -> True;
   Node0 _ _ _ _ -> False}

mem2 :: Natural -> Tree0 -> Bool
mem2 x t =
  case t of {
   Leaf0 -> False;
   Node0 _ l k r ->
    case compare2 x k of {
     LT -> mem2 x l;
     EQ -> True;
     GT -> mem2 x r}}

min_elt :: Tree0 -> Maybe Elt
min_elt t =
  case t of {
   Leaf0 -> Nothing;
   Node0 _ l x _ -> case l of {
                     Leaf0 -> Just x;
                     Node0 _ _ _ _ -> min_elt l}}

max_elt :: Tree0 -> Maybe Elt
max_elt t =
  case t of {
   Leaf0 -> Nothing;
   Node0 _ _ x r -> case r of {
                     Leaf0 -> Just x;
                     Node0 _ _ _ _ -> max_elt r}}

choose :: Tree0 -> Maybe Elt
choose =
  min_elt

fold2 :: (Elt -> a1 -> a1) -> Tree0 -> a1 -> a1
fold2 f t base =
  case t of {
   Leaf0 -> base;
   Node0 _ l x r -> fold2 f r (f x (fold2 f l base))}

elements_aux0 :: ([] Natural) -> Tree0 -> [] Natural
elements_aux0 acc s =
  case s of {
   Leaf0 -> acc;
   Node0 _ l x r -> elements_aux0 (( : ) x (elements_aux0 acc r)) l}

elements2 :: Tree0 -> [] Natural
elements2 =
  elements_aux0 []

rev_elements_aux :: ([] Natural) -> Tree0 -> [] Natural
rev_elements_aux acc s =
  case s of {
   Leaf0 -> acc;
   Node0 _ l x r -> rev_elements_aux (( : ) x (rev_elements_aux acc l)) r}

rev_elements :: Tree0 -> [] Natural
rev_elements =
  rev_elements_aux []

cardinal1 :: Tree0 -> Natural
cardinal1 s =
  case s of {
   Leaf0 -> 0;
   Node0 _ l _ r -> succ (add (cardinal1 l) (cardinal1 r))}

maxdepth :: Tree0 -> Natural
maxdepth s =
  case s of {
   Leaf0 -> 0;
   Node0 _ l _ r -> succ
    (max (maxdepth l) (maxdepth r))}

mindepth :: Tree0 -> Natural
mindepth s =
  case s of {
   Leaf0 -> 0;
   Node0 _ l _ r -> succ
    (min (mindepth l) (mindepth r))}

for_all :: (Elt -> Bool) -> Tree0 -> Bool
for_all f s =
  case s of {
   Leaf0 -> True;
   Node0 _ l x r ->
    case case f x of {
          True -> for_all f l;
          False -> False} of {
     True -> for_all f r;
     False -> False}}

exists_ :: (Elt -> Bool) -> Tree0 -> Bool
exists_ f s =
  case s of {
   Leaf0 -> False;
   Node0 _ l x r ->
    case case f x of {
          True -> True;
          False -> exists_ f l} of {
     True -> True;
     False -> exists_ f r}}

data Enumeration0 =
   End0
 | More0 Elt Tree0 Enumeration0

cons0 :: Tree0 -> Enumeration0 -> Enumeration0
cons0 s e =
  case s of {
   Leaf0 -> e;
   Node0 _ l x r -> cons0 l (More0 x r e)}

compare_more :: Natural -> (Enumeration0 -> Comparison) -> Enumeration0 ->
                Comparison
compare_more x1 cont e2 =
  case e2 of {
   End0 -> Gt;
   More0 x2 r2 e3 ->
    case compare2 x1 x2 of {
     LT -> Lt;
     EQ -> cont (cons0 r2 e3);
     GT -> Gt}}

compare_cont0 :: Tree0 -> (Enumeration0 -> Comparison) -> Enumeration0 ->
                 Comparison
compare_cont0 s1 cont e2 =
  case s1 of {
   Leaf0 -> cont e2;
   Node0 _ l1 x1 r1 ->
    compare_cont0 l1 (compare_more x1 (compare_cont0 r1 cont)) e2}

compare_end :: Enumeration0 -> Comparison
compare_end e2 =
  case e2 of {
   End0 -> Eq;
   More0 _ _ _ -> Lt}

compare6 :: Tree0 -> Tree0 -> Comparison
compare6 s1 s2 =
  compare_cont0 s1 compare_end (cons0 s2 End0)

equal2 :: Tree0 -> Tree0 -> Bool
equal2 s1 s2 =
  case compare6 s1 s2 of {
   Eq -> True;
   _ -> False}

subsetl :: (Tree0 -> Bool) -> Natural -> Tree0 -> Bool
subsetl subset_l1 x1 s2 =
  case s2 of {
   Leaf0 -> False;
   Node0 _ l2 x2 r2 ->
    case compare2 x1 x2 of {
     LT -> subsetl subset_l1 x1 l2;
     EQ -> subset_l1 l2;
     GT -> case mem2 x1 r2 of {
            True -> subset_l1 s2;
            False -> False}}}

subsetr :: (Tree0 -> Bool) -> Natural -> Tree0 -> Bool
subsetr subset_r1 x1 s2 =
  case s2 of {
   Leaf0 -> False;
   Node0 _ l2 x2 r2 ->
    case compare2 x1 x2 of {
     LT -> case mem2 x1 l2 of {
            True -> subset_r1 s2;
            False -> False};
     EQ -> subset_r1 r2;
     GT -> subsetr subset_r1 x1 r2}}

subset :: Tree0 -> Tree0 -> Bool
subset s1 s2 =
  case s1 of {
   Leaf0 -> True;
   Node0 _ l1 x1 r1 ->
    case s2 of {
     Leaf0 -> False;
     Node0 _ l2 x2 r2 ->
      case compare2 x1 x2 of {
       LT ->
        case subsetl (subset l1) x1 l2 of {
         True -> subset r1 s2;
         False -> False};
       EQ -> case subset l1 l2 of {
              True -> subset r1 r2;
              False -> False};
       GT ->
        case subsetr (subset r1) x1 r2 of {
         True -> subset l1 s2;
         False -> False}}}}

type T13 = Tree0

height0 :: T13 -> T
height0 s =
  case s of {
   Leaf0 -> _0;
   Node0 h _ _ _ -> h}

singleton :: Natural -> Tree0
singleton x =
  Node0 _1 Leaf0 x Leaf0

create0 :: T13 -> Natural -> T13 -> Tree0
create0 l x r =
  Node0 (add2 (max0 (height0 l) (height0 r)) _1) l x r

assert_false0 :: T13 -> Natural -> T13 -> Tree0
assert_false0 =
  create0

bal0 :: T13 -> Natural -> T13 -> Tree0
bal0 l x r =
  let {hl = height0 l} in
  let {hr = height0 r} in
  case ltb0 (add2 hr _2) hl of {
   True ->
    case l of {
     Leaf0 -> assert_false0 l x r;
     Node0 _ ll lx lr ->
      case leb0 (height0 lr) (height0 ll) of {
       True -> create0 ll lx (create0 lr x r);
       False ->
        case lr of {
         Leaf0 -> assert_false0 l x r;
         Node0 _ lrl lrx lrr ->
          create0 (create0 ll lx lrl) lrx (create0 lrr x r)}}};
   False ->
    case ltb0 (add2 hl _2) hr of {
     True ->
      case r of {
       Leaf0 -> assert_false0 l x r;
       Node0 _ rl rx rr ->
        case leb0 (height0 rl) (height0 rr) of {
         True -> create0 (create0 l x rl) rx rr;
         False ->
          case rl of {
           Leaf0 -> assert_false0 l x r;
           Node0 _ rll rlx rlr ->
            create0 (create0 l x rll) rlx (create0 rlr rx rr)}}};
     False -> create0 l x r}}

add6 :: Natural -> Tree0 -> Tree0
add6 x s =
  case s of {
   Leaf0 -> Node0 _1 Leaf0 x Leaf0;
   Node0 h l y r ->
    case compare2 x y of {
     LT -> bal0 (add6 x l) y r;
     EQ -> Node0 h l y r;
     GT -> bal0 l y (add6 x r)}}

join0 :: Tree0 -> Elt -> T13 -> T13
join0 l =
  case l of {
   Leaf0 -> add6;
   Node0 lh ll lx lr -> (\x ->
    let {
     join_aux r =
       case r of {
        Leaf0 -> add6 x l;
        Node0 rh rl rx rr ->
         case ltb0 (add2 rh _2) lh of {
          True -> bal0 ll lx (join0 lr x r);
          False ->
           case ltb0 (add2 lh _2) rh of {
            True -> bal0 (join_aux rl) rx rr;
            False -> create0 l x r}}}}
    in join_aux)}

remove_min0 :: Tree0 -> Elt -> T13 -> ( , ) T13 Elt
remove_min0 l x r =
  case l of {
   Leaf0 -> (,) r x;
   Node0 _ ll lx lr ->
    case remove_min0 ll lx lr of {
      (l', m) -> (,) (bal0 l' x r) m}}

merge0 :: Tree0 -> Tree0 -> Tree0
merge0 s1 s2 =
  case s1 of {
   Leaf0 -> s2;
   Node0 _ _ _ _ ->
    case s2 of {
     Leaf0 -> s1;
     Node0 _ l2 x2 r2 ->
      case remove_min0 l2 x2 r2 of {
        (s2', m) -> bal0 s1 m s2'}}}

remove2 :: Natural -> Tree0 -> Tree0
remove2 x s =
  case s of {
   Leaf0 -> Leaf0;
   Node0 _ l y r ->
    case compare2 x y of {
     LT -> bal0 (remove2 x l) y r;
     EQ -> merge0 l r;
     GT -> bal0 l y (remove2 x r)}}

concat0 :: Tree0 -> Tree0 -> Tree0
concat0 s1 s2 =
  case s1 of {
   Leaf0 -> s2;
   Node0 _ _ _ _ ->
    case s2 of {
     Leaf0 -> s1;
     Node0 _ l2 x2 r2 ->
      case remove_min0 l2 x2 r2 of {
        (s2', m) -> join0 s1 m s2'}}}

data Triple0 =
   Mktriple0 T13 Bool T13

t_left0 :: Triple0 -> T13
t_left0 t =
  case t of {
   Mktriple0 t_left1 _ _ -> t_left1}

t_in :: Triple0 -> Bool
t_in t =
  case t of {
   Mktriple0 _ t_in0 _ -> t_in0}

t_right0 :: Triple0 -> T13
t_right0 t =
  case t of {
   Mktriple0 _ _ t_right1 -> t_right1}

split0 :: Natural -> Tree0 -> Triple0
split0 x s =
  case s of {
   Leaf0 -> Mktriple0 Leaf0 False Leaf0;
   Node0 _ l y r ->
    case compare2 x y of {
     LT ->
      case split0 x l of {
       Mktriple0 ll b rl -> Mktriple0 ll b (join0 rl y r)};
     EQ -> Mktriple0 l True r;
     GT ->
      case split0 x r of {
       Mktriple0 rl b rr -> Mktriple0 (join0 l y rl) b rr}}}

inter :: Tree0 -> Tree0 -> Tree0
inter s1 s2 =
  case s1 of {
   Leaf0 -> Leaf0;
   Node0 _ l1 x1 r1 ->
    case s2 of {
     Leaf0 -> Leaf0;
     Node0 _ _ _ _ ->
      case split0 x1 s2 of {
       Mktriple0 l2' pres r2' ->
        case pres of {
         True -> join0 (inter l1 l2') x1 (inter r1 r2');
         False -> concat0 (inter l1 l2') (inter r1 r2')}}}}

diff :: Tree0 -> Tree0 -> Tree0
diff s1 s2 =
  case s1 of {
   Leaf0 -> Leaf0;
   Node0 _ l1 x1 r1 ->
    case s2 of {
     Leaf0 -> s1;
     Node0 _ _ _ _ ->
      case split0 x1 s2 of {
       Mktriple0 l2' pres r2' ->
        case pres of {
         True -> concat0 (diff l1 l2') (diff r1 r2');
         False -> join0 (diff l1 l2') x1 (diff r1 r2')}}}}

union :: Tree0 -> Tree0 -> Tree0
union s1 s2 =
  case s1 of {
   Leaf0 -> s2;
   Node0 _ l1 x1 r1 ->
    case s2 of {
     Leaf0 -> s1;
     Node0 _ _ _ _ ->
      case split0 x1 s2 of {
       Mktriple0 l2' _ r2' -> join0 (union l1 l2') x1 (union r1 r2')}}}

filter :: (Elt -> Bool) -> Tree0 -> Tree0
filter f s =
  case s of {
   Leaf0 -> Leaf0;
   Node0 _ l x r ->
    let {l' = filter f l} in
    let {r' = filter f r} in
    case f x of {
     True -> join0 l' x r';
     False -> concat0 l' r'}}

partition :: (Elt -> Bool) -> T13 -> ( , ) T13 T13
partition f s =
  case s of {
   Leaf0 -> (,) Leaf0 Leaf0;
   Node0 _ l x r ->
    case partition f l of {
      (l1, l2) ->
      case partition f r of {
        (r1, r2) ->
        case f x of {
         True -> (,) (join0 l1 x r1) (concat0 l2 r2);
         False -> (,) (concat0 l1 r1) (join0 l2 x r2)}}}}

ltb_tree :: Natural -> Tree0 -> Bool
ltb_tree x s =
  case s of {
   Leaf0 -> True;
   Node0 _ l y r ->
    case compare2 x y of {
     GT -> (&&) (ltb_tree x l) (ltb_tree x r);
     _ -> False}}

gtb_tree :: Natural -> Tree0 -> Bool
gtb_tree x s =
  case s of {
   Leaf0 -> True;
   Node0 _ l y r ->
    case compare2 x y of {
     LT -> (&&) (gtb_tree x l) (gtb_tree x r);
     _ -> False}}

isok :: Tree0 -> Bool
isok s =
  case s of {
   Leaf0 -> True;
   Node0 _ l x r ->
    (&&) ((&&) ((&&) (isok l) (isok r)) (ltb_tree x l)) (gtb_tree x r)}

type T14 = Natural

compare7 :: Natural -> Natural -> Comparison
compare7 x y =
  case compare2 x y of {
   LT -> Lt;
   EQ -> Eq;
   GT -> Gt}

eq_dec11 :: Natural -> Natural -> Bool
eq_dec11 =
  eq_dec10

type T15 = Natural

compare8 :: Natural -> Natural -> Comparison
compare8 x y =
  case compare2 x y of {
   LT -> Lt;
   EQ -> Eq;
   GT -> Gt}

eq_dec12 :: Natural -> Natural -> Bool
eq_dec12 =
  eq_dec11

eq_dec13 :: Natural -> Natural -> Bool
eq_dec13 =
  eq_dec10

lt_dec7 :: Natural -> Natural -> Bool
lt_dec7 x y =
  let {
   c = compSpec2Type x y
         (case compare2 x y of {
           LT -> Lt;
           EQ -> Eq;
           GT -> Gt})}
  in
  case c of {
   CompLtT -> True;
   _ -> False}

eqb8 :: Natural -> Natural -> Bool
eqb8 x y =
  case eq_dec13 x y of {
   True -> True;
   False -> False}

data R_min_elt =
   R_min_elt_0 Tree0
 | R_min_elt_1 Tree0 T Tree0 Natural Tree0
 | R_min_elt_2 Tree0 T Tree0 Natural Tree0 T Tree0 Natural Tree0 (Maybe Elt)
 R_min_elt

data R_max_elt =
   R_max_elt_0 Tree0
 | R_max_elt_1 Tree0 T Tree0 Natural Tree0
 | R_max_elt_2 Tree0 T Tree0 Natural Tree0 T Tree0 Natural Tree0 (Maybe Elt)
 R_max_elt

type T16 = Natural

compare9 :: Natural -> Natural -> Comparison
compare9 x y =
  case compare2 x y of {
   LT -> Lt;
   EQ -> Eq;
   GT -> Gt}

eq_dec14 :: Natural -> Natural -> Bool
eq_dec14 =
  eq_dec10

type T17 = Natural

compare10 :: Natural -> Natural -> Comparison
compare10 x y =
  case compare2 x y of {
   LT -> Lt;
   EQ -> Eq;
   GT -> Gt}

eq_dec15 :: Natural -> Natural -> Bool
eq_dec15 =
  eq_dec14

eq_dec16 :: Natural -> Natural -> Bool
eq_dec16 =
  eq_dec10

lt_dec8 :: Natural -> Natural -> Bool
lt_dec8 x y =
  let {
   c = compSpec2Type x y
         (case compare2 x y of {
           LT -> Lt;
           EQ -> Eq;
           GT -> Gt})}
  in
  case c of {
   CompLtT -> True;
   _ -> False}

eqb9 :: Natural -> Natural -> Bool
eqb9 x y =
  case eq_dec16 x y of {
   True -> True;
   False -> False}

flatten_e0 :: Enumeration0 -> [] Elt
flatten_e0 e =
  case e of {
   End0 -> [];
   More0 x t r -> ( : ) x (app (elements2 t) (flatten_e0 r))}

data R_bal0 =
   R_bal_9 T13 Natural T13
 | R_bal_10 T13 Natural T13 T Tree0 Natural Tree0
 | R_bal_11 T13 Natural T13 T Tree0 Natural Tree0
 | R_bal_12 T13 Natural T13 T Tree0 Natural Tree0 T Tree0 Natural Tree0
 | R_bal_13 T13 Natural T13
 | R_bal_14 T13 Natural T13 T Tree0 Natural Tree0
 | R_bal_15 T13 Natural T13 T Tree0 Natural Tree0
 | R_bal_16 T13 Natural T13 T Tree0 Natural Tree0 T Tree0 Natural Tree0
 | R_bal_17 T13 Natural T13

data R_remove_min0 =
   R_remove_min_2 Tree0 Elt T13
 | R_remove_min_3 Tree0 Elt T13 T Tree0 Natural Tree0 (( , ) T13 Elt) R_remove_min0
 T13 Elt

data R_merge0 =
   R_merge_3 Tree0 Tree0
 | R_merge_4 Tree0 Tree0 T Tree0 Natural Tree0
 | R_merge_5 Tree0 Tree0 T Tree0 Natural Tree0 T Tree0 Natural Tree0 T13 Elt

data R_concat0 =
   R_concat_3 Tree0 Tree0
 | R_concat_4 Tree0 Tree0 T Tree0 Natural Tree0
 | R_concat_5 Tree0 Tree0 T Tree0 Natural Tree0 T Tree0 Natural Tree0 T13 Elt

data R_inter =
   R_inter_0 Tree0 Tree0
 | R_inter_1 Tree0 Tree0 T Tree0 Natural Tree0
 | R_inter_2 Tree0 Tree0 T Tree0 Natural Tree0 T Tree0 Natural Tree0 T13 Bool
 T13 Tree0 R_inter Tree0 R_inter
 | R_inter_3 Tree0 Tree0 T Tree0 Natural Tree0 T Tree0 Natural Tree0 T13 Bool
 T13 Tree0 R_inter Tree0 R_inter

data R_diff =
   R_diff_0 Tree0 Tree0
 | R_diff_1 Tree0 Tree0 T Tree0 Natural Tree0
 | R_diff_2 Tree0 Tree0 T Tree0 Natural Tree0 T Tree0 Natural Tree0 T13 Bool
 T13 Tree0 R_diff Tree0 R_diff
 | R_diff_3 Tree0 Tree0 T Tree0 Natural Tree0 T Tree0 Natural Tree0 T13 Bool
 T13 Tree0 R_diff Tree0 R_diff

data R_union =
   R_union_0 Tree0 Tree0
 | R_union_1 Tree0 Tree0 T Tree0 Natural Tree0
 | R_union_2 Tree0 Tree0 T Tree0 Natural Tree0 T Tree0 Natural Tree0 T13 Bool
 T13 Tree0 R_union Tree0 R_union

type T18 = Natural

compare11 :: Natural -> Natural -> Comparison
compare11 x y =
  case compare2 x y of {
   LT -> Lt;
   EQ -> Eq;
   GT -> Gt}

eq_dec17 :: Natural -> Natural -> Bool
eq_dec17 =
  eq_dec10

type Elt0 = Natural

type T_ = T13
  -- singleton inductive, whose constructor was Mkt

this0 :: T_ -> T13
this0 t =
  t

type T19 = T_

mem3 :: Elt0 -> T19 -> Bool
mem3 x s =
  mem2 x (this0 s)

add7 :: Elt0 -> T19 -> T19
add7 x s =
  add6 x (this0 s)

remove3 :: Elt0 -> T19 -> T19
remove3 x s =
  remove2 x (this0 s)

singleton0 :: Elt0 -> T19
singleton0 =
  singleton

union0 :: T19 -> T19 -> T19
union0 s s' =
  union (this0 s) (this0 s')

inter0 :: T19 -> T19 -> T19
inter0 s s' =
  inter (this0 s) (this0 s')

diff0 :: T19 -> T19 -> T19
diff0 s s' =
  diff (this0 s) (this0 s')

equal3 :: T19 -> T19 -> Bool
equal3 s s' =
  equal2 (this0 s) (this0 s')

subset0 :: T19 -> T19 -> Bool
subset0 s s' =
  subset (this0 s) (this0 s')

empty3 :: T19
empty3 =
  empty2

is_empty3 :: T19 -> Bool
is_empty3 s =
  is_empty2 (this0 s)

elements3 :: T19 -> [] Elt0
elements3 s =
  elements2 (this0 s)

choose0 :: T19 -> Maybe Elt0
choose0 s =
  choose (this0 s)

fold3 :: (Elt0 -> a1 -> a1) -> T19 -> a1 -> a1
fold3 f s =
  fold2 f (this0 s)

cardinal2 :: T19 -> Natural
cardinal2 s =
  cardinal1 (this0 s)

filter0 :: (Elt0 -> Bool) -> T19 -> T19
filter0 f s =
  filter f (this0 s)

for_all0 :: (Elt0 -> Bool) -> T19 -> Bool
for_all0 f s =
  for_all f (this0 s)

exists_0 :: (Elt0 -> Bool) -> T19 -> Bool
exists_0 f s =
  exists_ f (this0 s)

partition0 :: (Elt0 -> Bool) -> T19 -> ( , ) T19 T19
partition0 f s =
  let {p = partition f (this0 s)} in (,) (fst p) (snd p)

eq_dec18 :: T19 -> T19 -> Bool
eq_dec18 s0 s'0 =
  let {b = equal2 s0 s'0} in case b of {
                              True -> True;
                              False -> False}

compare12 :: T19 -> T19 -> Comparison
compare12 s s' =
  compare6 (this0 s) (this0 s')

min_elt0 :: T19 -> Maybe Elt0
min_elt0 s =
  min_elt (this0 s)

max_elt0 :: T19 -> Maybe Elt0
max_elt0 s =
  max_elt (this0 s)

type State = T11 Val

get_state :: Posi -> State -> Val
get_state p f =
  case find1 p f of {
   Just v -> v;
   Nothing -> Nval False 0}

dec_val_eq :: Val -> Val -> Dec
dec_val_eq v v' =
  case v of {
   Nval b z ->
    case v' of {
     Nval b' z' ->
      let {s = bool_dec b b'} in
      case s of {
       True ->
        eq_rec_r b'
          (let {h = beq_reflect z z'} in
           case h of {
            ReflectT -> eq_rec_r z' True z;
            ReflectF -> False}) b;
       False -> False};
     Qval _ _ -> False};
   Qval z0 z1 ->
    case v' of {
     Nval _ _ -> False;
     Qval z0' z1' ->
      let {h = beq_reflect z0 z0'} in
      case h of {
       ReflectT ->
        let {h0 = beq_reflect z1 z1'} in
        case h0 of {
         ReflectT -> eq_rec_r z0' (eq_rec_r z1' True z1) z0;
         ReflectF -> eq_rec_r z0' False z0};
       ReflectF ->
        let {h0 = beq_reflect z1 z1'} in
        case h0 of {
         ReflectT -> eq_rec_r z1' False z1;
         ReflectF -> False}}}}

var_equivb :: State -> State -> Var -> Natural -> Bool
var_equivb st st' var n =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> True)
    (\n' ->
    case dec (dec_val_eq (get_state ((,) var n') st) (get_state ((,) var n') st')) of {
     True -> var_equivb st st' var n';
     False -> False})
    n

st_equivb :: T19 -> (Elt0 -> Natural) -> State -> State -> Bool
st_equivb vars env st st' =
  for_all0 (\x -> var_equivb st st' x (env x)) vars
