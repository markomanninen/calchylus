
Easy native implementation
==========================

This is the simple implementation of the Lambda calculus evaluator. It will
utilize the native anonymous function declaration ``fn`` in Hy.

Most of the main programming languages supports `anonymous functions`_, with
notable exceptions of Ada, C, COBOL, Fortran, and Pascal.

.. code-block:: hylang

  (eval-and-compile
    ; specify separator char
    (setv separator '·)
    ; find the index of the element from the list
    (defn index [elm lst]
      ; if the element is not found, return -1
      (try (.index lst elm) (except [ValueError] -1))))
  ; main lambda expression macro
  (defmacro 𝜆 [&rest expr]
    ; get the index of the argument-body separator
    (setv idx (index separator expr))
    ;  cut the arguments before the separator and append to the function
    `(fn ~(cut expr 0 (if (pos? idx) idx 0))
      ; cut the body of the expression and append to the function
      ~@(cut expr (inc idx))))

In Hy anonymous function is created with ``(fn [args] body)``. Because Hy is
Lisp at frontend, evaluation order of the elements in the program expression is
very similar to Lambda calculus syntax. The first element will be the function
and the rest of the elements are arguments to the function, where arguments can
of cource be functions themselves.

So the usage of the anonymous function in Hy is:

((fn [args] (print args)) 'args)

From that point of view, it really is just a matter of implementing Lambda
calculus syntax to functionality, that already exists in Hy.

http://docs.hylang.org/en/stable/language/api.html#fn

.. _anonymous functions: https://en.wikipedia.org/wiki/Anonymous_function
