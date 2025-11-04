## -*- mode: tcl ; fill-column: 90 -*-
# # # ## ### ##### ######## ############# #####################
## Transformer -- Recombine band data

operator op::bands::recombine {
    section transform

    example {
	aktive image from matrix width 3 height 3 values 0.3588 0.7044 0.1368 0.2990 0.5870 0.1140 0.2392 0.4696 0.0912 | -matrix
	butterfly
	@1 @2
    }

    note Returns an image with the input's band information \
	recombined through a matrix-vector multiplication.

    note The band values of the input's pixels are the vectors \
	which are multiplied with the recombination matrix.

    note The matrix is the first image argument. \
	The input to be processed is the second image argument.

    note The matrix has to be single-band and its height has \
	to match the depth of the input. The width of the \
	matrix becomes the depth of the result.

    note The location of the matrix image is ignored.

    input matrix	Matrix to process the source's bands with.
    input src		Image to process

    # Internal :: The matrix image is fully materialized on construction.

    state -fields {
	aktive_region matrix;	// region to hold materialized combiner matrix
	double*       mpixel;	// quick access matrix data
	aktive_uint   mwidth;	// quick access matrix width
	aktive_uint   mheight;	// quick access matrix height
    } -cleanup {
	aktive_region_destroy (state->matrix);
	// mpixel goes away with the region.
    } -setup {
	aktive_image     matrix = srcs->v[0];
	aktive_geometry* mg     = aktive_image_get_geometry (matrix);
	aktive_geometry* ig     = aktive_image_get_geometry (srcs->v[1]);

	// Validate geometries

	if (mg->height != ig->depth) \
	    aktive_failf ("mismatch, matrix height %d does not match image depth %d",
			  mg->height, ig->depth);

	// initialize result geometry

	aktive_geometry_copy (domain, ig);
	domain->depth = mg->width;

	// materialize recombiner matrix

	state->matrix  = aktive_region_new (matrix, 0);
	state->mwidth  = mg->width;
	state->mheight = mg->height;
	state->mpixel  = aktive_region_fetch_area_head (state->matrix,
				aktive_geometry_as_rectangle (mg))->pixel;
    }

    blit recombiner {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
    } {raw matrix-multiply-bands {
	// dstvalue       - vector of destination bands
	// srcvalue       - vector of source bands
	// istate->mpixel - recombiner matrix
	aktive_matrix_mul (dstvalue, srcvalue, istate->mpixel,
			   istate->mwidth, istate->mheight);
    }}

    pixels {
	// src[0] = matrix is handled specially, see state (setup)
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (1, request);
	@@recombiner@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
