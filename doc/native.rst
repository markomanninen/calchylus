
Easy native implementation
==========================

This is the simple implementation of the Lambda calculus evaluator. It will
utilize the native anonymous function declaration in Hy. Most of the main
programming languages
`supports <https://en.wikipedia.org/wiki/Anonymous_function>`__ anonymous
functions, with notable exceptions of Ada, C, COBOL, Fortran, and Pascal.

.. code-block:: hylang

  (eval-and-compile
    (setv separator '·)
    ; find index of the element from the list.
    (defn index [elm lst]
      ; if the element is not found, return -1
      (try (.index lst elm) (except [ValueError] -1))))
  ; lambda expression macro
  (defmacro 𝜆 [&rest expr]
    ; find the index of the separator
    (setv idx (index separator expr))
    ;  cut arguments before the separator and append to the function
    `(fn ~(cut expr 0 (if (pos? idx) idx 0))
      ; cut body of the expression and append to the created function
      ~@(cut expr (inc idx))))
