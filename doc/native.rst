
Easy native implementation
==========================

.. code-block:: hylang

  (eval-and-compile
    ; set separator
    (setv comma '·)
    ; find index of the element from the list. if the element is not found, return -1
    (defn index [elm lst]
      (try (.index lst elm) (except [ValueError] -1))))
  ; lambda expression macro
  (defmacro 𝜆 [&rest expr]
    (setv idx (index comma expr))
    `(fn ~(cut expr 0 (if (pos? idx) idx 0)) ~@(cut expr (inc idx))))
