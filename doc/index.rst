
Calchylus - Lambda calculus with Hy
===================================

``calchylus`` is a `Hy <http://docs.hylang.org>`__ module that is used to
evaluate, and furthermore through this documentation, shine light to the basics
of Lambda calculus (also written as λ-calculus).

	`Lambda calculus <https://en.wikipedia.org/wiki/Lambda_calculus>`__ is a
	formal system in mathematical logic for expressing computation that is
	based on function abstraction and application using variable binding and
	substitution. -*wikipedia.org*

Intended audience is those who:

a) are interested in the theory and the history of the programming languages,
b) may have some experience in Python and/or Lisp,
c) but also those, who wants to narrow the gap between mathematical notation and
   programming languages, especially by means of logic.

`Andrew Bayer <http://math.andrej.com/2016/08/30/formal-proofs-are-not-just-deduction-steps/>`__
writes in his blog post in 2016/08:

	Traditional logic, and to some extent also type theory, hides computation
	behind equality.

Lambda calculus, on the other hand, reveals how the computation is made by
manipulation of the Lambda terms.

``calchylus`` can also serve as a starting point for a mini programming language.
Via custom macros representing well known Lambda forms, ``calchylus`` provides
all necessary elements for boolean, integer, and list data types as well as
conditionals, loops, variable setters, mathematical operators, and exemplary
arithmetic functions like, summation, factorial, and fibonacci. Finally, one
can expect to get a good understanding of combinatory logic, not the least of
the fixed point combinator or ϒ combinator:

$$\\Large ϒ = 𝜆x.(𝜆y.x \\space (y \\space y)) \\space (𝜆y.x \\space (y \\space y))$$

Contents:

.. toctree::
   :maxdepth: 3

   quick
   history
   concepts
	 evaluation
   tests
