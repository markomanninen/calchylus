
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

1. Lambda function indicator, that is usually a Greek lambda letter: `𝜆`
2. Lambda function argument and body separator, that is usually a dot: `.`

Optional:

3. Parentheses to group and indicate the Lambda function bodies and variables.
The most convenient way is to use left `(` and right `)` parentheses for this.
Other purpose of using parentheses is to visually make Lambda expressions easier
to read and avoid arbitrarities in Lambda expressions.
4. Space character to indicate separate variables. This is optional, because in
the simplest form single characters are used to denote variables. But it is easy
to see that this is quite limiting for practical purposes.

All seven rules are implemented in the `Calchylus` module so that for example
the very basic Lambda calculus application `𝜆x.x y` becomes
`(𝜆 x . x y)` in `Calchylus` notation. Infact, function indicator and
separator characters can be freely defined in `Calchylus`. In the most of the
examples we will use `L` and `,` because it will be easier to type `L` from the
keyboard. Using comma rather than dot comes from the Hy programming language
environment restrictions, because dot is reserved for cons in list processing.

Let us strip down the former expression and show how all rules are taking place
in it.

In `(L x , x y)`, `L` is the Lambda function indicator and parentheses `()`
indicate the whole application that should be evaluated. `x` before the
separator `,` is the function argument. `x` after the separator is the function
body or just the Lambda term, as it is more conventionally called. Finally `y`
is the value for the function, thus we have a full application here, rather
than just an abstraction. Abstraction would, on the other hand be: `(L x , x)`.

Because these rules are notable in any functional and Lisp like language, there
is a great temptation to implement Lambda calculus evaluator as a native
anonymous function calls. The problem with this approach is very subtle and
will bring practicer to the deep foundations of programming language. That is,
in which order to evaluate arguments and functions and how to deal with argument
name collisions.

### Evaluation

Next we need some evaluation rules to call the function with given input and
give the result. These rules or procedures are called:

- alpha conversion
- beta reduction

Optional:

- eta conversion
