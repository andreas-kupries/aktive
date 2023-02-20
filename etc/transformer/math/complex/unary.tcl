## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers - Complex math - Unary operations
#
## A pairs of bands is treated as one complex numbered band
## Inputs have to have exactly 2 bands.

operator {cfunction dexpr} {
    op::cmath::acos         cacos                   {}
    op::cmath::acosh        cacosh                  {}
    op::cmath::asin         casin                   {}
    op::cmath::asinh        casinh                  {}
    op::cmath::atan         catan                   {}
    op::cmath::atanh        catanh                  {}
    op::cmath::cbrt         aktive_cmath_cbrt       {}
    op::cmath::conjugate    conj                    {}
    op::cmath::cos          ccos                    {}
    op::cmath::cosh         ccosh                   {}
    op::cmath::exp          cexp                    {}
    op::cmath::exp10        aktive_cmath_exp10      {}
    op::cmath::exp2         aktive_cmath_exp2       {}
    op::cmath::log          clog                    {}
    op::cmath::log10        aktive_cmath_log10      {}
    op::cmath::log2         aktive_cmath_log2       {}
    op::cmath::neg          aktive_cmath_neg        -I
    op::cmath::reciproc     aktive_cmath_reciprocal 1/I
    op::cmath::sin	    csin                    {}
    op::cmath::sinh         csinh                   {}
    op::cmath::sqrt	    csqrt                   {}
    op::cmath::tan	    ctan                    {}
    op::cmath::tanh         ctanh                   {}
    op::cmath::tocartesian  aktive_cmath_cartesian  {}
    op::cmath::topolar      aktive_cmath_polar      {}

} {
    if {$dexpr eq {}} { set dexpr [namespace tail $__op] }
    if {![string match *I* $dexpr]} { append dexpr (I) }

    note Transformer. \
	Performs the complex unary function '$dexpr' on all pixels of the image.

    note The resulting image has the same geometry as the input.

    input keep

    state -setup {
	aktive_image     src  = srcs->v[0];
	aktive_geometry* srcg = aktive_image_get_geometry (src);

	if (aktive_geometry_get_depth (srcg) != 2) aktive_fail ("Reject image with depth != 2");

	aktive_geometry_copy (domain, srcg);
    }

    pixels {
	aktive_blit_cunary (block, dst, @@cfunction@@,
			    aktive_region_fetch_area (srcs->v[0], request));
    }
}

nyi operator {function dexpr} {
    op::cmath::magnitude    aktive_cmath_abs       abs
    op::cmath::sqmagnitude  aktive_cmath_sqabs     abs^2
} {
    # TODO :: result is 1-band image from the 2-band complex input
}

##
# # ## ### ##### ######## ############# #####################
::return
