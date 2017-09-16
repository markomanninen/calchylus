
Lambda expressions in ``calchylus`` module
==========================================

All `three concepts and four rules <http://calchylus.readthedocs.io/en/latest/concepts.html>`__
are implemented in the ``calchylus`` module so that for example the very basic
Lambda calculus identity application ``λx.x y`` becomes ``(L x , x y)`` in
``calchylus`` notation. Infact, the function indicator and the separator
character can be freely defined in ``calchylus``. In the most of the examples
we will use ``L`` and ``,`` because it will be easier to type ``L`` from the
keyboard. Using the comma rather than the dot comes from the Hy programming
language environment restrictions, where the dot is a reserved letter for cons
in list processing.

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

Let us first see the easy native implementation of the Lambda calculus to learn
what all this means.
