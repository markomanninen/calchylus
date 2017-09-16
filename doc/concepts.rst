

Concepts of Lambda calculus
===========================

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
   lambda letter: ``𝜆``
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
``𝜆x.x y`` becomes ``(L x , x y)`` in ``calchylus`` notation. Infact, the
function indicator and the separator character can be freely defined in
``calchylus``. In the most of the examples we will use ``L`` and ``,`` because
it will be easier to type ``L`` from the keyboard. Using the comma rather than
the dot comes from the Hy programming language environment restrictions, where
the dot is a reserved letter for cons in list processing.

Let us strip down the former expression and show how all rules are taking place
in it.

In ```(L x , x y)``, ``L`` is the Lambda function indicator and parentheses
``()`` indicate the whole application that should be evaluated. ``x`` before the
separator ``,`` is the function argument. ``x`` after the separator is the
function body or just the Lambda term, as it is more conventionally called.
Finally ``y`` is the value for the function, thus we have a full application
here, rather than just an abstraction. Abstraction would, on the other hand be:
``(L x , x)``.

.. note::

	In mathematics, identity function can be denoted either by $f(x) = x$ or by
  $x → f(x)$.

Because these rules are notable in any functional and Lisp like language, there
is a great temptation to implement Lambda calculus evaluator as a native
anonymous function calls. The problem with this approach is very subtle and
will bring practicer to the deep foundations of the programming languages. That
is, to decide in which order to evaluate arguments and functions and how to deal
with argument name collisions.

.. |Output:| replace:: [output]
