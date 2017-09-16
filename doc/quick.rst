
Quick start
-----------

.. code-block:: bash

	$ pip install hy calchylus
	$ hy

.. code-block:: hylang

	(require [calchylus.lambdas [*]])
	(with-alpha-conversion-and-macros L ,)
	(L x y , (x (x (x (x (x y))))) a b) ; output: (a (a (a (a (a b)))))

.. code-block:: hylang

	(FIBONACCI FIVE) ; output: (x (x (x (x (x y)))))


Explanation
-----------

``calchylus`` module works in Windows, Linux, and MacOS operating systems.
Python 2.7 or 3.6 and greater are required.

Install Hy language interpreter and ``calchylus`` module by using ``pip``
Python package management tool:

.. code-block:: bash

	$ pip install hy calchylus

Open Hy, since ``calchylus`` is mostly written as Hy macros:

.. code-block:: bash

	$ hy

Import Lambda calculus macros and define Lambda function indicator letter ``L``
and Lambda argument-body separator character ``,``:

.. code-block:: hylang

	(require [calchylus.lambdas [*]])
	(with-alpha-conversion-and-macros L ,)

``with-alpha-conversion-and-macros`` we say that arguments should be internally
renamed to prevent name collision and that we want to load custom macros
representing Lambda forms.

Now we are ready to evaluate Lambda expressions. Here we apply
`Church numeral <https://en.wikipedia.org/wiki/Church_encoding>`__  five to
the two values, ``a`` and ``b``:

.. code-block:: hylang

	(L x y , (x (x (x (x (x y))))) a b)

|Output:|

.. code-block:: text

	(a (a (a (a (a b)))))

For now, not going deeper to this, we can see that all ``x`` got replaced by
``a`` and all ``y`` got replaced by ``b``.

Predefined macros are available as shorthands to the most common Lambda forms.
For example, calculating the fifth Fibonacci number can be done by using Church
numeral FIVE shorthand and by using the FIBONACCI shorthand for the arithmetic
operation:

.. code-block:: hylang

	(FIBONACCI FIVE)

|Output:|

.. code-block:: text

	(x (x (x (x (x (x (x (x y))))))))

That is the Church numeral 8, the fifth
`Fibonacci number <https://en.wikipedia.org/wiki/Fibonacci_number>`__.

In ``calcylus`` these custom macro shorthands representing Lambda forms serves
as a mathematical and logical foundation for a minimal programming language
that is based on untyped Lambda calculus.


.. |Output:| replace:: [output]
