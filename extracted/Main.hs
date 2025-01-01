module Main where

import qualified Prelude
import Prelude (IO, mod, undefined, ($), print, Show, const, Bool (..), Natural, Maybe (..), succ, min, max, (^), (+), div, (-), (*), Eq (..), Ord ((<), (>), (<=), (>=)), (&&))
import Data.Bits (shiftR)
import Unsafe.Coerce

import Test.QuickCheck hiding (elements)

import qualified Tests
import Tests hiding (Tree (..), T)
import Common
import Equiv

import Numeric.Natural


(~-) :: a -> a
(~-) = Prelude.id

__ :: any
__ = Prelude.error "Logical or arity value used"

eq_rect :: a1 -> a2 -> a1 -> a2
eq_rect _ f _ =
  f

eq_rect_r :: a1 -> a2 -> a1 -> a2
eq_rect_r =
  eq_rect

negb :: Bool -> Bool
negb b =
  case b of {
   True -> False;
   False -> True}

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

add :: Natural -> Natural -> Natural
add = (+)

mul :: Natural -> Natural -> Natural
mul = (*)

sub :: Natural -> Natural -> Natural
sub = \ n m -> max 0 (n-m)

add0 :: Natural -> Natural -> Natural
add0 = (+)

mul0 :: Natural -> Natural -> Natural
mul0 = (*)

sub0 :: Natural -> Natural -> Natural
sub0 = (-)

ltb :: Natural -> Natural -> Bool
ltb n m =
  (<=) (succ n) m

compare :: Natural -> Natural -> Comparison
compare = \ n m -> if n==m then Eq else if n<m then Lt else Gt

pow :: Natural -> Natural -> Natural
pow n m =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> succ 0)
    (\m0 -> mul0 n (pow n m0))
    m

divmod :: Natural -> Natural -> Natural -> Natural -> ( , ) Natural Natural
divmod x y q u =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> (,) q u)
    (\x' ->
    (\ fO fS n -> if n==0 then fO () else fS (n-1))
      (\_ -> divmod x' y (succ q) y)
      (\u' -> divmod x' y q u')
      u)
    x

-- div :: Natural -> Natural -> Natural
-- div = (/)

modulo :: Natural -> Natural -> Natural
modulo = (mod)

b2n :: Bool -> Natural
b2n b =
  case b of {
   True -> succ 0;
   False -> 0}

-- succ :: Natural -> Natural
-- succ = Pervasives.succ

add1 :: Natural -> Natural -> Natural
add1 = (+)

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
      (\q -> (\ p->1+2*p) (add1 p q))
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

of_succ_nat :: Natural -> Natural
of_succ_nat n =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> 1)
    (\x -> succ (of_succ_nat x))
    n

of_nat :: Natural -> Natural
of_nat = (\ x -> x)

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

add2 :: Natural -> Natural -> Natural
add2 = (+)

compare1 :: Natural -> Natural -> Comparison
compare1 = \ x y -> if x==y then Eq else if x<y then Lt else Gt

ltb0 :: Natural -> Natural -> Bool
ltb0 x y =
  case compare1 x y of {
   Lt -> True;
   _ -> False}

-- max :: Natural -> Natural -> Natural
-- max = Pervasives.max

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

add3 :: Natural -> Natural -> Natural
add3 =
  add2

max0 :: Natural -> Natural -> Natural
max0 =
  max

gt_le_dec :: Natural -> Natural -> Bool
gt_le_dec i j =
  let {b = ltb0 j i} in case b of {
                         True -> True;
                         False -> False}

ge_lt_dec :: Natural -> Natural -> Bool
ge_lt_dec i j =
  let {b = ltb0 i j} in case b of {
                         True -> False;
                         False -> True}

allfalse :: Natural -> Bool
allfalse _ =
  False

fb_push :: Bool -> (Natural -> Bool) -> Natural -> Bool
fb_push b f x =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> b)
    (\n -> f n)
    x

