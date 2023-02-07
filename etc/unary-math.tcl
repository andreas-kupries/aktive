## -*- mode: tcl ; fill-column: 90 -*-
# # # ## ### ##### ######## ############# #####################
## Image transformer - Unary math

# # # ## ### ##### ######## ############# #####################
## Unary without parameters

operator {function mathfunc class} {
    op::math1::abs              fabs                  abs               idempotent
    op::math1::clamp            aktive_clamp          aktive_clamp      idempotent
    op::math1::wrap             aktive_wrap           aktive_wrap       itempotent
    op::math1::invert           aktive_invert         aktive_invert     cancel
    op::math1::neg              aktive_neg            aktive_neg        cancel
    op::math1::sign             aktive_sign           aktive_sign       idempotent
    op::math1::sign*            aktive_signb          aktive_signb      idempotent
    op::math1::reciproc         aktive_reciprocal     aktive_reciprocal -/-
    op::math1::sqrt             sqrt                  sqrt              -/-
    op::math1::cbrt             cbrt                  aktive_cbrt       -/-
    op::math1::exp              exp                   exp               -/-
    op::math1::exp2             exp2                  aktive_exp2       -/-
    op::math1::exp10            aktive_exp10          aktive_exp10      -/-
    op::math1::log              log                   log               -/-
    op::math1::log2             log2                  aktive_log2       -/-
    op::math1::log10            log10                 log10             -/-
    op::math1::cos              cos                   cos		-/-
    op::math1::sin              sin                   sin		-/-
    op::math1::tan              tan                   tan		-/-
    op::math1::cosh             cosh                  cosh		-/-
    op::math1::sinh             sinh                  sinh		-/-
    op::math1::tanh             tanh                  tanh		-/-
    op::math1::acos             acos                  acos		-/-
    op::math1::asin             asin                  asin		-/-
    op::math1::atan             atan                  atan		-/-
    op::math1::acosh            acosh                 -			-/-
    op::math1::asinh            asinh                 -			-/-
    op::math1::atanh            atanh                 -			-/-
    op::math1::gamma-compress   aktive_gamma_compress -			op::math1::gamma-expand
    op::math1::gamma-expand     aktive_gamma_expand   -			op::math1::gamma-compress
} {
    # function: C function to invoke   - aktive_* functions are implemented in op/op.c, else <math.h>
    # mathfunc: Tcl function to invoke - aktive_* functions are implemented in policy.tcl, else builtin
    #
    # A mathfunc, if available is used for peep-hole optimization of the operator.
    # The operator class provides more opportunities for peep-hole optimization.

    note Performs the unary operation $function
    note The resulting image has the same geometry as the input.

    input keep

    if {$mathfunc ne "-"} { overlay constant $mathfunc }
    switch -exact -- $class {
	idempotent { overlay input @self pass }
	cancel     { overlay input @self pass/child }
	-/-        {}
	default {
	    # value is complementary type canceling self
	    overlay input $class pass/child
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

## # # ## ### ##### ######## ############# #####################
## Unary with one parameter

operator {function name description} {
    op::math1::shift          aktive_shift  offset    {Add scalar offset}
    op::math1::neg-shift      aktive_nshift offset    {Subtract from scalar offset}
    op::math1::scale          aktive_scale  factor    {Multiply by scalar factor}
    op::math1::reciproc-scale aktive_rscale factor    {Divide from scalar factor}
    op::math1::moda           fmod          modulus   {Remainder by scalar modulus}
    op::math1::modb           aktive_fmod   numerator {Remainder by scalar numerator}
    op::math1::pow            pow           exponent  {Power by scalar exponent}
    op::math1::expx           aktive_pow    base      {Power by scalar base}
    op::math1::hypot          hypot         y         {Hypot to scalar y}
    op::math1::max            fmax          min       {Limit to greater or equal a scalar min}
    op::math1::min            fmin          max       {Limit to less    or equal a scalar max}
    op::math1::atan2a         atan2         x         {Atan by scalar x}
    op::math1::atan2b         aktive_atan   y         {Atan by scalar y}
    op::math1::ge             aktive_ge     threshold {Indicate pixels greater or equal the scalar threshold}
    op::math1::le             aktive_le     threshold {Indicate pixels less    or equal the scalar threshold}
    op::math1::gt             aktive_gt     threshold {Indicate pixels greater than     the scalar threshold}
    op::math1::lt             aktive_lt     threshold {Indicate pixels less    than     the scalar threshold}
    op::solarize              aktive_sol    threshold {Solarize pixels per the threshold}
} {
    note Performs the unary operation $function with parameter $name
    note The resulting image has the same geometry as the input.

    input keep

    double $name  {*}$description

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_blit_unary1 (block, dst, @@function@@, param->@@name@@, aktive_region_fetch_area (srcs->v[0], request));
    }

    # TODO :: consider generation of the blit implementation through the DSL.
    # TODO :: would allow macro for ops, inlined, more compiler optimizations?
    # TODO :: defered for now until benchmarks prove it necessary - do threading first
}

## # # ## ### ##### ######## ############# #####################
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
    note Performs a double sided thresholding against the $lowkind/$highkind
    note interval given by the two bounaries. Values $mode the interval
    note are indicated in the result.
    note The resulting image has the same geometry as the input.

    input keep ;#-pass-ignore

    double low   Lower $lowkind boundary
    double high  Upper $highkind boundary

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_blit_unary2 (block, dst, @@function@@, param->low, param->high,
			    aktive_region_fetch_area (srcs->v[0], request));
    }
}

## # # ## ### ##### ######## ############# #####################
# Math on complex numbers
# Inputs have to have even number of bands
# Each pair of bands is treated as re/im of a complex number

nyi operator {
    op::cmath::conjugate
    op::cmath::cos
    op::cmath::div
    op::cmath::exp
    op::cmath::log
    op::cmath::log10
    op::cmath::magnitude
    op::cmath::mul
    op::cmath::sin
    op::cmath::sqmagnitude
    op::cmath::sqrt
    op::cmath::tan
    op::cmath::tocartesian
    op::cmath::topolar

    op::integrate
} {
    input keep

    # %% TODO %% specify implementation
}

## # # ## ### ##### ######## ############# #####################

##
## # # ## ### ##### ######## ############# #####################
::return
