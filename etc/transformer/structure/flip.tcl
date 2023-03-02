## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Mirror the image along one of the coordinate axes

operator {coordinate dimension} {
    op::flip::x  x width
    op::flip::y  y height
    op::flip::z  z depth
} {
    section transform structure

    note Returns image which mirrors the input along the ${coordinate}-axis.

    input

    # flips are self-complementary
    simplify for   src/type @self   returns src/child

    # base blitter setup
    set blitspec {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    }
    # ... invert specific axis
    switch -exact -- $coordinate {
	y { lset blitspec 0 2 3 down }
	x { lset blitspec 1 2 3 down }
	z { lset blitspec 2 2 3 down }
    }
    # ... generate code
    blit flipper $blitspec copy

    def flip-rewrite-core {
	// Flip the request before passing it on.
	int new = idomain->@@dimension@@ - 1 - aktive_rectangle_get_@@coordinate@@max (request);
	TRACE ("flip @@coordinate@@ %d --> %d = (%d-1-%d)", request->@@coordinate@@, new,
	       idomain->@@dimension@@, aktive_rectangle_get_@@coordinate@@max (request));
	subrequest.@@coordinate@@ = new;
    }

    def rewrite [dict get {
	x { @@flip-rewrite-core@@ }
	y { @@flip-rewrite-core@@ }
	z { // Nothing to flip, depth requests are never partial }
    } $coordinate]

    state -setup {
	// The geometry and location are unchanged. Only the internal arrangement of the
	// pixels in memory changes.
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_rectangle_def_as (subrequest, request);
	@@rewrite@@
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	// The @@coordinate@@ axis is scanned in reverse order.
	@@flipper@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
