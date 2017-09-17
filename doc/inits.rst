
Initialization macros
=====================

After importing ``calchylus`` module with ``(require [calchylus.lambdas [*]])``,
the system itself is initialized by one of the four start up macros:

- ``with-macros``, that loads macro shorthands
- ``with-alpha-conversion``, that make argument renaming in the background
- ``with-alpha-conversion-and-macros``, that loads both features
- ``with-alpha-conversion-nor-macros``, that loads neither one

``with-alpha-conversion-and-macros`` is the recommended way of using the module,
because it will provide automatic alpha conversion for variable names and
import useful shorthands for dozens of well known custom lambda forms.

There are two parameters you can use on initialization:

1. lambda character identifier (more formally the binding operator)
2. argument and body separator character

Identifier is usually a lambda character ``λ``, but can be any character you
desire. Even unicode letters are supported, which often is typographically
more satisfying. Writing unicode letters from keyboard however, can be tricky
so one need to rely on copy and paste, when you use an unicode identifier.

Same applies to separator character. For a demonstration, let us load the full
recommended set from the ``calchylus`` module:

.. code-block:: hylang

	(with-alpha-conversion-and-macros λ ·)

There will be an output, that indicates last created lambda function, something
like:

.. code-block:: text

	<function <lambda> at 0x000001790B7208C8>

Althought using ``with-alpha-conversion-and-macros`` is the recommended, for
efficiency, testing, and benchmarking purposes, one would sometimes
want to load only macros to the global Hy environment by
``with-macros``.

Similarly, by initializing ``with-alpha-conversion``, macros
are discarded but alpha conversion is activated. In that case you cannot use
macro shorthands on Lambda expressions, which may or may not be a good idea,
depending on your purpose.

Lastly, there is an option to do neither one by
``with-alpha-conversion-nor-macros``. You will like hit some problems like
recursion error if using this with complex Lambda expressions. With a very
careful argument name selection you could pass these problems, but one should
note, that there is no internal warning if argument overriding happens, or on
the other hand, if there are any arguments that are not bound, not used, or not
replaced.
