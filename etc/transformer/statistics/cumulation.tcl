## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Cumulations along the various axes
##                 (rows, columns, bands), and the entire image.
##                Tiled does not make sense.
##
## Note: Cumulation of the entire image is also known as `Sum Area Table`.

## Note: Due to the wrap around from one row to the next this operation
##       is __not separable__ into a combination of row and column csums.
##       It might be possible to use a veccache for some perf boost.

# # ## ### ##### ######## ############# #####################

operator op::row::cumulative {
    section transform statistics

    input

    note Returns image with the input rows transformed into cumulative sums.

    note This means that each pixel in a row is the sum of the values in the \
	columns before it, having the same row.

    note The result has the same geometry as the input. Only the contents change.

    state -fields {
	aktive_iveccache sums; // cache, result row cumulations
    } -cleanup {
	aktive_iveccache_release (state->sums);
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->sums = aktive_iveccache_new (domain->height * domain->depth, domain->width);
	// note: #(row vectors) takes bands into account
    }

    pixels -state {
	aktive_iveccache sums; // cache, result row sums, thread-shared
    } -setup {
	state->sums = istate->sums;
    } {
	// Scan the rows of the request
	// - Get the associated cumulative sums from the cache
	// - If needed, compute the sums

	aktive_rectangle_def_as (subrequest, request);
	subrequest.height = 1; subrequest.width = idomain->width; subrequest.x = 0;
	TRACE_RECTANGLE_M("row csum", &subrequest);

	aktive_uint x, y, z, k, j;
	aktive_uint stride = block->domain.width * block->domain.depth;
	aktive_uint bands  = block->domain.depth;

	aktive_csum_context csc = {
	    // .z is set during the iteration. same for subrequest.y
	    .size    = subrequest.width,
	    .stride  = bands,
	    .request = &subrequest,
	    .src     = srcs->v[0]
	};

	#define ITERZ for (z = 0; z < bands; z++)
	#define ITERX for (x = request->x, k = 0; k < request->width  ; x++, k++)
	#define ITERY for (y = request->y, j = 0; j < request->height ; y++, j++)

	ITERY {
	    ITERZ {
		csc.z = z;
		/* csc->request */ subrequest.y = y;
		double* cs = aktive_iveccache_get (state->sums, y*bands+z, AKTIVE_CSUM_FILL, &csc);
		// cs is full input width

		TRACE_HEADER(1); TRACE_ADD ("[x,z=%u,%u] sum = {", x, z);
		for (int a = 0; a < subrequest.height; a++) { TRACE_ADD (" %f", cs[a]); }
		TRACE_ADD(" }", 0); TRACE_CLOSER;

		ITERX {
		    TRACE ("line [%u], band [%u] place k%u b%u j%u s%u -> %u", y, z, k, bands, j, stride, z+k*bands+j*stride);
		    block->pixel [z+k*bands+j*stride] = cs[x];
		}    // TODO :: ASSERT against capacity
	    }

	    TRACE_HEADER(1); TRACE_ADD ("[y=%u] line = {", y);
	    for (int a = 0; a < request->width; a++) { TRACE_ADD (" %f", block->pixel[a]); }
	    TRACE_ADD(" }", 0); TRACE_CLOSER;
	}


	#undef ITERX
	#undef ITERY
	#undef ITERZ

	TRACE_DO (__aktive_block_dump ("row csum out", block));
    }
}

# # ## ### ##### ######## ############# #####################

