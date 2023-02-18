## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Image transformer - Binary math (pixel wise)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core

tcl-operator op::math::difference {a b} {
    return [aktive math1 abs [sub $a $b]]
}

tcl-operator op::math::screen {a b} {
    return [sub [add $a $b] [mul $a $b]]
}

# # ## ### ##### ######## ############# #####################
## Binary without parameters

operator {cfunction dexpr} {
    op::math::add     __aktive_add  {A + B}
    op::math::atan2   atan2         {}
    op::math::div     __aktive_div  {A / B}
    op::math::ge      aktive_ge     {A >= B}
    op::math::gt      aktive_gt     {A > B}
    op::math::hypot   hypot         {}
    op::math::le      aktive_le     {A <= B}
    op::math::lt      aktive_lt     {A < B}
    op::math::max     fmax          max
    op::math::min     fmin          min
    op::math::mod     fmod          {A % B}
    op::math::mul     __aktive_mul  {A * B}
    op::math::pow     pow           {}
    op::math::sub     __aktive_sub  {A - B}
} {
    set fun [namespace tail $__op]
    if {$dexpr eq {}} { set dexpr $fun }
    if {![string match *A* $dexpr]} { append dexpr "(A, B)" }

    note Transformer. \
	Performs the binary operation '$dexpr' on all shared pixels of the inputs.

    note The result geometry is the intersection of the inputs.

    input keep
    input keep

    state -setup {
	#define MIN(a,b) ((a) < (b) ? (a) : (b))

	aktive_geometry* a = aktive_image_get_geometry (srcs->v[0]);
	aktive_geometry* b = aktive_image_get_geometry (srcs->v[1]);

	aktive_rectangle_intersect (aktive_geometry_as_rectangle(domain),
				    aktive_geometry_as_rectangle(a),
				    aktive_geometry_as_rectangle(b));

	domain->depth = MIN (a->depth, b->depth);
    }

    pixels {
	// As the result geometry is the intersection of the inputs
	// we trivially know that the request is good for both inputs.

	aktive_block* a = aktive_region_fetch_area (srcs->v[0], request);
	aktive_block* b = aktive_region_fetch_area (srcs->v[1], request);

	#define SRCA  a->domain
	#define SRCB  b->domain
	#define DST  block->domain

	aktive_uint sadepth = SRCA.depth;
	aktive_uint sbdepth = SRCB.depth;
	aktive_uint ddepth  = DST.depth;

	aktive_uint sapitch = SRCA.width * sadepth;
	aktive_uint sbpitch = SRCA.width * sbdepth;
	aktive_uint dpitch  = DST.width  * ddepth;

	TRACE ("sa (d %d p %d) | sb (d %d p %d) | d (d %d p %d)",
	       sadepth, sapitch, sbdepth, sbpitch, ddepth, dpitch);
	TRACE ("sy  sx  sz  | in  | dy  dx  dz  | out | capSA %d | capSB %d | capD %d",
	       a->used, b->used, block->used);

	aktive_uint dsty, dstx, dstz;
	aktive_uint srcay, srcax, srcaz;
	aktive_uint srcby, srcbx, srcbz;
	aktive_uint row, col, band;

	for (row = 0, dsty = DST.y, srcay = SRCA.y, srcby = SRCB.y;
	     row < DST.height;
	     row ++ , dsty ++     , srcay ++, srcby ++) {
	    for (col = 0, dstx = DST.x, srcax = SRCA.x, srcbx = SRCB.x;
		 col < DST.width;
		 col ++ , dstx ++     , srcax ++, srcbx ++) {
		for (band = 0, dstz = 0, srcaz = 0, srcbz = 0;
		     band < DST.depth;
		     band ++, dstz ++, srcaz ++, srcbz ++) {

		    aktive_uint srcapos = srcay * sapitch + srcax * sadepth + srcaz;
		    aktive_uint srcbpos = srcby * sbpitch + srcbx * sbdepth + srcbz;
		    aktive_uint dstpos  = dsty  * dpitch  + dstx  * ddepth  + dstz;

		    double valuea = a->pixel [srcapos];
		    double valueb = b->pixel [srcbpos];

		    TRACE ("%3d %3d %3d | %3d | %3d %3d %3d | %3d | %3d %3d %3d | %3d | %.2f | %.2f",
			   srcay, srcax, srcaz, srcapos,
			   srcay, srcbx, srcbz, srcbpos,
			   dsty, dstx, dstz, dstpos,
			   valuea, valueb);

		    ASSERT (srcapos < a->used,     "pixel source A out of bounds");
		    ASSERT (srcbpos < b->used,     "pixel source B out of bounds");
		    ASSERT (dstpos  < block->used, "pixel destin out of bounds");

		    block->pixel [dstpos] = @@cfunction@@ (valuea, valueb);
		}
	    }
	}
	#undef SRCA
	#undef SRCB
	#undef DST
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
