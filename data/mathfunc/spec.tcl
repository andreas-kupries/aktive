# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

## This file contains function specifications in the form of C/C++ code fragments, and
## also references the function templates these fragments will be inserted into. This
## should make the code generator easier, and also easier to keep fragments and
## environment in sync with each other. The main things to keep track of between here and
## the generator are the placeholders to use, and any special processing the generator
## does.
#
## Each math function __has to__ have a `direct` specification, to support scalar implementation.
## Each math function __may__ have a `highway` specification to support Highway SIMD.
##
## In production mode a highway specification has preference over direct.
## In benchmarking mode all specifications are implemented to allow for comparison.
#
## The general placeholders in use are:
##
## - `@name@`	Name of the math function code is generated for.
## - `@opcode@` The C/C++ code executed within the scalar (`direct`) or vector (`highway`) loop.
##
## Placeholders specific to `highway` are:
##
## - `@decls@` Set of code-specific `const auto` declarations to be placed before the
##             vector loop. They are pulled out of the original code fragment by looking
##             for lines prefixed with `const auto `.
#
## - `@0`   Common vector constant `0`.
## - `@1`   Common vector constant `1`.
## - `@-1`  Common vector constant `-1`.
## - `@0.5` Common vector constant `0.5`.
#
## The `const auto` declarations needed for the above constants are auto-generated for the
## code fragments using them.
#
## The interface between code fragments and templates is kept track of here alone.
##
## The template environments provide the following variables to `@opcode@`. All are of
## type `double` for the scalar code, and of whatever vector type the highway type tag
## `f64` refers to.
##
## - `v` The variable for the code to place the result into.
##       Also the primary input variable for all unary operations.
##
## - `a` Single parameter of unary operations with a parameter;
##       First parameter of unary operations with two parameters;
##       First input of binary operations.
##
## - `b` Second parameter of unary operations with two parameters;
##       Second input of binary operations.
##
## Note that loading of inputs and storing of results is performed by the templates.
## The @opcode@ only has to care about computing the proper result from the inputs.
#
## Highway provides the following vector instructions:
#
# Zero (T)
# Set  (T, val)
# Iota (T, startval)
#
# Neg        (v)
# Abs        (v)
# Sqrt       (v)
# Round      (v)
# Trunc      (v)
# Ceil       (v)
# Floor      (v)
# IsNegative (v)
#
# Add   (a, b)
# Sub   (a, b)
# Div   (a, b)
# Mod   (a, b) // not for float
# Mul   (a, b)
#
# Clamp (v, low, high)
#
# Eq    (a, b)
# Lt    (a, b)
# Gt    (a, b)
# Ne    (a, b)
# Le    (a, b)
# Ge    (a, b)
#
# ApproximateReciprocal (v) (Div(1, v) better ?)
#
# MinNumber (a, b)
# MaxNumber (a, b)
#
# MulAdd    (a, b, c)	 a*b+c
# NegMulAdd (a, b, c)   -a*b+c
# MulSub    (a, b, c)	 a*b-c
# NegMulSub (a, b, c)	-a*b-c
#
# IfThenElse             (m, t, e)
# IfThenElseZero         (m, t)    ==> IfThenElse (m, t, Zero)
# IfThenZeroElse         (m, e)    ==> IfThenElse (m, Zero, e)
#
# IfNegativeThenElse     (v, t, e) ==> IfThenElse (IsNegative (v), t, e)
# IfNegativeThenElseZero (v, t)    ==> IfNegativeThenElse (v, t, Zero)
# IfNegativeThenZeroElse (v, e)    ==> IfNegativeThenElse (v, Zero, e)
#
# IfVecThenElse (v, t, e) ==> IfThenElse (MaskFromVec (v), t, e)
#
# Not
# And
# Or
# Xor
# AndNot (a, b) !a && b
#
# SumOfLanes	+ GetLane ... => ReduceSum
# MaxOfLanes                     ReduceMax
# MinOfLanes                     ReduceMin
#

# # ## ### ##### ######## #############
## Unary math functions, without parameters
##
## code environment
## - `v` = input value to transform, also output

