; Copyright (c) Marko Manninen (@markomanninen), 2017
;----------------------------------------------
; Lambda Calchylus evaluator for Hy
;
; Source:
; https://github.com/markomanninen/calchylus/
;
; Install:
; $ pip install calchylus
;
; Import macros:
; (require (calchylus.calchylus (*)))
; (require (calchylus.forms (*)))
;
; Usage:
;
; Author: Marko Manninen <elonmedia@gmail.com>
; Copyright: Marko Manninen (c) 2017
; Licence: MIT
;----------------------------------------------
(import hy)
(eval-and-compile
  (setv ; lambda expression macro name
        lambdachr 'L
        ; lambda expression argument and body separator
        separator ',
        ; TODO: these could be constructed by some lambda-term-generator macro
        forms ["CONST" "IDENT" "TRUE" "FALSE" "REPLACE" "OMIT"
               "PAIR" "HEAD" "TAIL" "FIRST" "SECOND" "NIL" "NIL?" "is_NIL"
               "ZERO" "ZERO?" "is_ZERO" "NUM"
               "ONE" "TWO" "THREE" "FOUR" "FIVE" "SIX" "SEVEN" "EIGHT" "NINE" "TEN"
               "COND" "AND" "OR" "NOT" "XOR"
               "ADD" "PRED" "SUCC" "EXP" "SUM" "PROD" "SUB"
               "EQ?" "is_EQ" "LEQ?" "is_LEQ" "SELF" "YCOMB"
               "SUMMATION" "FACTORIAL" "FIBONACCI"])
  ; is gensym?
  (defn gensym? [x] (or (= (first x) ":") (= (first x) "\ufdd0")))
  ; pretty print utility
  (defn pprint [expr]
    (if-not (coll? expr) (str expr)
      (% "(%s)" (.join " " (list-comp (pprint x) [x expr])))))
  ; safe get index for the first occurrence of the x
  ; (index (, 1 2) 0) ; -> -1
  (defn index [l x]
    (try (.index l x)
         (except [e [ValueError AttributeError]]
           -1)))
  ; extend and return list instead of .extend list in place
  ; provide a as a copy (.copy a) in cases where strange
  ; recursive error behaviour is occurring
  (defn extend [a &rest b]
    (for [c b] (.extend a c)) a)
  ; church number body generator helper (N 3 m n) ; -> (m (m (m n)))
  ;(defn N [n x y]
  ;  (if (zero? n) y
  ;      (% "(%s %s%s" (, x  (N (dec n) x y) ")"))))
  ; is expr(ession) a suitable macro form?
  (defn macro-form? [expr] (and (symbol? expr) (in expr forms)))
  ; is expr(ession) or the firs sub expression a suitable macro form
  (defn form? [expr]
    (or (macro-form? expr)
        (and (coll? expr) (macro-form? (first expr)))))
  ; is expr(ession) a lambda expression i.e. starts with lambdachr: (L ...)?
  (defn L? [expr]
    (and (coll? expr)
         (symbol? (first expr))
         (= (first expr) lambdachr)))
  ; make lambda expression from body and other parts
  (defn build-lambda [body &optional [args []] [vals []]]
    (hy.HyExpression (extend [lambdachr] args [separator] body vals)))
  ; substitute lambda sub expr(ession). it requires special handler
  ; because of variable shadowing and not-coll body
  (defn substitute* [a b expr] ; (print 's2 a b expr)
    (setv p (extract-parts expr)
          args (get p "args")
          body (get p "body")
          vals (get p "vals")
          free (drop (len args) vals))
    ; first substitute a to b in possible values
    (if-not (empty? vals) (setv vals (substitute a b vals)))
    ; shadow arguments, don't substitute if a is in new arguments
    (if (in a args) expr
        (build-lambda
          ; only coll body can be iterated
          (if (coll? body)
              [(substitute a b body)]
              [(if (= a body) b body)])
          args vals)))
  ; substitute a with b in expr
  (defn substitute [a b expr] ; (print 's1 a b expr)
    (if (coll? expr)
        ; if e is lambda expression, call special handler
        (if (L? expr) (substitute* a b expr)
            ; else substitute all sub expressions
            ((type expr) (genexpr (substitute a b e) [e expr])))
        ; return substitute (b), if match is found
        (if (= a expr) b expr)))
  ; shift arguments inside functions in application expressions
  ; ((L x , x) a b) -> (L x , x a b) -> (a b)
  ; ((TRUE) TRUE FALSE) -> (TRUE TRUE FALSE) -> TRUE
  ; this is required to convert and evaluate substituted function forms
  ; (L x y z , ((x) y z) TRUE a b) -> ((TRUE) a b) -> (TRUE a b) -> a
  (defn shift-arguments [expr]
    (if-not (coll? expr) expr
      (do
        (setv f (first expr))
        ;(print 'shift-arguments-1 (pprint expr))
        (if (or (L? f) (and (coll? f) (form? f)))
            (setv expr (extend ((type f) (.copy f)) (tuple (rest expr)))))
        ;(print 'shift-arguments-2 (pprint expr))
        ((type expr) (genexpr (shift-arguments e) [e expr])))))
  ; alpha renaming / compile argument names if name collision occurs
  (defn name-collision* [args expr]
    (if (coll? expr)
        (do (setv p False)
            (for [e expr]
              (if (name-collision* args e)
                (do (setv p True)
                    (break)))) p)
        (in expr args)))
  ; alpha renaming / compile argument names if name collision occurs
  (defn name-collision [vals args e]
    (setv p False)
    (for [e vals]
      (if (coll? e)
          (if (name-collision* args e)
              (do (setv p True)
                  (break)))
          (if (in e args)
              (do (setv p True)
                  (break))))) p)
  ; get lambda expression parts
  ; body: (x x), args: (x), values (y), and params: ([x y])
  (defn extract-parts [expr]
    (setv idx (index expr separator)
          ; expression might start with L: (L x , x ...)
          ; or without L: (x , x ...)
          ldx (if (L? expr) 1 0))
    ; if separator index is less than expected
    ; lambda expression is possibly malformed, just return the expression
    (if (< idx ldx) {"body" (if (coll? expr) (first expr) expr) "args" [] "vals" [] "params" []}
        (do
          (setv body (cut expr (inc idx))
                bodyb (first body)
                args (cut expr ldx idx)
                ; args 2 for alpha conversion
                args2 (tuple (map (fn [x] (if (gensym? (name x)) x (gensym x))) args))
                vals (tuple (rest body)))
          ; alpha conversion / variable renaming
          ; this is a brute force method. name collision should not occur because
          ; all variable names are changed and replaced. other way around would be to find out,
          ; if there are name collisions, and replace only those variable names.
          ; this might however require several loops and argument carrying for each variable and expression...
          ;(if (name-collision vals args bodyb)
          (for [[a b] (zip args args2)]
            (setv bodyb (substitute a b bodyb)))
          ; return body, args, vals, and key-value pairs based on args-vals
          {"body" bodyb "args" args2 "vals" vals "params" (zip args2 vals)})))
  ; handle macro forms extra
  (defn expand-form* [body]
    (if-not (coll? body) body
        (if (macro-form? (first body))
            (eval body)
            ((type body) (genexpr (expand-form* e) [e body])))))
  ; helper function to expand form that has custom lambda macros / forms
  ; used after everything else for the lambda form evaluation is done
  (defn expand-forms [expr]
    (if-not (none? expr)
      (if (or (symbol? expr) (coll? expr) (iterable? expr))
          (pprint (expand-form* (read-str expr)))
          expr)))
  ; are evaluated lambda forms same and there are no free values
  ; inside the form. because, if there are, we can still reduce the form
  (defn B? [body bodyx]
    (setv p (extract-parts body))
    (and (empty? (get p "vals")) (= body bodyx)))
  ; convert generated machine variable names to normal forms
  (defn human-readable [expr]
    (if (coll? expr)
        (genexpr (human-readable e) [e expr])
        (if (gensym? (name expr))
            (do
               (setv idx (inc (index (name expr) ":")))
               (cut (name expr) idx (inc idx)))
            expr)))
  ; beta reduction helper
  (defn beta-reduction* [expr]
    (setv p (extract-parts expr)
          body (get p "body")
          bodyx body
          ; rest of the free arguments that are not in params
          free (list (drop (len (get p "args")) (get p "vals"))))
    ; substitute bound arguments
    ;(print 'before-substitute-body: (pprint body) (get p "params"))
    (for [[a b] (get p "params")]
      (setv body (substitute a b body)))
    ;(print 'after-substitute-body: (pprint body))
    ; shift application arguments
    (if (coll? body) (setv body (shift-arguments body)))
    ;(print 'after-shift-arguments: (pprint body))
    ; extend body
    (if (and (L? body) (not (empty? free)))
        (setv body (extend body free)))
    ;(print 'after-extend-body: (pprint body) (not (coll? body)) (= body bodyx))
    (if (form? body)
        (if (coll? body)
            (eval (if (empty? free) body (extend body free)))
            (if (empty? free) (human-readable body)
                (eval (hy.HyExpression (extend [body] free)))))
        (if (or (not (coll? body)) (B? body bodyx))
            (if (empty? (get p "args")) (beta-reduction body)
                (if (empty? (get p "vals")) (human-readable expr)
                    (if (empty? free) (human-readable body)
                        (human-readable (extend [body] free)))))
            (if (L? body)
                (beta-reduction body)
                ((type body) (genexpr (beta-reduction x) [x (if (empty? free) body (extend [body] free))]))))))
  ; main form beta / eta reduction steps
  (defn beta-reduction [expr]
    ;(print)
    ;(print 'beta-reduction: (pprint expr))
    ; TODO: should we try to shift argument before everything else is done?
    ;(if (and (coll? expr)) (setv expr (shift-arguments expr)))
    ; if the form (expr) is not lambda for i.e. starting with L
    ; we still want to seek if there are sub lambda expressions
    ; (x (x (L x , x y))) should return (x (x y))
    (if (L? expr)
        (beta-reduction* expr)
        (if (coll? expr)
            ((type expr) (genexpr (beta-reduction x) [x expr]))
            (human-readable expr))))
  ; reformulate expression, because by using L macro, L is naturally left out from the expression
  ; beta-reduction functions on the other hand relys on the L in the beginning of the expression!
  ; then pass parameters and possibly expand macro form later
  (defn evaluate-lambda-expression [expr]
    (setv expr (beta-reduction (hy.HyExpression (extend [lambdachr] expr))))
    (if (or (coll? expr) (symbol? expr))
        ; symbols and expression should be pretty "printed"
        (pprint expr)
        ; numbers for example get passed as they are
        ; this is not exactly included on lambda calculus but just a way
        ; to keep data types existing for hy and later usage
        expr)))

; shorthand to evaluate lambda form and expand the result
; it still has some cases, where expansion is not working as expected,
; for example: #Ÿ(SUM (SUM ONE ONE) ZERO) ; -> (x (x (ZERO x y)))
(defsharp Ÿ [expr] `(expand-forms (L , ~expr)))

; lambda expression main macro
(defmacro L [&rest expr]
  ; try except is not working alone on macro body!
  (if-not (empty? expr)
    (try
      (evaluate-lambda-expression expr)
      (except [e [RecursionError hy.errors.HyMacroExpansionError]]
        (print (str e) "for lambda expression:" (pprint expr))))))

; church number generator: (NUM 3) ; -> (L x y , (x (x (x y))))
; launch application: (NUM 3 a b) ; -> (a (a (a b)))
;(defmacro NUM [n &rest args]
;  `(L x y , ~(read_str (N n 'x 'y)) ~@args))
; Tuukka Turto (@tuturto), 2017
(defmacro NUM [n &rest args]
  (if (< n 0) (macro-error n (% "For NUM n needs to be zero or more, was: %s" n))
      (= n 0) `(L x y , y ~@args)
      (> n 0) (do (setv expr `(x y))
                  (for [i (range (dec n))]
                    (setv expr `(x ~expr)))
                  `(L x y , ~expr ~@args))))
