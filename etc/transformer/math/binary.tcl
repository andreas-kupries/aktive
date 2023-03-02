## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Image transformer - Binary math (pixel wise)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core

tcl-operator op::math::difference {
    note Transformer. Math.

    arguments a b
    body {
	return [aktive op math1 abs [sub $a $b]]
    }
}

tcl-operator op::math::screen {
    note Transformer. Math.

    arguments a b
    body {
	# (a+b)-ab = a-ab+b = a(1-b)+b
	return [sub [add $a $b] [mul $a $b]]
    }
}

# # ## ### ##### ######## ############# #####################
## Binary without parameters

operator {cfunction dexpr} {
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

    note Transformer. \
	Performs the binary operation '$dexpr' on all shared pixels \
	of the inputs.

    note The result geometry is the intersection of the inputs.

    input
    input

    state -setup {
	#define MIN(a,b) ((a) < (b) ? (a) : (b))

	aktive_geometry* a = aktive_image_get_geometry (srcs->v[0]);
	aktive_geometry* b = aktive_image_get_geometry (srcs->v[1]);

	aktive_rectangle_intersect (aktive_geometry_as_rectangle (domain),
				    aktive_geometry_as_rectangle (a),
				    aktive_geometry_as_rectangle (b));

	domain->depth = MIN (a->depth, b->depth);
	#undef MIN
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
