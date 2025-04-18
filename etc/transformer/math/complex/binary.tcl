## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers - Complex math - Binary operations
#
## A pairs of bands is treated as one complex numbered band
## Inputs have to have exactly 2 bands.

operator {cfunction dexpr} {
    op::cmath::add    aktive_cmath_add {A + B}
    op::cmath::div    aktive_cmath_div {A / B}
    op::cmath::mul    aktive_cmath_mul {A * B}
    op::cmath::sub    aktive_cmath_sub {A - B}
    op::cmath::pow    cpow	       pow
} {
    section transform math complex binary

    if {$dexpr eq {}} { set dexpr [namespace tail $__op] }
    if {![string match *A* $dexpr]} { append dexpr "(A, B)" }

    note Returns complex-valued image with the complex-valued binary \
	operation `${dexpr}` applied to all shared pixels of the two inputs.

    note The result geometry is the intersection of the inputs.

    input a	Complex image A
    input b	Complex image B

    state -setup {
	aktive_geometry* a = aktive_image_get_geometry (srcs->v[0]);
	aktive_geometry* b = aktive_image_get_geometry (srcs->v[1]);

	if (aktive_geometry_get_depth (a) != 2) aktive_fail ("Reject image A with depth != 2");
	if (aktive_geometry_get_depth (b) != 2) aktive_fail ("Reject image B with depth != 2");

	aktive_rectangle_intersect (aktive_geometry_as_rectangle (domain),
				    aktive_geometry_as_rectangle (a),
				    aktive_geometry_as_rectangle (b));

	domain->depth = a->depth;
    }

    pixels {
	// As the result geometry is the intersection of the inputs
	// we trivially know that the request is good for both inputs.

	aktive_blit_cbinary (block, dst, @@cfunction@@,
			     aktive_region_fetch_area (srcs->v[0], request),
			     aktive_region_fetch_area (srcs->v[1], request));
    }
}

# # ## ### ##### ######## ############# #####################
## Constructing complex-valued images

operator op::cmath::cons {
    section transform math complex binary

    note Returns a complex-valued image constructed from two single-band inputs.

    input real		Single-band image becoming the real part of the complex result
    input imaginary	Single-band image becoming the imaginary part of the complex result

    body {
	if {([aktive query depth $real] != 1) ||
	    ([aktive query depth $imaginary] != 1)} {
	    aktive error "Unable to use image with multiple bands for complex result" \
		CAST COMPLEX MULTI-BAND
	}

	return [aktive op montage z $real $imaginary]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
