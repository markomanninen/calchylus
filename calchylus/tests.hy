(import calchylus [*])
(require calchylus [*])
; not lambda expression
(assert (= (, 'x) (, 'x)))
; no body lambda expression
(assert (= (L ,) None))
; constant
(assert (= (L , c) 'c))
; identity, without argument
(assert (= (L x , x) "(L x , x)"))
; identity, with argument
(assert (= (L x , x y) 'y))
; select first, without arguments
(assert (= (L x y , x) "(L x y , x)"))
; select second, without arguments
(assert (= (L x y , y) "(L x y , y)"))
; select first, with arguments
(assert (= (L x y , x 1 0) 1))
; select second, with arguments
(assert (= (L x y , y 1 0) 0))
; function without arguments
(assert (= (L x y z , (x y z)) "(L x y z , (x y z))"))
; nested functions and arguments
(assert (= (L x , (L y , (L z , (z x y) l) k) j) "(l j k)"))
; nested functions, flatten arguments
(assert (= (L x , (L y , (L z , (z x y))) j k l) "(l j k)"))
; flatten functions and arguments
(assert (= (L x y z , (z x y) j k l) "(l j k)"))
; application without arguments
(assert (= (L , ((L x y z , (x y z)))) "(L x y z , (x y z))"))
; application with arguments
(assert (= (L , ((L x y z , (x y z)) a b c)) "(a b c)"))
; free argument
(assert (= (L x , x y z) "(y z)"))
; nested
(assert (= (L , ((L x y z , (x y z) x y z) a b c) 1 2 3) "((x y z) a b c 1 2 3)"))

; variable renaming should give right result
; instead of first substituting x with y, and then both y's with z, resulting (2 2)
; this test should give (y z) because y is bound to x and x only. latter y should not replace it
(assert (= (L x y , (x y) y z) "(y z)"))
; same should apply to deeper values too
(assert (= (L x y , (x y) (y (y z)) z) "((y (y z)) z)"))

; special macros for main lambda terms / forms
; constant
(assert (= (CONST x) 'x))
; identity, without arguments
(assert (= (IDENT) "(L a , a)"))
; identity, with arguments
(assert (= (IDENT 1) 1))
; identity, nested
(assert (= (IDENT (IDENT 1)) 1))
; boolean macros
(assert (= (, (TRUE) (TRUE 1 0)
              (FALSE) (FALSE 1 0))
           (, "(L a b , a)" 1
              "(L a b , b)" 0)))

; lists
(assert (= (NIL) "(L a b , b)"))
; pair constructor
(assert (= (PAIR TRUE NIL) "(s TRUE NIL)"))
; selector
(assert (= (PAIR TRUE NIL FIRST) 'TRUE))
; head and tail
(assert (= (, (HEAD (PAIR TRUE NIL))
              (TAIL (PAIR TRUE NIL)))
           (, 'TRUE 'NIL)))
; is nil, simple
(assert (= (, (NIL? NIL) (NIL? TRUE)) (, 'TRUE 'FALSE)))
; is nil, head and tail
(assert (= (, (NIL? (HEAD (PAIR TRUE NIL)))
              (NIL? (TAIL (PAIR TRUE NIL))))
           (, 'FALSE 'TRUE)))
; nested pairs and heads and tails
(assert (=
   (, (HEAD (PAIR TRUE (PAIR TRUE NIL)))
      (HEAD (TAIL (PAIR TRUE (PAIR TRUE NIL))))
      (TAIL (TAIL (PAIR TRUE (PAIR TRUE NIL)))))
   (, 'TRUE 'TRUE 'NIL)))
; nil? for nested pairs
(assert (=
  (, (NIL? (TAIL (TAIL (PAIR TRUE (PAIR TRUE NIL)))))
     (NIL? (HEAD (TAIL (PAIR TRUE (PAIR TRUE NIL))))))
  (, 'TRUE 'FALSE)))
; selectors for pairs
(assert (=  (, (PAIR (PAIR TRUE FALSE FIRST) NIL FIRST)
               (PAIR (PAIR TRUE FALSE SECOND) NIL FIRST)
               (PAIR (PAIR TRUE FALSE FIRST) NIL SECOND)
               (PAIR (PAIR TRUE FALSE SECOND) NIL SECOND)
               (PAIR TRUE (PAIR TRUE NIL FIRST) FIRST)
               (PAIR TRUE (PAIR TRUE NIL SECOND) FIRST)
               (PAIR TRUE (PAIR TRUE NIL FIRST) SECOND)
               (PAIR TRUE (PAIR TRUE NIL SECOND) SECOND))
            (, 'TRUE 'FALSE 'NIL 'NIL
               'TRUE 'TRUE 'TRUE 'NIL)))
; simple condition
(assert (=
    (, (COND TRUE TRUE FALSE)
       (COND FALSE TRUE FALSE))
    (, 'TRUE 'FALSE)))
; number nil? conditions
(assert (=
    (, (COND (NIL? (NUM 0)) TRUE FALSE)
       (COND (NIL? (NUM 1)) TRUE FALSE)
       (COND (NIL? (NUM 10)) TRUE FALSE))
    (, 'TRUE 'FALSE 'FALSE)))
; nil tail/head pair condition
(assert (=
    (, (COND (NIL? (TAIL (PAIR (NUM 1) NIL))) TRUE FALSE)
       (COND (NIL? (HEAD (PAIR (NUM 1) NIL))) TRUE FALSE))
    (, 'TRUE 'FALSE)))

; church numeral general generator, without arguments
(assert (= (NUM 3) "(L x y , (x (x (x y))))"))
; church numeral, general generator, with arguments
(assert (= (NUM 3 m n) "(m (m (m n)))"))
; church numeral, zero
(assert (= (ZERO) "(L a b , b)"))
; church numeral, zero with arguments
(assert (= (ZERO a b) 'b))
;(assert (= (, (ZERO) (ZERO a b) (ONE) #𝜆(TWO x y) (THREE m n))
           ;('(L a b , b)', 'b', '(L x y , (x y))', '(x (x y))', '(m (m (m n)))')
;           (, "(L a b , b)" "b", "(L x y , (x y))" "(x (x y))" "(m (m (m n)))")))

; and tests
(assert (=
  (, (AND TRUE TRUE) (AND TRUE FALSE)
     (AND FALSE TRUE) (AND FALSE FALSE))
  (, 'TRUE 'FALSE 'FALSE 'FALSE)))
; or tests
(assert (=
  (, (OR TRUE TRUE) (OR TRUE FALSE)
     (OR FALSE TRUE) (OR FALSE FALSE))
  (, 'TRUE 'TRUE 'TRUE 'FALSE)))
; not tests
(assert (= (, (NOT TRUE) (NOT FALSE)) (, 'FALSE 'TRUE)))
; xor tests
(assert (=
  (, (XOR TRUE TRUE) (XOR TRUE FALSE)
     (XOR FALSE TRUE) (XOR FALSE FALSE))
  (, 'FALSE 'TRUE 'TRUE 'FALSE)))
; logic condition
(assert (= (COND (AND (NOT (XOR FALSE FALSE)) (OR TRUE FALSE)) TRUE FALSE) 'TRUE))
; eval read str
(assert (= (eval (read-str "(TRUE)")) "(L a b , a)"))
; less or equal
(assert (= (, (LEQ? ONE TWO) (LEQ? TWO ONE)  (LEQ? ONE ONE)
           (, 'TRUE 'FALSE 'TRUE))))
; equal
(assert (= (, (EQ? ONE TWO) (EQ? TWO ONE)  (EQ? ONE ONE)
           (, 'FALSE 'FALSE 'TRUE))))
; math operations
; next, inc, successive
(assert (= #Ÿ(SUCC ONE) "(x (x y))"))
; add is same as succ
(assert (= (ADD ONE) "(x (x y))"))
; infix notation
(assert (= (ONE ADD ONE ADD ONE) "(x (x (x y)))"))
; previous, dec, predecessive
(assert (= (PRED THREE) "(x (x y))"))
; previous, dec, predecessor, with arguments
(assert (= (PRED THREE a b) "(a (a b))"))
; nested predecessor
(assert (= (PRED (PRED (PRED FOUR))) "(x y)"))
; previous + next is same
(assert (= #Ÿ(SUCC (PRED TWO)) "(x (x y))"))
; previous + next is same for zero
(assert (= (PRED (SUCC ZERO)) 'y))
; but previous + next is one for zero!
(assert (= #Ÿ(SUCC (PRED ZERO)) "(x y)"))
; sum two values
(assert (= #Ÿ(SUM TWO TWO) "(x (x (x (x y))))"))
; substract two x from y
(assert (= (, (SUB ONE TWO) (SUB ONE ONE) (SUB TWO ONE))
           (, "(x y)" 'y 'y)))
(assert (= (, #Ÿ(EXP TWO TWO) #Ÿ(EXP TEN ZERO) #Ÿ(EXP ZERO ZERO))
           (, "(x (x (x (x y))))" "(x y)" "(x y)")))
(assert (= (, #Ÿ(PROD ZERO ONE a b) #Ÿ(PROD ONE ONE a b) #Ÿ(PROD TWO TWO a b))
           (, 'b "(a b)" "(a (a (a (a b))))")))
; self application
(assert (= (SELF (L x , x) 1) 1))
; self application, fixed point
;count down to zero
(assert (= (SELF (L f n , (COND (ZERO? n) ZERO (f f (PRED n)))) THREE) 'ZERO))
; count down to one with lesser or equal comparison
(assert (= (SELF (L f n , (COND (LEQ? n ONE) n (f f (PRED n)))) FOUR) "(x y)"))
; count down to one with equal comparison
(assert (= (SELF (L f n , (COND (EQ? n ONE) n (f f (PRED n)))) FOUR) "(x y)"))

; summation sequence, with plain number
(assert (= (SUMMATION (L x y , (x (x (x y))))) "(x (x (x (x (x (x y))))))"))
; summation sequence, with number macro form
(assert (= (SUMMATION THREE) "(x (x (x (x (x (x y))))))"))
; product sequence, with plain number
(assert (= (FACTORIAL (L x y , (x (x (x y))))) "(x (x (x (x (x (x y))))))"))
; product sequence, with number macro form
(assert (= (FACTORIAL THREE) "(x (x (x (x (x (x y))))))"))

; self application recursive loop
(setv result (L x , (x x) (L x , (x x))))
(assert (none? result))
