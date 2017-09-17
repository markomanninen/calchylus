
Calchylus - Lambda calculus with Hy
===================================

Intro
-----

``calchylus`` is a computer installable `Hy <http://docs.hylang.org>`__ module
that is used to evaluate, and furthermore through this documentation, shine
light to the basics of Lambda calculus (also written as λ-calculus).

	`Lambda calculus <https://en.wikipedia.org/wiki/Lambda_calculus>`__ is a
	formal system in mathematical logic for expressing computation that is
	based on function abstraction and application using variable binding and
	substitution.

The target audience is those who:

a) are interested in the theory and the history of the programming languages
b) may have or are interested to gain some experience in Python and/or Lisp
c) who wants to narrow the gap between mathematical notation and
   programming languages, especially by means of logic

`Andrew Bayer <http://math.andrej.com/2016/08/30/formal-proofs-are-not-just-deduction-steps/>`__
writes in his blog post about formal proofs and deduction:

	*Traditional logic, and to some extent also type theory, hides computation
	behind equality.*

Lambda calculus, on the other hand, reveals how the computation in logic is
done by manipulation of the Lambda terms. Manipulation rules are simple and
were originally made with a paper and a pen, but now we rather use computers for
the task. Lambda calculus also addresses the problem, what can be proved and
solved and what cannot be computed in a finite time.

Beside evaluating Lambda expressions, ``calchylus`` module can serve as a
starting point for a mini programming language. Via custom macros representing
well known Lambda forms, ``calchylus`` provides all necessary elements for
boolean, positive integer, and list data types as well as conditionals, loops,
variable setters, imperative do structure, logical connectives, and arithmetic
operators. Also, exemplary functions calculating summation, factorial, and
nth fibonacci number are provided. You can build upon that, for example
`real numbers <https://cs.stackexchange.com/questions/2272/representing-negative-and-complex-numbers-using-lambda-calculus?noredirect=1&lq=1>`__,
even negative complex numbers if that makes any sense. Your imagination is
really the only limit.

Finally, when investigating the open source ``calchylus`` implementation that is
hosted on `GitHub <https://github.com/markomanninen/calchylus>`__, one can
expect to get a good understanding of the higher order functions and the
`combinatory logic <https://en.wikipedia.org/wiki/Combinatory_logic>`__, not the
least of the fixed point combinator or shortly, ϒ combinator.


Quick start
-----------

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
that is based on a purely untyped Lambda calculus.


Concepts of Lambda calculus
---------------------------

Lambda calculus takes everything to the very few basic computational ideas.
First of all, there are only three concepts necessary to express Lambda calculus:

1. variables, that are any single or multiple letter identifiers designating
   parameters or mathematical values
2. abstractions, that are function definitions which binds arguments to the
   function body
3. application, that applies the function abstraction to the variables

In the original Lambda calculus you could define one and one only argument per
function, but even before Lambda calculus in 1920's
`Schönfinkel <https://en.wikipedia.org/wiki/Moses_Sch%C3%B6nfinkel#Work>`__
showed that nested unary functions can be used to imitate multiary functions.

Later this mechanism settled down to be called as "currying" and is fully
implemented in the ``calchylus`` module.

Two other syntactic rules must be introduced to be able to write and evaluate
Lambda applications:

1. Lambda function indicator, or binding operator that is usually a Greek
   lambda letter: ``λ``
2. Lambda function argument and body separator, that is usually a dot: ``.``

Optional:

3. Parentheses to group and indicate the Lambda function bodies and variables.
   The most convenient way is to use left ``(`` and right ``)`` parentheses.
   Other purpose of using parentheses is to visually make Lambda
   expressions easier to read and to avoid arbitrarities in Lambda expressions.
4. Space character to distinct function indicator, separator, variables, body,
   and arguments. This is optional, because in the simplest Lambda calculus
   implementation single character letters are used to denote variables. But it
   is easy to see that this is quite limiting for practical purposes.


Lambda expressions in ``calchylus`` module
------------------------------------------

All three concepts and four rules are implemented in the ``calchylus`` module
so that for example the very basic Lambda calculus identity application
``λx.x y`` becomes ``(L x , x y)`` in ``calchylus`` notation. Infact, the
function indicator and the separator character can be freely defined in
``calchylus``. In the most of the examples we will use ``L`` and ``,`` because
it will be easier to type ``L`` from the keyboard. Using the comma rather than
the dot comes from the Hy programming language environment restrictions, where
the dot is a reserved letter for cons in list processing.

Let us strip down the former expression and show how all rules are taking place
in it.

In ``(L x , x y)``, ``L`` is the Lambda function indicator and parentheses
``()`` indicate the whole application that should be evaluated. ``x`` before the
separator ``,`` is the function argument. ``x`` after the separator is the
function body or just the Lambda term, as it is more conventionally called.
Finally ``y`` is the value for the function, thus we have a full application
here, rather than just an abstraction. Abstraction would, on the other hand be:
``(L x , x)``.

.. note::

	In mathematics, identity function can be denoted either by $$f(x) = x$$ or by
  $$x → f(x)$$.

Because these rules are notable in any functional and Lisp like language, there
is a great temptation to implement Lambda calculus evaluator as a native
anonymous function calls. The problem with this approach is very subtle and
will bring practicer to the deep foundations of the programming languages. That
is, to decide in which order to evaluate arguments and functions and how to deal
with argument name collisions.


Evaluation stages
-----------------

Next we need some evaluation rules to call the function with given input and
give the result. These rules or procedures are called:

- alpha conversion
- beta reduction

Optional:

- eta conversion


The most of the modern computer languages utilizes some notation of functions.
More precicely, anonymous functions that are not supposed to be referenced by
a name in a computer program, at first seems to be equivalent to Lambda
calculus. But there are some catches one needs to be aware of.

*****

In reality, there is really not so much to implement because Hy is already a
Lisp language with a quite consice anonymous function notation. Lisp, on the
other hand, can be defined as *an untyped Lambda calculus extended with
constants*. So actually we just need to introduce the `𝜆` macro, simplify
the usual Lisp notation, and act only with functions. Maybe more useful are all
main concepts and Lambda terms presented in the document. One can study the
very basics of functional language with given examples.

At the current development stage, ``calchylus`` does not provide `eta conversion
<https://en.wikipedia.org/wiki/Lambda_calculus#Reduction>`__ because it only
has some meaning on extensibility of the function and proofing if forms are
same or not.


The `MIT <http://choosealicense.com/licenses/mit/>`__ License
-------------------------------------------------------------

Copyright (c) 2017 Marko Manninen

.. |Output:| replace:: [output]
