## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers - Unary math, with up to two parameters

# # ## ### ##### ######## ############# #####################
## Unary without parameters

operator {function mathfunc show class} {
    op::math1::abs              fabs                  abs          {}    idempotent
    op::math1::clamp            aktive_clamp          <<           {}    idempotent
    op::math1::wrap             aktive_wrap           <<           {}    idempotent
    op::math1::invert           aktive_invert         <<           "1-I" cancel
    op::math1::neg              aktive_neg            <<           "-I"  cancel
    op::math1::sign             aktive_sign           <<           {}    idempotent
    op::math1::sign*            aktive_signb          <<           {}    idempotent
    op::math1::reciproc         aktive_reciprocal     <<           "1/I" -/-
    op::math1::sqrt             sqrt                  <<           {}    -/-
    op::math1::cbrt             cbrt                  aktive_cbrt  {}    -/-
    op::math1::exp              exp                   <<           {}    -/-
    op::math1::exp2             exp2                  aktive_exp2  {}    -/-
    op::math1::exp10            aktive_exp10          aktive_exp10 {}    -/-
    op::math1::log              log                   <<           {}    -/-
    op::math1::log2             log2                  aktive_log2  {}    -/-
    op::math1::log10            log10                 <<           {}    -/-
    op::math1::cos              cos                   <<           {}    -/-
    op::math1::sin              sin                   <<           {}    -/-
    op::math1::tan              tan                   <<           {}    -/-
    op::math1::cosh             cosh                  <<           {}    -/-
    op::math1::sinh             sinh                  <<           {}    -/-
    op::math1::tanh             tanh                  <<           {}    -/-
    op::math1::acos             acos                  <<           {}    -/-
    op::math1::asin             asin                  <<           {}    -/-
    op::math1::atan             atan                  <<           {}    -/-
    op::math1::acosh            acosh                 -            {}    -/-
    op::math1::asinh            asinh                 -            {}    -/-
    op::math1::atanh            atanh                 -            {}    -/-
    op::math1::gamma-compress   aktive_gamma_compress -            {}    op::math1::gamma-expand
    op::math1::gamma-expand     aktive_gamma_expand   -            {}    op::math1::gamma-compress
} {
    if {$mathfunc eq "<<"} { set mathfunc $function }
    # function: C function to invoke   - aktive_* functions are implemented in op/op.c, else <math.h>
    # mathfunc: Tcl function to invoke - aktive_* functions are implemented in policy.tcl, else builtin
    #
    # A mathfunc, if available is used for peep-hole optimization of the operator.
    # The operator class provides more opportunities for peep-hole optimization.

    set cmd [namespace tail $__op]
    if {$show ne {}} { set cmd $show }
    if {![string match *I* $cmd]} { append cmd (I) }

    note Performs the unary function '$cmd' on all pixels of the image.
    note The resulting image has the same geometry as the input.

    input keep

    # TODO neg && I=[0] is pass/input

    # General const folding on the input ...
    if {$mathfunc ne "-"} { overlay   constant $mathfunc }

    # Additional optimizations based on the nature of the function
    switch -exact -- $class {
	idempotent { overlay   input @self   is input       }
	cancel     { overlay   input @self   is input/child }
	-/-        {}
	default {
	    # value is complementary type canceling self
	    overlay   input $class   is input/child
	}
    }

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_blit_unary0 (block, dst, @@function@@, aktive_region_fetch_area (srcs->v[0], request));
    }

    # TODO :: consider generation of the blit implementation through the DSL.   -- note /blitcore/ block --
    # TODO :: would allow macro for ops, inlined, more compiler optimizations?
    # TODO :: defered for now until benchmarks prove it necessary - do threading first
}

##
# # ## ### ##### ######## ############# #####################
## Unary with one parameter

