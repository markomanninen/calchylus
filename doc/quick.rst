
Quick start
===========

.. code:: unix

	$ pip install hy calchylus
	$ hy

.. code:: lisp

	> (require [calchylus.lambdas [*]])
	> (with-alpha-conversion-and-macros L ,)
	> (L x y , (x (x (x (x (x y))))) a b)
	(a (a (a (a (a b)))))
	> (FIBONACCI FIVE)
	(x (x (x (x (x (x (x (x (x (x (x (x (x y)))))))))))))


Explanation
-----------

Python 2.7 or 3.6 and greater are required. Install Hy language interpreter and
`calchylus` module by using `pip` Python package management tool:

.. code:: unix

	$ pip install hy calchylus

Open Hy since `Calchylus` is written as Hy macros:

.. code:: unix

	$ hy

Import Lambda calculus macros and define function indicator letter `L` and
argument-body separator character `,`:

.. code:: lisp

	> (require [calchylus.lambdas [*]])
	> (with-alpha-conversion-and-macros L ,)

Now we can evaluate Lambda expressions. Here we use the Church numeral five,
that is one of the most common number representations in Lambda calculus:

.. code:: lisp

	> (L x y , (x (x (x (x (x y))))) a b)
	(a (a (a (a (a b)))))
