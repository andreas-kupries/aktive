## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Image transformer - Binary math (pixel wise)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core

operator op::math::difference {
    section transform math binary

    note Returns image holding the absolute difference `abs(A-B)` of the inputs.

    input a	Image A
    input b	Image B

    body {
	return [aktive op math1 abs [sub $a $b]]
    }
}

operator op::math::screen {
    section transform math binary

    note Returns image holding the `screen(A,B) = A+B-A*B = A*(1-B)+B` of the inputs.

    input a	Image A
    input b	Image B

    body {
	# (a+b)-ab = a-ab+b = a(1-b)+b
	return [sub [add $a $b] [mul $a $b]]
    }
}

# # ## ### ##### ######## ############# #####################
## Binary without parameters

proc logical {} { ::return {
    op::math::nand
    op::math::and
    op::math::or
    op::math::nor
    op::math::xor
}}

operator {cfunction dexpr} {
    op::math::nand      aktive_nand  {!(A && B)}
    op::math::nor       aktive_nor   {!(A || B)}

    op::math::atan2     atan2        {atan2(A, B)}
    op::math::div       aktive_div   {A / B}
    op::math::eq        aktive_eq    {A == B}
    op::math::ge        aktive_ge    {A >= B}
    op::math::gt        aktive_gt    {A > B}
    op::math::hypot     hypot        {hypot (A, B)}
    op::math::le        aktive_le    {A <= B}
    op::math::lt        aktive_lt    {A < B}
    op::math::mod       fmod         {A % B}
    op::math::ne        aktive_ne    {A != B}
    op::math::pow       pow          {pow (A, B)}
    op::math::sub       aktive_sub   {A - B}
} {
    op -> _ _ fun

    note Returns image with the binary operation `${dexpr}` applied to \
	all shared pixels of the two inputs.

    note The result geometry is the intersection of the inputs.

    if {$__op in [logical]} {
	section transform math binary logical

	note As a logical operation the inputs are trivially thresholded at 0.5. \
	    Values <= 0.5 are seen as false, else as true.
    } else {
	section transform math binary
    }

    input a	Image A
    input b	Image B

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

# # ## ### ##### ######## ############# #####################
## Multi-ary operations of commutative any-associative binary ops

operator {cfunction dexpr} {
    op::math::and  aktive_and {A && B}
    op::math::or   aktive_or  {A || B}
    op::math::xor  aktive_xor {A ^^ B}
    op::math::add  aktive_add {A + B}
    op::math::mul  aktive_mul {A * B}
    op::math::max  fmax       {max(A, B)}
    op::math::min  fmin       {min(A, B)}
} {
    op -> _ _ fun
    if {$__op in [logical]} {
	section transform math n-ary logical

	note As a logical operation the inputs are trivially thresholded at 0.5. \
	    Values <= 0.5 are seen as false, else as true.
    } else {
	section transform math n-ary
    }

    input...

    note Returns image aggregated from the application of the associative \
	binary operation `${dexpr}` to all shared pixels of all the inputs.

    state -setup {
	aktive_uint i;
	aktive_geometry* g = aktive_image_get_geometry (srcs->v[0]);

	aktive_geometry_copy (domain, g);
	domain->depth = MIN (domain->depth, g->depth);

	for (i = 1; i < srcs->c; i++) {
	    g = aktive_image_get_geometry (srcs->v[i]);
	    aktive_rectangle_intersect (aktive_geometry_as_rectangle (domain),
					aktive_geometry_as_rectangle (domain),
					aktive_geometry_as_rectangle (g));
	    domain->depth = MIN (domain->depth, g->depth);
	}
    }

    pixels {
	// As the result geometry is the intersection of all inputs
	// we trivially know that the request is good for all inputs.

	aktive_uint i;

	aktive_blit_copy0 (block, dst, aktive_region_fetch_area (srcs->v[0], request));

	for (i = 1; i < srcs->c; i++) {
	    aktive_blit_binary_acc (block, dst, @@cfunction@@,
				    aktive_region_fetch_area (srcs->v[i], request));
	}
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
