## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Composer -- Joinining two or more images in some form

# # ## ### ##### ######## ############# #####################
## Merge images along one of the coordinate axes
#
## - Replicated montage of a single image.
## - Multi-image montage on top of the binary core
## - Montage core, 2 images

operator {coordinate layout} {
    op::montage::x-rep  x {left to right}
    op::montage::y-rep  y {top to bottom}
    op::montage::z-rep  z {front to back}
} {
    section composer

    example {aktive image zone width 32 height 32} {@1 by 3}

    note Returns image with input joined $layout with itself N times \
	along the ${coordinate}-axis.

    uint by	Replication factor

    input

    body {
	# I. Base list of images to montage
	set copies {}
	while {$by} { lappend copies $src ; incr by -1 }
	# II. Multi-montage
	return [@@coordinate@@ {*}$copies]
    }
}

operator {coordinate layout} {
    op::montage::x  x {left to right}
    op::montage::y  y {top to bottom}
    op::montage::z  z {front to back}
} {
    section composer

    example \
	{aktive image zone     width  32 height  32} \
	{aktive image gradient width  64 height  64 depth 1 first 0 last 1} \
	{aktive image eye      width 128 height 128 factor 0.8} \
	{@1 @2 @3}

    example \
	{aktive                        image gradient width 64 height 64 depth 1 first 0 last 1} \
	{aktive op rotate cw   [aktive image gradient width 64 height 64 depth 1 first 0 last 1]} \
	{aktive op rotate half [aktive image gradient width 64 height 64 depth 1 first 0 last 1]} \
	{@1 @2 @3}

    note Returns image with all inputs joined $layout along the ${coordinate}-axis.

    input...

    body {
	aktive::aggregate {
	    aktive op montage @@coordinate@@-core
	} $args
    }
}

