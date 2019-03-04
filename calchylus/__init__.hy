#! /usr/bin/env hy
;----------------------------------------------
; Calchylus - Lambda calculus with Hy
;
; Source:
; https://github.com/markomanninen/calchylus/
;
; Install:
; $ pip install hy calchylus
;
; Open Hy:
; $ hy
;
; Import library:
; (require (calchylus.lambdas (*)))
;
; Initialize macros:
; (with-alpha-conversion-and-macros L ,)
;
; Use:
; (λ x y , (x (x y)) a b) ->
; (a (a b))
;
; Documentation: http://calchylus.readthedocs.io/
; Author: Marko Manninen <elonmedia@gmail.com>
; Copyright: Marko Manninen (c) 2017
; Licence: MIT
;----------------------------------------------

(setv __version__ "v0.1.22")
