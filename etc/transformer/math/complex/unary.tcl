## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers - Complex math - Unary operations
#
## A pairs of bands is treated as one complex numbered band
## Inputs have to have exactly 2 bands.

# # ## ### ##### ######## ############# #####################
## Constructing complex-valued images

## See op/amath.h
##     op/math.c

operator band {
    op::cmath::as-real       real
    op::cmath::as-imaginary  imaginary
} {
    section transform math complex unary

    note Returns complex-valued image constructed from the single-band input. \
	Input becomes the @@band@@ part.

    def filler { [aktive image from value width $w height $h depth 1 value 0] }
    def montage [dict get {
	real      { $src @@filler@@ }
	imaginary { @@filler@@ $src }
    } $band]

    input

    body {
	lassign [aktive query geometry $src] _ _ w h d
	if {$d != 1} {
	    aktive error "Unable to use image with multiple bands for complex result" \
		CAST COMPLEX MULTI-BAND
	}
	return [aktive op montage z @@montage@@]
    }
}

operator op::cmath::cons {
    section transform math complex binary

    note Returns complex-valued image constructed from the 2 single-band inputs. \
	First input becomes the real part, second the imaginary.

    input	;# re
    input	;# im

    body {
	if {([aktive query depth $src0] != 1) ||
	    ([aktive query depth $src1] != 1)} {
	    aktive error "Unable to use image with multiple bands for complex result" \
		CAST COMPLEX MULTI-BAND
	}

	return [aktive op montage z $src0 $src1]
    }
}

# # ## ### ##### ######## ############# #####################
##

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
    op::cmath::sign         aktive_cmath_sign       {}
    op::cmath::sin          csin                    {}
    op::cmath::sinh         csinh                   {}
    op::cmath::sqrt         csqrt                   {}
    op::cmath::tan          ctan                    {}
    op::cmath::tanh         ctanh                   {}
    op::cmath::tocartesian  aktive_cmath_cartesian  {}
    op::cmath::topolar      aktive_cmath_polar      {}
} {
    section transform math complex unary

    import? ../../simpler/$cfunction.rules

    if {$dexpr eq {}} { set dexpr [namespace tail $__op] }
    if {![string match *I* $dexpr]} { append dexpr (I) }

    note Returns complex-valued image with the complex-valued unary \
	function '$dexpr' applied to all pixels of the image.

    note The resulting image has the same geometry as the input.

    input

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

##
# # ## ### ##### ######## ############# #####################
::return
