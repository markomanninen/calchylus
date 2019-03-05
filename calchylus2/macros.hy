#! /usr/bin/env hy
;--------------------------------
; Lambda calculus custom macros
;--------------------------------

(defmacro init-macros [binder]
  `(do
    (eval-and-compile
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

        ; make a chuch numeral
        ; (NUM 4) -> FOUR -> (L x y (x (x (x (x y)))))
        (defmacro NUM [n &rest args]
          `(~binder x y ~(reduce (fn [x y] (hy.HyList ['x x])) (range n) 'y) ~@args))

        ; natural numbers
        ; ONE -> (L x y (x y))
        (defmacro ℕ+ [number] `(NUM ~(abs number)))
        (deftag ℕ [number] `(ℕ+ ~number))

        ; church natural number to native the native one
        (defn MUN [n]
          (do (setv x (n 1 0))
            (if (numeric? x) x
              (sum (flatten x)))))

        (setv ; https://en.wikipedia.org/wiki/SKI_combinator_calculus
             ; S = apply x to y in the domain of z
             S (~binder x y z [[x z] [y z]]) ; X (X (X (X X))) ≡ X K ≡ X′ (X′ X′) ≡ B (B (B W) C) (B B)
             K (~binder a b a) ; X (X (X X)) ≡ X′ X′ X′
             K′ (~binder a b b) ; X (X X) ≡ X′ X′
             I (~binder x x) ; S K S ≡ S K K ≡ X X ≡ (X′ (X′ X′)) ((X′ X′) X′) X′
             ; https://en.wikipedia.org/wiki/B,_C,_K,_W_system
             B (~binder x y z [x [y z]]) ; S (K S) K
             C (~binder x y z [x z y]) ; S (S (K (S (K S) K)) S) (K K)
             W (~binder x y [x y y]) ; S S (K (S K K))
             W′ (~binder x y [x y x]) ; X (X (X (X (X X))))
             ; all above combinators could be presented by a single iota combinator:
             X (~binder x [x S K]) ; (iota, (~binder x [x FALSE])
             X′ (~binder x [x K S K]) ;
             X′′ (~binder x [x K]) ;
             ; (X′ X′) = (I K K) = (~binder a TRUE)
             ; (X′ FALSE) = (I (K (S K))) = (~binder a FALSE)
             ; self referencial combinators
             Y (~binder g [(~binder x [g [x x]]) (~binder x [g [x x]])]) ; S (K (S I I)) (S (S (K S) K) (K (S I I)))
             Y′ [(~binder x y [x y x]) (~binder y x [y [x y x]])] ; S S K (S (K (S S (S (S S K)))) K)
             Θ [(~binder x y [y [x x y]]) (~binder x y [y [x x y]])] ; Turing fixed-point combinator
             ω (~binder x [x x]) ; S I I
             Ω [ω ω]
             Ω2 [(~binder x [x x x]) (~binder x [x x x])]

             IDENT I ; (X X)
             FALSE (~binder a b b) ; (~binder x I) (CONST x I) (S K) (X (X X))
             TRUE K ; (X (X (X X)))
             COND (~binder a b c [a b c])

             NOT (~binder p [p FALSE TRUE]) ; (p FALSE TRUE)
             AND (~binder a b [a b FALSE]) ; (a b FALSE)
             OR (~binder a b [a TRUE b]) ; (a TRUE b)
             XOR (~binder a b [a (NOT b) b]) ; (a (b FALSE TRUE) b)
             NAND (~binder a b (NOT (AND a b))) ; (a b FALSE FALSE TRUE)
             NOR (~binder a b (NOT (OR a b))) ; (a TRUE b FALSE TRUE)
             XNOR (~binder a b (NOT (XOR a b))) ; (a (b FALSE TRUE) b FALSE TRUE)
             IMP (~binder a b (OR (NOT a) b)) ; (a FALSE TRUE TRUE b)
             NIMP (~binder a b (NOT (OR (NOT a) b))) ; (a FALSE TRUE TRUE b FALSE TRUE)
             ;MIMP (~binder a b (AND (NOT a) b)) ; (a FALSE TRUE b FALSE)
             ;NMIMP (~binder a b (NOT (AND (NOT a) b))) ; (a FALSE TRUE b FALSE FALSE TRUE)
             EQV XNOR
             NEQV NOR

             ZERO FALSE
             ZERO? (~binder s [s (~binder a FALSE) TRUE])

             ONE (NUM 1)
             TWO (NUM 2)
             THREE (NUM 3)
             FOUR (NUM 4)
             FIVE (NUM 5)
             SIX (NUM 6)
             SEVEN (NUM 7)
             EIGHT (NUM 8)
             NINE (NUM 9)
             TEN (NUM 10)

             SUM (~binder m n x y [m x [n x y]])
             PRED (~binder n x y [n (~binder g h [h [g x]]) (~binder x y) (~binder x x)])
             SUCC (~binder n x y [x [n x y]])
             SUB (~binder m n [m PRED n])
             PROD (~binder m n x y [m [n x] y])
             EXP (~binder m n x y [n m x y])

             LEQ? (~binder m n (ZERO? [n PRED m]))
             EQ? (~binder m n (AND (LEQ? m n) (LEQ? n m)))
             GE? (~binder m n (NOT (LEQ? m n)))
             GEQ? (~binder m n (OR (GE? m n) (EQ? m n)))
             ;LE? (~binder m n (NOT (GEQ? m n)))
             LE? (~binder m n (NOT (LEQ? n m)))

             PAIR (~binder a b s [s a b])
             HEAD (~binder s [s TRUE])
             TAIL (~binder s [s FALSE])
             NIL (~binder x TRUE)
             EMPTY (PAIR NIL NIL)
             EMPTY? (~binder l (TAIL l (~binder h (~binder t FALSE))))

             NIL? ZERO?
             INDEX (~binder i l (HEAD [(i TAIL) l]))

             PREPEND PAIR
             FIRST HEAD
             SECOND (~binder l (HEAD (TAIL l)))
             THIRD (~binder l (HEAD (TAIL (TAIL l)))))

        ; get church number by calling SUCC as many times as given in the argument
        (defn N [m]
          (setv n ZERO)
          (while (pos? m)
            (setv n (SUCC n) m (dec m))) n)

        (defn FLAT [l]
          (while (not (MUN (EMPTY? l)))
            (do (yield (FIRST l))
                (setv l (TAIL l)))))

        (defn LIST [&rest args]
          (reduce (fn [y x] (PAIR x y)) (reverse (list args)) EMPTY))

        (defn NM [n &optional [m FALSE]]
          (while (> n 0)
            (setv n (dec n) m (SUCC m))) m)

        ; integers
        ; -4 -> (PAIR FALSE FOUR)
        (defmacro ℤ+ [number] `(PAIR TRUE #ℕ ~number))
        (defmacro ℤ- [number] `(PAIR FALSE #ℕ ~number))
        (deftag ℤ [number] (if (pos? number) `(ℤ+ ~number) `(ℤ- ~number)))

        ; rational numbers
        ; -1/7 -> (PAIR FALSE (PAIR ONE SEVEN))
        (defmacro ℚ+ [number] `(PAIR TRUE (PAIR #ℕ ~(second number) #ℕ ~(last number))))
        (defmacro ℚ- [number] `(PAIR FALSE (PAIR #ℕ ~(second number) #ℕ ~(last number))))
        (deftag ℚ [number]
          `(PAIR (if (pos? ~number) TRUE FALSE)
            (PAIR #ℕ ~(second number) #ℕ ~(last number))))

        ; imaginary numbers
        ; #ℂ-0.5+2j -> (PAIR (PAIR FALSE (PAIR ONE TWO)) (PAIR TRUE (PAIR TWO ONE)))
        (deftag ℂ [number]
          (import [fractions [Fraction]])
          (setv real (Fraction (abs number.real))
               imag (Fraction (abs number.imag)))
          `(do
            (PAIR
              (PAIR (if (pos? ~number.real) TRUE FALSE)
                (PAIR (NUM ~real.numerator) (NUM ~real.denominator)))
              (PAIR (if (pos? ~number.imag) TRUE FALSE)
                (PAIR (NUM ~imag.numerator) (NUM ~imag.denominator))))))

        (setv ; self referential combinators
             SELF (~binder f x [f f x])
             YCOMB (~binder f [(~binder x [x x]) (~binder y [f [y y]])])

             GET (YCOMB (~binder f l n [ZERO? n (HEAD l) (, f (TAIL l) (PRED n))]))
             LEN (YCOMB (~binder f l [(EMPTY? l) ZERO (SUM ONE [f (TAIL l)])]))
             LAST (YCOMB (~binder f l (EMPTY? (TAIL l) (HEAD l) [f (TAIL l)])))
             ; EXTEND LIST LIST
             EXTEND (YCOMB (~binder g a b [(EMPTY? a) b (PAIR (HEAD a) [g (TAIL a) b])]))
             ; APPEND LIST item
             APPEND (YCOMB (~binder g a b [(EMPTY? a) (PAIR b EMPTY) (PAIR (HEAD a) [g (TAIL a) b])]))
             ;APPEND EXTEND
             MAP (YCOMB (~binder g f x [(EMPTY? x) EMPTY (PAIR [f (HEAD x)] [g f (TAIL x)])]))
             FOLD-LEFT (YCOMB (~binder g f e x [(EMPTY? x) e [g f [f e (HEAD x)] (TAIL x)]]))
             FOLD-RIGHT (~binder f e x [YCOMB (~binder g y [(EMPTY? y) e [f (HEAD y) [g (TAIL y)]]]) x])
             ;
             REVERSE (YCOMB (~binder g a l [(EMPTY? l) a [g (PAIR (HEAD l) a) (TAIL l)]]) EMPTY)
             ;
             APPLY (YCOMB (~binder g f x [(EMPTY? x) f [g [f (HEAD x)] (TAIL x)]]))
             ;TRUNCATE (LIST ONE TWO THREE) -> (LIST ONE TWO)
             TRUNCATE (YCOMB (~binder g x [EMPTY? x EMPTY [EMPTY? (TAIL x) EMPTY (PAIR (HEAD x) [g (TAIL x)])]]))
             ; RANGE ONE FOUR -> (LIST ONE TWO THREE)
             RANGE (~binder s e (YCOMB (~binder g c [LE? c e (PAIR c [g (SUCC c)]) EMPTY]) s))
             ; FILTER ZERO? (LIST ONE ZERO ONE ZERO ONE) -> (LIST ZERO ZERO)
             FILTER (YCOMB (~binder g f x [EMPTY? x EMPTY [f (HEAD x) (PAIR (HEAD x)) IDENT [g f (TAIL x)]]]))
             ; CROSS PAIR (LIST ONE TWO) (LIST THREE FOUR) ->
             ; (LIST (PAIR ONE THREE) (PAIR ONE FOUR) (PAIR TWO THREE) (PAIR TWO FOUR))
             CROSS (~binder f l m [FOLD-LEFT EXTEND EMPTY (MAP (~binder x (MAP [f x] m)) l)])
             ; ZIP (LIST ONE THREE) (LIST TWO FOUR) -> (LIST (PAIR ONE TWO) (PAIR THREE FOUR))
             ZIP (YCOMB (~binder f l m [EMPTY? l EMPTY (PAIR (PAIR (HEAD l) (HEAD m)) [f (TAIL l) (TAIL m)])]))
             ; (LIST* THREE ONE TWO THREE)
             LIST* (~binder n [n (~binder f a x [f (PAIR x a)]) REVERSE EMPTY])

             ; (DIV FIVE THREE) -> PAIR IDIV MOD
             DIV (YCOMB (~binder g q a b (LE? a b (PAIR q a) [g (SUCC q) (SUB b a) b])) ZERO)
             ; (IDIV FIVE THREE) -> ONE
             IDIV (~binder a b [HEAD [DIV a b]])
             ; (MOD FIVE THREE) -> TWO
             MOD (~binder a b [TAIL [DIV a b]])
             ; greatest common divisor: (GCD 54 48) -> 6
             GCD ((~binder g m n [LEQ? m n [g n m] [g m n]]) [YCOMB (~binder g x y [ZERO? y x [g y [MOD x y]]])])

             ; 1 + 2 + 3 + ... + n
             SUMMATION (~binder n (YCOMB (~binder f n [(ZERO? n) n (SUM n [f (PRED n)])]) n))
             ; 1 * 2 * 3 * ... * n
             FACTORIAL (~binder n (YCOMB (~binder f n [(ZERO? n) ONE (PROD n [f (PRED n)])]) n))
             ; Fn = F(n-1) + F(n-2)
             ;FIBONACCI (~binder n (YCOMB (~binder f n [(ZERO? n) ONE (SUM [f (PRED n)] [f (PRED (PRED n))])]) (PRED n)))
             ; excludes the first two seed numbers
             FIBONACCI (~binder n (YCOMB (~binder f n [(LEQ? n TWO) n (SUM [f (PRED n)] [f (PRED (PRED n))])]) n))
             ; erastotenes prime sieve
             PRIME? (~binder m [NOT [FOLD-LEFT OR FALSE (MAP (~binder n [ZERO? [MOD m n]]) (RANGE TWO m))]])
             PRIMES (~binder m n (FILTER PRIME? (RANGE m (SUCC n))))
             ; compute real digits, decimal expansion by: numerator denominator number-base limit
             ; (DIGITS (NUM 1) (NUM 7) (NUM 10) (NUM 6)) -> 0 1 4 2 8 5 7
             DIGITS (~binder l m n o [YCOMB (~binder f p q
                      (ZERO? q EMPTY (PAIR (HEAD p) [f [DIV (PROD (TAIL p) n) m] (PRED q)]))) [DIV l m] o])))))
