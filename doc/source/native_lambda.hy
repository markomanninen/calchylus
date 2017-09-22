#! /usr/bin/env hy
; native function utilizer by lambda calculus syntax in Hy
(eval-and-compile
    ; specify separator char
    (setv separator '·)
    ; find the numerical index of the element from the list
    (defn index [elm lst]
      ; if the element is not found, return -1
      (try (.index lst elm) (except [ValueError] -1))))
  ; main lambda expression macro
  (defmacro λ [&rest expr]
    ; get the index of the argument-body separator
    (setv idx (index separator expr))
    ;  cut the arguments before the separator and append to the function
    `(fn ~(cut expr 0 (if (pos? idx) idx 0))
      ; cut the body (And the rest of the arguments) of the expression and append to the function
      ~@(cut expr (inc idx))))
