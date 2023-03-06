## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Exchange two axes with each other

operator {coorda coordb coordc dima dimb dimc} {
    op::swap::xy x y z   width  height depth
    op::swap::xz x z y   width  depth  height
    op::swap::yz y z x   height depth  width
} {
    section transform structure

    note Returns image with the ${coorda}- and ${coordb}-axes of the input exchanged.

    note The location of the image is not changed.

    input

    # swaps are self-complementary

    simplify for   src/type @self   returns src/child

    # A swap is a mirror along a diagonal. This exchanges two axes.  The location is left
    # unchanged. This makes the implementation more consistent when the swap involves the
    # z-axis. Changing the location with z involved are degenerative cases.

    # - `xz` :: A requested column-block becomes a band-block in the source.
    # - `yz` :: A requested row-block becomes a band-block in the source.
    #
    #           As we cannot ask for band-blocks the source is asked for all bands.  The
    #           blitter is then responsible for pulling out only the desired bands to
    #           become columns, or rows.
    #
    #           See block `swap-rewrite` below.

    # base blitter setup
    set blitspec {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    }
    #    0  1          2
    #        0 1 2 3    0 1 2 3
    #             axis -^ ^- first

    # ... swap two axes
    switch -exact -- $coorda$coordb {
	xy { lset blitspec 0 2 0 x ; lset blitspec 1 2 0 y }
	xz { lset blitspec 1 2 0 z ; lset blitspec 2 2 0 x ; lset blitspec 1 2 1 first }
	yz { lset blitspec 0 2 0 z ; lset blitspec 2 2 0 y ; lset blitspec 0 2 1 first }
    }
    #                                ^- axis ----------^     ^- first ---------^
    # ... generate code
    blit swapper $blitspec copy

    def swap-rewrite [dict get {
	xy {
	    // Full exchange width/height
	    AKTIVE_SWIVEL (&subrequest, width, height);
	    // Recode the request location into the unswapped coordinate system
	    subrequest.y = idomain->y + (request->x - idomain->x);
	    subrequest.x = idomain->x + (request->y - idomain->y);
	}
	xz {
	    // Partial exchange width/depth
	    subrequest.width  = idomain->depth;
	    // Recode the request location into the unswapped coordinate system
	    subrequest.x      = idomain->x; // idomain->x + (request->z - idomain->z)
	    //                                               0          - 0
	    aktive_uint first = 0 + (request->x - idomain->x); TRACE("first %d", first);
	}
	yz {
	    // Partial exchange height/depth
	    subrequest.height = idomain->depth;
	    // Recode the request location into the unswapped coordinate system
	    subrequest.y      = idomain->y; // idomain->y + (request->z - idomain->z)
	    //                                               0          - 0
	    aktive_uint first = 0 + (request->y - idomain->y); TRACE("first %d", first);
	}
    } $coorda$coordb]

    state -setup {
	// The dimensions for the swapped axes (@@coorda@@, @@coordb@@) are exchanged.
	// The location does not change.

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));

	AKTIVE_SWIVEL (domain, @@dima@@, @@dimb@@);
    }
    pixels {
	aktive_rectangle_def_as (subrequest, request);
	// Rewrite request
	@@swap-rewrite@@

	TRACE_RECTANGLE_M ("rewritten", &subrequest);

	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	// The        dst @@coorda@@-axis is fed from the src @@coordb@@-axis
	// Vice versa dst @@coordb@@-axis is fed from the src @@coorda@@-axis
	// The @@coordc@@-axis maps as-is
	@@swapper@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