operator op::column::cumulative {
    section transform statistics

    input

    note Returns image with the input columns transformed into cumulative sums.

    note This means that each pixel in a column is the sum of the values in the \
	rows before it, having the same column.

    note The result has the same geometry as the input. Only the contents change.

    state -fields {
	aktive_iveccache sums; // cache, result column cumulations
    } -cleanup {
	aktive_iveccache_release (state->sums);
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->sums = aktive_iveccache_new (domain->width * domain->depth, domain->height);
	// note: #(column vectors) takes bands into account
    }

    pixels -state {
	aktive_iveccache sums; // cache, result column sums, thread-shared
    } -setup {
	state->sums = istate->sums;
    } {
	// Scan the columns of the request
	// - Get the associated cumulative sums from the cache
	// - If needed, compute the sums

	aktive_rectangle_def_as (subrequest, request);
	subrequest.width = 1; subrequest.height = idomain->height; subrequest.y = 0;
	TRACE_RECTANGLE_M("column csum", &subrequest);

	aktive_uint x, y, z, k, q, j;
	aktive_uint stride = block->domain.width * block->domain.depth;
	aktive_uint bands  = block->domain.depth;

	aktive_csum_context csc = {
	    // .z is set during the iteration. same for subrequest.x
	    .size    = subrequest.height,
	    .stride  = bands,
	    .request = &subrequest,
	    .src     = srcs->v[0]
	};

	// start each line in a different column. spreads the threads across the width of
	// the image. reduces chance of lock fighting over the column vectors during their
	// creation

	aktive_uint xmin   = request->x;
	aktive_uint xmax   = request->x + request->width - 1;
	aktive_uint xoff   = aktive_fnv_step (request->y) % request->width;
	aktive_uint xstart = xmin + xoff;

	#define ITERZ for (z = 0; z < bands; z++)
	#define ITERX for (x = xstart, k = xoff, q = 0; q < request->width  ; q++)
	#define ITERY for (y = request->y, j = 0      ; j < request->height ; y++, j++)

	ITERX {
	    ITERZ {
		csc.z = z;
		/* csc->request */ subrequest.x = x;
		double* cs = aktive_iveccache_get (state->sums, x*bands+z, AKTIVE_CSUM_FILL, &csc);
		// cs is full input height

		TRACE_HEADER(1); TRACE_ADD ("[x,z=%u,%u] column sum = {", x, z);
		for (int a = 0; a < subrequest.height; a++) { TRACE_ADD (" %f", cs[a]); }
		TRACE_ADD(" }", 0); TRACE_CLOSER;

		ITERY {
		    TRACE ("line [%u], band [%u] place k%u b%u j%u s%u -> %u", y, z, k, bands, j, stride, z+k*bands+j*stride);
		    block->pixel [z+k*bands+j*stride] = cs[y];
		}    // TODO :: ASSERT against capacity
	    }

	    // step the column with wrap around
	    x++ ; if (x > xmax) x = request->x;
	    k++ ; if (k >= request->width) k = 0;
	}

	TRACE_HEADER(1); TRACE_ADD ("[y=%u] line = {", y);
	for (int a = 0; a < request->width; a++) { TRACE_ADD (" %f", block->pixel[a]); }
	TRACE_ADD(" }", 0); TRACE_CLOSER;

	#undef ITERX
	#undef ITERY
	#undef ITERZ

	TRACE_DO (__aktive_block_dump ("column csum out", block));
    }
}

# # ## ### ##### ######## ############# #####################

operator op::band::cumulative {
    section transform statistics

    input

    note Returns image with the input bands transformed into cumulative sums.

    note This means that each pixel in a band is the sum of the values in the \
	bands before it, having the same row and column.

    note The result has the same geometry as the input. Only the contents change.

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }

    blit prefixsum {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
    } {raw sum-bands {
	// dstvalue = row/col start - 1-strided full band vector
	// srcvalue = row/col start - 1-strided full band vector
	aktive_cumulative_sum (dstvalue, DD, srcvalue, 1);
    }}

    pixels {
	// No caching is required for the bands.
	// The request is passed unchanged.
	// We can and do use a regular blitter.

	aktive_rectangle_def_as (subrequest, request);
	TRACE_RECTANGLE_M("band csum", &subrequest);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	#define AH (dst->height)
	#define AW (dst->width)
	#define AX (dst->x)
	#define AY (dst->y)
	@@prefixsum@@
	#undef AH
	#undef AW
	#undef AX
	#undef AY

	TRACE_DO (__aktive_block_dump ("band csum out", block));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
