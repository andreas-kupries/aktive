## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers - Complex math - Reductions to real
#
## A pairs of bands is treated as one complex numbered band
## Inputs have to have exactly 2 bands.

# # ## ### ##### ######## ############# #####################
## The projections do not require any kind of math

operator {band part} {
    op::cmath::real       0 real
    op::cmath::imaginary  1 imaginary
} {
    section transform math complex reduce

    note Returns a single-band image containing the $part part of the complex-valued input.

    input

    body {
	aktive op select z $src from @@band@@
    }
}

# # ## ### ##### ######## ############# #####################
##

operator {cfunction dexpr} {
    op::cmath::abs    cabs                   abs
    op::cmath::sqabs  aktive_cmath_sqabs     abs^2
    op::cmath::arg    carg                   phase-angle
} {
    section transform math complex reduce

    # NOTE: abs and arg are the magnitude and phase angle of the polar representation of
    # complex numbers.

    if {$dexpr eq {}} { set dexpr [namespace tail $__op] }
    if {![string match *I* $dexpr]} { append dexpr "(I)" }

    note Returns single-band image with the complex unary reduction function `${dexpr}` \
	applied to all pixels of the complex-valued input.

    note The result geometry is the same as the input, except for depth, which becomes 1.

    input

    state -setup {
	aktive_image     src  = srcs->v[0];
	aktive_geometry* srcg = aktive_image_get_geometry (src);

	if (aktive_geometry_get_depth (srcg) != 2) aktive_fail ("Reject image with depth != 2");

	aktive_geometry_copy (domain, srcg);
	domain->depth = 1;
    }

    pixels {
	aktive_blit_creduce (block, dst, @@cfunction@@,
			     aktive_region_fetch_area (0, request));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
