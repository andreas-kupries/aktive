## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Cumulations along the various axes, and the entire image
##
## Note: Cumulation of the entire image is also known as `Sum Area Table`.

# # ## ### ##### ######## ############# #####################

operator op::row::cumulative {
    section transform statistics

    input

    note Returns image with the input rows transformed into cumulative sums.
    note This means that each pixel in a row is the sum of the values in the columns before it, \
	having the same row.
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

	rcs_context rcs = {
	    .bands   = bands,
	    .request = &subrequest,
	    .src     = srcs->v[0]
	};

	#define ITERZ for (z = 0; z < bands; z++)
	#define ITERX for (x = request->x, k = 0; k < request->width  ; x++, k++)
	#define ITERY for (y = request->y, j = 0; j < request->height ; y++, j++)

	ITERY {
	    ITERZ {
		rcs.z = z;
		/* rcs->request */ subrequest.y = y;
		double* cs = aktive_iveccache_get (state->sums, y*bands+z, RCSFILL, &rcs);
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
	#undef RCSFILL

	TRACE_DO (__aktive_block_dump ("row csum out", block));
    }

    support {
	typedef struct rcs_context {
	    aktive_uint         z;       // requested band
	    aktive_uint         bands;   // overall #bands
	    aktive_rectangle*   request; // request for input (has actual column)
	    aktive_region       src;     // input region to pull from
	} rcs_context;

	static void
	row_cumulative_sum (rcs_context* rcs, aktive_uint index, double* dst)
	{
	    TRACE_FUNC("([%d] %u,%u[%u] (dst) %p [%u])", index, rcs->request->y, rcs->z,
		       rcs->bands, dst, rcs->request->width);

	    // ask for single row, all bands
	    aktive_block* src = aktive_region_fetch_area (rcs->src, rcs->request);

	    // compute the cumulative sum directly into the destination
	    // properly offset into the requested band, with stride

	    kahan running_sum; aktive_kahan_init (&running_sum);

	    #define ITER aktive_uint i; for (i=0; i < rcs->request->width; i++)
	    ITER {
		double x = src->pixel [rcs->z + i*rcs->bands];
		aktive_kahan_add (&running_sum, x);
		dst[i] = aktive_kahan_final (&running_sum);
	    }
	    #undef ITER

	    TRACE_HEADER(1); TRACE_ADD ("row csum = {", 0);
	    for (int j = 0; j < rcs->request->width; j++) { TRACE_ADD (" %f", dst[j]); }
	    TRACE_ADD(" }", 0); TRACE_CLOSER;

	    TRACE_RETURN_VOID;
	}

	#define RCSFILL ((aktive_iveccache_fill) row_cumulative_sum)
    }
}

# # ## ### ##### ######## ############# #####################

operator op::column::cumulative {
    section transform statistics

    input

    note Returns image with the input columns transformed into cumulative sums.
    note This means that each pixel in a column is the sum of the values in the rows before it, \
	having the same column.
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
	TRACE_RECTANGLE_M("colcsum", &subrequest);

	aktive_uint x, y, z, k, q, j;
	aktive_uint stride = block->domain.width * block->domain.depth;
	aktive_uint bands  = block->domain.depth;

	// start each line in a different column, spread the threads across the width of the image
	// reduce chance of lock fighting over the column vectors during the creation phase

	aktive_uint xmin   = request->x;
	aktive_uint xmax   = request->x + request->width - 1;
	aktive_uint xoff   = aktive_fnv_step (request->y) % request->width;
	aktive_uint xstart = xmin + xoff;

	ccs_context ccs = {
	    .bands   = bands,
	    .request = &subrequest,
	    .src     = srcs->v[0]
	};

	#define ITERZ for (z = 0; z < bands; z++)
	#define ITERX for (x = xstart, k = xoff, q = 0; q < request->width  ; q++)
	#define ITERY for (y = request->y, j = 0      ; j < request->height ; y++, j++)

	ITERX {
	    ITERZ {
		ccs.z = z;
		/* ccs->request */ subrequest.x = x;
		double* cs = aktive_iveccache_get (state->sums, x*bands+z, CCSFILL, &ccs);
		// cs is full input height

		TRACE_HEADER(1); TRACE_ADD ("[x,z=%u,%u] col sum = {", x, z);
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
	#undef CCSFILL

	TRACE_DO (__aktive_block_dump ("column csum out", block));
    }

    support {
	typedef struct ccs_context {
	    aktive_uint         z;       // requested band
	    aktive_uint         bands;   // overall #bands
	    aktive_rectangle*   request; // request for input (has actual column)
	    aktive_region       src;     // input region to pull from
	} ccs_context;

	static void
	col_cumulative_sum (ccs_context* ccs, aktive_uint index, double* dst)
	{
	    TRACE_FUNC("([%d] %u,%u[%u] (dst) %p [%u])", index, ccs->request->x, ccs->z,
		       ccs->bands, dst, ccs->request->height);

	    // ask for single input column, all bands
	    aktive_block* src = aktive_region_fetch_area (ccs->src, ccs->request);

	    // compute the cumulative sum directly into the destination
	    // properly offset into the requested band, with stride

	    kahan running_sum; aktive_kahan_init (&running_sum);

	    #define ITER aktive_uint i; for (i=0; i < ccs->request->height; i++)
	    ITER {
		double x = src->pixel [ccs->z + i*ccs->bands];
		aktive_kahan_add (&running_sum, x);
		dst[i] = aktive_kahan_final (&running_sum);
	    }
	    #undef ITER

	    TRACE_HEADER(1); TRACE_ADD ("col csum = {", 0);
	    for (int j = 0; j < ccs->request->height; j++) { TRACE_ADD (" %f", dst[j]); }
	    TRACE_ADD(" }", 0); TRACE_CLOSER;

	    TRACE_RETURN_VOID;
	}

	#define CCSFILL ((aktive_iveccache_fill) col_cumulative_sum)
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
