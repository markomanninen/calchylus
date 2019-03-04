#! /usr/bin/env hy
;--------------------------------
; Lambda calculus custom macros
;--------------------------------

(defmacro init-macros [binder]
  `(do
    (eval-and-compile
      (setv
        forms ["LET" "LET*" "DO" "CONST"])

        ; named variables. multiple variables can be associated first, then the last expression is the body
        ; (LET a 1 b 2 (a b)) ->
        ; ((L a b (a b)) 1 2)
        (defmacro LET [&rest args]
          ; all odd parameters except the last are argument names
          (setv x (if args (cut (cut args 0 (len args) 2) 0 -1) ())
                y (if args (cut args 1 (len args) 2) ())
                z (if args (last args) ()))
          (if args `((~binder ~@x ~z) ~@y)))

        ; same as LET but preceding variables are evaluated before using them on the body so that
        ; variables associated previously can be used on the later variables
        ; (LET* a 1 b a (a b)) ->
        ; (LET a 1 (LET b a (a b))) -> (1 1)
        (defmacro LET* [&rest code]
          (setv ; the last parameter in the expression is the body
                expr (if code (last code) ())
                ; argument names are all odd except the last parameter
                args (if code (cut (cut code 0 (len code) 2) 0 -1) ())
                ; values are all even parameters
                vals (if code (cut code 1 (len code) 2) ()))
          ; create nested expressions but in reverse order
          (for [[x y] (reverse (list (zip args vals)))]
            (setv expr `((~binder ~x ~expr) ~y)))
          ;(if args expr `(~binder ~separator ~@code)))
          (if args expr code))

        ; the do structure for imperative style command sequences
        ; (DO (LET a 1) (LET b 2) (a b)) ->
        ; (LET a 1 (LET b 2 (a b))) -> (1 2)
        (defmacro DO [&rest args]
          ; fold right with reduce reverse
          (reduce (fn [x y] (extend y [x]))
            (reverse (HyExpression args))))

        ; the constant macro takes the first argument as the name of the argument
        ; and the second argument as the function body. when the constant function is
        ; applied to any parameter, the static body will return be returned
        ; ((L x 1) 2) -> 1
        (defmacro CONST [&rest args]
          `(~binder ~(first args) ~@(rest args)))

        (setv ; https://en.wikipedia.org/wiki/SKI_combinator_calculus
             ; S = apply x to y in the domain of z
             S (~binder x y z [[x z] [y z]]) ; X (X (X (X X))) ≡ X K ≡ X′ (X′ X′) ≡ B (B (B W) C) (B B)
             K (~binder a b a) ; X (X (X X)) ≡ X′ X′ X′
             K′ (~binder a b b) ; X (X X) ≡ X′ X′
             I (~binder x x) ; S K S ≡ S K K ≡ X X ≡ (X′ (X′ X′)) ((X′ X′) X′) X′

             IDENT I ; (X X)
             FALSE (~binder a b b) ; (L x I) (CONST x I) (S K) (X (X X))
             TRUE K ; (X (X (X X)))
             COND (~binder a b c [a b c])) )))