pos2fb :: Natural -> Natural -> Bool
pos2fb p =
  (\ f2p1 f2p f1 p -> if p==1 then f1 () else if p `mod` 2 == 0 then f2p (p `shiftR` 1) else f2p1 (p `shiftR` 1))
    (\p' -> fb_push True (pos2fb p'))
    (\p' -> fb_push False (pos2fb p'))
    (\_ -> fb_push True allfalse)
    p

n2fb :: Natural -> Natural -> Bool
n2fb n =
  (\ f0 fp n -> if n==0 then f0 () else fp n)
    (\_ -> allfalse)
    (\p -> pos2fb p)
    n

nat2fb :: Natural -> Natural -> Bool
nat2fb n =
  n2fb (of_nat n)

fbrev :: Natural -> (Natural -> a1) -> Natural -> a1
fbrev n f x =
  case ltb x n of {
   True -> f (sub (sub n (succ 0)) x);
   False -> f x}

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

eqb :: Natural -> Natural -> Bool
eqb x y =
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

eqb0 :: Natural -> Natural -> Bool
eqb0 x y =
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

eqb1 :: Natural -> Natural -> Bool
eqb1 x y =
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

eqb2 :: Natural -> Natural -> Bool
eqb2 x y =
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

-- data Tree elt =
--    Leaf
--  | Node (Tree elt) Key elt (Tree elt) T

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
  Node l x e r (add3 (max0 (height l) (height r)) _1)

assert_false :: (Tree a1) -> Key -> a1 -> (Tree a1) -> Tree a1
assert_false =
  create

