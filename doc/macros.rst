
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

- ``APP`` (application)
- ``CONST`` constant
- ``IDENT`` - identity

Boolean constructors

- ``TRUE``
- ``FALSE``

Logical connective constructors

- Unary
  - ``NOT``

- Binary
  - ``AND``
  - ``OR``
  - ``XOR``
  - ``IMP``
  - ``EQV``

Structural constructors

- ``COND`` a condition block for flow control
- ``LET``, ``LET*``
- ``DO`` do in sequence

2-tuple constructor

- ``PAIR`` a `nested ordered pair <https://en.wikipedia.org/wiki/Tuple#Tuples_as_nested_ordered_pairs>`__
- ``HEAD``
- ``TAIL``

List constructors

- LIST
- PREPEND
- APPEND
- FIRST
- SECOND
- LAST
- EMPTY?
- LEN?
- NIL?
- NIL
- ``∅`` empty set

Church numerals

- NUM
- ZERO
- ONE TWO THREE FOUR FIVE SIX SEVEN EIGHT NINE TEN
- NUM?

Number equivalence

- ZERO?
- EQ?
- LEQ?
- GEQ?
- LE?
- GE?

Arithmetic constructors

- SUCC
- PRED
- SUM
- SUB
- PROD
- EXP

Recursive constructors

- SELF
- YCOMB

Sample mathematical functions

- SUMMATION
- FACTORIAL
- FIBONACCI
