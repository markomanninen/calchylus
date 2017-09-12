import hy
from hy.models import HyExpression, HySymbol
from hy.core.language import gensym, is_coll, is_symbol, read_str

# lambda expression macro name
lambdachr = HySymbol("L")
# lambda expression argument and body separator
separator = ","

# pretty print utility
def pprint(expr):
    if is_coll(expr):
        return "(%s)" % " ".join(map(pprint, expr))
    return str(expr)

# safe get index for the first occurrence of the x
# (index (, 1 2) 0) ; -> -1
def index(l, x):
    try:
        return l.index(x)
    except(ValueError, AttributeError) as e:
        return -1

# extend and return list instead of .extend list in place
# provide a as a copy (.copy a) in cases where strange
# recursive error behaviour is occurring
def extend(a, *b):
    for c in b:
        a.extend(c)
    return a

# is expression a generated symbol / unique variable name
def is_gensym(x):
    return x[0] is ":" or x[0] is "\ufdd0"

# is expr(ession) a lambda expression i.e. starts with lambdachr: (L ...)?
def is_L(expr):
    return is_coll(expr) and expr and is_symbol(expr[0]) and expr[0] == lambdachr

# make lambda expression from body and other parts
def build_lambda(body, args = [], vals = []):
    return extend([lambdachr], args, [separator], body, vals)

# get lambda expression parts
# body: (x x), args: (x), values (y), and params: ([x y])
def extract_parts(expr):
    idx = index(expr, separator)
    # if separator index is less than expected
    # lambda expression is possibly malformed, just return the expression
    if idx < 1 or len(expr) < (idx+2):
        return {"body": None, "args": [], "vals": [], "params": []}
    body = expr[idx+1:]
    args, vals = expr[1:idx], body[1:]
    # return body, args, vals, and key-value pairs based on args-vals
    return {"body": body[0], "args": tuple(args), "vals": list(vals), "params": zip(args, vals)}

# substitute lambda sub expr(ession). it requires special handler
# because of variable shadowing and not-coll body
def _substitute(a, b, expr):
    p = extract_parts(expr)
    args, body, vals = p["args"],  p["body"], p["vals"]
    # first substitute a to b in possible values
    if vals:
        vals = substitute(a, b, vals)
    # shadow arguments, don't substitute if a is in new arguments
    # but some instances in vals may have been substituted, so we need to
    # construct expression anyway
    if a in args:
        return build_lambda([body], args, vals)
    if is_coll(body):
        body = substitute(a, b, body)
    else:
        body = b if a == body else body
    return build_lambda([body], args, vals)

# substitute a with b in expr
def substitute(a, b, expr):
    if is_coll(expr):
        # if e is lambda expression, call special handler
        if is_L(expr):
            return _substitute(a, b, expr)
        # else substitute all sub expressions
        return type(expr)(map(lambda e: substitute(a, b, e), expr))
    # return substitute (b), if match is found
    return b if a == expr else expr

# shift arguments inside functions in application expressions
# ((L x , x) a b) -> (L x , x a b) -> (a b)
# ((TRUE) TRUE FALSE) -> (TRUE TRUE FALSE) -> TRUE
# this is required to convert and evaluate substituted function forms
# (L x y z , ((x) y z) TRUE a b) -> ((TRUE) a b) -> (TRUE a b) -> a
def shift_arguments(expr):
    if expr and is_coll(expr):
        f = expr[0]
        if is_L(f):
            expr = extend(f.copy(), expr[1:])
        return type(expr)(map(shift_arguments, expr))
    return expr

# helper for alpha_conversion gensym map
def _gensym(x):
    return x if is_gensym(x) else gensym(x)

# rename arguments for collision prevention
# without renaming this expression (L x y , (x y) y z) would yield: (z z)
# but because arguments are renamed by gensym, expression will become
# (L :x_1234 :y_1234 , (:x_1234 :y_1234) y z) and result corretly: (y z)
# human-readable function can be used to turn expression back to normal form,
# that is, if there are any lambda abstractions available in the expression
def alpha_conversion(expr):
    if is_L(expr):
        p = extract_parts(expr)
        body, args, vals = p["body"],  p["args"], p["vals"]
        args2 = tuple(map(_gensym, args))
        for a, b in zip(args, args2):
            body = substitute(a, b, body)
        return build_lambda([alpha_conversion(body)], args2, (alpha_conversion(vals) if vals else vals))
    return type(expr)(map(alpha_conversion, expr)) if is_coll(expr) else expr

# convert generated machine variable names to normal forms
# but this is rather dummy version. better would be to use
# substitution so that first occurrence of gensym variable
# is given x, and only that one replaced throught out the
# expression. then other possible gensym variable starting
# with x is given x2, x3, x4 and so forth...
def human_readable(expr):
    if is_coll(expr):
        return map(human_readable, expr)
    elif is_gensym(str(expr)):
        idx = index(str(expr), ":") + 1
        return str(expr)[idx:idx+1]
    return expr

def _beta_reduction(expr):
    p = extract_parts(expr)
    body, args, vals  = p["body"], p["args"], p["vals"]
    # rest of the free arguments that are not in params
    free = list(vals[len(args):])
    # substitute bound arguments
    #print("before-substitute-body:", (pprint body))
    for a, b in p["params"]:
        body = substitute(a, b, body)
    # shift application arguments
    if is_coll(body):
        body = shift_arguments(body)
    #print("after-shift-arguments:", (pprint body))
    if is_coll(body):
        if is_L(body):
            body = extend(body, free)
            pp = extract_parts(body)
            vals, args = pp["vals"], pp["args"]
            # if evaluated expression has no further values, but also
            # it is not a constant, render final form
            if not vals and args:
                return human_readable(expr if free else body)
                # else evaluate again but using helper because we know
                # expression is lambda form
            return _beta_reduction(body)
        # if original expression has no values, it was lambda expression and
        # it had arguments, render final form
        elif not vals and is_L(expr) and args:
            return human_readable(expr)
        # else evaluate again using main redex
        return map(beta_reduction, (extend([body], free) if free else body))
    # render final form. here we want to return either
    # the body or the whole expression depending on args, vals and free variables
    if args:
        if vals:
            if free:
                return human_readable(extend([body], free))
            return human_readable(body)
        return human_readable(expr)
    return human_readable(body)

# main form beta / eta reduction steps
def beta_reduction(expr):
    # if the form (expr) is not lambda for i.e. starting with L
    # we still want to seek if there are sub lambda expressions
    # (x (x (L x , x y))) should return (x (x y))
    if is_L(expr):
        return _beta_reduction(expr)
    elif is_coll(expr):
        return map(beta_reduction, expr)
    return human_readable(expr)

# reformulate expression, because by using L macro, L is naturally left out from the expression
# beta-reduction functions on the other hand relys on the L in the beginning of the expression!
# then pass parameters and possibly expand macro form later
def evaluate_lambda_expression(expr, alpha = True):
    expr = extend([lambdachr], expr)
    # if alpha conversion should be used
    if alpha:
        expr = alpha_conversion(expr)
    expr = beta_reduction(expr)
    if is_coll(expr) or is_symbol(expr):
        # symbols and expressions should be pretty "printed"
        return pprint(expr)
    # numbers for example get passed as they are
    # this is not exactly included on lambda calculus but just a way
    # to keep data types existing for hy and later usage
    return expr