operator {function name mathfunc flip show description} {
    op::math1::shift          aktive_shift  offset    <<  0   "I+@"       {Add scalar offset}
    op::math1::neg-shift      aktive_nshift offset    <<   1  "@-I"       {Subtract from scalar offset}
    op::math1::scale          aktive_scale  factor    <<  0   "I*@"       {Multiply by scalar factor}
    op::math1::reciproc-scale aktive_rscale factor    <<   1  "@/I"       {Divide from scalar factor}
    op::math1::mod            fmod          modulus   <<  0   fmod        {Remainder by scalar modulus}
    op::math1::modb           aktive_fmod   numerator <<   1  fmod(@,I)   {Remainder by scalar numerator}
    op::math1::pow            pow           exponent  <<  0   {}          {Power by scalar exponent}
    op::math1::expx           aktive_pow    base      <<   1  pow(@,I)    {Power by scalar base}
    op::math1::hypot          hypot         y         <<  0   {}          {Hypot to scalar y}
    op::math1::max            fmax          min       max 0   {}          {Limit to greater or equal a scalar min}
    op::math1::min            fmin          max       min 0   {}          {Limit to less    or equal a scalar max}
    op::math1::atan2          atan2         x         <<  0   atan2       {Atan by scalar x}
    op::math1::atan2b         aktive_atan   y         <<   1  atan2(@,I)  {Atan by scalar y}
    op::math1::ge             aktive_ge     threshold <<  0   "I >= @"    {Indicate pixels greater or equal the scalar threshold}
    op::math1::le             aktive_le     threshold <<  0   "I <= @"    {Indicate pixels less or equal the scalar threshold}
    op::math1::gt             aktive_gt     threshold <<  0   "I > @"     {Indicate pixels greater than the scalar threshold}
    op::math1::lt             aktive_lt     threshold <<  0   "I < @"     {Indicate pixels less than the scalar threshold}
    op::solarize              aktive_sol    threshold <<  0   solarize    {Solarize pixels per the threshold}
} {
    if {$mathfunc eq "<<"} { set mathfunc $function }

    set cmd [namespace tail $__op]
    if {$show ne {}} { set cmd $show }
    if {![string match *@* $cmd]} { append cmd (I,@) }
    set cmd [string map [list @ $name] $cmd]

    note Performs the binary function '$cmd' on all pixels of the image.
    if {$flip} {
	note The image is the first argument of the command, even if not of the function
    } else {
	note The image is the first argument of the command
    }

    # For non-commutative functions we have a separate operation reversing the order (mod a/b atan2 a/b, ...)
    note The resulting image has the same geometry as the input.

    input keep

    # Special rules per function, and parameter values
    switch -exact -- $function {
	aktive_shift  {
	    overlay   param offset == 0   is input
	}
	aktive_nshift {
	    overlay   param offset == 0   is unary0 neg
	    overlay   param offset == 1   is unary0 invert
	}
	aktive_scale  {
	    overlay   param factor == 1   is input
	    # TODO factor 0 and I=[0] is is input
	    #overlay   param factor 0   isconst isvalue 1  is input
	    overlay   param factor == 0   is const 0
	}
	aktive_rscale {
	    # TODO factor 0 and I=[0] is [inf]
	    #overlay   param factor 0 isconst isvalue 0  is const Inf
	    overlay   param factor == 0   is const 0
	    # TODO factor 1 and I=[1] is is input
	    #overlay   param factor 1 isconst isvalue 1  is input
	    # TODO factor 1 and I=[0] is [inf]
	    #overlay   param factor 1 isconst isvalue 0  is const Inf
	    overlay   param factor == 1   is unary0 reciproc
	    # TODO input is rscale b  => a/(b/I) is scale (a/b)
	    #overlay  input @self  inparam factor a  expr {$factor/$a}   is unary1 scale __expr
	}
	fmod          {}
	aktive_fmod   {}
	pow           {
	    # TODO exp  0, I=[0]  is [1]
	    # TODO exp  0, I=[-1] is [1]
	    # TODO exp  0, I=[1] is is input
	    # TODO exp >0, I=[0] is is input
	    # TODO exp <0, I=[0] is [inf]
	    overlay  param exponent == 0  is const 1
	    overlay  param exponent == 1  is input
	}
	aktive_pow    {}
	hypot         {}
	fmax          {}
	fmin          {}
	atan2         {}
	aktive_atan   {}
	aktive_ge     {}
	aktive_le     {}
	aktive_gt     {}
	aktive_lt     {}
	aktive_sol    {}
    }

    # General const folding on the input ... Note that the special rules were applied
    # first. They can generate something simpler, based on specific combinations of image
    # and parameter.
    overlay   constant $mathfunc $name

    double $name  {*}$description

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_blit_unary1 (block, dst, @@function@@, param->@@name@@, aktive_region_fetch_area (srcs->v[0], request));
    }

    # TODO :: consider generation of the blit implementation through the DSL.   -- note /blitcore/ block --
    # TODO :: would allow macro for ops, inlined, more compiler optimizations?
    # TODO :: defered for now until benchmarks prove it necessary - do threading first
}

##
# # ## ### ##### ######## ############# #####################
## Unary with two parameters

operator {function lowkind highkind mode} {
    op::math::inside-oo  aktive_inside_oo  open   open   inside
    op::math::inside-oc	 aktive_inside_oc  open   closed inside
    op::math::inside-co	 aktive_inside_co  closed open   inside
    op::math::inside-cc	 aktive_inside_cc  closed closed inside

    op::math::outside-oo aktive_outside_oo open   open   outside
    op::math::outside-oc aktive_outside_oc open   closed outside
    op::math::outside-co aktive_outside_co closed open   outside
    op::math::outside-cc aktive_outside_cc closed closed outside
} {
    note Performs a double sided thresholding against the $lowkind/$highkind interval given by the two boundaries.
    note Values $mode the interval are indicated in the result.
    note The resulting image has the same geometry as the input.

    input keep

    overlay   constant $function low high

    double low   Lower $lowkind boundary
    double high  Upper $highkind boundary

    # TODO Chain reduction is possible -- new operator takes in the information from the
    # TODO input, and stacks on the input/child, ignoring the input.

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_blit_unary2 (block, dst, @@function@@, param->low, param->high,
			    aktive_region_fetch_area (srcs->v[0], request));
    }

    # TODO :: consider generation of the blit implementation through the DSL.   -- note /blitcore/ block --
    # TODO :: would allow macro for ops, inlined, more compiler optimizations?
    # TODO :: defered for now until benchmarks prove it necessary - do threading first
}

##
# # ## ### ##### ######## ############# #####################
::return
