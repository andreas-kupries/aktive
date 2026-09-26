## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Image transformer - Matrix math, inversion

operator op::math::matrix::invert {
    section transform math matrix

    note Treat the input image as matrix and invert it. \
	The image is allowed to be multi-band. \
	Each band is treated as its own matrix.

    note The input has to be square, i.e. `width == height`. \
	Errors are thrown if this condition is not met.

    note The input has to be non-singular. \
	If its determinant is zero, then no inverse exists, and an error is thrown.

    note The result has the same geometry as the input.

    note See "<!xref: aktive op math matrix invert-core>" for examples

    input mat

    body {
	# pass single-band directly into the core
	if {[aktive query depth $mat] == 1} { return [invert-core $mat] }

	# explode multi-band into layers, process each, and re-join
	aktive op montage z {*}[lmap band [aktive op split z $mat] { invert-core $band }]
    }
}

operator op::math::matrix::invert-core {
    section transform math matrix

    example {
	aktive image from matrix width 1 height 1 values 2  | -matrix -int
	@1                                                  | -matrix
    } ;# 1/2

    example {
	aktive image from matrix width 2 height 2 values 1 2 4 5 | -matrix -int
	@cmd @1                                                  | -matrix
	!!aktive op math matrix multiply @1 @2                   | -matrix
    }
    # --- | -----------
    # 1 2 | -1-2/3  2/3
    # 4 5 |  1+1/3 -1/3
    # --- | -----------

    example {
	set a {
	    1 2 3
	    4 5 6
	    7 8 8
	}
    } {
	aktive image from matrix width 3 height 3 values {*}$a | -matrix -int
	@cmd @1                                                | -matrix
	!!aktive op math matrix multiply @1 @2                 | -matrix
    }
    # ----- | ----------------
    # 1 2 3 | -2-2/3  2+2/3 -1
    # 4 5 6 |  3+1/3 -4-1/3  2
    # 7 8 9 | -1      2     -1
    # ----- | ----------------

    example {
	set a {
	    1 2 3 4
	    5 6 7 8
	    9 0 1 2
	    3 4 5 7
	}
    } {
	aktive image from matrix width 4 height 4 values {*}$a | -matrix -int
	@cmd @1                                                | -matrix
	!!aktive op math matrix multiply @1 @2                 | -matrix
    }
    # ------- | --------------------
    # 1 2 3 4 | -0.15  0.05  0.10  0
    # 5 6 7 8 |	-1.95  0.15 -0.20  1
    # 9 0 1 2 |	 2.35  0.55  0.10 -2
    # 3 4 5 7 |	-0.50 -0.50  0     1
    # ------- | --------------------

    example {
	set a {
	    1 2 3 4 2
	    5 6 7 8 3
	    9 0 1 2 5
	    3 4 5 7 7
	    7 5 3 2 0
	}
    } {
	aktive image from matrix width 5 height 5 values {*}$a | -matrix -int
	@cmd @1                                                | -matrix
	!!aktive op math matrix multiply @1 @2                 | -matrix
    }
    # --------- | --------------------------------------------
    # 1 2 3 4 2 |   0.4545  -0.1727   0.1000  -0.1273   0.1273
    # 5 6 7 8 3 |   2.4545  -1.4727  -0.2000   0.0727   0.9273
    # 9 0 1 2 5 | -10.0000   5.1000   0.1000   0.6000  -2.6000
    # 3 4 5 7 7 |   7.2727  -3.3636   0.0000  -0.6364   1.6364
    # 7 5 3 2 0 |  -1.7273   0.6364   0.0000   0.3636  -0.3636
    # --------- | --------------------------------------------

    note Treat the single-band input image as matrix and invert it.

    note The input has to be square, i.e. `width == height`. \
    	Errors are thrown if this condition is not met.

    note The input has to be non-singular. \
	If its determinant is zero, then no inverse exists, and an error is thrown.

    note The result has the same geometry as the input.

    strict first

    input mat	The matrix to invert

    state -fields {
	aktive_block invers; // the inversion result
    } -cleanup {
	aktive_blit_close (&state->invers);
    } -setup {
	aktive_image     matimage = srcs->v[0];
	aktive_geometry* matgeo   = aktive_image_get_geometry (matimage);
	TRACE_GEOMETRY_M("mat", matgeo);
	if (matgeo->width != matgeo->height) { aktive_fail ("expected a square matrix"); }
	if (matgeo->depth != 1) { aktive_fail ("expected a single-band matrix"); }

	aktive_geometry_copy (domain, matgeo);

	// we compute the inversion now, during construction.
	// IOW, this is a strict operator.

	aktive_rectangle_def_as (matrequest, matgeo);
	aktive_context context = aktive_context_new ();
	aktive_region  region  = aktive_region_new (matimage, context);
	aktive_block*  mat     = aktive_region_fetch_area_head (region, &matrequest);

	memset (&state->invers, 0, sizeof(aktive_block));
	aktive_geometry_copy (&state->invers.domain, matgeo);
	aktive_blit_setup    (&state->invers, aktive_geometry_as_rectangle (matgeo));
	state->invers.initialized = 1;

	switch (matgeo->width) {
	    case 1:  aktive_matrix_invert_1x1 (mat, &state->invers); break;
	    case 2:  aktive_matrix_invert_2x2 (mat, &state->invers); break;
	    case 3:  aktive_matrix_invert_3x3 (mat, &state->invers); break;
	    case 4:  aktive_matrix_invert_4x4 (mat, &state->invers); break;
	    default: aktive_matrix_invert_lup (mat, &state->invers); break;
	}

	aktive_region_destroy  (region);
	aktive_context_destroy (context);

	if (aktive_error_raised ()) { TRACE_RETURN ("(object0*) NIL", 0); }
    }

    pixels -state {
	aktive_block* invers;
    } -setup {
	state->invers = &istate->invers;
    } {
	TRACE("read from cached result", 0);
	aktive_blit_copy (block, dst, state->invers, aktive_rectangle_as_point (request));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