bal :: (Tree a1) -> Key -> a1 -> (Tree a1) -> Tree a1
bal l x d r =
  let {hl = height l} in
  let {hr = height r} in
  case gt_le_dec hl (add3 hr _2) of {
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
    case gt_le_dec hr (add3 hl _2) of {
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

add4 :: Key -> a1 -> (Tree a1) -> Tree a1
add4 x d m =
  case m of {
   Leaf -> Node Leaf x d Leaf _1;
   Node l y d' r h ->
    case compare3 x y of {
     LT -> bal (add4 x d l) y d' r;
     EQ -> Node l y d r h;
     GT -> bal l y d' (add4 x d r)}}

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
   Leaf -> add4;
   Node ll lx ld lr lh -> (\x d ->
    let {
     join_aux r =
       case r of {
        Leaf -> add4 x d l;
        Node rl rx rd rr rh ->
         case gt_le_dec lh (add3 rh _2) of {
          True -> bal ll lx ld (join lr x d r);
          False ->
           case gt_le_dec rh (add3 lh _2) of {
            True -> bal (join_aux rl) rx rd rr;
            False -> create l x d r}}}}
    in join_aux)}

data Triple elt =
   Mktriple (Tree elt) (Maybe elt) (Tree elt)

t_left :: (Triple a1) -> Tree a1
t_left t =
  case t of {
   Mktriple t_left0 _ _ -> t_left0}

t_opt :: (Triple a1) -> Maybe a1
t_opt t =
  case t of {
   Mktriple _ t_opt0 _ -> t_opt0}

t_right :: (Triple a1) -> Tree a1
t_right t =
  case t of {
   Mktriple _ _ t_right0 -> t_right0}

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

eqb3 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eqb3 x y =
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

eqb4 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eqb4 x y =
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

eqb5 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eqb5 x y =
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

eqb6 :: (( , ) Natural Natural) -> (( , ) Natural Natural) -> Bool
eqb6 x y =
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

add5 :: Key0 -> a1 -> (T10 a1) -> T10 a1
add5 k x s =
  case s of {
   [] -> ( : ) ((,) k x) [];
   ( : ) p l ->
    case p of {
      (k', y) ->
      case compare3 k k' of {
       LT -> ( : ) ((,) k x) s;
       EQ -> ( : ) ((,) k x) l;
       GT -> ( : ) ((,) k' y) (add5 k x l)}}}

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
          GT -> ( : ) ((,) k' y) (add5 k x l)}}})
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
          GT -> f8 __ __}}}) (add5 k x s)

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
    eq_rect_r (( : ) ((,) y0 y1) (add5 k x y2)) (R_add_3 y y0 y1 y2
      (add5 k x y2) (y6 (add5 k x y2) __)) z) s _res __

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

add6 :: Key1 -> a1 -> (T11 a1) -> T11 a1
add6 x e m =
  add4 x e (this m)

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

addto :: Rz_val -> Natural -> Natural -> Rz_val
addto r n rmax =
  modulo (add r (pow (succ (succ 0)) (sub rmax n)))
    (pow (succ (succ 0)) rmax)

addto_n :: Rz_val -> Natural -> Natural -> Natural
addto_n r n rmax =
  modulo
    (sub (add r (pow (succ (succ 0)) rmax))
      (pow (succ (succ 0)) (sub rmax n)))
    (pow (succ (succ 0)) rmax)

-- type State = T11 Val

get_state :: Posi -> State -> Val
get_state p f =
  case find1 p f of {
   Just v -> v;
   Nothing -> Nval False 0}

exchange :: Val -> Val
exchange v =
  case v of {
   Nval b r -> Nval (negb b) r;
   Qval _ _ -> v}

get_cua :: Val -> Bool
get_cua v =
  case v of {
   Nval x _ -> x;
   Qval _ _ -> False}

get_cus :: Natural -> State -> Var -> Natural -> Bool
get_cus n f x i =
  case ltb i n of {
   True -> case get_state ((,) x i) f of {
            Nval b _ -> b;
            Qval _ _ -> False};
   False -> allfalse i}

get_r :: Val -> Rz_val
get_r v =
  case v of {
   Nval _ r -> r;
   Qval rc _ -> rc}

rotate :: Rz_val -> Natural -> Natural -> Rz_val
rotate =
  addto

times_rotate :: Val -> Natural -> Natural -> Val
times_rotate v q rmax =
  case v of {
   Nval b r ->
    case b of {
     True -> Nval b (rotate r q rmax);
     False -> Nval b r};
   Qval rc r -> Qval rc (rotate r q rmax)}

r_rotate :: Rz_val -> Natural -> Natural -> Natural
r_rotate =
  addto_n

times_r_rotate :: Val -> Natural -> Natural -> Val
times_r_rotate v q rmax =
  case v of {
   Nval b r ->
    case b of {
     True -> Nval b (r_rotate r q rmax);
     False -> Nval b r};
   Qval rc r -> Qval rc (r_rotate r q rmax)}

sr_rotate' :: State -> Var -> Natural -> Natural -> Natural -> State
sr_rotate' st x n size rmax =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> st)
    (\m ->
    sr_rotate'
      (add6 ((,) x m) (times_rotate (get_state ((,) x m) st) (sub size m) rmax) st)
      x m size rmax)
    n

sr_rotate :: State -> Var -> Natural -> Natural -> State
sr_rotate st x n rmax =
  sr_rotate' st x (succ n) (succ n) rmax

srr_rotate' :: State -> Var -> Natural -> Natural -> Natural -> State
srr_rotate' st x n size rmax =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> st)
    (\m ->
    srr_rotate'
      (add6 ((,) x m) (times_r_rotate (get_state ((,) x m) st) (sub size m) rmax)
        st) x m size rmax)
    n

srr_rotate :: State -> Var -> Natural -> Natural -> State
srr_rotate st x n rmax =
  srr_rotate' st x (succ n) (succ n) rmax

lshift' :: Natural -> Natural -> State -> Var -> T11 Val
lshift' n size f x =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> add6 ((,) x 0) (get_state ((,) x size) f) f)
    (\m -> add6 ((,) x n) (get_state ((,) x m) f) (lshift' m size f x))
    n

lshift :: State -> Var -> Natural -> T11 Val
lshift f x n =
  lshift' (sub n (succ 0)) (sub n (succ 0)) f x

rshift' :: Natural -> Natural -> State -> Var -> T11 Val
rshift' n size f x =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> add6 ((,) x size) (get_state ((,) x 0) f) f)
    (\m -> add6 ((,) x m) (get_state ((,) x n) f) (rshift' m size f x))
    n

rshift :: State -> Var -> Natural -> T11 Val
rshift f x n =
  rshift' (sub n (succ 0)) (sub n (succ 0)) f x

reverse' :: State -> Var -> Natural -> Natural -> State -> State
reverse' f x n i f' =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> f')
    (\i' ->
    reverse' f x n i' (add6 ((,) x i') (get_state ((,) x (sub n i)) f) f'))
    i

reverse :: State -> Var -> Natural -> State
reverse f x n =
  reverse' f x n n f

up_h :: Val -> Natural -> Val
up_h v rmax =
  case v of {
   Nval b r ->
    case b of {
     True -> Qval r (rotate 0 (succ 0) rmax);
     False -> Qval r 0};
   Qval r f -> Nval
    ((<=)
      (pow (succ (succ 0))
        (sub rmax (succ 0))) f) r}

assign_h :: State -> Var -> Natural -> Natural -> Natural -> State
assign_h f x n i rmax =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> f)
    (\m ->
    assign_h (add6 ((,) x (add n m)) (up_h (get_state ((,) x (add n m)) f) rmax) f)
      x n m rmax)
    i

up_qft :: Val -> Rz_val -> Val
up_qft v f =
  case v of {
   Nval _ r -> Qval r f;
   Qval _ _ -> v}

a_nat2fb' :: (Natural -> Bool) -> Natural -> Natural -> Natural
a_nat2fb' f n acc =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> acc)
    (\m ->
    a_nat2fb' f m
      (add acc
        (mul (b2n (f m)) (pow (succ (succ 0)) m))))
    n

a_nat2fb :: (Natural -> Bool) -> Natural -> Natural
a_nat2fb f n =
  a_nat2fb' f n 0

assign_r :: State -> Var -> Natural -> Natural -> Natural -> Natural -> State
assign_r f x r n size rmax =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> f)
    (\m ->
    assign_r
      (add6 ((,) x (sub size n)) (up_qft (get_state ((,) x (sub size n)) f) r) f) x
      (modulo (mul r (succ (succ 0)))
        (pow (succ (succ 0)) rmax)) m size rmax)
    n

turn_qft :: State -> Var -> Natural -> Natural -> State
turn_qft f x n rmax =
  assign_h
    (assign_r f x
      (mul (pow (succ (succ 0)) (sub rmax n))
        (a_nat2fb (fbrev n (get_cus n f x)) n)) n n rmax) x n (sub rmax n)
    rmax

assign_seq :: State -> Var -> (Natural -> Bool) -> Natural -> Natural -> State
assign_seq f x vals size n =
  (\ fO fS n -> if n==0 then fO () else fS (n-1))
    (\_ -> f)
    (\m ->
    assign_seq
      (add6 ((,) x (sub size n)) (Nval (vals (sub size n))
        (get_r (get_state ((,) x (sub size n)) f))) f) x vals size m)
    n

get_r_qft :: State -> Var -> Natural -> Natural -> Natural -> Bool
get_r_qft f x n rmax =
  case get_state ((,) x 0) f of {
   Nval _ _ -> allfalse;
   Qval _ g ->
    fbrev n
      (nat2fb
        (div g (pow (succ (succ 0)) (sub rmax n))))}

turn_rqft :: State -> Var -> Natural -> Natural -> State
turn_rqft st x n rmax =
  assign_h (assign_seq st x (get_r_qft st x n rmax) n rmax) x n (sub rmax n)
    rmax

exp_sem :: (Var -> Natural) -> Natural -> Exp -> State -> State
exp_sem env rmax e st =
  case e of {
   SKIP _ -> st;
   X p -> add6 p (exchange (get_state p st)) st;
   CU p e' ->
    case get_cua (get_state p st) of {
     True -> exp_sem env rmax e' st;
     False -> st};
   RZ q p -> add6 p (times_rotate (get_state p st) q rmax) st;
   RRZ q p -> add6 p (times_r_rotate (get_state p st) q rmax) st;
   SR n x -> sr_rotate st x n rmax;
   SRR n x -> srr_rotate st x n rmax;
   Lshift x -> lshift st x (env x);
   Rshift x -> rshift st x (env x);
   Rev x -> reverse st x (env x);
   QFT x _ -> turn_qft st x (env x) rmax;
   RQFT x _ -> turn_rqft st x (env x) rmax;
   Seq e1 e2 -> exp_sem env rmax e2 (exp_sem env rmax e1 st)}

-- data Bool =
--    True
--  | False
--
-- andb :: Bool -> Bool -> Bool
-- andb b1 b2 =
--   case b1 of {
--    True -> b2;
--    False -> False}
--
-- xorb :: Bool -> Bool -> Bool
-- xorb b1 b2 =
--   case b1 of {
--    True -> case b2 of {
--             True -> False;
--             False -> True};
--    False -> b2}
--
-- negb :: Bool -> Bool
-- negb b =
--   case b of {
--    True -> False;
--    False -> True}
--
-- fst :: (Prod a1 a2) -> a1
-- fst p =
--   case p of {
--    Pair x _ -> x}
--
-- snd :: (Prod a1 a2) -> a2
-- snd p =
--   case p of {
--    Pair _ y -> y}
--
-- add :: Nat -> Nat -> Nat
-- add n m =
--   case n of {
--    O -> m;
--    S p -> S (add p m)}
--
-- sub :: Nat -> Nat -> Nat
-- sub n m =
--   case n of {
--    O -> n;
--    S k -> case m of {
--            O -> n;
--            S l -> sub k l}}
--
-- data Positive =
--    XI Positive
--  | XO Positive
--  | XH
--
-- data N =
--    N0
--  | Npos Positive
--
-- eqb :: Nat -> Nat -> Bool
-- eqb n m =
--   case n of {
--    O -> case m of {
--          O -> True;
--          S _ -> False};
--    S n' -> case m of {
--             O -> False;
--             S m' -> eqb n' m'}}
--
-- leb :: Nat -> Nat -> Bool
-- leb n m =
--   case n of {
--    O -> True;
--    S n' -> case m of {
--             O -> False;
--             S m' -> leb n' m'}}
--
-- ltb :: Nat -> Nat -> Bool
-- ltb n m =
--   leb (S n) m
--
-- succ :: Positive -> Positive
-- succ x =
--   case x of {
--    XI p -> XO (succ p);
--    XO p -> XI p;
--    XH -> XO XH}
--
-- of_succ_nat :: Nat -> Positive
-- of_succ_nat n =
--   case n of {
--    O -> XH;
--    S x -> succ (of_succ_nat x)}
--
-- of_nat :: Nat -> N
-- of_nat n =
--   case n of {
--    O -> N0;
--    S n' -> Npos (of_succ_nat n')}
--
-- posi_eq :: Posi -> Posi -> Bool
-- posi_eq r1 r2 =
--   case r1 of {
--    Pair x1 y1 -> case r2 of {
--                   Pair x2 y2 -> andb (eqb x1 x2) (eqb y1 y2)}}
--
-- type Rz_val = Nat -> Bool
--
-- data Val =
--    Nval Bool Rz_val
--  | Qval Rz_val Rz_val
--
-- eupdate :: (Posi -> a1) -> Posi -> a1 -> Posi -> a1
-- eupdate f i x j =
--   case posi_eq j i of {
--    True -> x;
--    False -> f j}
--
-- allfalse :: Nat -> Bool
-- allfalse _ =
--   False
--
-- fb_push :: Bool -> (Nat -> Bool) -> Nat -> Bool
-- fb_push b f x =
--   case x of {
--    O -> b;
--    S n -> f n}
--
-- pos2fb :: Positive -> Nat -> Bool
-- pos2fb p =
--   case p of {
--    XI p' -> fb_push True (pos2fb p');
--    XO p' -> fb_push False (pos2fb p');
--    XH -> fb_push True allfalse}
--
-- n2fb :: N -> Nat -> Bool
-- n2fb n =
--   case n of {
--    N0 -> allfalse;
--    Npos p -> pos2fb p}
--
-- nat2fb :: Nat -> Nat -> Bool
-- nat2fb n =
--   n2fb (of_nat n)
--
-- carry :: Bool -> Nat -> (Nat -> Bool) -> (Nat -> Bool) -> Bool
-- carry b n f g =
--   case n of {
--    O -> b;
--    S n' ->
--     let {c = carry b n' f g} in
--     let {a = f n'} in
--     let {b0 = g n'} in xorb (xorb (andb a b0) (andb b0 c)) (andb a c)}
--
-- sumfb :: Bool -> (Nat -> Bool) -> (Nat -> Bool) -> Nat -> Bool
-- sumfb b f g x =
--   xorb (xorb (carry b x f g) (f x)) (g x)
--
-- negatem :: Nat -> (Nat -> Bool) -> Nat -> Bool
-- negatem i f x =
--   case ltb x i of {
--    True -> negb (f x);
--    False -> f x}
--
-- cut_n :: (Nat -> Bool) -> Nat -> Nat -> Bool
-- cut_n f n i =
--   case ltb i n of {
--    True -> f i;
--    False -> allfalse i}
--
-- fbrev :: Nat -> (Nat -> a1) -> Nat -> a1
-- fbrev n f x =
--   case ltb x n of {
--    True -> f (sub (sub n (S O)) x);
--    False -> f x}
--
-- addto :: (Nat -> Bool) -> Nat -> Nat -> Bool
-- addto r n i =
--   case ltb i n of {
--    True ->
--     cut_n (fbrev n (sumfb False (cut_n (fbrev n r) n) (nat2fb (S O)))) n i;
--    False -> r i}
--
-- addto_n :: (Nat -> Bool) -> Nat -> Nat -> Bool
-- addto_n r n i =
--   case ltb i n of {
--    True ->
--     cut_n
--       (fbrev n (sumfb False (cut_n (fbrev n r) n) (negatem n (nat2fb O)))) n
--       i;
--    False -> r i}
--
-- get_cua :: Val -> Bool
-- get_cua v =
--   case v of {
--    Nval x _ -> x;
--    Qval _ _ -> False}
--
-- get_cus :: Nat -> (Posi -> Val) -> Var -> Nat -> Bool
-- get_cus n f x i =
--   case ltb i n of {
--    True -> case f (Pair x i) of {
--             Nval b _ -> b;
--             Qval _ _ -> False};
--    False -> allfalse i}
--
-- rotate :: Rz_val -> Nat -> Nat -> Bool
-- rotate =
--   addto
--
-- times_rotate :: Val -> Nat -> Val
-- times_rotate v q =
--   case v of {
--    Nval b r -> case b of {
--                 True -> Nval b (rotate r q);
--                 False -> Nval b r};
--    Qval rc r -> Qval rc (rotate r q)}
--
-- sr_rotate' :: (Posi -> Val) -> Var -> Nat -> Nat -> Posi -> Val
-- sr_rotate' st x n size =
--   case n of {
--    O -> st;
--    S m ->
--     eupdate (sr_rotate' st x m size) (Pair x m)
--       (times_rotate (st (Pair x m)) (sub size m))}
--
-- sr_rotate :: (Posi -> Val) -> Var -> Nat -> Posi -> Val
-- sr_rotate st x n =
--   sr_rotate' st x (S n) (S n)
--
-- r_rotate :: Rz_val -> Nat -> Nat -> Bool
-- r_rotate =
--   addto_n
--
-- times_r_rotate :: Val -> Nat -> Val
-- times_r_rotate v q =
--   case v of {
--    Nval b r -> case b of {
--                 True -> Nval b (r_rotate r q);
--                 False -> Nval b r};
--    Qval rc r -> Qval rc (r_rotate r q)}
--
-- srr_rotate' :: (Posi -> Val) -> Var -> Nat -> Nat -> Posi -> Val
-- srr_rotate' st x n size =
--   case n of {
--    O -> st;
--    S m ->
--     eupdate (srr_rotate' st x m size) (Pair x m)
--       (times_r_rotate (st (Pair x m)) (sub size m))}
--
-- srr_rotate :: (Posi -> Val) -> Var -> Nat -> Posi -> Val
-- srr_rotate st x n =
--   srr_rotate' st x (S n) (S n)
--
-- exchange :: Val -> Val
-- exchange v =
--   case v of {
--    Nval b r -> Nval (negb b) r;
--    Qval _ _ -> v}
--
-- lshift' :: Nat -> Nat -> (Posi -> Val) -> Var -> Posi -> Val
-- lshift' n size f x =
--   case n of {
--    O -> eupdate f (Pair x O) (f (Pair x size));
--    S m -> eupdate (lshift' m size f x) (Pair x n) (f (Pair x m))}
--
-- lshift :: (Posi -> Val) -> Var -> Nat -> Posi -> Val
-- lshift f x n =
--   lshift' (sub n (S O)) (sub n (S O)) f x
--
-- rshift' :: Nat -> Nat -> (Posi -> Val) -> Var -> Posi -> Val
-- rshift' n size f x =
--   case n of {
--    O -> eupdate f (Pair x size) (f (Pair x O));
--    S m -> eupdate (rshift' m size f x) (Pair x m) (f (Pair x n))}
--
-- rshift :: (Posi -> Val) -> Var -> Nat -> Posi -> Val
-- rshift f x n =
--   rshift' (sub n (S O)) (sub n (S O)) f x
--
-- reverse :: (Posi -> Val) -> Var -> Nat -> (Prod Var Nat) -> Val
-- reverse f x n a =
--   case andb (eqb (fst a) x) (ltb (snd a) n) of {
--    True -> f (Pair x (sub (sub n (S O)) (snd a)));
--    False -> f a}
--
-- up_qft :: Val -> (Nat -> Bool) -> Val
-- up_qft v f =
--   case v of {
--    Nval _ r -> Qval r f;
--    Qval _ _ -> v}
--
-- lshift_fun :: (Nat -> Bool) -> Nat -> Nat -> Bool
-- lshift_fun f n i =
--   f (add i n)
--
-- get_r :: Val -> Rz_val
-- get_r v =
--   case v of {
--    Nval _ r -> r;
--    Qval rc _ -> rc}
--
-- assign_r :: (Posi -> Val) -> Var -> (Nat -> Bool) -> Nat -> Posi -> Val
-- assign_r f x r n =
--   case n of {
--    O -> f;
--    S m ->
--     eupdate (assign_r f x r m) (Pair x m)
--       (up_qft (f (Pair x m)) (lshift_fun r m))}
--
-- up_h :: Val -> Val
-- up_h v =
--   case v of {
--    Nval b r ->
--     case b of {
--      True -> Qval r (rotate allfalse (S O));
--      False -> Qval r allfalse};
--    Qval r f -> Nval (f O) r}
--
-- assign_h :: (Posi -> Val) -> Var -> Nat -> Nat -> Posi -> Val
-- assign_h f x n i =
--   case i of {
--    O -> f;
--    S m ->
--     eupdate (assign_h f x n m) (Pair x (add n m))
--       (up_h (f (Pair x (add n m))))}
--
-- turn_qft :: (Posi -> Val) -> Var -> Nat -> Nat -> Posi -> Val
-- turn_qft st x b rmax =
--   assign_h (assign_r st x (get_cus b st x) b) x b (sub rmax b)
--
-- assign_seq :: (Posi -> Val) -> Var -> (Nat -> Bool) -> Nat -> Posi -> Val
-- assign_seq f x vals n =
--   case n of {
--    O -> f;
--    S m ->
--     eupdate (assign_seq f x vals m) (Pair x m) (Nval (vals m)
--       (get_r (f (Pair x m))))}
--
-- assign_h_r :: (Posi -> Val) -> Var -> Nat -> Nat -> Posi -> Val
-- assign_h_r f x n i =
--   case i of {
--    O -> f;
--    S m ->
--     eupdate (assign_h_r f x n m) (Pair x (add n m))
--       (up_h (f (Pair x (add n m))))}
--
-- get_r_qft :: (Posi -> Val) -> Var -> Nat -> Bool
-- get_r_qft f x =
--   case f (Pair x O) of {
--    Nval _ _ -> allfalse;
--    Qval _ g -> g}
--
-- turn_rqft :: (Posi -> Val) -> Var -> Nat -> Nat -> Posi -> Val
-- turn_rqft st x b rmax =
--   assign_h_r (assign_seq st x (get_r_qft st x) b) x b (sub rmax b)
--
-- exp_sem :: (Var -> Nat) -> Exp -> (Posi -> Val) -> Posi -> Val
-- exp_sem env e st =
--   case e of {
--    SKIP _ -> st;
--    X p -> eupdate st p (exchange (st p));
--    CU p e' ->
--     case get_cua (st p) of {
--      True -> exp_sem env e' st;
--      False -> st};
--    RZ q p -> eupdate st p (times_rotate (st p) q);
--    RRZ q p -> eupdate st p (times_r_rotate (st p) q);
--    SR n x -> sr_rotate st x n;
--    SRR n x -> srr_rotate st x n;
--    Lshift x -> lshift st x (env x);
--    Rshift x -> rshift st x (env x);
--    Rev x -> reverse st x (env x);
--    QFT x b -> turn_qft st x b (env x);
--    RQFT x b -> turn_rqft st x b (env x);
--    Seq e1 e2 -> exp_sem env e2 (exp_sem env e1 st)}

prop :: Property
prop =
  forAll (choose (60, 60)) $ \n ->
  forAll (choose (1, 2 ^ min n 30 - 1)) $ \m ->
  -- forAllShrink arbitrary shrink $ \(vx :: Bvector) ->
  forAll arbitrary $ \(vx :: Bvector) ->
  let x_var = 0
      y_var = 1
      z_var = 2
  in

  let env = div_mod_env n
      vars = div_mod_vars n
      expr = rz_div_mod_out n m
  in
  st_equivb vars env
             (exp_sem env (succ n) expr (update_var 1 empty x_var vx))
             (update_vars
              2
              empty
              [(x_var, vx .%. m)
              ,(y_var, vx ./. m)])


main :: IO ()
main = do
  quickCheck prop
  -- let x_var = 0
  --     y_var = 1
  --     z_var = 2
  --
  -- let n = 5
  --     m = 3
  -- let expr1 = rz_div_mod_out n m
  -- print expr1
  -- -- print $ exp_sem (const 0) expr1 (const (Nval True (const False))) ((,) 1 7)
  -- print $ exp_sem (div_mod_env n) (succ n) expr1 empty
  --
  -- let env = div_mod_env n
  --     vars = div_mod_vars n
  --
  -- let z = st_equivb vars env
  --            (exp_sem env (succ n) expr1 undefined)
  --            undefined
  --
  -- undefined
  --
