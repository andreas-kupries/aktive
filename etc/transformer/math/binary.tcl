## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Image transformer - Binary math (pixel wise)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core

operator op::math::difference {
    section transform math binary

    note Returns image holding the absolute difference of the inputs.

    input
    input

    body {
	return [aktive op math1 abs [sub $src0 $src1]]
    }
}

operator op::math::screen {
    section transform math binary

    note Returns image holding the `screen` of the inputs
    # TODO :: what is this operation exactly ?

    input
    input

    body {
	# (a+b)-ab = a-ab+b = a(1-b)+b
	return [sub [add $src0 $src1] [mul $src0 $src1]]
    }
}

# # ## ### ##### ######## ############# #####################
## Binary without parameters

operator {cfunction dexpr} {
    op::math::and     aktive_and    {A && B}
    op::math::nand    aktive_nand   {!(A && B)}
    op::math::or      aktive_or     {A || B}
    op::math::nor     aktive_nor    {!(A || B)}
    op::math::xor     aktive_xor    {A ^^ B}

    op::math::add     aktive_add    {A + B}
    op::math::atan2   atan2         {}
    op::math::div     aktive_div    {A / B}
    op::math::eq      aktive_eq     {A == B}
    op::math::ge      aktive_ge     {A >= B}
    op::math::gt      aktive_gt     {A > B}
    op::math::hypot   hypot         {}
    op::math::le      aktive_le     {A <= B}
    op::math::lt      aktive_lt     {A < B}
    op::math::max     fmax          max
    op::math::min     fmin          min
    op::math::mod     fmod          {A % B}
    op::math::mul     aktive_mul    {A * B}
    op::math::ne      aktive_ne     {A != B}
    op::math::pow     pow           {}
    op::math::sub     aktive_sub    {A - B}
} {
    set fun [namespace tail $__op]
    if {$dexpr eq {}} { set dexpr $fun }
    if {![string match *A* $dexpr]} { append dexpr "(A, B)" }

    note Returns image with the binary operation '$dexpr' applied to \
	all shared pixels of the two inputs.

    note The result geometry is the intersection of the inputs.

    if {$__op in {
	op::math::and
	op::math::nand
	op::math::or
	op::math::nor
	op::math::xor
    }} {
	section transform math binary logical

	note As a logical operation the inputs are trivially thresholded at 0.5. \
	    Values <= 0.5 are seen as false, else as true.
    } else {
	section transform math binary
    }

    input
    input

    state -setup {
	aktive_geometry* a = aktive_image_get_geometry (srcs->v[0]);
	aktive_geometry* b = aktive_image_get_geometry (srcs->v[1]);

	aktive_rectangle_intersect (aktive_geometry_as_rectangle (domain),
				    aktive_geometry_as_rectangle (a),
				    aktive_geometry_as_rectangle (b));

	domain->depth = MIN (a->depth, b->depth);
    }

    pixels {
	// As the result geometry is the intersection of the inputs
	// we trivially know that the request is good for both inputs.

	aktive_blit_binary (block, dst, @@cfunction@@,
			    aktive_region_fetch_area (srcs->v[0], request),
			    aktive_region_fetch_area (srcs->v[1], request));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
