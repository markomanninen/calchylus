#! /usr/bin/env hy
;----------------------------------------------
; Calchylus - Lambda calculus with Hy
;
; Source:
; https://github.com/markomanninen/calchylus/
;
; Install:
; $ pip install calchylus
;
; Open Hy:
; $ hy
;
; Import library:
; (require [calchylus2.lambdas [*]])
; (import [calchylus2.lambdas [*]])
;
; Initialize macros:
; (with-macros L)
;
; Use:
; (L x y (x (x y)) a b) ->
; (a (a b))
;
; Documentation: http://calchylus.readthedocs.io/
; Author: Marko Manninen <elonmedia@gmail.com>
; Copyright: Marko Manninen (c) 2019
; Licence: MIT
;----------------------------------------------

(setv __version__ "v0.1.25")