set unary0 {
    acos  { direct { v = acos  (v);     } }
    acosh { direct { v = acosh (v);     } }
    asin  { direct { v = asin  (v);     } }
    asinh { direct { v = asinh (v);     } }
    atan  { direct { v = atan  (v);     } }
    atanh { direct { v = atanh (v);     } }
    cbrt  { direct { v = cbrt  (v);     } }
    ceil {
	direct  { v = ceil (v); }
	highway { v = Ceil (v); }
    }
    clamp {
	direct  { v = fmax (0, fmin (1, v)); }
	highway { v = Clamp (v, @0, @1); }
    }
    cos   { direct { v = cos   (v);     } }
    cosh  { direct { v = cosh  (v);     } }
    exp   { direct { v = exp   (v);     } }
    exp10 { direct { v = pow   (10, v); } }
    exp2  { direct { v = exp2  (v);     } }
    fabs {
	direct  { v = fabs (v); }
	highway { v = Abs  (v); }
    }
    floor {
	direct  { v = floor (v); }
	highway { v = Floor (v); }
    }
    gamma_compress {
	direct {
	    #define GAMMA  (2.4)
	    #define OFFSET (0.055)
	    #define SCALE  (1.055)
	    #define IGAIN  (12.92)
	    #define ILIMIT (0.0031308)
	    v = (v <= ILIMIT) ? v * IGAIN : SCALE * pow (v, 1.0/GAMMA) - OFFSET;
	    #undef GAMMA
	    #undef OFFSET
	    #undef SCALE
	    #undef IGAIN
	    #undef ILIMIT
	}
	disabled-highway {
	    CDEF (igamma, 1.0/2.4);
	    CDEF (offset, 0.055);
	    CDEF (scale,  1.055);
	    CDEF (igain,  12.92);
	    CDEF (ilimit, 0.0031308);
	    v = IfThenElse (Le (v, ilimit), Mul (v, igain), Sub (Mul (scale, !POW! (v, igamma)), offset));
	    // !POW! this is the missing piece
	}
    }
    gamma_expand {
	direct {
	    #define GAMMA  (2.4)
	    #define OFFSET (0.055)
	    #define SCALE  (1.055)
	    #define IGAIN  (12.92)
	    #define GLIMIT (0.04045)
	    v = (v <= GLIMIT) ? v / IGAIN : pow ((v + OFFSET) / SCALE, GAMMA);
	    #undef GAMMA
	    #undef OFFSET
	    #undef SCALE
	    #undef IGAIN
	    #undef GLIMIT
	}
	disabled-highway {
	    CDEF (gamma,  2.4);
	    CDEF (offset, 0.055);
	    CDEF (scale,  1.055);
	    CDEF (igain,  12.92);
	    CDEF (glimit, 0.04045);
	    v = IfThenelse (Le (v, glimit), Div (v, igain), !POW! (Div (Add (v, offset), scale), gamma));
	    // !POW! this is the missing piece
	}
    }
    invert {
	direct  { v = 1 - v; }
	highway { v = Sub (@1, v); }
    }
    log        { direct { v = log   (v);          } }
    log10      { direct { v = log10 (v);          } }
    log2       { direct { v = log2  (v);          } }
    neg {
	direct  { v = - v; }
	highway { v = Neg (v); }
    }
    not {
	direct  { v = (v <= 0.5) ? 1 : 0; }
	highway { v = IfThenElseZero (Le (v, @0.5), @1); }
    }
    reciprocal {
	direct  { v = 1.0 / v; }
	highway { v = Div (@1, v); }
    }
    round {
	direct  { v = round (v); }
	highway { v = Round (v); }
    }
    sign {
	direct  { v = (v < 0) ? -1 : (v > 0) ? 1 : 0; }
	highway { v = IfNegativeThenElse (v, @-1, IfThenElseZero (Gt (v, @0), @1)); }
    }
    signb {
	direct  { v = (v < 0) ? -1 : 1; }
	highway { v = IfNegativeThenElse (v, @-1, @1); }
    }
    sin        { direct { v = sin  (v);           } }
    sinh       { direct { v = sinh (v);           } }
    sqrt {
	direct  { v = sqrt (v); }
	highway { v = Sqrt (v); }
    }
    square {
	direct  { v = v * v; }
	highway { v = Mul (v, v); }
    }
    tan        { direct { v = tan  (v);           } }
    tanh       { direct { v = tanh (v);           } }
    wrap       { direct { v = (v > 1) ? fmod(v, 1) : (v < 0) ? (1 + fmod(v - 1, 1)) : v;    } }
}

