
Quick start
===========

.. code-block:: bash

	$ pip install hy calchylus
	$ hy

.. code-block:: hylang

	(require [calchylus.lambdas [*]])
	(with-alpha-conversion-and-macros L ,)
	(L x y , (x (x (x (x (x y))))) a b)
	; (a (a (a (a (a b)))))
	(FIBONACCI FIVE)
	; (x (x (x (x (x (x (x (x (x (x (x (x (x y)))))))))))))


Explanation
-----------

For Windows, Linux, and MacOS Python 2.7 or 3.6 and greater are required.
Install Hy language interpreter and ``calchylus`` module by using ``pip``
Python package management tool:

.. code-block:: bash

	$ pip install hy calchylus

Open Hy since `Calchylus` is written as Hy macros:

.. code-block:: bash

	$ hy

Import Lambda calculus macros and define function indicator letter ``L`` and
argument-body separator character ``,``:

.. code-block:: hylang

	(require [calchylus.lambdas [*]])
	(with-alpha-conversion-and-macros L ,)

Now we can evaluate Lambda expressions. Here we use the Church numeral five,
that is one of the most common number representations in Lambda calculus:

.. code-block:: hylang

	(L x y , (x (x (x (x (x y))))) a b)
	; (a (a (a (a (a b)))))

Predefined Lambda macros are also available as shorthands to the most common
Lambda forms, for example calculating nth Fibonacci number by using Church
numerals:

.. code-block:: hylang

	(FIBONACCI FIVE)
	; (x (x (x (x (x (x (x (x (x (x (x (x (x y)))))))))))))
