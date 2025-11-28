# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

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
    ceil  { direct { v = ceil  (v);     } }
    clamp { direct { v = fmax  (0, fmin (1, v)); } }
    cos   { direct { v = cos   (v);     } }
    cosh  { direct { v = cosh  (v);     } }
    exp   { direct { v = exp   (v);     } }
    exp10 { direct { v = pow   (10, v); } }
    exp2  { direct { v = exp2  (v);     } }
    fabs  { direct { v = fabs  (v);     } }
    floor { direct { v = floor (v);     } }
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
    }
    invert     { direct { v = 1 - v;              } }
    log        { direct { v = log   (v);          } }
    log10      { direct { v = log10 (v);          } }
    log2       { direct { v = log2  (v);          } }
    neg        { direct { v = - v;                } }
    not        { direct { v = (v <= 0.5) ? 1 : 0; } }
    reciprocal { direct { v = 1.0 / v;            } }
    round      { direct { v = round (v);          } }
    sign       { direct { v = (v < 0) ? -1 : (v > 0) ? 1 : 0; } }
    signb      { direct { v = (v < 0) ? -1 : 1;   } }
    sin        { direct { v = sin  (v);           } }
    sinh       { direct { v = sinh (v);           } }
    sqrt       { direct { v = sqrt (v);           } }
    square     { direct { v = v * v;              } }
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
    eq     { direct { v = (v == a) ? 1 : 0;   } }
    expx   { direct { v = pow (a, v);         } }
    fmax   { direct { v = fmax (v, a);        } }
    fmin   { direct { v = fmin (v, a);        } }
    fmod   { direct { v = fmod(v, a);         } }
    ge     { direct { v = (v >= a) ? 1 : 0;   } }
    gt     { direct { v = (v > a) ? 1 : 0;    } }
    hypot  { direct { v = hypot (v, a);       } }
    le     { direct { v = (v <= a) ? 1 : 0;   } }
    lt     { direct { v = (v <  a) ? 1 : 0;   } }
    ne     { direct { v = (v != a) ? 1 : 0;   } }
    nshift { direct { v = a - v;              } }
    pow    { direct { v = pow (v, a);         } }
    ratan2 { direct { v = atan2 (a, v);       } }
    rfmod  { direct { v = fmod (a, v);        } }
    rscale { direct { v = a / v;              } }
    scale  { direct { v = v * a;              } }
    shift  { direct { v = v + a;              } }
    sol    { direct { v = (v <= a) ? v : 1-v; } }
}

# # ## ### ##### ######## #############
## Unary math functions, two parameters
##
## code environment
## - `v` = input value to transform, also output
## - `a` = parameter 1
## - `b` = parameter 2

set unary2 {
    inside_cc  { direct { v = (a <= v) && (v <= b) ? 1 : 0; } }
    inside_co  { direct { v = (a <= v) && (v <  b) ? 1 : 0; } }
    inside_oc  { direct { v = (a <  v) && (v <= b) ? 1 : 0; } }
    inside_oo  { direct { v = (a <  v) && (v <  b) ? 1 : 0; } }
    outside_cc { direct { v = (a <= v) && (v <= b) ? 0 : 1; } }
    outside_co { direct { v = (a <= v) && (v <  b) ? 0 : 1; } }
    outside_oc { direct { v = (a <  v) && (v <= b) ? 0 : 1; } }
    outside_oo { direct { v = (a <  v) && (v <  b) ? 0 : 1; } }
}

# # ## ### ##### ######## #############
## Binary math functions
##
## code environment
## - `a` = input value 1
## - `b` = input value 2
## - `v`  = output

set binary {
    and   { direct { v = ( a > 0.5) && (b >  0.5) ? 1 : 0; } }
    nand  { direct { v = ( a > 0.5) && (b >  0.5) ? 0 : 1; } }
    nor   { direct { v = ( a > 0.5) || (b >  0.5) ? 0 : 1; } }
    or    { direct { v = ( a > 0.5) || (b >  0.5) ? 1 : 0; } }
    xor   { direct { v = ((a > 0.5) && (b <= 0.5)) || ((a <= 0.5) && (b >  0.5)) ? 1 : 0; } }

    add   { direct { v = a + b; } }
    sub   { direct { v = a - b; } }
    mul   { direct { v = a * b; } }
    div   { direct { v = a / b; } }
    fmod  { direct { v = fmod (a, b); } }
    pow   { direct { v = pow  (a, b); } }

    atan2 { direct { v = atan2 (a, b); } }
    hypot { direct { v = hypot (a, b); } }
    fmax  { direct { v = fmax  (a, b); } }
    fmin  { direct { v = fmin  (a, b); } }

    eq    { direct { v = (a == b) ? 1 : 0; } }
    ge    { direct { v = (a >= b) ? 1 : 0; } }
    gt    { direct { v = (a >  b) ? 1 : 0; } }
    le    { direct { v = (a <= b) ? 1 : 0; } }
    lt    { direct { v = (a <  b) ? 1 : 0; } }
    ne    { direct { v = (a != b) ? 1 : 0; } }
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

source $here/highway.tcl

# # ## ### ##### ######## #############

return
