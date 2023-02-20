## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Mirror the image along one of the coordinate axes

operator coordinate {
    op::flip::x x
    op::flip::y y
    op::flip::z z
} {
    note Transformer. Structure. Mirrors the input along the ${coordinate}-axis.

    input keep

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

    def rewrite [dict get {
	x {
	    // Flip the request before passing it on.
	    int newx = idomain->width - 1 - aktive_rectangle_get_xmax (request);
	    TRACE ("flip x %d --> (%d-1-%d) %d", request->x, idomain->width, aktive_rectangle_get_xmax (request), newx);
	    request->x = newx;
	}
	y {
	    // Flip the request before passing it on.
	    int newy = idomain->height - 1 - aktive_rectangle_get_ymax (request);
	    TRACE ("flip y %d --> (%d-1-%d) %d", request->y, idomain->width, aktive_rectangle_get_ymax (request), newy);
	    request->y = newy;
	}
	z {
	    // Nothing to flip, depth requests are never partial
	}
    } $coordinate]

    state -setup {
	// The geometry and location are unchanged. Only the internal arrangement of the
	// pixels in memory changes.
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	@@rewrite@@
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	// The @@coordinate@@ axis is scanned in reverse order.
	@@flipper@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
