
Calchylus - Lambda calculus with Hy
===================================

``calchylus`` is a `Hy <http://docs.hylang.org>`__ module that is used to
evaluate, and furthermore, to understand the basics of Lambda calculus
(also written as λ-calculus).

	`Lambda calculus <https://en.wikipedia.org/wiki/Lambda_calculus>`__ is a
	formal system in mathematical logic for expressing computation that is
	based on function abstraction and application using variable binding and
	substitution. -*wikipedia.org*

Intended audience is those who:

a) are interested of the theory and the history of the programming languages,
b) may have some experience in Python and/or Lisp,
c) but also those, who wants to narrow the gap between mathematical notation and
   programming languages, especially in terms of logics.

`Andrew Bayer <http://math.andrej.com/2016/08/30/formal-proofs-are-not-just-deduction-steps/>`__
writes in his blog post in 2016/08:

	Traditional logic, and to some extent also type theory, hides computation
	behind equality.

Lambda calculus, on the other hand, reveals how the computation is made by
manipulation of objects.

``calchylus`` can also serve as a starting point for a mini programming language.
Via custom macros representing well known Lambda forms, ``calchylus`` provides
all necessary elements for boolean, integer and list data types as well as
conditionals, loops, variable setters, mathematical operators and exemplary
arithmetic functions like, summation, factorial, and fibonacci.


Quick start
-----------

.. code-block:: bash

	$ pip install hy calchylus
	$ hy

.. code-block:: hylang

	(require [calchylus.lambdas [*]])
	(with-alpha-conversion-and-macros L ,)
	(L x y , (x (x (x (x (x y))))) a b)

|Output:|

.. code-block:: hylang

	(a (a (a (a (a b)))))

.. code-block:: hylang

	(FIBONACCI FIVE)

|Output:|

.. code-block:: hylang

  (x (x (x (x (x (x (x (x (x (x (x (x (x y)))))))))))))


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

`with-alpha-conversion-and-macros` we say that arguments should be internally
renamed to prevent name collision and that we want to load custom macros
representing Lambda forms.

Now we are ready to evaluate Lambda expressions. Here we apply
`Church numerals <https://en.wikipedia.org/wiki/Church_encoding>`__  five to
the two values, ``a`` and ``b``:

.. code-block:: hylang

	(L x y , (x (x (x (x (x y))))) a b)

|Output:|

.. code-block:: hylang

	(a (a (a (a (a b)))))

For now, not going deeper to this, we can see that all ``x``'s got replaced by
``a`` and all ``y``'s got replaced by ``b``.

Predefined macros are available as shorthands to the most common Lambda forms.
For example, calculating the fifth Fibonacci number can be done by using Church
numeral (one of the most common number representations in Lambda calculus) FIVE
shorthand and by using the FIBONACCI shorthand for the arithmetic operation:

.. code-block:: hylang

	(FIBONACCI FIVE)

|Output:|

.. code-block:: hylang

	(x (x (x (x (x (x (x (x y))))))))

That is the Church numeral 8, the fifth
`Fibonacci number <https://en.wikipedia.org/wiki/Fibonacci_number>`__.

In ``calcylus`` these custom macro shorthands representing Lambda forms serves
as a strictly mathematical and logical foundation for a minimal programming
language that is based on purely untyped Lambda calculus.


History
-------

Lambda calculus was invented by Alonzo Church in the 1930s. That happened
actually a decade before modern electrically powered computers were created.
Lambda calculus can be describes as the simplest and the smallest universal
programming language.

The most of the modern computer languages utilizes some notation of functions.
More precicely, anonymous functions that are not supposed to be referenced by
a name in a computer program, are pretty much equivalent to Lambda calculus.
But even then, there are some catches one needs to be aware of.

Lambda calculus takes everything to the very few basic computational ideas.
First of all, there are three rules to follow in Lambda calculus:

1. variables, that are any single or multiple letter identifiers designating
   parameters or mathematical values
2. abstractions, that are function definitions which binds variables to the
   function body
3. application, that applies the function abstraction to the variables

