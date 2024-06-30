## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Convolution, Spatial
#
## References
#
# - https://en.wikipedia.org/wiki/Convolution
# - https://betterexplained.com/articles/intuitive-convolution/
# - http://www.dspguide.com/ch24/6.htm
# - https://micro.magnet.fsu.edu/primer/java/digitalimaging/processing/kernelmaskoperation/
# - https://archive.org/details/Lectures_on_Image_Processing

# # ## ### ##### ######## ############# #####################

operator {
    op::convolve::xy
} {
    # simplifications - none implemented (yet)
    ##
    # As convolution is associative a chain of convolutions can be converted into a single
    # convolution of the chain of convolved matrices. IOW:
    #
    # R = (...((I * M1) * M2) *...* Mk)
    #   = I * (M1*M2*...*Mk)
    #
    # This is a simplification as the filter matrices would be convolved once and the
    # combined filter result materialized.
    #
    # Actual setup of this simplification is more difficult because we should expect
    # intercalated embed operations ensuring proper sizing. These would have to be moved
    # to the input together.

    section transform convolution

    input	;# convolution matrix - internally materialized (See `op::band::recombine`).
    input	;# input image (See `op::tile::rank` for analogous blit setup).

    note Returns image of input (2nd argument) convolved with the matrix (1st argument).

    strict 1st The convolution kernel is materialized and cached.

    note The location of the matrix image is ignored.

    note A matrix with even width and/or height is extended at the right/bottom to \
	be of odd width and height.

    note Beware, the result image is shrunken by matrix `width-1` and `height-1` \
	relative to the input. Inputs smaller than that are rejected.

    note If shrinkage is not desired add a border to the input using one of \
	the `aktive op embed ...` operators before applying this operator.

    note The prefered embedding for convolution is `mirror`. \
	It is chosen to have minimal to no impact on results \
	at the original input's borders.

    state -fields {
	aktive_region matrix;	// region to hold materialized convolution matrix
	double*       mpixel;	// quick access to matrix data
	aktive_uint   mcap;     // quick access to matrix capacity/use
	aktive_uint   mwidth;	// quick access to matrix width
	aktive_uint   mheight;	// quick access to matrix height
	aktive_uint   mwradius;	// quick access to matrix width radius
	aktive_uint   mhradius;	// quick access to matrix height radius
    } -cleanup {
	aktive_region_destroy (state->matrix);
	// mpixel goes away with the region.
    } -setup {
	aktive_image     matrix = srcs->v[0];
	aktive_geometry* mg     = aktive_image_get_geometry (matrix);
	aktive_geometry* ig     = aktive_image_get_geometry (srcs->v[1]);
	aktive_geometry_copy (domain, ig);

	// extend matrix geometry if needed (internally it is always odd-sized)

	aktive_uint mwidth  = mg->width;  if (mwidth  % 2 == 0) { mwidth  ++; }
	aktive_uint mheight = mg->height; if (mheight % 2 == 0) { mheight ++; }

	if ((domain->width  < mwidth) ||
	    (domain->height < mheight)) {
	    aktive_failf ("Image %dx%d too small for %dx%d convolution matrix",
			  domain->width, domain->height, mwidth, mheight);
	}

	aktive_uint mwradius = mwidth  / 2;
	aktive_uint mhradius = mheight / 2;

	// materialize recombiner matrix -- note that this performs the actual
	// extension of an even-sized matrix, i.e. provides necessary zeroes
	// to the right and bottom.

	state->matrix   = aktive_region_new (matrix, 0);
	state->mwidth   = mwidth;
	state->mheight  = mheight;
	state->mwradius = mwradius;
	state->mhradius = mhradius;

	aktive_rectangle_def_as(mrect,aktive_geometry_as_rectangle (mg));
	mrect.width     = mwidth;
	mrect.height    = mheight;

	aktive_block* m = aktive_region_fetch_area (state->matrix, &mrect);
	state->mpixel   = m->pixel;
	state->mcap     = m->used;

	// finalize the reduced result domain

	domain->x      += mwradius;
	domain->y      += mhradius;
	domain->width  -= mwidth-1;
	domain->height -= mheight-1;
    }

    blit convolver {
	{AH {y AY 1 up} {y mhradius 1 up}}
	{AW {x AX 1 up} {x mwradius 1 up}}
	{DD {z  0 1 up} {z        0 1 up}}
    } [list raw convolve-tile {
	// dstvalue = cell to set
	// srcvalue = center cell of tile
	*dstvalue = aktive_tile_convolve (srcvalue, srcpos, SRCCAP, srcpitch, srcstride,
					  mpixel, mcap, mwidth, mheight, mwradius, mhradius);
    }]

    pixels {
	// cache the important values locally

	aktive_uint mwradius = istate->mwradius;	TRACE ("mwradius %u", mwradius);
	aktive_uint mhradius = istate->mhradius;	TRACE ("mhradius %u", mhradius);
	aktive_uint mwidth   = istate->mwidth;		TRACE ("mwidth   %u", mwidth  );
	aktive_uint mheight  = istate->mheight;		TRACE ("mheight  %u", mheight );
	aktive_uint mcap     = istate->mcap;		TRACE ("mcap     %u", mcap    );
	double*     mpixel   = istate->mpixel;

	// compute and fetch input region needed for calculating the request data

	aktive_rectangle_def_as (subrequest, request);
	subrequest.x      -= mwradius;
	subrequest.y      -= mhradius;
	subrequest.width  += istate->mwidth-1;
	subrequest.height += istate->mheight-1;

	TRACE_RECTANGLE_M("convolve", &subrequest);
	aktive_block* src = aktive_region_fetch_area (srcs->v[1], &subrequest);

	// do the calculation

	@@convolver@@

	TRACE_DO (__aktive_block_dump ("@@thing@@ convolve out", block));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
