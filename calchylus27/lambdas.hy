#! /usr/bin/env hy
;----------------------------------------------
; Calchylus - Lambda calculus with Hy
;
; Source:
; https://github.com/markomanninen/calchylus/
;
; Install:
; $ pip install hy calchylus
;
; Open Hy:
; $ hy
;
; Import macros:
; (require (calchylus.lambda (*)))
;
; Use:
; (L x y , (x (x y)) a b) ->
; (a (a b))
;
; Documentation: http://calchylus.readthedocs.io/
; Author: Marko Manninen <elonmedia@gmail.com>
; Copyright: Marko Manninen (c) 2017
; Licence: MIT
;----------------------------------------------

(defmacro with-alpha-conversion-and-macros [lambdachr separator]
   `(init-system ~lambdachr ~separator True True))

(defmacro with-alpha-conversion-nor-macros [lambdachr separator]
   `(init-system ~lambdachr ~separator False False))

(defmacro with-alpha-conversion [lambdachr separator]
   `(init-system ~lambdachr ~separator True False))

(defmacro with-macros [lambdachr separator]
   `(init-system ~lambdachr ~separator False True))

(defmacro init-system [lambdachr separator alpha macros]

  `(do

    (eval-and-compile

      (setv ; lambda expression macro name
            lambdachr '~lambdachr
            ; lambda expression argument and body separator
            separator '~separator)

      ; is expression a generated symbol / unique variable name
      (defn gensym? [x]
        (or (= (first x) ":") (= (first x) "\ufdd0")))

      ; pretty print utility
      (defn pprint [expr]
        (if-not (coll? expr) (str expr)
          (% "(%s)" (.join " " (map pprint expr)))))

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

      ; is expr(ession) a lambda expression i.e. starts with lambdachr: (L ...)?
      (defn L? [expr]
        (and (coll? expr)
             expr ; not empty
             (symbol? (first expr))
             (= (first expr) lambdachr)))

      ; make lambda expression from body and other parts
      (defn build-lambda [body &optional [args []] [vals []]]
        (extend [lambdachr] args [separator] body vals))

      ; get lambda expression parts
      ; body: (x x), args: (x), values (y), and params: ([x y])
      (defn extract-parts [expr]
        (setv idx (index expr separator))
        ; if separator index is less than expected, lambda expression is possibly malformed
        (if (or (< idx 1) (< (len expr) (+ idx 2))) {"body" None "args" [] "vals" [] "params" []}
            (do
              (setv body (cut expr (inc idx))
                    args (cut expr 1 idx)
                    vals (tuple (rest body)))
              ; return body, args, vals, and key-value pairs based on args-vals
              {"body" (first body) "args" (tuple args) "vals" vals "params" (zip args vals)})))

      ; substitute lambda sub expr(ession). it requires special handler
      ; because of variable shadowing and not-coll body
      (defn substitute* [a b expr]
        (setv p (extract-parts expr)
              args (get p "args")
              body (get p "body")
              vals (get p "vals"))
        ; first substitute a to b in possible values
        (if-not (empty? vals) (setv vals (substitute a b vals)))
        ; shadow arguments, don't substitute if a is in new arguments
        ; but some instances in vals may have been substituted, so we need to
        ; construct expression anyway
        (if (in a args) (build-lambda [body] args vals)
            (build-lambda
              ; only coll body can be iterated
              (if (coll? body)
                  [(substitute a b body)]
                  [(if (= a body) b body)])
              args vals)))

      ; substitute a with b in expr
      (defn substitute [a b expr]
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
            (if (L? f) (setv expr (extend f (tuple (rest expr)))))
            ((type expr) (map shift-arguments expr)))))

      ; p is extracted lambda expression
      (defn alpha-conversion* [p]
        (setv body (get p "body")
              args (get p "args")
              vals (get p "vals")
							; generate argument names for unique ones
              args2 (tuple (map gensym args)))
				; replace by new argument names
        (for [[a b] (zip args args2)]
          (setv body (substitute a b body)))
				; re-create expression by substituting body and possible values
        (build-lambda [(alpha-conversion body)] args2 (if (empty? vals) vals (alpha-conversion vals))))

      ; rename arguments for collision prevention
      ; without renaming this expression (L x y , (x y) y z) would yield: (z z)
      ; but because arguments are renamed by gensym, expression will become
      ; (L :x_1234 :y_1234 , (:x_1234 :y_1234) y z) and result corretly: (y z)
      ; human-readable function can be used to turn expression back to normal form,
      ; that is, if there are any lambda abstractions available in the expression
      (defn alpha-conversion [expr]
        (if (coll? expr)
            (if (L? expr)
              (alpha-conversion* (extract-parts expr))
              ((type expr) (map alpha-conversion expr)))
            expr))

      ; extract gen sym original variable name
      (defn symgen [expr]
        (setv idx (inc (index (name expr) ":")))
        (cut (name expr) idx (inc idx)))

      ; convert generated machine variable names to normal forms
      (defn human-readable [expr]
        (if ~alpha
          (if (coll? expr)
              (map human_readable expr)
              (if (gensym? (name expr))
                  (symgen expr)
                  expr))
            expr))

      ; beta reduction helper
      (defn beta-reduction* [expr]
        (setv p (extract-parts expr)
              body (get p "body")
              args (get p "args")
              vals (get p "vals")
              ; rest of the free arguments that are not in params
              free (list (drop (len args) vals)))
        ; substitute bound arguments
        ;(print 'before-substitute-body: (pprint body))
        (for [[a b] (get p "params")]
          (setv body (substitute a b body)))
        ;(print 'after-substitute-body: (pprint body))
        ; shift application arguments
        (if (coll? body)
          (setv body (shift-arguments body)))
        ;(print 'after-shift-arguments: (pprint body))
        (if (coll? body)
            (if (L? body)
                (do (setv body (extend body free))
                    (setv pp (extract-parts body))
                    ; if evaluated expression has no further values, but also
                    ; it is not a constant, render final form
                    (if (and (empty? (get pp "vals")) (not (empty? (get pp "args"))))
                        (if (and (empty? free) (not (empty? args)) (empty? vals))
                            (human-readable expr)
                            (human-readable (if (empty? free) body expr)))
                        ; else evaluate again but using helper because we know
                        ; expression is lambda form
                        (beta_reduction* body)))
                ; if original expression has no values, it was lambda expression and
                ; it had arguments, render final form
                (if (and (empty? vals) (L? expr) (not (empty? args)))
                    (human-readable expr)
                    ; else evaluate again using main redex
                    (map beta-reduction (if (empty? free) body (extend [body] free)))))
            ; render final form. here we want to return either
            ; the body or the whole expression depending on args, vals and free variables
            (human-readable
              (if args
                (if vals
                  (if free
                    (extend [body] free)
                  body)
                expr)
              (if free (extend [body] free) body)))))

      ; main form beta / eta reduction steps
      (defn beta-reduction [expr]
        ;(print)
        ;(print 'beta-reduction: (pprint expr))
        ; if the form (expr) is not a lambda form i.e. not starting with L
        ; we still want to seek if there are sub lambda expressions inside
        ; (x (x (L x , x y))) should return (x (x y))
        (if (L? expr)
            (beta_reduction* expr)
            (if (coll? expr)
                (map beta-reduction expr)
                (human-readable expr))))

      ; reformulate expression, because by using L macro, L is naturally left out from the expression
      ; beta-reduction functions on the other hand relys on the L in the beginning of the expression!
      ; then pass parameters and possibly expand macro form later
      (defn evaluate-lambda-expression [expr]
        ;(print 'evaluate-lambda-expression (pprint expr))
        (setv expr (hy.HyExpression (extend [lambdachr] expr)))
        (setv expr (beta-reduction (if ~alpha (alpha-conversion expr) expr)))
        (if (or (coll? expr) (symbol? expr))
            ; symbols and expression should be pretty "printed"
            (pprint expr)
            ; numbers for example get passed as they are
            ; this is not exactly included on lambda calculus but just a way
            ; to keep data types existing for hy and later usage
            expr)))

    ; lambda expression main macro
    (defmacro ~lambdachr [&rest expr]
      ; try except is not working alone on macro body!
      (if-not (empty? expr)
        (try
          (evaluate-lambda-expression (if ~macros (macro-expand expr) expr))
          (except [e [RuntimeError hy.errors.HyMacroExpansionError]]
            (print "Recursion error occured for lambda expression: " (pprint expr))))))

    ; lambda application sharp macro
    (defsharp Y [expr] `(~lambdachr ~separator ~expr))

    (if ~macros
      (do
         ; for some reason macros will be included even if this block
         ; is not reached runtime...
         (require [calchylus27.macros [*]])
         (init-macros ~lambdachr ~separator)))))
