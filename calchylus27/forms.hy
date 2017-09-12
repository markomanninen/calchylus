; constant, doesn't take any arguments, will return given "static" value
(defmacro CONST  [&rest args] `(L , ~@args))
; identity, return passed argument as it is
(defmacro IDENT  [&rest args] `(L a , a ~@args))
; booleans
; true, take two arguments, return the first and omit the second
(defmacro TRUE   [&rest args] `(L a b , a ~@args))
; false, take two arguments, return the second and omit the first
(defmacro FALSE  [&rest args] `(L a b , b ~@args))
; replace next argument with false, take one argument, but return a static FALSE value
; if two arguments are given, then FALSE will return the latter, in a way this is similar
; giving two arguments to FALSE
;(defmacro REPLACE [&rest args] `(L a , FALSE ~@args))
(defmacro REPLACE [&rest args] `(L a , (L a b , b) ~@args))
; omit next
(defmacro OMIT   [&rest args] `(L a , b ~@args))
; lists
(defmacro NIL    [&rest args] `(FALSE ~@args))
(defmacro PAIR   [&rest args] `(L a b s , (s a b) ~@args))
(defmacro FIRST  [&rest args] `(TRUE ~@args))
(defmacro SECOND [&rest args] `(FALSE ~@args))
(defmacro HEAD   [&rest args] `(L s , (s TRUE) ~@args))
(defmacro TAIL   [&rest args] `(L s , (s FALSE) ~@args))
(defmacro NIL?   [&rest args] `(L s , (s FALSE TRUE) ~@args))
; zero things
(defmacro ZERO  [&rest args] `(FALSE ~@args))
;(defmacro ZERO? [&rest args] `(L f , (f (L x , FALSE) TRUE) ~@args))
;(defmacro ZERO? [&rest args] `(L f , (f REPLACE TRUE) ~@args))
(defmacro ZERO? [&rest args] `(L f , (f (L a , (L a b , b)) (L a b , a)) ~@args))
; logic
(defmacro COND  [&rest args] `(L p a b , (p a b) ~@args))
(defmacro AND   [&rest args] `(L a b , (a b FALSE) ~@args))
;(defmacro AND2  [&rest args] `(L a b , (a b a) ~@args))
(defmacro OR    [&rest args] `(L a b , (a TRUE b) ~@args))
;(defmacro OR2   [&rest args] `(L a b , (a a b) ~@args))
(defmacro NOT   [&rest args] `(L p , (p FALSE TRUE) ~@args))
;(defmacro NOT2  [&rest args] `(L p a b , (p b a) ~@args))?
(defmacro XOR   [&rest args] `(L a b , (a (NOT b) b) ~@args))
; positive "church" numerals
;(defmacro ONE   [&rest args] `(L x y , (x y) ~@args))
(defmacro ONE   [&rest args] `(NUM 1 ~@args))
;(defmacro TWO   [&rest args] `(L x y , (x (x y)) ~@args))
(defmacro TWO   [&rest args] `(NUM 2 ~@args))
;(defmacro THREE [&rest args] `(L x y , (x (x (x y))) ~@args))
(defmacro THREE [&rest args] `(NUM 3 ~@args))
;(defmacro FOUR  [&rest args] `(L x y , (x (x (x (x y)))) ~@args))
(defmacro FOUR  [&rest args] `(NUM 4 ~@args))
;(defmacro FIVE  [&rest args] `(L x y , (x (x (x (x (x y))))) ~@args))
(defmacro FIVE  [&rest args] `(NUM 5 ~@args))
;(defmacro SIX   [&rest args] `(L x y , (x (x (x (x (x (x y)))))) ~@args))
(defmacro SIX   [&rest args] `(NUM 6 ~@args))
;(defmacro SEVEN [&rest args] `(L x y , (x (x (x (x (x (x (x y))))))) ~@args))
(defmacro SEVEN [&rest args] `(NUM 7 ~@args))
;(defmacro EIGHT [&rest args] `(L x y , (x (x (x (x (x (x (x (x y)))))))) ~@args))
(defmacro EIGHT [&rest args] `(NUM 8 ~@args))
;(defmacro NINE  [&rest args] `(L x y , (x (x (x (x (x (x (x (x (x y))))))))) ~@args))
(defmacro NINE  [&rest args] `(NUM 9 ~@args))
;(defmacro TEN   [&rest args] `(L x y , (x (x (x (x (x (x (x (x (x (x y)))))))))) ~@args))
(defmacro TEN   [&rest args] `(NUM 10 ~@args))
; arithmetics
; add one, increase by one
(defmacro ADD   [&rest args] `(L n x y , (n x (x y)) ~@args))
; next / successor = INC = ADD
(defmacro SUCC  [&rest args] `(L n x y , (x (n x y)) ~@args))
; previous / predecessor = DEC
;(defmacro PRED  [&rest args] `(L n x y , (n (L g h , (h (g x))) (L x , y) (L u , u)) ~@args))
;(defmacro PRED  [&rest args] `(L n x y , (n (L g h , (h (g x))) (L x , y) IDENT) ~@args))
(defmacro PRED  [&rest args] `(L n x y , (n (L g h , (h (g x))) (L x , y) (L a , a)) ~@args))
; substract two numbers from each other
;(defmacro SUB   [&rest args] `(L k , (k (L p u , (u (ADD (p TRUE)) (p TRUE))) (L u , u ZERO ZERO)) ~(first args) FALSE ~@(rest args)))
(defmacro SUB   [&rest args] `(L m n , (m PRED n) ~@args))
; sum two numbers together
;(defmacro SUM  [&rest args] `(L m n , (m SUCC n) ~@args))
(defmacro SUM   [&rest args] `(L m n x y , (m x (n x y)) ~@args))
; multiplication, product of two numbers
(defmacro PROD  [&rest args] `(L m n x y , (m (n x) y) ~@args))
; exponent x^y
(defmacro EXP   [&rest args] `(L m n x y , (n m x y) ~@args))
; lesser or equal
(defmacro LEQ?  [&rest args] `(L m n , (ZERO? (n PRED m)) ~@args))
; equal
(defmacro EQ?   [&rest args] `(L m n , (AND (LEQ? m n) (LEQ? n m)) ~@args))
; combinators / applications
(defmacro SELF  [&rest args] `(L f x , (f f x) ~@args))
; TODO!
(defmacro YCOMB [&rest args] `(L f , (L x , (f (f x)) (L x , (f (f x)))) ~@args))
; some math functions
; ∑
(defmacro SUMMATION [&rest args] `(L x , (SELF (L f n , (COND (ZERO? n) ZERO (SUM n (f f (PRED n))))) x) ~@args))
; ∏ TODO: number greater than THREE will mess up the evaluation
; Also if number (n) is give first at: (PROD n (f f (PRED n))) it will mess up the thing
(defmacro FACTORIAL [&rest args] `(L x , (SELF (L f n , (COND (ZERO? n) ONE (PROD (f f (PRED n)) n))) x) ~@args))
; F TODO: implement
(defmacro FIBONACCI [])
