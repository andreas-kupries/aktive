## -*- mode: tcl ; fill-column: 90 -*-
# # # ## ### ##### ######## ############# #####################
## Image transformer - Unary math

# # # ## ### ##### ######## ############# #####################
## Unary without parameters

operator function {
    op::math1::abs		fabs
    op::math1::clamp		aktive_clamp
    op::math1::wrap		aktive_wrap
    op::math1::invert		aktive_invert
    op::math1::neg		aktive_neg
    op::math1::sign		aktive_sign
    op::math1::sign*		aktive_signb
    op::math1::reciproc		aktive_reciprocal
    op::math1::sqrt		sqrt
    op::math1::cbrt		cbrt
    op::math1::exp		exp
    op::math1::exp2		exp2
    op::math1::exp10		aktive_exp10
    op::math1::log		log
    op::math1::log2		log2
    op::math1::log10		log10
    op::math1::cos		cos
    op::math1::sin		sin
    op::math1::tan		tan
    op::math1::cosh		cosh
    op::math1::sinh		sinh
    op::math1::tanh		tanh
    op::math1::acos		acos
    op::math1::asin		asin
    op::math1::atan		atan
    op::math1::acosh		acosh
    op::math1::asinh		asinh
    op::math1::atanh		atanh
    op::math1::gamma-compress	aktive_gamma_compress
    op::math1::gamma-expand	aktive_gamma_expand
} {
    note Performs the unary operation $function
    note The resulting image has the same geometry as the input.

    input keep ;#-pass-ignore

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_blit_unary0 (block, dst, @@, aktive_region_fetch_area (srcs->v[0], request));
    } @@ $function

    # TODO :: consider generation of the blit implementation through the DSL.
    # TODO :: would allow macro for ops, inlined, more compiler optimizations?
    # TODO :: defered for now until benchmarks prove it necessary - do threading first
}

## # # ## ### ##### ######## ############# #####################

nyi operator {
    op::math::inside-oo
    op::math::inside-oc
    op::math::inside-co
    op::math::inside-cc
    op::math::outside-oo
    op::math::outside-oc
    op::math::outside-co
    op::math::outside-cc
} {
    input keep ;#-pass-ignore

    double low   Low boundary
    double high  High boundary

    # %% TODO %% specify implementation
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
