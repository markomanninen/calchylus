
Macro shorthands
================

Whilst in Lambda calculus there is no limit on how many or what kind of forms
one can create, there is a set of common forms useful for constructing Lambda
expressions. Named forms are provided as macros in Hy based ``calchylus``
module and they serve for shorthands when coding in Lambda calculus. Named forms
are useful in explaining Lambda calculus and they make expressions more compact,
readable, and understandable.

This is the list of the all available macros for Lambda forms in ``calchylus``
module:

Basic constructors

- ``APP`` - an application
- ``CONST`` - a constant
- ``IDENT`` - an identity

Boolean constructors

- ``TRUE`` - an arbitrary tautology
- ``FALSE`` - an arbitrary contradiction

Logical connective constructors

- Unary

  - ``NOT`` - a negation

- Binary

  - ``AND`` - a conjuction
  - ``OR`` - a disjunction
  - ``XOR`` - an exclusive disjunction
  - ``IMP`` - a material implication
  - ``EQV`` - an equivalence / a material biconditional

Structural constructors

- ``COND`` - a condition block for flow control
- ``LET`` - introduce a variable/variables with a value / values, last term is the function body!
- ``LET*`` - same as LET, but consequencing variables can use former variables in the body
- ``DO`` - do things in sequence, similar to ``LET*``, but except setters are disclosed

2-tuple constructor

- ``PAIR`` - a `nested ordered pair <https://en.wikipedia.org/wiki/Tuple#Tuples_as_nested_ordered_pairs>`__
- ``HEAD`` - a head of the pair
- ``TAIL`` - a tail of the pair

List constructors

- ``LIST`` - create list with sequential items, generates nested pairs from given terms
- ``PREPEND`` - prepend to the beginning of the list
- ``APPEND`` - append to the end of the list
- ``FIRST`` - the first item of the list
- ``SECOND`` - the second item of the list
- ``LAST`` - the last item of the list
- ``EMPTY?`` - is given term an empty list?
- ``LEN?`` - length of the list?
- ``NIL?`` - is given term nil?

- Internal

  - ``NIL`` - a nil for the empty set
  - ``∅`` - an empty set

Church numerals

- ``NUM`` - a Church numeral generator
- ``ZERO`` - the number zero, same as ``FALSE``
- numerals from one to ten

  - ``ONE`` ``TWO`` ``THREE`` ``FOUR`` ``FIVE`` ``SIX`` ``SEVEN`` ``EIGHT`` ``NINE`` ``TEN``

- ``NUM?`` - is given term a number, unary predicate checker for Church numbers

Number equivalence

- ``ZERO?`` - is number zero?
- ``EQ?`` - are two numbers equal?
- ``LEQ?`` - is number a equal or smaller than b?
- ``GEQ?`` - is number a equal or greater than b?
- ``LE?`` - is number a less than b?
- ``GE?`` - is number a greater than b?

Arithmetic constructors

- ``SUCC`` - a successor of a number
- ``PRED`` - a predecessor of a number
- ``SUM`` - a summa of two numbers
- ``SUB`` - a substraction of two numbers
- ``PROD`` - a product of two numbers
- ``EXP`` - the nth power of number x

Recursive constructors

- ``SELF`` - a self application
- ``YCOMB`` - an Y combinator

Sample mathematical functions

- ``SUMMATION`` - thte nth triangular number
- ``FACTORIAL`` - a product of numbers up to n
- ``FIBONACCI`` - the nth Fibonacci number
