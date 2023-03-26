## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Geometry changes

# # ## ### ##### ######## ############# #####################
## - Band   un/folding -- Bands become columns and the reverse
## - Row    un/folding -- does not make sense
## - Column un/folding -- does not make sense

# # ## ### ##### ######## ############# #####################

operator op::geometry::bands::fold {

    section transform geometry

    note Returns image with the input's columns folded into bands, reducing width. \
	The result is a (input depth * k)-band image and input width divided by k.

    note The parameter k has to be a proper divisor of the input width. \
	I.e. the input width divided by k leaves no remainder.

    input

    uint by	Folding factor. Range 2... Factor 1 is a nop-op.

    # No operation for fold factor 1.
    simplify for  if {$by == 1}  returns src

    # folding is complementary to an unfold, if the fold factor matches the depth of
    # the image the unfold applied to.
    simplify for \
	src/type op::geometry::bands::unfold \
	src/pop \
	src/attr depth __d \
	if {$by == $__d} \
	returns src	;# this actually is src/child

    # A chain of folds is a single fold with a multiplied fold factor.
    simplify for \
	src/type @self \
	src/value by __by \
	calc __by {$__by * $by} \
	src/pop \
	returns op geometry bands fold : by __by

    state -setup {
	// could be moved into the cons wrapper created for simplification
	if (param->by == 0) {
	    aktive_fail ("Rejecting undefined folding by 0");
	}

	// geometry setup
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));

	if ((domain->width % param->by) != 0) {
	    aktive_failf ("Rejecting folding by %d, not a divisor of %d",
			  param->by, domain->width);
	}

	domain->width /= param->by;
	domain->depth *= param->by;
    }

    # folded (depth 4)
    #
    #    0123456789
    #    aaaaaaaaaa
    #    bbbbbbbbbb
    #    cccccccccc
    #       |---|	query 3..7 w=5, d=4
    #
    # unfolded (depth 2, factor by = 2)
    #          |--------|
    #    0123456789012345678901234567890123456789
    #    0a1a2a3a4a5a6a7a8a9a
    #    bcbcbcbcbcbcbcbcbcbc
    #          |--------| 6...15 = 3*by..7*by+(by-1) =((7+1)*by-1)
    #                     w = 10 = 5*by

    pixels {
	// rewrite request and returned pixel block
	// child request

	aktive_rectangle_def_as (subrequest, request);
	subrequest.x     *= param->by;
	subrequest.width *= param->by;

	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	// rewrite result geometry to match this image, for proper blit.
	// done in a local copy because `src` belongs to the input.

	aktive_block srcr  = *src;
	srcr.domain.width /= param->by;
	srcr.domain.depth *= param->by;

	aktive_blit_copy0 (block, dst, &srcr);

    }
}

operator op::geometry::bands::unfold {

    section transform geometry

    note Returns image with the input's bands unfolded and making it wider. \
	The result is a single-band image wider by input depth times.

    input

    # No operation if the input is already single-band
    simplify for \
	src/attr depth __d \
	if {$__d == 1} \
	returns src

    # unfold and fold are complementary and cancel
    simplify for \
	src/type op::geometry::bands::fold \
	returns src/child

    state -fields {
	aktive_uint depth;	// quick access to input depth.
	aktive_uint width;	// quick access to input width.
    } -setup {
	// geometry setup
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->width = domain->width;
	state->depth = domain->depth;
	domain->width *= domain->depth;
	domain->depth = 1;
    }

    # unfolded
    #	012345678901234567890123456789012345678
    #   ..........1.........2.........3........
    #             |---------| query: 10...20 w=11
    #
    # folded (depth 3)
    #      |--|		3..6 w=4 10%3 == 1 ~ start/x offset in fetched block
    #   0123456789012
    #   ..........1..
    #      |  |
    #   0369258147036
    #   1470369258147
    #   2581470369258
    #

    pixels {
	// rewrite request and returned pixel block
	// x offset in fetched block

	aktive_point srcloc = { .x = request->x % istate->depth, .y = 0 };

	// child request, gridded to input

	aktive_rectangle_def_as (subrequest, request);
	subrequest.x     /= istate->depth;
	subrequest.width /= istate->depth;
	int xm = aktive_rectangle_get_xmax (&subrequest);
	if (xm > istate->width) { subrequest.width -= xm - istate->width; }

	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	// rewrite result geometry to match this image, for proper blit
	// done in a local copy because `src` belongs to the input.

	aktive_block srcr  = *src;
	srcr.domain.width *= srcr.domain.depth;
	srcr.domain.depth  = 1;

	aktive_blit_copy (block, dst, &srcr, &srcloc);
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
