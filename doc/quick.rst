
Quick start
===========

**Install**

.. code-block:: bash

	$ pip install hy calchylus
	$ hy

**Run**

.. code-block:: hylang

	(require [calchylus.lambdas [*]])
	(with-alpha-conversion-and-macros L ,)

.. code-block:: hylang

	(L x y , (x (x (x (x (x y))))) a b) ; output: (a (a (a (a (a b)))))

.. code-block:: hylang

	(FIBONACCI SEVEN) ; output: (x (x (x (x (x (x (x (x (x (x (x (x (x y)))))))))))))


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

By ``with-alpha-conversion-and-macros`` we want to say that arguments should
be internally renamed to prevent argument name collision and that we want to
load custom macros representing Lambda forms.

Now, we are ready to evaluate Lambda expressions. Here we apply
`Church numeral <https://en.wikipedia.org/wiki/Church_encoding>`__  five to
the two values, ``a`` and ``b``:

.. code-block:: hylang

	(L x y , (x (x (x (x (x y))))) a b)

|Output:|

.. code-block:: text

	(a (a (a (a (a b)))))

Without going deeper into this yet, we can see that all ``x`` got replaced by
``a`` and all ``y`` got replaced by ``b``.

Predefined macros are available as shorthands for the most common Lambda forms.
For example, calculating the seventh Fibonacci number can be done by using the
Church numeral ``SEVEN`` and the ``FIBONACCI`` shorthands:

.. code-block:: hylang

	(FIBONACCI SEVEN)

|Output:|

.. code-block:: text

	(x (x (x (x (x (x (x (x (x (x (x (x (x y)))))))))))))

That is the Church numeral 13, the seventh
`Fibonacci number <https://en.wikipedia.org/wiki/Fibonacci_number>`__.

In ``calcylus`` these custom macro shorthands representing Lambda forms serves
as a mathematical and logical foundation for a prototype programming language
that is based on purely untyped Lambda calculus.
