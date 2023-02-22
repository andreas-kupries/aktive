## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Exchange two axes with each other

operator {coorda coordb coordc} {
    op::swap::xy x y z
    op::swap::xz x z y
    op::swap::yz y z x
} {
    note Transformer. Structure. Exchanges the ${coorda}- and ${coordb}-axes of the input.

    input keep

    # swaps are self-complementary

    simplify for   src/type @self   returns src/child

    # A swap is a mirror along a diagonal. This exchanges two axes.
    # The location is mirrored as well. Mostly.

    # As the `z` location is fixed to `0`, swaps involving it do not
    # fully fit into that setup. In more detail:

    # - `xz` :: A requested column-block becomes a band-block in the source.
    # - `yz` :: A requested row-block becomes a band-block in the source.
    #
    #           As we cannot ask for band-blocks the source is asked for all bands.  The
    #           blitter is then responsible for pulling out only the desired bands to
    #           become columns, or rows.
    #
    #           See `bandselect`, `first`.

    # base blitter setup
    set blitspec {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    }
    # ... swap two axes
    switch -exact -- $coorda$coordb {
	xy { lset blitspec 0 2 0 x ; lset blitspec 1 2 0 y }
	xz { lset blitspec 1 2 0 z ; lset blitspec 2 2 0 x ; lset blitspec 1 2 1 first }
	yz { lset blitspec 0 2 0 z ; lset blitspec 2 2 0 y ; lset blitspec 0 2 1 first }
    }
    # ... generate code
    blit swapper $blitspec copy

    def bandselect [dict get {
	xy {}
	xz { aktive_uint first = request->x; TRACE("first %d", first); }
	yz { aktive_uint first = request->y; TRACE("first %d", first); }
    } $coorda$coordb]

    state -setup {
	// The locations and dimensions for the swapped axes (@@coorda@@, @@coordb@@) are exchanged.

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	aktive_geometry_swap_@@coorda@@@@coordb@@ (domain);
    }
    pixels {
	@@bandselect@@
	// Rewrite request
	aktive_rectangle_swap_@@coorda@@@@coordb@@ (request, idomain->depth);

	TRACE_RECTANGLE_M ("rewritten", request);

	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	// The        dst @@coorda@@-axis is fed from the src @@coordb@@-axis
	// Vice versa dst @@coordb@@-axis is fed from the src @@coorda@@-axis
	// The @@coordc@@-axis maps as-is
	@@swapper@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
