
Introduction
============

Calchylus is a computer installable `Hy`_ module that is used to evaluate
Lambda expressions, and furthermore through this documentation, shine light to
the basics of Lambda calculus (also written as λ-calculus).

.. note::

	`Lambda calculus`_ is a formal system in mathematical logic for expressing
	computation that is based on function abstraction and application using
	variable binding and substitution.

The target audience is those who:

a) are interested in the theory and the history of the programming languages
b) may have or are interested to gain some experience in Python and/or Lisp
c) who wants to narrow the gap between mathematical notation and
   programming languages, especially by means of logic

`Andrew Bayer`_ writes in his blog post about formal proofs and deduction:

	*Traditional logic, and to some extent also type theory, hides computation
	behind equality.*

Lambda calculus, on the other hand, reveals how the computation in logic is
done by manipulation of the Lambda terms. Manipulation rules are simple and
were originally made with a paper and a pen, but now we rather use computers for
the task. Lambda calculus also addresses the problem, what can be proved and
solved and what cannot be computed in a finite time. Formally these are called
the `decidability`_ and the `halting problem`_.

Beside evaluating Lambda expressions, ``calchylus`` module can serve as a
starting point for a mini programming language. Via `custom macros`_
representing well known Lambda forms, ``calchylus`` provides all necessary
elements for boolean, positive integer, and list data types as well as
conditionals, loops, variable setters, imperative do structure, logical
connectives, and arithmetic operators. You can build upon that, for example
`real numbers`_, even negative complex numbers if that makes any sense. Your
imagination is really the only limit.

Finally, when investigating the open source ``calchylus`` implementation that is
hosted on `GitHub`_ , one can expect to get a good understanding of the higher
order functions and the `combinatory logic`_, not the least of the fixed point
combinator or shortly, ϒ combinator:

$$\\Large ϒ = 𝜆x.(𝜆y.x \\space (y \\space y)) \\space (𝜆y.x \\space (y \\space y))$$

.. _halting problem: http://www.huffingtonpost.com/entry/how-to-describing-alan-turings-halting-problem-to_us_58d1ae08e4b062043ad4add7
.. _combinatory logic: https://en.wikipedia.org/wiki/Combinatory_logic
.. _GitHub: https://github.com/markomanninen/calchylus
.. _real numbers: https://cs.stackexchange.com/questions/2272/representing-negative-and-complex-numbers-using-lambda-calculus?noredirect=1&lq=1
.. _my favorite programming language: http://www.python.org
.. _custom macros: http://calchylus.readthedocs.io/en/latest/macros.html
.. _decidability: https://plato.stanford.edu/entries/computability/#UnsHalPro
.. _Andrew Bayer: http://math.andrej.com/2016/08/30/formal-proofs-are-not-just-deduction-steps/
.. _Lambda calculus: https://en.wikipedia.org/wiki/Lambda_calculus
.. _Hy: http://docs.hylang.org