# # ## ### ##### ######## #############
## Unary math functions, single parameter
##
## code environment
## - `v` = input value to transform, also output
## - `a` = parameter

set unary1 {
    atan2  { direct { v = atan2 (v, a);       } }
    eq     {
	direct  { v = (v == a) ? 1 : 0; }
	highway { v = IfThenElseZero (Eq (v, a), @1); }
    }
    expx   { direct { v = pow (a, v);         } }
    fmax   {
	direct  { v = fmax (v, a); }
	highway { v = Max  (v, a); }
    }
    fmin   {
	direct  { v = fmin (v, a); }
	highway { v = Min  (v, a);	}
    }
    fmod   { direct { v = fmod(v, a);         } }
    ge     {
	direct  { v = (v >= a) ? 1 : 0; }
	highway { v = IfThenElseZero (Ge (v, a), @1); }
    }
    gt     {
	direct  { v = (v > a) ? 1 : 0;  }
	highway { v = IfThenElseZero (Gt (v, a), @1); }
    }
    hypot  { direct { v = hypot (v, a);       } }
    le     {
	direct  { v = (v <= a) ? 1 : 0; }
	highway { v = IfThenElseZero (Le (v, a), @1); }
    }
    lt     {
	direct  { v = (v <  a) ? 1 : 0; }
	highway { v = IfThenElseZero (Lt (v, a), @1); }
    }
    ne     {
	direct  { v = (v != a) ? 1 : 0;   }
	highway { v = IfThenElseZero (Ne (v, a), @1); }
    }
    nshift {
	direct  { v = a - v;      }
	highway { v = Sub (a, v); }
    }
    pow    { direct { v = pow (v, a);         } }
    ratan2 { direct { v = atan2 (a, v);       } }
    rfmod  { direct { v = fmod (a, v);        } }
    rscale {
	direct  { v = a / v;      }
	highway { v = Div (a, v); }
    }
    scale  {
	direct  { v = v * a;      }
	highway { v = Mul (v, a); }
    }
    shift  {
	direct  { v = v + a;      }
	highway { v = Add (v, a); }
    }
    sol    {
	direct  { v = (v <= a) ? v : 1-v; }
	highway { v = IfThenElse (Le (v, a), v, Sub (@1, v)); }
    }
}

# # ## ### ##### ######## #############
## Unary math functions, two parameters
##
## code environment
## - `v` = input value to transform, also output
## - `a` = parameter 1
## - `b` = parameter 2

set unary2 {
    inside_cc  {
	direct  { v = (a <= v) && (v <= b) ? 1 : 0; }
	highway { v = IfThenElseZero (And (Le (a, v), Le(v, b)), @1); }
    }
    inside_co {
	direct  { v = (a <= v) && (v <  b) ? 1 : 0; }
	highway { v = IfThenElseZero (And (Le (a, v), Lt(v, b)), @1); }
    }
    inside_oc {
	direct  { v = (a <  v) && (v <= b) ? 1 : 0; }
	highway { v = IfThenElseZero (And (Lt (a, v), Le(v, b)), @1); }
    }
    inside_oo {
	direct  { v = (a <  v) && (v <  b) ? 1 : 0; }
	highway { v = IfThenElseZero (And (Lt (a, v), Lt(v, b)), @1); }
    }
    outside_cc {
	direct  { v = (a <= v) && (v <= b) ? 0 : 1; }
	highway { v = IfThenZeroElse (And (Le (a, v), Le(v, b)), @1); }
    }
    outside_co {
	direct  { v = (a <= v) && (v <  b) ? 0 : 1; }
	highway { v = IfThenZeroElse (And (Le (a, v), Lt(v, b)), @1); }
    }
    outside_oc {
	direct  { v = (a <  v) && (v <= b) ? 0 : 1; }
	highway { v = IfThenZeroElse (And (Lt (a, v), Le(v, b)), @1); }
    }
    outside_oo {
	direct  { v = (a <  v) && (v <  b) ? 0 : 1; }
	highway { v = IfThenZeroElse (And (Lt (a, v), Lt(v, b)), @1); }
    }
}