In the original Lambda calculus there was one and one only argument per
function, but it was soon shown that nested Lambda abstractions can be used
to "imitate" multiary functions.

Two other syntactic rules must be introduced to be able to write and evaluate
Lambda applications:

1. Lambda function indicator, that is usually a Greek lambda letter: ``𝜆``
2. Lambda function argument and body separator, that is usually a dot: ``.``

Optional:

3. Parentheses to group and indicate the Lambda function bodies and variables.
The most convenient way is to use left ``(`` and right ``)`` parentheses for this.
Other purpose of using parentheses is to visually make Lambda expressions easier
to read and avoid arbitrarities in Lambda expressions.
4. Space character to indicate separate variables. This is optional, because in
the simplest form single characters are used to denote variables. But it is easy
to see that this is quite limiting for practical purposes.

All seven rules are implemented in the ``Calchylus`` module so that for example
the very basic Lambda calculus application ``𝜆x.x y`` becomes
``(𝜆 x . x y)`` in ``calchylus`` notation. Infact, function indicator and
separator characters can be freely defined in ``calchylus``. In the most of the
examples we will use ``L`` and ``,`` because it will be easier to type ``L``
from the keyboard. Using comma rather than dot comes from the Hy programming
language environment restrictions, because dot is reserved for cons in list
processing.

Let us strip down the former expression and show how all rules are taking place
in it.

In ``(L x , x y)``, ``L`` is the Lambda function indicator and parentheses
``()`` indicate the whole application that should be evaluated. ``x`` before the
separator ``,`` is the function argument. ``x`` after the separator is the
function body or just the Lambda term, as it is more conventionally called.
Finally, ``y` `is the value for the function, thus we have a full application
here, rather than just an abstraction. Abstraction would, on the other hand be:
``(L x , x)``.

Because these rules are notable in any functional and Lisp like language, there
is a great temptation to implement Lambda calculus evaluator as a native
anonymous function calls. The problem with this approach is very subtle and
will bring practicer to the deep foundations of programming language. That is,
in which order to evaluate arguments and functions and how to deal with argument
name collisions.

Evaluation
----------

Next we need some evaluation rules to call the function with given input and
give the result. These rules or procedures are called:

- alpha conversion
- beta reduction

Optional:

- eta conversion

*****

All available Lambda macros are:

- CONST IDENT LET LET*
- TRUE FALSE
- PAIR HEAD TAIL FIRST SECOND NIL NIL?
- NUM ZERO ONE TWO THREE FOUR FIVE SIX SEVEN EIGHT NINE TEN
- ZERO? EQ? LEQ?
- COND AND OR NOT XOR IMP
- PRED SUCC SUM SUB PROD EXP
- SELF YCOMB
- SUMMATION FACTORIAL FIBONACCI

In reality, there is really not so much to implement because Hy is already a
Lisp language with a quite consice anonymous function notation. Lisp, on the
other hand, can be defined as *an untyped Lambda calculus extended with
constants*. So actually we just need to introduce the `𝜆` macro, simplify
the usual Lisp notation, and act only with functions. Maybe more useful are all
main concepts and Lambda terms presented in the document. One can study the
very basics of functional language with given examples.

At the current development stage, `Calchylus` does not provide alpha conversion
and beta [reduction](https://en.wikipedia.org/wiki/Lambda_calculus#Reduction)
stages of terms as an output. `Calchylus` provides just the direct evaluated
result via the `𝜆` macro.

### Repository

`Calchylus` Jupyter notebook [document](http://nbviewer.jupyter.org/github/markomanninen/calchylus/blob/master/Calchylus%20-%20Lambda%20calculus%20in%20Hy.ipynb) and GitHub [repository](https://github.com/markomanninen/calchylus) was initialized by [Marko Manninen](https://github.com/markomanninen), 08/2017.



The `MIT <http://choosealicense.com/licenses/mit/>`__ License
-------------------------------------------------------------

Copyright (c) 2017 Marko Manninen

.. |Output:| replace:: [output]
