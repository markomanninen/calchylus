#!/usr/bin/python3
; Lambda Calculus custom macros
(defmacro init-macros [lambdachr separator]

  `(do

    (eval-and-compile

      (setv ; TODO: these could be constructed by some lambda-term-generator macro
          forms ["CONST" "IDENT" "LET" "LETS" "TRUE" "FALSE" "REPLACE" "OMIT"
                 "PAIR" "HEAD" "TAIL" "FIRST" "SECOND" "NIL" "NIL?" "is_NIL"
                 "ZERO" "ZERO?" "is_ZERO" "NUM"
                 "ONE" "TWO" "THREE" "FOUR" "FIVE" "SIX" "SEVEN" "EIGHT" "NINE" "TEN"
                 "COND" "AND" "OR" "NOT" "XOR"
                 "ADD" "PRED" "SUCC" "EXP" "SUM" "PROD" "SUB"
                 "EQ?" "is_EQ" "LEQ?" "is_LEQ" "SELF" "YCOMB"
                 "SUMMATION" "FACTORIAL" "FIBONACCI"])

     ; is expr(ession) a suitable macro form?
     (defn macro-form? [expr] (and (symbol? expr) (in expr forms)))

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

    ; unnamed constant, doesn't take any arguments, will return given "static" value
    (defmacro CONST  [&rest args] `(~lambdachr ~separator ~@args))
		; named constant, doesn't take any arguments, will return given "static" value
		(defmacro LET    [x &rest args] `(~lambdachr ~x ~separator ~@args))
		; named constant, doesn't take any arguments, will return given "static" value
		(defmacro LETS   [&rest args] `(~lambdachr ~x ~separator ~@args))
    ; identity, return passed argument as it is
    (defmacro IDENT  [&rest args] `(~lambdachr a ~separator a ~@args))
    ; booleans
    ; true, take two arguments, return the first and omit the second
    (defmacro TRUE   [&rest args] `(~lambdachr a b ~separator a ~@args))
    ; false, take two arguments, return the second and omit the first
    (defmacro FALSE  [&rest args] `(~lambdachr a b ~separator b ~@args))
    ; replace next argument with false, take one argument, but return a static FALSE value
    ; if two arguments are given, then FALSE will return the latter, in a way this is similar
    ; giving two arguments to FALSE
    (defmacro REPLACE [&rest args] `(~lambdachr a ~separator FALSE ~@args))
    ;(defmacro REPLACE [&rest args] `(L a , (L a b , b) ~@args))
    ; omit next
    (defmacro OMIT   [&rest args] `(~lambdachr a ~separator b ~@args))
    ; lists
    (defmacro NIL    [&rest args] `(FALSE ~@args))
    (defmacro PAIR   [&rest args] `(~lambdachr a b s ~separator (s a b) ~@args))
    (defmacro FIRST  [&rest args] `(TRUE ~@args))
    (defmacro SECOND [&rest args] `(FALSE ~@args))
    (defmacro HEAD   [&rest args] `(~lambdachr s ~separator (s TRUE) ~@args))
    (defmacro TAIL   [&rest args] `(~lambdachr s ~separator (s FALSE) ~@args))
    (defmacro NIL?   [&rest args] `(~lambdachr s ~separator (s FALSE TRUE) ~@args))
    ; zero things
    (defmacro ZERO  [&rest args] `(FALSE ~@args))
    ;(defmacro ZERO? [&rest args] `(~lambdachr n , (n (L a , (L a b , b)) (L a b , a)) ~@args))
    (defmacro ZERO? [&rest args] `(~lambdachr n ~separator (n REPLACE TRUE) ~@args))
    ; logic
    (defmacro COND  [&rest args] `(~lambdachr p a b ~separator (p a b) ~@args))
    (defmacro AND   [&rest args] `(~lambdachr a b ~separator (a b FALSE) ~@args))
    ;(defmacro AND2  [&rest args] `(~lambdachr a b , (a b a) ~@args))
    (defmacro OR    [&rest args] `(~lambdachr a b ~separator (a TRUE b) ~@args))
    ;(defmacro OR2   [&rest args] `(~lambdachr a b , (a a b) ~@args))
    (defmacro NOT   [&rest args] `(~lambdachr p ~separator (p FALSE TRUE) ~@args))
    ;(defmacro NOT2  [&rest args] `(~lambdachr p a b , (p b a) ~@args))?
    (defmacro XOR   [&rest args] `(~lambdachr a b ~separator (a (NOT b) b) ~@args))
    ; church number generator: (NUM 3) ; -> (L x y , (x (x (x y))))
    ; launch application: (NUM 3 a b) ; -> (a (a (a b)))
    ; (defmacro NUM [n &rest args]
    ;   `(L x y , ~(read_str (N n 'x 'y)) ~@args))
    ; Tuukka Turto (@tuturto), 2017
    (defmacro NUM [n &rest args]
      (if (< n 0) (macro-error n (% "For NUM n needs to be zero or more, was: %s" n))
          (= n 0) `(~lambdachr x y ~separator y ~@args)
          (> n 0) (do (setv expr `(x y))
                      (for [i (range (dec n))]
                        (setv expr `(x ~expr)))
                      `(~lambdachr x y ~separator ~expr ~@args))))
    ; positive "church" numerals
    ;(defmacro ONE   [&rest args] `(L x y , (x y) ~@args))
    (defmacro ONE   [&rest args] `(NUM 1 ~@args))
    ;(defmacro TWO   [&rest args] `(L x y , (x (x y)) ~@args))
    (defmacro TWO   [&rest args] `(NUM 2 ~@args))
    ;(defmacro THREE [&rest args] `(L x y , (x (x (x y))) ~@args))
    (defmacro THREE [&rest args] `(NUM 3 ~@args))
    ;(defmacro FOUR  [&rest args] `(L x y , (x (x (x (x y)))) ~@args))
    (defmacro FOUR  [&rest args] `(NUM 4 ~@args))
    ;(defmacro FIVE  [&rest args] `(L x y , (x (x (x (x (x y))))) ~@args))
    (defmacro FIVE  [&rest args] `(NUM 5 ~@args))
    ;(defmacro SIX   [&rest args] `(L x y , (x (x (x (x (x (x y)))))) ~@args))
    (defmacro SIX   [&rest args] `(NUM 6 ~@args))
    ;(defmacro SEVEN [&rest args] `(L x y , (x (x (x (x (x (x (x y))))))) ~@args))
    (defmacro SEVEN [&rest args] `(NUM 7 ~@args))
    ;(defmacro EIGHT [&rest args] `(L x y , (x (x (x (x (x (x (x (x y)))))))) ~@args))
    (defmacro EIGHT [&rest args] `(NUM 8 ~@args))
    ;(defmacro NINE  [&rest args] `(L x y , (x (x (x (x (x (x (x (x (x y))))))))) ~@args))
    (defmacro NINE  [&rest args] `(NUM 9 ~@args))
    ;(defmacro TEN   [&rest args] `(L x y , (x (x (x (x (x (x (x (x (x (x y)))))))))) ~@args))
    (defmacro TEN   [&rest args] `(NUM 10 ~@args))
    ; arithmetics
    ; add one, increase by one
    (defmacro ADD   [&rest args] `(~lambdachr n x y ~separator (n x (x y)) ~@args))
    ; next / successor = INC = ADD
    (defmacro SUCC  [&rest args] `(~lambdachr n x y ~separator (x (n x y)) ~@args))
    ; previous / predecessor = DEC
    ;(defmacro PRED  [&rest args] `(L n x y , (n (L g h , (h (g x))) (L x , y) (L u , u)) ~@args))
    (defmacro PRED  [&rest args] `(~lambdachr n x y ~separator (n (~lambdachr g h ~separator (h (g x))) (~lambdachr x ~separator y) IDENT) ~@args))
    ; substract two numbers from each other
    (defmacro SUB   [&rest args] `(~lambdachr m n ~separator (m PRED n) ~@args))
    ; sum two numbers together
    ;(defmacro SUM  [&rest args] `(L m n , (m SUCC n) ~@args))
    (defmacro SUM   [&rest args] `(~lambdachr m n x y ~separator (m x (n x y)) ~@args))
    ; multiplication, product of two numbers
    (defmacro PROD  [&rest args] `(~lambdachr m n x y ~separator (m (n x) y) ~@args))
    ; exponent x^y
    (defmacro EXP   [&rest args] `(~lambdachr m n x y ~separator (n m x y) ~@args))
    ; lesser or equal
    (defmacro LEQ?  [&rest args] `(~lambdachr m n ~separator (ZERO? (n PRED m)) ~@args))
    ; equal
    (defmacro EQ?   [&rest args] `(~lambdachr m n ~separator (AND (LEQ? m n) (LEQ? n m)) ~@args))
    ; self application
    (defmacro SELF  [&rest args] `(~lambdachr f x ~separator (f f x) ~@args))
    ; Y combinator
    (defmacro YCOMB [&rest args] `(~lambdachr f ~separator (~lambdachr x ~separator (f (x x)) (~lambdachr x ~separator (f (x x)))) ~@args))
    ; some math functions
    ; summation function
    ;(defmacro SUMMATION [&rest args]
    ;  `(~lambdachr x ~separator (SELF (~lambdachr f n , (COND (ZERO? n) ZERO (SUM n (f f (PRED n))))) x) ~@args))
    (defmacro SUMMATION [&rest args]
      `(~lambdachr x ~separator
        (YCOMB (~lambdachr f n ~separator (COND (ZERO? n) ZERO (SUM n (f (PRED n))))) x) ~@args))
    ; factorial function
    ;(defmacro FACTORIAL [&rest args]
    ;  `(~lambdachr x ~separator (SELF (~lambdachr f n , (COND (ZERO? n) ONE (PROD n (f f (PRED n))))) x) ~@args))
    (defmacro FACTORIAL [&rest args]
      `(~lambdachr x ~separator
        (YCOMB (~lambdachr f n ~separator (COND (ZERO? n) ONE (PROD (f (PRED n)) n))) x) ~@args))
    ; F/f fibonacci function
    ;(defmacro FIBONACCI [&rest args]
    ;  `(~lambdachr x ~separator (SELF (~lambdachr f n , (COND (ZERO? n) ONE (SUM (f f (PRED n)) (f f (PRED (PRED n)))))) x) ~@args))
    (defmacro FIBONACCI [&rest args]
      `(~lambdachr x ~separator
        (YCOMB (~lambdachr f n ~separator (COND (ZERO? n) ONE (SUM (f (PRED n)) (f (PRED (PRED n)))))) x) ~@args))))
