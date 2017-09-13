# Calchylus - Lambda calculus with Hy

`Calchylus` is a [Hy](http://docs.hylang.org) module that is used to write, evaluate, and understand Lambda calculus.

<blockquote><a href="https://en.wikipedia.org/wiki/Lambda_calculus">Lambda calculus</a> is a formal system in mathematical logic for expressing computation based on function abstraction and application using variable binding and substitution. -<i> wikipedia.org</i></blockquote>

The `𝜆` (Lambda) macro, that is presented in the document, makes it possible to define and evaluate Lambda expressions the most conventional way in Hy environment.

In reality, there is really not so much to implement because Hy is already a Lisp language with a quite consice anonymous function notation. Lisp, on the other hand, can be defined as *an untyped Lambda calculus extended with constants*. So actually we just need to introduce the `𝜆` macro, simplify the usual Lisp notation, and act only with functions. Maybe more useful are all main concepts and Lambda terms presented in the document. One can study the very basics of functional language with given examples.

At the current development stage, `Calchylus` does not provide alpha conversion and beta [reduction](https://en.wikipedia.org/wiki/Lambda_calculus#Reduction) stages of terms as an output. `Calchylus` provides just the direct evaluated result via the `𝜆` macro.

### Repository

`Calchylus` Jupyter notebook [document](http://nbviewer.jupyter.org/github/markomanninen/calchylus/blob/master/Calchylus%20-%20Lambda%20calculus%20in%20Hy.ipynb) and GitHub [repository](https://github.com/markomanninen/calchylus) was initialized by [Marko Manninen](https://github.com/markomanninen), 08/2017.