operator {coordinate dimension layout dima dimb} {
    op::montage::x-core  x width  {left to right} height depth
    op::montage::y-core  y height {top to bottom} width  depth
    op::montage::z-core  z depth  {front to back} width  height
} {
    section composer

    note Returns image with the 2 inputs joined $layout along the ${coordinate}-axis.

    note The location of the first image becomes the location of the result.
    note The other location is ignored.

    note The $dimension of the result is the sum of the ${dimension}s of the inputs.

    note The other dimensions use the maximum of the same over the inputs.
    note In the result the uncovered parts are zero (black)-filled.

    input
    input

    def xadjust [dict get {
	x {g0->x + g0->width}
	y {g0->x}
	z {g0->x}
    } $coordinate]

    def yadjust [dict get {
	x {g0->y}
	y {g0->y + g0->height}
	z {g0->y}
    } $coordinate]

    def xyfields {
	aktive_rectangle r0;	// Input domains in the result geometry
	aktive_rectangle r1;	//
	aktive_uint      d0;	// Input depths to control band fill
	aktive_uint      d1;	//
    }
    def xysetup {
	state->d0 = g0->depth;
	state->d1 = g1->depth;

	aktive_rectangle_copy (&state->r0, aktive_geometry_as_rectangle (g0));
	aktive_rectangle_copy (&state->r1, aktive_geometry_as_rectangle (g1));
	aktive_rectangle_add  (&state->r1, &state->delta);

	TRACE_GEOMETRY_M  ("geo[0]", g0);
	TRACE_GEOMETRY_M  ("geo[1]", g1);
	TRACE_POINT_M     ("offset", &state->delta);
	TRACE_RECTANGLE_M ("dom[0]", &state->r0);
	TRACE_RECTANGLE_M ("dom[1]", &state->r1);
    }

    def fields [dict get {
	x { @@xyfields@@ }
	y { @@xyfields@@ }
	z { aktive_uint	   d0;	// Input depth to control band fill }
    } $coordinate]

    def setup [dict get {
	x { @@xysetup@@ }
	y { @@xysetup@@ }
	z {
	    state->d0 = aktive_image_get_depth (srcs->v [0]);

	    TRACE_POINT_M ("offset", &state->delta);
	}
    } $coordinate]

    state -fields {
	aktive_point     delta;	// Delta from 2nd input's result location to actual location.
	@@fields@@
    } -setup {
	aktive_geometry* g0 = aktive_image_get_geometry (srcs->v [0]);
	aktive_geometry* g1 = aktive_image_get_geometry (srcs->v [1]);

	aktive_point_set (&state->delta, @@xadjust@@ - g1->x, @@yadjust@@ - g1->y);

	@@setup@@

	aktive_geometry_copy (domain, g0);
	domain->@@dimension@@ += g1->@@dimension@@;
	domain->@@dima@@ = MAX (domain->@@dima@@, g1->@@dima@@);
	domain->@@dimb@@ = MAX (domain->@@dimb@@, g1->@@dimb@@);
    }

    if {$coordinate in {x y}} {
	# With the original request cropped to the domain of the montage we know that it
	# starts in one input, and ends in another (possibly the same), for the montage
	# dimension. The sub requests are created by intersecting the translated request
	# with the input domains.

	#
	# |--------------|---------------|
	#     |-------------| req
	#     |----------|    intersect 0
	#		 |--| intersect 1

	pixels {
	    aktive_rectangle section;

	    aktive_rectangle_intersect (&section, request, &istate->r0);

	    TRACE_RECTANGLE_M ("request            ", request);
	    TRACE_RECTANGLE_M ("geo[0] intersection", &section);

	    if (!aktive_rectangle_is_empty (&section)) {
		aktive_rectangle_def_as (dstm, dst);

		int smax = aktive_rectangle_get_@@coordinate@@max (&section);
		int rmax = aktive_rectangle_get_@@coordinate@@max (request);

		TRACE ("CUT %d < %d | %d", smax, rmax, rmax - smax);
		if (smax < rmax) { dstm.@@dimension@@ -= rmax - smax; }
		dstm.@@dima@@ = section.@@dima@@;

		TRACE_RECTANGLE_M ("dst[0] ............", &dstm);

		aktive_block* src = aktive_region_fetch_area (srcs->v[0], &section);

		aktive_blit_copy0 (block, &dstm, src);

		if (istate->d0 < idomain->depth) {
		    aktive_blit_clear_bands_from (block, &dstm,
			  istate->d0, idomain->depth - istate->d0);
		}
	    }

	    TRACE_POINT_M ("offset", &istate->delta);

	    aktive_rectangle_intersect (&section, request, &istate->r1);

	    TRACE_RECTANGLE_M ("request	           ", request);
	    TRACE_RECTANGLE_M ("geo[1] intersection", &section);

	    if (!aktive_rectangle_is_empty (&section)) {
		aktive_rectangle_def_as (dstm, dst);

		int smin = section.@@coordinate@@;
		int rmin = request->@@coordinate@@;
		TRACE ("SHIFT+CUT %d < %d | %d", smin, rmin, smin - rmin);
		if (smin > rmin) {
		    int off = smin - rmin;
		    dstm.@@dimension@@ -= off;
		    dstm.@@coordinate@@ += off;
		}
		dstm.@@dima@@ = section.@@dima@@;

		TRACE_RECTANGLE_M ("dst[1] ............", &dstm);

		// Translate intersection from result geometry to input
		aktive_rectangle_sub (&section, &istate->delta);

		TRACE_POINT(&istate->delta);
		TRACE_RECTANGLE_M ("geo[1] section'delt", &section);

		aktive_block* src = aktive_region_fetch_area (srcs->v[1], &section);

		aktive_blit_copy0 (block, &dstm, src);

		if (istate->d1 < idomain->depth) {
		    aktive_blit_clear_bands_from (block, &dstm,
			  istate->d1, idomain->depth - istate->d1);
		}
	    }
	}
    } else {
	# z montage - mostly simplification - (z, zmax) == (0, depth). no x/y translations involved.
	#	    - some complexification - input depth < result depth => needs 0-fill

	pixels {
	    // For z montage the incoming request is not intersected, we know that it fits.
	    // We do perform the translation for the 2nd input, though. This is done on a
	    // copy of the request as the called image's fetcher can rewrite it.

	    aktive_rectangle rectb;
	    aktive_rectangle_copy (&rectb, request);

	    aktive_blit_copy0_bands_to (block, dst,
					aktive_region_fetch_area (srcs->v[0], request),
					0);

	    TRACE_POINT(&istate->delta);

	    aktive_rectangle_sub (&rectb, &istate->delta);
	    aktive_blit_copy0_bands_to (block, dst,
					aktive_region_fetch_area (srcs->v[1], &rectb),
					istate->d0);
	}
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
