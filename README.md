# Calchylus - Lambda calculus with Hy

`Calchylus` is a [Hy](http://docs.hylang.org) module that is used to evaluate, and furthermore, to understand Lambda calculus (also written as λ-calculus) basics.

<blockquote><a href="https://en.wikipedia.org/wiki/Lambda_calculus">Lambda calculus</a> is a formal system in mathematical logic for expressing computation based on function abstraction and application using variable binding and substitution. -<i> wikipedia.org</i></blockquote>

### Quick start

`pip install calchylus`

`$ hy`

```
> (require [calchylus.lambdas [*]])
> (with-macros L ,)
> (FIBONACCI FIVE)
(x (x (x (x (x (x (x (x (x (x (x (x (x y)))))))))))))
```

### History

Lambda calculus was invented by Alonzo Church in the 1930s. That happened actually a decade before modern electrically powered computers were created. Lambda calculus can be describes as the simplest and the smallest universal programming language.

The most of the modern computer languages utilizes some notation of functions. More precicely, anonymous functions that are not supposed to be referenced by a name in a computer program, are pretty much equivalent to Lambda calculus. But even then, there are some catches one needs to be aware of.

Lambda calculus takes everything to the very few basic computational ideas. First of all, there are three rules to follow in Lambda calculus syntax:

1. variables, that are any single or multiple letters designating parameters or mathematical values
2. abstractions, that are function definitions binding variables to the function body (also called lambda term)
3. application, that applies the function abstraction to the argument

In the original Lambda calculus there was one and one only argument per function, but it was soon shown that nested Lambda abstractions can be used to "imitate" multiary functions.

Two other syntactic rules must be introduced to be able to write and evaluate Lambda applications:

1. Lambda function indicator, that is usually a Greek letter lambda: `𝜆`
2. Lambda function argument and body separator, that usually a dot: `.`

Optional:

3. Parentheses to group and indicate the Lambda function bodies and variables. The most convenient way is to use left `(` and right `)` parentheses for this. Other purpose of using parentheses is to visually make Lambda expressions easier to read.
4. Space character to indicate separate variables. This is optional, because in the simplest case characters are used to denote variables. But it is easy to see that this is quite limiting for practical purposes.

All seven rules are implemented in the `Calchylus` module so that the very basic Lambda calculus application `𝜆x.x y` becomes `(𝜆 x . x y)` in `Calchylus`. Infact, function indicator and separator characters can be freely defined in `Calchylus`. In the most of the examples we will use `L` and `,` because it will be easier to type L from the keyboard. Using comma rather than dot comes from the Hy programming language environment reservations, because dot is used for cons list processing.

Let us strip down the former expression and show how all rules are taking place in it.

In `(L x , x y)`, `L` is the Lambda function indicator and parentheses `()` indicate the whole application that should be evaluated. `x` before the separator `,` is the function argument. `x` after the separator is the function body or just the Lambda term as it is more conventionally called. Finally `y` is the value for the function, thus we have a full application here, rather than just an abstraction. Abstraction would, on the other hand be: `(L x , x)`.

### Evaluation

Next we need some evaluation rules to call the function with given input and give the result. These rules or procedures are called:

- alpha conversion
- beta reduction

Optional:

- eta conversion

*****

In reality, there is really not so much to implement because Hy is already a Lisp language with a quite consice anonymous function notation. Lisp, on the other hand, can be defined as *an untyped Lambda calculus extended with constants*. So actually we just need to introduce the `𝜆` macro, simplify the usual Lisp notation, and act only with functions. Maybe more useful are all main concepts and Lambda terms presented in the document. One can study the very basics of functional language with given examples.

At the current development stage, `Calchylus` does not provide alpha conversion and beta [reduction](https://en.wikipedia.org/wiki/Lambda_calculus#Reduction) stages of terms as an output. `Calchylus` provides just the direct evaluated result via the `𝜆` macro.

### Repository

`Calchylus` Jupyter notebook [document](http://nbviewer.jupyter.org/github/markomanninen/calchylus/blob/master/Calchylus%20-%20Lambda%20calculus%20in%20Hy.ipynb) and GitHub [repository](https://github.com/markomanninen/calchylus) was initialized by [Marko Manninen](https://github.com/markomanninen), 08/2017.
