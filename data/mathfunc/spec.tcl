# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

# # ## ### ##### ######## #############
## Unary math functions, without parameters
##
## code environment
## - `@V` = input value to transform, also output
##
## The defines for gamma_compress/expand reside in the sibling file `template-scalar.c`

set unary0 {
    acos           { scalar { @V = acos  (@V);     } }
    acosh          { scalar { @V = acosh (@V);     } }
    asin           { scalar { @V = asin  (@V);     } }
    asinh          { scalar { @V = asinh (@V);     } }
    atan           { scalar { @V = atan  (@V);     } }
    atanh          { scalar { @V = atanh (@V);     } }
    cbrt           { scalar { @V = cbrt  (@V);     } }
    ceil           { scalar { @V = ceil  (@V);     } }
    clamp          { scalar { @V = fmax  (0, fmin (1, @V)); } }
    cos            { scalar { @V = cos   (@V);     } }
    cosh           { scalar { @V = cosh  (@V);     } }
    exp            { scalar { @V = exp   (@V);     } }
    exp10          { scalar { @V = pow   (10, @V); } }
    exp2           { scalar { @V = exp2  (@V);     } }
    fabs           { scalar { @V = fabs  (@V);     } }
    floor          { scalar { @V = floor (@V);     } }
    gamma_compress { scalar { @V = (@V <= ILIMIT) ? @V * IGAIN : SCALE * pow (@V, 1.0/GAMMA) - OFFSET; } }
    gamma_expand   { scalar { @V = (@V <= GLIMIT) ? @V / IGAIN : pow ((@V + OFFSET) / SCALE, GAMMA);   } }
    invert         { scalar { @V = 1 - @V;              } }
    log            { scalar { @V = log   (@V);          } }
    log10          { scalar { @V = log10 (@V);          } }
    log2           { scalar { @V = log2  (@V);          } }
    neg            { scalar { @V = - @V;                } }
    not            { scalar { @V = (@V <= 0.5);         } }
    reciprocal     { scalar { @V = 1.0 / @V;            } }
    round          { scalar { @V = round (@V);          } }
    sign           { scalar { @V = (@V < 0) ? -1 : (@V > 0) ? 1 : 0; } }
    signb          { scalar { @V = (@V < 0) ? -1 : 1;   } }
    sin            { scalar { @V = sin  (@V);           } }
    sinh           { scalar { @V = sinh (@V);           } }
    sqrt           { scalar { @V = sqrt (@V);           } }
    square         { scalar { @V = @V * @V;             } }
    tan            { scalar { @V = tan  (@V);           } }
    tanh           { scalar { @V = tanh (@V);           } }
    wrap           { scalar { @V = (@V > 1) ? fmod(@V, 1) : (@V < 0) ? (1 + fmod(@V - 1, 1)) : @V; } }
}

# # ## ### ##### ######## #############
## Unary math functions, single parameter
##
## code environment
## - `@V` = input value to transform, also output
## - `a` = parameter

set unary1 {
    atan2  { scalar { @V = atan2 (@V, a);         } }
    eq     { scalar { @V = (@V == a);             } }
    expx   { scalar { @V = pow (a, @V);           } }
    fmax   { scalar { @V = fmax (@V, a);          } }
    fmin   { scalar { @V = fmin (@V, a);          } }
    fmod   { scalar { @V = fmod(@V, a);           } }
    ge     { scalar { @V = (@V >= a);             } }
    gt     { scalar { @V = (@V > a);              } }
    hypot  { scalar { @V = hypot (@V, a);         } }
    le     { scalar { @V = (@V <= a);             } }
    lt     { scalar { @V = (@V <  a);             } }
    ne     { scalar { @V = (@V != a);             } }
    nshift { scalar { @V = a - @V;                } }
    pow    { scalar { @V = pow (@V, a);           } }
    ratan2 { scalar { @V = atan2 (a, @V);         } }
    rfmod  { scalar { @V = fmod (a, @V);          } }
    rscale { scalar { @V = a / @V;                } }
    scale  { scalar { @V = @V * a;                } }
    shift  { scalar { @V = @V + a;                } }
    sol    { scalar { @V = (@V <= a) ? @V : 1-@V; } }
}

# # ## ### ##### ######## #############
## Unary math functions, two parameters
##
## code environment
## - `@V` = input value to transform, also output
## - `a` = parameter 1
## - `b` = parameter 2

set unary2 {
    inside_cc  { scalar { @V =   (a <= @V) && (@V <= b);  } }
    inside_co  { scalar { @V =   (a <= @V) && (@V <  b);  } }
    inside_oc  { scalar { @V =   (a <  @V) && (@V <= b);  } }
    inside_oo  { scalar { @V =   (a <  @V) && (@V <  b);  } }
    outside_cc { scalar { @V = !((a <= @V) && (@V <= b)); } }
    outside_co { scalar { @V = !((a <= @V) && (@V <  b)); } }
    outside_oc { scalar { @V = !((a <  @V) && (@V <= b)); } }
    outside_oo { scalar { @V = !((a <  @V) && (@V <  b)); } }
}

# # ## ### ##### ######## #############
## Binary math functions
##
## code environment
## - `@A` = input value 1
## - `@B` = input value 2
## - `@V` = output

set binary {
    and   { scalar { @V =   ( @A > 0.5) && (@B >  0.5);  } }
    nand  { scalar { @V = !(( @A > 0.5) && (@B >  0.5)); } }
    nor   { scalar { @V = !(( @A > 0.5) || (@B >  0.5)); } }
    or    { scalar { @V =   ( @A > 0.5) || (@B >  0.5);  } }
    xor   { scalar { @V = ((@A > 0.5) && (@B <= 0.5)) || ((@A <= 0.5) && (@B >  0.5)); } }

    add   { scalar { @V = @A + @B; } }
    sub   { scalar { @V = @A - @B; } }
    mul   { scalar { @V = @A * @B; } }
    div   { scalar { @V = @A / @B; } }
    fmod  { scalar { @V = fmod (@A, @B); } }
    pow   { scalar { @V = pow  (@A, @B); } }

    atan2 { scalar { @V = atan2 (@A, @B); } }
    hypot { scalar { @V = hypot (@A, @B); } }
    fmax  { scalar { @V = fmax  (@A, @B); } }
    fmin  { scalar { @V = fmin  (@A, @B); } }

    eq    { scalar { @V = (@A == @B); } }
    ge    { scalar { @V = (@A >= @B); } }
    gt    { scalar { @V = (@A >  @B); } }
    le    { scalar { @V = (@A <= @B); } }
    lt    { scalar { @V = (@A <  @B); } }
    ne    { scalar { @V = (@A != @B); } }
}

# # ## ### ##### ######## #############
## Templated code fragments to assemble the functions from.

set here [file dirname [info script]]
source $here/fragments.tcl

# # ## ### ##### ######## #############

return