# # ## ### ##### ######## #############
## Binary math functions
##
## code environment
## - `a` = input value 1
## - `b` = input value 2
## - `v`  = output

set binary {
    and   {
	direct  { v = ( a >  0.5) && (b >  0.5) ? 1 : 0; }
	highway { v = IfThenElseZero (And (Gt(a, @0.5), Gt(b, @0.5)), @1); }
    }
    nand  {
	direct  { v = ( a >  0.5) && (b >  0.5) ? 0 : 1; }
	highway { v = IfThenZeroElse (And (Gt(a, @0.5), Gt(b, @0.5)), @1); }
    }
    nor   {
	direct  { v = ( a >  0.5) || (b >  0.5) ? 0 : 1; }
	highway { v = IfThenZeroElse (Or (Gt(a, @0.5), Gt(b, @0.5)), @1); }
    }
    or    {
	direct  { v = ( a >  0.5) || (b >  0.5) ? 1 : 0; }
	highway { v = IfThenElseZero (Or (Gt(a, @0.5), Gt(b, @0.5)), @1); }
    }
    xor   {
	direct  { v = ((a > 0.5) && (b <= 0.5)) || ((a <= 0.5) && (b >  0.5)) ? 1 : 0; }
	highway { v = IfThenElseZero (Xor (Gt(a, @0.5), Gt(b, @0.5)), @1); }
    }

    add   {
	direct  { v = a + b; }
	highway { v = Add (a, b); }
    }
    sub   {
	direct  { v = a - b; }
	highway { v = Sub (a, b); }
    }
    mul   {
	direct  { v = a * b; }
	highway { v = Mul (a, b); }
    }
    div   {
	direct  { v = a / b; }
	highway { v = Div (a, b); }
    }
    fmod  { direct { v = fmod (a, b); } }
    pow   { direct { v = pow  (a, b); } }

    atan2 { direct { v = atan2 (a, b); } }
    hypot { direct { v = hypot (a, b); } }
    fmax  {
	direct  { v = fmax (a, b); }
	highway { v = Max  (a, b); }
    }
    fmin  {
	direct  { v = fmin (a, b); }
	highway { v = Min  (a, b); }
    }

    eq    {
	direct  { v = (a == b) ? 1 : 0; }
	highway { v = IfThenElseZero (Eq (a, b), @1); }
    }
    ge    {
	direct  { v = (a >= b) ? 1 : 0; }
	highway { v = IfThenElseZero (Ge (a, b), @1); }
    }
    gt    {
	direct  { v = (a >  b) ? 1 : 0; }
	highway { v = IfThenElseZero (Gt (a, b), @1); }
    }
    le    {
	direct  { v = (a <= b) ? 1 : 0; }
	highway { v = IfThenElseZero (Le (a, b), @1); }
    }
    lt    {
	direct  { v = (a <  b) ? 1 : 0; }
	highway { v = IfThenElseZero (Lt (a, b), @1); }
    }
    ne    {
	direct  { v = (a != b) ? 1 : 0; }
	highway { v = IfThenElseZero (Ne (a, b), @1); }
    }
}

# # ## ### ##### ######## #############
## Templates for the vector and highway functions.
## This is the code we put the function code fragments
## declared above into.

set here [file dirname [info script]]

# # ## ### ##### ######## #############
## vector direct, various levels of loop unrolling

source $here/direct1.tcl
source $here/direct2.tcl
source $here/direct4.tcl

# # ## ### ##### ######## #############
## vector highway, no unrolling

source $here/highway1.tcl
source $here/highway2.tcl
source $here/highway4.tcl

# # ## ### ##### ######## #############

return
