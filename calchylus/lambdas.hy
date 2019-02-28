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
; Import library:
; (require (calchylus.lambdas (*)))
;
; Initialize macros:
; (with-alpha-conversion-and-macros L ,)
;
; Use:
; (λ x y , (x (x y)) a b) ->
; (a (a b))
;
; Documentation: http://calchylus.readthedocs.io/
; Author: Marko Manninen <elonmedia@gmail.com>
; Copyright: Marko Manninen (c) 2017
; Licence: MIT
;----------------------------------------------

(defmacro with-alpha-conversion-and-macros [lambdachr separator &optional [redex False]]
   `(init-system ~lambdachr ~separator True True ~redex))

(defmacro with-alpha-conversion-nor-macros [lambdachr separator &optional [redex False]]
   `(init-system ~lambdachr ~separator False False ~redex))

(defmacro with-alpha-conversion [lambdachr separator &optional [redex False]]
   `(init-system ~lambdachr ~separator True False ~redex))

(defmacro with-macros [lambdachr separator &optional [redex False]]
   `(init-system ~lambdachr ~separator False True ~redex))

(defmacro init-system [lambdachr separator alpha macros redex]

  `(do
    (try (do (import IPython)
      (if (in 'display (.__dir__ IPython))
        (import (IPython.display [HTML]))))
      (except (e Exception)))

    (eval-and-compile

      (setv ; lambda expression macro name
            lambdachr '~lambdachr
            ; lambda expression argument and body separator
            separator '~separator
            ; should we collect forms of the evaluation process
            redex? ~redex
            ; collection of reduced forms on the evaluation process
            redexes [])

      ; pretty print utility
      (defn pprint [expr]
        (if-not (coll? expr) (str expr)
          (do
            ; see if there is an additional wrapper on application
            ; we don't need to show it...
            (setv p (extract-parts expr)
                  expr (if (or (none? (:body p)) (:args p)) expr (:body p)))
            ; add support for escaped dot syntax
            (% "(%s)" (.replace (.join " " (map pprint expr)) "\." ".")))))

      ; safe get index for the first occurrence of the x
      ; (index (, 1 2) 0) ; -> -1
      (defn index [l x]
        (try (.index l x)
             (except [e [ValueError AttributeError]] -1)))

      ; extend and return list instead of .extend list in place
      ; provide a as a copy (.copy a) in cases where strange
      ; recursive error behaviour is occurring
      (defn extend [a &rest b]
        (for [c b] (.extend a c)) a)

      ; is expr(ession) a lambda expression i.e. starts with lambdachr: (λ ...)?
      (defn L? [expr]
        (and (coll? expr)
             expr ; not empty
             (symbol? (first expr))
             (= (first expr) lambdachr)))

      ; make lambda expression from body and other parts
      (defn build-lambda [body &optional [args []] [vals []]]
        (extend [lambdachr] args [separator] body vals))

      ; get lambda expression parts
      ; (λ x , (x x) y) -> body: (x x), args: (x) and values (y)
      ; (λ x (x x) y) without separator for single parameter expressions is fine too
      (defn extract-parts [expr]
        (setv idx (index expr separator)
               lx (len expr))
        ; if separator index is less than expected, lambda expression is possibly malformed
        (if (< lx (+ idx 2)) {:body None :args [] :vals (,)}
            (do
              ; short constant lambda form without separator (λ x 1) is supported
              (setv ly (if (= lx 2) 1 2)
                    ; lambda form without separator has index -1 which is handled both on body and args
                    body (cut expr (if (= idx -1) ly (inc idx)))
                    args (cut expr 1 (if (= idx -1) ly idx)))
              ; return body, args, and vals
              {:body (first body) :args (list args) :vals (tuple (rest body))})))

      ; substitute lambda sub expr(ession). it requires special handler
      ; because of variable shadowing and not-coll body
      (defn substitute* [a b p]
        (setv args (:args p)
              body (:body p)
              vals (:vals p))
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
            (if (L? expr) (substitute* a b (extract-parts expr))
                ; else substitute all sub expressions
                ((type expr) (genexpr (substitute a b e) [e expr])))
            ; return substitute (b), if match is found
            (if (= a expr) b expr)))

      ; shift arguments inside functions in application expressions
      ; ((λ x , x) a b) -> (λ x , x a b) -> (a b)
      ; ((TRUE) TRUE FALSE) -> (TRUE TRUE FALSE) -> TRUE
      ; this is required to convert and evaluate substituted function forms
      ; (λ x y z , ((x) y z) TRUE a b) -> ((TRUE) a b) -> (TRUE a b) ->
      ; ((λ x y , x) a b) -> (λ x y , x a b) -> a
      (defn shift-arguments [expr]
        (if-not (coll? expr) expr
          (do
            (setv f (first expr))
            (if (L? f) (setv expr (extend ((type f) (.copy f)) (tuple (rest expr)))))
            ((type expr) (map shift-arguments expr)))))

      ; generated variable name for alpha conversion
      (defclass Variable [HySymbol]
        (defn --init-- [self &optional [variable_name "G"]]
          (setv self.variable_name variable_name
                self.generated_variable_name (gensym variable_name)))
        (defn --repr-- [self]
          self.generated_variable_name)
        (defn --eq-- [self x]
          (= x self.generated_variable_name)))

      ; p is an extracted lambda expression
      (defn alpha-conversion* [p]
        (setv body (:body p)
              args (:args p)
              vals (:vals p)
              ; generate unique argument names
              args2 (tuple (map Variable args)))
        ; replace by new argument names
        (for [[a b] (zip args args2)]
          (setv body (substitute a b body)))
        ; re-create expression by substituting body and possible values
        (build-lambda [(alpha-conversion body)] args2
          (if (empty? vals) vals (alpha-conversion vals))))

      ; rename arguments for collision prevention
      ; without renaming this expression (λ x y , (x y) y z) would yield: (z z)
      ; but because arguments are renamed by gensym, expression will become
      ; (λ :x_1234 :y_1234 , (:x_1234 :y_1234) y z) and result corretly: (y z)
      (defn alpha-conversion [expr]
        (if (coll? expr)
            (if (L? expr)
              (alpha-conversion* (extract-parts expr))
              ((type expr) (map alpha-conversion expr))) expr))

      ; either get the final reduced form or reduce more
      (defn render-or-reduce [expr body]
        (setv p (extract-parts body))
        ; if evaluated expression has no further values, but also
        ; it is not a constant, render the final form
        (if (and (empty? (:vals p)) (not (empty? (:args p)))) expr
            ; else evaluate again but using helper because we know
            ; expression is lambda form
            (lambda-reduction body)))

      ; substitute bound variable and parameter AND
      ; shift application arguments
      ; this means that function forms are translated from
      ; ((a) b) to (a b) which makes it possible to evaluate
      ; lambda expressions with less parentheses
      (defn normal-form [body arg val free parent]
        (if redex? (setv pr (% "%s[%s:=%s]" (tuple (map pprint (, body arg val))))))
        (setv body (shift-arguments (substitute arg val body))
              expr (if free (extend [body] free) body))
        (if (and redex? arg) (.append redexes (% "%s → %s" (, (pprint parent) pr))))
        ; if body is still a list after substitution and shift
        (if (coll? body)
            ; and it is a lambda expression
            (if (L? body)
                (render-or-reduce expr (extend body free))
                ; else evaluate again using main redex function
                (do
                  (if redex? (.append redexes (% "%s " (pprint expr))))
                  (map beta-reduction expr))) expr))

      ; head normal form
      ; when normal form has been achieved, the body of the application
      ; can still have reducible expressions
      ; ; (λ x , (λ y , (λ z , z 1))) -> (λ x , (λ y , 1))
      (defn head-normal-form [body args vals parent]
        (if (and redex? args) (.append redexes (% "%s ← %s " (, (pprint parent) (pprint body)))))
        (if args (build-lambda [(beta-reduction body)] args)
            (beta-reduction body)))
      ; (λ x y z , (x y z) 1 2 3)
      ; (λ x , (λ y , (λ z , (x y z))) 1 2 3)
      ; this will also delay evaluating all multiple arguments at once
      ; so that only the left most argument and its value gets substituted
      ; to the body first, then going deeper and deeper
      (defn currying [body args vals]
        (while args
          (setv body (build-lambda [body] [(.pop args)])))
        ; reduce re-created expression again
        (lambda-reduction (extend body vals)))

      ; this function assumes that expression is lambda one
      ; if not knowing, then beta-reduction should be used
      (defn lambda-reduction [expr]
        (setv p (extract-parts expr)
              body (:body p)
              args (:args p)
              vals (:vals p))
        ; if multiple arguments are provided then curry them
        (if (> (len args) 1) (currying body args vals)
            ; else either continue beta reduction to normal form
            ; at this point there is only one argument and one parameter
            ; and possibly extra free variables. this causes normal order reduction
            ; contra to applicative order where parameters are reduced first
            (if vals (normal-form body (first args) (first vals) (list (drop (len args) vals)) expr)
                ; or continue reducing to head normal form
                (head-normal-form body args vals expr))))

      ; main beta reduction steps
      (defn beta-reduction [expr]
        ; if the form (expr) is not a lambda form i.e. not starting with L
        ; we still want to seek if there are sub lambda expressions inside
        ; (x (x (λ x , x y))) should return (x (x y))
        ; ((λ x , e) 2) should return e
        (if (coll? expr)
          (setv expr (shift-arguments expr)))
        (if (L? expr)
            (lambda-reduction expr)
            (if (coll? expr)
                (do
                  (setv expr ((type expr) (map beta-reduction expr)))
                  (if (and (coll? expr) (coll? (first expr))) (beta-reduction expr) expr)) expr)))

      ; start evaluation of the lambda expression
      (defn evaluate-lambda-expression [expr]
        ; delete previous redexes for latex print utility
        (if redex? (del (cut redexes)))
        ; reformulate expression, because by using L macro, L is naturally left out from the expression
        ; beta-reduction functions on the other hand relys on the L in the beginning of the expression!
        (setv expr (hy.HyExpression (extend [lambdachr] expr)))
        ; alpha convert and beta reduce
        (setv expr (beta-reduction (if ~alpha (alpha-conversion expr) expr)))
        (if (or (coll? expr) (symbol? expr))
            ; symbols and expression should be pretty "printed"
            (pprint expr)
            ; numbers for example get passed as they are
            ; this is not exactly included on lambda calculus but just a way
            ; to keep data types existing for hy and later usage
            expr))

      ; helper for macro-print
      (defn replace-with-acute [expr]
        ; change spaces to \space for better padding around symbols
        (setv expr (.replace (.replace (.replace (pprint expr) " " "\\ ") "\\ ^\\" "^") "(\\\ " "("))
        ; remove parentheses the outer-most parentheses
        (if (and (.startswith expr "(") (.endswith expr ")")) (cut expr 1 -1) expr))

      ; output expression in latex / mathjax format for pretty print in html documents
      (defn latex-output [expr &optional [size "large"] [result False]]
        ; add application closure for a moment
        (setv expr (extend '(APP) [expr]))
        ; add html linebreak for top padding, add $$ for mathjax rendering, use large font
        (% "$$\\\\\%s %s$$"
          (, size (% "%s%s"
            (, (replace-with-acute (macro-expand expr))
              ; add result to the equation?
              (do
                (setv c (eval expr) re "")
                (if redex? (setv re (.join "\\\\" (map replace-with-acute redexes))))
                (if result (% "\\\\%s\\\\\%s =_{\\beta}\\\\\\%s %s"
                (, re size size (replace-with-acute c))) ""))))))))

    ; lambda expression main macro
    (defmacro ~lambdachr [&rest expr]
      ; try except is not working alone on macro body!
      (if-not (empty? expr)
        (try
          (evaluate-lambda-expression (if ~macros (macro-expand expr) expr))
          (except [e [RecursionError hy.errors.HyMacroExpansionError]]
            (print "Recursion error occured for lambda expression: " (pprint expr))))))

    ; lambda application sharp macro
    (defsharp Ÿ [expr] `(~lambdachr ~separator ~expr))
    ; output expression formatted by mathjax
    (defmacro defprint [expr &optional [result False] [size "large"]]
      `(HTML ~(latex-output expr :size size :result result)))
    ; output expression formatted by mathjax with default settings
    (defsharp § [expr] `(defprint ~expr))
    ; output expression and its beta reduced form formatted by mathjax
    (defsharp ¤ [expr] `(defprint ~expr True))
    ; include macros if required
    (if ~macros
      (do
         ; for some reason macros will be included even if this block
         ; is not reached runtime...
         (require [calchylus.macros [*]])
         (init-macros ~lambdachr ~separator)))))
