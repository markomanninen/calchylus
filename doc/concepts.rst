
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
   lambda letter: ``λ``
2. Lambda function argument and body separator, that is usually a dot: ``.``

Optionally two more syntax rules can be implemented:

3. Parentheses to group and indicate Lambda applications, abstractions,
   function bodies and variables. The most convenient way is to use left ``(``
   and right ``)`` parentheses. Other purpose of using parentheses is to
   visually make Lambda expressions easier to read and to avoid arbitrarities
   in Lambda expressions.
4. Space character to distinct function indicator, separator, variables, body,
   and arguments. This is optional, because in the simplest Lambda calculus
   implementation single character letters are used to denote variables. But it
   is easy to see that this would be quite limiting for the practical purposes.

Knowing these we should be fine to write Lambda expressions.
