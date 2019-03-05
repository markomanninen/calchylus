#! /usr/bin/env hy
;----------------------------------------------
; Calchylus2 - Lambda calculus with Hy
;
; Source:
; https://github.com/markomanninen/calchylus/
;
; Install:
; $ pip install calchylus
;
; Open Hy:
; $ hy
;
; Import library:
; (require [calchylus2.lambdas [*]])
; (import [calchylus2.lambdas [*]])
;
; Initialize with macros:
; (with-macros λ)
; or without macros
; (without-macros λ)
;
; For example church number two:
; (λ x y (x (x y)) a b) ->
; (a (a b))
; or if macros are included, then:
; (TWO a b) ->
; (a (a b))
;
; Documentation: http://calchylus.readthedocs.io/
; Author: Marko Manninen <elonmedia@gmail.com>
; Copyright: Marko Manninen (c) 2019
; Licence: MIT
;----------------------------------------------

(defmacro with-macros [binder &optional [delimitter ""]]
  `(do
    (init-system ~binder ~delimitter)
    (require [calchylus2.macros [*]])
    (init-macros ~binder)))

(defmacro without-macros [binder &optional [delimitter ""]]
   `(init-system ~binder ~delimitter))

(defmacro init-system [binder delimitter]
  `(do
    (eval-and-compile
      (setv ; lambda expression macro name.
            ; this is required for macros to work. otherwise binder is regarded as an unknown symbol.
            binder '~binder
            ; this is required for pretty print to work. otherwise delimitter is regarded as an unknown symbol.
            delimitter '~delimitter)
      ; extend output rather than in place
      (defn extend [a b] (.extend a b) a)
      ; reverse ouput rather than in place
      (defn reverse [a] (.reverse a) a)
      ; is instance a function abstraction?
      (defn function? [e] (instance? Function e))
      ; instead of straighforward native apply function, apply*
      ; will take care of the result that is possibly not a function but a list
      ; in that case result will be extended with the remaining arguments
      (defn apply* [a b]
        ; by checking callable instead of function? we will extend the standard lambda
        ; function body to allow native hy/python function calls too
        (while (and (callable a) b)
          (setv a (a (.pop b 0))))
        (if b (extend a b) a))
      ; head normal form of the lambda application
      (defn normalize [e]
        (if-not (coll? e) e
          (if (function? (first e))
            (apply* (first e) (list (rest e)))
            (if (function? e) e
              ; with HyList object instead of native list, we enable pretty printing
              (do (setv x (hy.HyList (map normalize e)))
                  (if (function? (first x)) (normalize x) x))))))
      ; prettier lambda function abstraction representation
      (defn repr [e]
        (if (and (coll? e) (not (function? e)))
          ; using HyList object comma separated list representations becomes more clear
          (hy.HyList (map repr e)) e))
      ; lambda term / variable
      (defclass Variable []
        (defn --init-- [self x]
          ; crate the human readable name for the variable
          (setv self.x (name x)))
        ; show the human readable name
        (defn --repr-- [self] self.x)
        ; if variable is the first element of the expression, then hy tries to use it
        ; as a function callee, thus we need to return both the callee and the
        ; possible arguments back intact
        (defn --call-- [self &rest expr]
          (extend [self] expr)))
      ; lambda function abstraction
      (defclass Function [hy.HyList]
        ; pretty representation of the function. normally function in python / hy doesn't have
        ; any suitable printing format because of the arbitrary content of the function.
        ; in lambda calculus function body is structured in a very strict manner so we can
        ; show the exact content of the function body
        (defn --repr-- [self]
          (% "(%s %s%s%s)" (, '~binder (first self)
            ; one could normalize the second self, but max recursion error are probably impossible
            ; to handle in the self referencing forms
            (if delimitter (% " %s " (, (.strip delimitter "\\"))) " ") (repr (second self)))))
        ; the function body to the normal head form (call by value)
        (defn --call-- [self value &rest args]
          (setv expr (normalize ((last self) value)))
          ; if extra arguments are given then they are curryed forward
          ; insteadd of using apply we use a slightly modified functionality with apply*
          (if args (apply* expr (list args)) expr))))

    ; main lambda macro
    (defmacro ~binder [&rest expr]
      (reduce (fn [body arg]
        `((fn[] (setv ~arg (Variable '~arg))
          (Function ['~arg ~body (fn [~arg] ~body)])))) (reverse (list expr))))))
