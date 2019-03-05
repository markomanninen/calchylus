#! /usr/bin/python3
# -*- coding: utf-8 -*-

import hy
#import calchylus
from hy.importer import hy_eval, import_buffer_to_hst

def heval(tokens):
    try:
        return hy_eval(import_buffer_to_hst(tokens), {}, '<string>')
    except Exception as e:
    	print(e)

def peval(tokens):
	return heval("(print %s)" % tokens)

def Y(tokens):
	return heval("""
(require [calchylus2.lambdas [*]])
(import [calchylus2.lambdas [*]])
(with-macros L)
%s
""" % tokens)
