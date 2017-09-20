#!/usr/bin/python3
;--------------------------------
; Lambda calculus custom macros
;--------------------------------
(defmacro init-macros [lambdachr separator]

  `(do

    (eval-and-compile

      (setv ; TODO: these could be constructed by some lambda-term-generator macro?
        forms ["CONST" "IDENT" "LET" "LET*"
               "TRUE" "FALSE"
               "PAIR" "HEAD" "TAIL" "FIRST" "SECOND" "NIL" "NIL?" "is_NIL"
               "LIST" "LAST" "PREPEND" "APPEND"
               "NUM" "ZERO" "ONE" "TWO" "THREE" "FOUR" "FIVE" "SIX" "SEVEN" "EIGHT" "NINE" "TEN"
               "ZERO?" "is_ZERO" "EMPTY?" "is_EMPTY" "NUM?" "is_NUM" "LEN"
               "LEQ?" "is_LEQ" "EQ?" "is_EQ"  "GEQ?" "is_GEQ" "GE?" "is_GE" "LE?" "is_LE"
               "COND" "AND" "OR" "NOT" "XOR" "IMP" "EQV"
               "SUCC" "PRED"  "SUM" "SUB" "PROD" "EXP"
               "SELF" "YCOMB" "DO" "APP"
               "SUMMATION" "FACTORIAL" "FIBONACCI"])
        ; return reversed list rather than reverse in place
        (defn reverse [l] (.reverse l) l)
        ; is expr(ession) a suitable macro form?
        (defn macro-form? [expr] (and (symbol? expr) (in expr forms)))
        ; helper for append to the end of the list
        ; TODO: can probably be done more efficiently
        (defn append* [x l]
          (if-not (coll? l) l
            (if (= (second l) 'NIL)
                (extend (read-str (% "(PAIR %s)" x)) [l])
                (if (= (first l) 'LIST)
                    (extend l [x])
                    ((type l) (genexpr (append* x y) [y l]))))))
        ; expand custom lambda forms to the normal lambda forms
        ; (PAIR TRUE (PAIR TRUE NIL)) should become:
        ; (L a b s , (s a b) (L a b , a) (L a b s , (s a b) (L a b , a) (L a b , b)))
        (defn macro-expand [expr]
          (if (coll? expr)
              (if (macro-form? (first expr))
                  ; if the first symbol is a custom macro form, expand it by using internal macroexpand-1
                  (macro-expand (macroexpand-1 expr))
                  ; loop everything inside
                  ((type expr) (genexpr (macro-expand x) [x expr])))
              (if (macro-form? expr)
                  ; plain macro names like TRUE will be reformed to (TRUE) so that they can be expanded
                  (macro-expand (read-str (% "(%s)" expr)))
                  ; return other forms as they are
                  expr))))
    ;--------------------------------
    ; special forms
    ;--------------------------------
    ; LET, LET*, CONST, DO, APP
		; named variables. multiple variables can be associated first, then the last expression is the body
		; (LET a 1 b 2 (a b)) ->
    ; (L a b p , (p a b) 1 2 (L a b , (a b))) -> (1 2)
    (defmacro LET [&rest args]
      ; all odd parameters except the last are argument names
      (setv x (if args (cut (cut args 0 (len args) 2) 0 -1) ())
            y (if args (cut args 1 (len args) 2) ())
            z (if args (last args) ()))
      `(~lambdachr ~@x p ~separator (p ~@x) ~@y (~lambdachr ~@x ~separator ~z)))
    ; same as LET but preceding variables are evaluated becore using on the body so that
    ; variables associated previously can be used on the later variables
    ; (LET* a 1 b a (a b)) ->
    ; (LET a 1 (LET b a (a b))) -> (1 1)
    (defmacro LET* [&rest args]
      (setv ; the last parameter in the expression is the body
            expr `(LET ~(if args (last args) ()))
            ; argument names are all odd except the last paramter
            a (if args (cut (cut args 0 (len args) 2) 0 -1) ())
            ; values are all even paramters
            b (if args (cut args 1 (len args) 2) ()))
      ; create nested LET clauses
      (for [[x y] (zip a b)]
        (setv expr `(LET ~x ~y ~expr)))
      expr)
    ; constant, takes the first argument as the name of the argument
    ; and the second argument as the function body
    ; when function is applied to any value, the static body will return be returned
    ; (L x , 1 2) -> 1
    (defmacro CONST  [&rest args]
      `(~lambdachr ~(first args) ~separator ~@(rest args)))
    ; do structure for imperative command sequences
    ; (DO (LET a 1) (LET b 2) (a b)) ->
    ; (LET a 1 (LET b 2 (a b))) ->
    ; (1 2)
    (defmacro DO [&rest args]
      ; fold right with reduce reverse (extend?!)
      (reduce (fn [x y] (extend y [x]))
        (reverse (HyExpression args))))
    ; list sequence constructor
    (defmacro LIST [&rest args]
      ; fold right with reduce reverse
      (reduce (fn [x y] `(PAIR ~y ~x))
        (reverse (HyExpression args))
        ; default and the deepest start pair / tuple
        `(PAIR NIL NIL)))
    ; append item to the list
    ;(macro-form APPEND
    ;  `(~lambdachr a l f x ~separator (f a (l f x))))
    ;(defmacro APPEND  [&rest args]
    ;  `(~lambdachr a l x ~separator (x a (l x)) ~@args))
    ; append n to the end of the list, i.e. change (PAIR m (PAIR NIL NIL)) to
    ; (PAIR m (PAIR n (PAIR NIL NIL)))
    (defmacro APPEND [n l &rest args]
      `(L , ~(append* n l) ~@args))
    ; lambda form macro generator
    (defmacro macro-form [form body]
      `(do
        ; TODO: add form to forms list, does not work yet
        ; because macro-form? does not recognize global forms variable
        ;(.append forms (hy.HySymbol ~(name form)))
        (setv forms (extend forms (, ~(name form))))
        (defmacro ~form [&rest args] (extend ~body args))))
    ; lambda application wrapper. Y application sharp macro can also be used
    ; identically with APP macro
    (macro-form APP    `(~lambdachr ~separator))
    ;--------------------------------
    ; basic forms
    ;--------------------------------
    ; identity, return passed argument as it is
    (macro-form IDENT  `(~lambdachr a ~separator a))
    ; booleans
    (macro-form TRUE   `(~lambdachr a b ~separator a))
    (macro-form FALSE  `(~lambdachr a b ~separator b))
    ;--------------------------------
    ; list forms
    ;--------------------------------
    ; make a pair for list
    (macro-form PAIR   `(~lambdachr a b s ~separator (s a b)))
    ; last item of the nested lists should be nil
    (macro-form NIL    `(FALSE))
    ; first item of the list, used as the parent node of the list i.e. cons
    (macro-form HEAD   `(~lambdachr s ~separator (s TRUE)))
    ; last item of the list, used as the parent node of the list i.e. cdr
    (macro-form TAIL   `(~lambdachr s ~separator (s FALSE)))
		; prepend to the beginning of the list
		(macro-form PREPEND `(PAIR))
    ; first item of the list, same as head or cons
    (macro-form FIRST  `(HEAD))
    ; second item of the list, head of the tail
    (macro-form SECOND `(~lambdachr l ~separator (HEAD (TAIL l))))
    ; last item of the list
    (macro-form LAST
      `(YCOMB (~lambdachr f l ~separator
          (COND (NIL? (HEAD (TAIL l))) (HEAD l) (f (TAIL l))))))
    ; is empty list
    (macro-form EMPTY? `(~lambdachr s ~separator (s TRUE FALSE TRUE TRUE FALSE)))
    ; NUM? any number from one and up or ZERO / FALSE
    (macro-form NUM?   `(~lambdachr s ~separator (OR (NOT s) (s TRUE TRUE FALSE))))
    ; is item empty / EMPTY?
    (macro-form NIL?   `(~lambdachr s ~separator (s (~lambdachr a ~separator FALSE) TRUE)))
		; length of the list
    (macro-form LEN    `(~lambdachr ~separator))
    ;--------------------------------
    ; zero forms
    ;--------------------------------
    (macro-form ZERO   `(FALSE))
    (macro-form ZERO?  `(~lambdachr n ~separator (NIL? n)))
    ;--------------------------------
    ; logic forms
    ;--------------------------------
    (macro-form COND   `(~lambdachr p a b ~separator (p a b)))
    ; (macro-form AND   `(~lambdachr a b , (a b a)))
    (macro-form AND    `(~lambdachr a b ~separator (a b FALSE)))
    ; (macro-form OR    `(~lambdachr a b , (a a b)))
    (macro-form OR     `(~lambdachr a b ~separator (a TRUE b)))
    ; (macro-form OR    `(~lambdachr p a b , (p b a))) ?
    (macro-form NOT    `(~lambdachr p ~separator (p FALSE TRUE)))
    ; exlusive or
    (macro-form XOR    `(~lambdachr a b ~separator (a (NOT b) b)))
    ; implication
    (macro-form IMP    `(~lambdachr a b ~separator (OR (NOT a) b)))
    ; equivalence / xnor
    (macro-form EQV    `(~lambdachr a b ~separator (NOT (XOR a b))))
    ; church number generator: (NUM 3) ; -> (L x y , (x (x (x y))))
    ; launch application: (NUM 3 a b) ; -> (a (a (a b)))
    (defmacro NUM [n &rest args]
      `(~lambdachr x y ~separator
        ~(reduce (fn [x y] ['x x]) (range n) 'y) ~@args))
    ;--------------------------------
    ; positive "church" numeral forms
    ;--------------------------------
    (macro-form ONE `(NUM 1))
    (macro-form TWO `(NUM 2))
    (macro-form THREE `(NUM 3))
    (macro-form FOUR `(NUM 4))
    (macro-form FIVE `(NUM 5))
    (macro-form SIX `(NUM 6))
    (macro-form SEVEN `(NUM 7))
    (macro-form EIGHT `(NUM 8))
    (macro-form NINE `(NUM 9))
    (macro-form TEN `(NUM 10))
    ;--------------------------------
    ; arithmetic forms
    ;--------------------------------
    ; next / successor = INC = ADD
    (macro-form SUCC `(~lambdachr n x y ~separator (x (n x y))))
    ; previous / predecessor = DEC
    (macro-form PRED
      `(~lambdachr n x y ~separator (n (~lambdachr g h ~separator (h (g x))) (~lambdachr x ~separator y) IDENT)))
    ; sum (x+y) two numbers together
    ;(macro-form SUM `(L m n , (m SUCC n)))
    (macro-form SUM  `(~lambdachr m n x y ~separator (m x (n x y))))
    ; substract (x-y) two numbers from each other
    (macro-form SUB  `(~lambdachr m n ~separator (m PRED n)))
    ; multiplication (x*y), product of two numbers
    (macro-form PROD `(~lambdachr m n x y ~separator (m (n x) y)))
    ; exponent (x^y)
    (macro-form EXP  `(~lambdachr m n x y ~separator (n m x y)))
    ; lesser or equals
    (macro-form LEQ? `(~lambdachr m n ~separator (ZERO? (n PRED m))))
    ; equals
    (macro-form EQ?  `(~lambdachr m n ~separator (AND (LEQ? m n) (LEQ? n m))))
    ; greater
    (macro-form GE?  `(~lambdachr m n ~separator (NOT (LEQ? m n))))
    ; greater or equals
    (macro-form GEQ? `(~lambdachr m n ~separator (OR (GE? m n) (EQ? m n))))
    ; lesser
    (macro-form LE?  `(~lambdachr m n ~separator (NOT (GEQ? m n))))
    ; self application
    (macro-form SELF `(~lambdachr f x ~separator (f f x)))
    ; ϒ combinator
    (macro-form YCOMB
      `(~lambdachr f ~separator (~lambdachr x ~separator (f (x x)) (~lambdachr x ~separator (f (x x))))))
    ;--------------------------------
    ; math functions
    ;--------------------------------
    ; ∑ summation function
    ;(macro-form SUMMATION `(~lambdachr x ~separator (SELF (~lambdachr f n , (COND (ZERO? n) ZERO (SUM n (f f (PRED n))))) x)))
    (macro-form SUMMATION
      `(~lambdachr x ~separator
        (YCOMB (~lambdachr f n ~separator (COND (ZERO? n) ZERO (SUM n (f (PRED n))))) x)))
    ; ∏ factorial function
    ;(macro-form FACTORIAL `(~lambdachr x ~separator (SELF (~lambdachr f n , (COND (ZERO? n) ONE (PROD n (f f (PRED n))))) x)))
    (macro-form FACTORIAL
      `(~lambdachr x ~separator
        (YCOMB (~lambdachr f n ~separator (COND (ZERO? n) ONE (PROD (f (PRED n)) n))) x)))
    ; F/f fibonacci function
    ;(macro-form FIBONACCI `(~lambdachr x ~separator (SELF (~lambdachr f n , (COND (LEQ? n TWO) ONE (SUM (f f (PRED n)) (f f (PRED (PRED n)))))) x)))
    (macro-form FIBONACCI
      `(~lambdachr x ~separator
        (YCOMB (~lambdachr f n ~separator (COND (LEQ? n TWO) ONE (SUM (f (PRED n)) (f (PRED (PRED n)))))) x)))))
