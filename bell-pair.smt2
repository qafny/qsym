(set-logic ALL)
(set-option :produce-models true)
(set-option :pp.decimal true)

(declare-const mem (Array Int (Array Int Real)))
(declare-const mem-vecs (Array Int (_ BitVec 2)))

(declare-const mem2 (Array Int (Array Int Real)))
(declare-const mem2-vecs (Array Int (_ BitVec 2)))

(declare-const mem3 (Array Int (Array Int Real)))
(declare-const mem3-vecs (Array Int (_ BitVec 2)))

(declare-const q Int)
(declare-const q2 Int)

(assert (= q 0))
(assert (= q2 1))

(assert (= (select mem-vecs 0) (_ bv0 2)))
(assert (= (select mem-vecs 1) (_ bv1 2)))

(declare-const sqrt2 Real)

(assert (= (* sqrt2 sqrt2) 2))
(assert (> sqrt2 0))

(define-fun hadamard-fst ((m (Array Int (Array Int Real))) (loc Int)) Real
  (/ (+ (select (select m loc) 0)
        (select (select m loc) 1))
     sqrt2))

(define-fun hadamard-snd ((m (Array Int (Array Int Real))) (loc Int)) Real
  (/ (- (select (select m loc) 0)
        (select (select m loc) 1))
     sqrt2))

; Initial state
;; First qubit
(assert (= (select (select mem q) 0) 1))
(assert (= (select (select mem q) 1) 0))

;; Second qubit
(assert (= (select (select mem q2) 0) 1))
(assert (= (select (select mem q2) 1) 0))

(assert (= mem2-vecs mem-vecs))

; H
(assert
  (= (select (select mem2 q) 0)
     (hadamard-fst mem q)))

(assert
  (= (select (select mem2 q) 1)
     (hadamard-snd mem q)))

(assert
  (= (select (select mem2 q2) 0)
     (select (select mem q2) 0)))

(assert
  (= (select (select mem2 q2) 1)
     (select (select mem q2) 1)))

(assert (= mem2-vecs mem-vecs))

; CNOT
;; First qubit (unchanged)
(assert
  (= (select (select mem3 q) 0)
     (select (select mem2 q) 0)))

(assert
  (= (select (select mem3 q) 1)
     (select (select mem2 q) 1)))

;; Second qubit
(assert
  (= (select (select mem3 q2) 0)
     (select (select mem2 q2) 1)))

(assert
  (= (select (select mem3 q2) 1)
     (select (select mem2 q2) 0)))

(assert
  (= (select mem3-vecs 0) (_ bv00 2)))

(assert
  (= (select mem3-vecs 1) (_ bv11 2)))

; Find a model
(check-sat)
(get-model)

