# Calchylus - Lambda calculus with Hy

`Calchylus` is a combination of [Hy](http://docs.hylang.org) macro and Lambda term dictionary. It was written to help to write and evaluate Lambda expressions.

<blockquote>[Lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus) is a formal system in mathematical logic for expressing computation based on function abstraction and application using variable binding and substitution. -<i> wikipedia.org</i></blockquote>

The short `𝜆` macro presented below, makes it possible to define and evaluate Lambda expressions the most conventional way. There is really not much to implement because Hy is already a LISP language. LISP, on the other hand, can be defined as *an untyped Lambda calculus extended with constants*. So actually we just need to introduce `𝜆` macro,  simplify the usual LISP notation, and act only with functions.

At the current development stage, `Calchylus` does not provide alpha and beta reduction stages of the terms, just direct evaluation.

### Repository

`Calchylus` Jupyter notebook [document](http://nbviewer.jupyter.org/github/markomanninen/calchylus/blob/master/Calchylus%20-%20Lambda%20calculus%20in%20Hy.ipynb) and GitHub [repository](https://github.com/markomanninen/calchylus) was initialized by [Marko Manninen](https://github.com/markomanninen), 08/2017.
