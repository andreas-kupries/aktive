## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Histogram Statistics

## Not handled in the by-* specs. Histogram statistics are sufficiently different in the
## details of their calculation from the others (aktive_histogram* client data, etc.) to
## warrant separate handling.

## BEWARE : As written performance is sub-optimal - Because asking for a small part of the
##          result causes full (re)calculation of the required histogram. This is
##          especially noticeable for the operations where the primary result direction
##          (i.e. column-wise) is orthogonal to the primary result query direction
##          (i.e. row-wise)
#
##          For good performance this needs a cache holding already calculated histogram
##          data. On the other side of that beware the ballooning memory needed to contain
##          said cache. A disk cache may be needed for large images to limit this, at the
##          expense of some of the performance.
#
##          This is also a place where future management of request types (i.e. by rows,
##          by columns, by tiles, etc.) will be useful.

# # ## ### ##### ######## ############# #####################
## Semi-compress bands/rows/columns/tiles/image down to a statistic (histogram).

operator op::image::histogram {
    section transform statistics

    int? 256 bins \
	The number of bins in the returned histogram. The pixel values are quantized \
	to fit. Only values in the range of \[0..1\] are considered valid. Values \
	outside of that range are placed into the smallest/largest bin. \
	\
	The default quantizes the image values to 8-bit.

    input

    note Returns image with the input transformed into a histogram of `bins` values.

    # Deprecated: Note: it is computed as the column sum of the row histograms of the input
    #
    # Note: it is computed as the transposed row sum of the column histograms of the input
    #
    #       in the current setup, where we concurrently scan over rows
    #       the column sum of the original implementation returns a single row,
    #       causing threading to be effectively disabled.
    #
    #       while the new form computes column histograms their vector cache ensures
    #       that each is calculated only once, and the row sums are concurrent.
    #
    # TODO FUTURE - ops declare prefered access pattern, sinks choose
    # TODO FUTURE - sink auto-chooses different patterns based on image geometry
    #               i.e. thin tall -> by rows, thin wide -> by columns, else ops preference

    body {
	if 0 {
	    set src [aktive op row histogram $src bins $bins]
	    set src [aktive op column sum $src]
	} else {
	    set src [aktive op column histogram $src bins $bins]
	    set src [aktive op row sum $src]
	    set src [aktive op transpose $src]
	}
	return $src
    }
}

operator {dim unchanged} {
    op::band::histogram   band {width and height}
    op::tile::histogram   {}   {}
} {
    section transform statistics

    def thing [lindex [split $__op :] 2]

    if {$thing eq "tile"} {
	uint radius Tile size as radius from center. \
	    Full width and height of the tile are `2*radius+1`.
    }

    int? 256 bins \
	The number of bins held by a single histogram. The pixel values are quantized \
	to fit. Only values in the range of \[0..1\] are considered valid. Values \
	outside of that range are placed into the smallest/largest bin. \
	\
	The default quantizes the image values to 8-bit.

    input

    note Returns image with input ${thing}s transformed into a histogram of `bins` values.

    switch -exact -- $thing {
	band   {
	    note The result is an image of bin-sized histogram ${dim}s with {*}$unchanged of the input
	}
	tile   {
	    note Only single-band images are legal inputs. The result will have `bins` bands.

	    note Beware, the operator consumes overlapping tiles, not just adjacent.

	    note Beware, the result image is shrunken by 2*radius in width and height \
		relative to the input. Inputs smaller than that are rejected.

	    note If shrinkage is not desired add a border to the input using one of \
		the `aktive op embed ...` operators before applying this operator.

	    note The prefered embedding for histogram is black. \
		It is chosen to have minimal to no impact on the statistics \
		at the original input's borders.
	}
    }

    def fieldsetup [dict get {
	band   { state->size = domain->depth;  domain->depth  = param->bins; }
	tile   {
	    if (domain->depth > 1) {
		aktive_failf ("rejecting input with depth %d != 1", domain->depth);
	    }

	    aktive_uint len = 2*param->radius+1;
	    if ((domain->width  < len) ||
		(domain->height < len)) {
		aktive_failf ("Image %dx%d too small for %d-radius tiles",
			      domain->width, domain->height, param->radius);
	    }

	    state->size = len*len;

	    domain->x      += param->radius;
	    domain->y      += param->radius;
	    domain->width  -= 2*param->radius;
	    domain->height -= 2*param->radius;
	    domain->depth   = param->bins;
	}
    } $thing]

    state -fields {
	aktive_uint size; // quick access to the original size of the reduced @@thing@@s
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	@@fieldsetup@@
    }

    switch -exact -- $thing {
	band {
	    blit histogrammer {
		{AH {y AY 1 up} {y 0 1 up}}
		{AW {x AX 1 up} {x 0 1 up}}
	    } {raw histogram-band {
		// dstvalue = row/col start - 1-strided band (full histogram)
		// srcvalue = row/col start - 1-strided full band vector
		aktive_reduce_histogram (srcvalue, SD, 1, &state->h);
		memcpy (dstvalue, state->h.count, DD * sizeof(double));
	    }}
	}
	tile {
	    # This assumes a single band input
	    blit histogrammer {
		{AH {y AY 1 up} {y radius 1 up}}
		{AW {x AX 1 up} {x radius 1 up}}
	    } {raw histogram-tile {
		// dstvalue = cells to set (bands = histogram)
		// srcvalue = center cell of tile
		aktive_tile_reduce_histogram (srcvalue, radius, srcpos, SRCCAP, srcpitch, srcstride, &state->h);
		memcpy (dstvalue, state->h.count, DD * sizeof(double));
	    }}
	}
    }

    def subrequest [dict get {
	band   {}
	tile   {
	    aktive_uint radius = param->radius;
	    subrequest.x      -= radius;
	    subrequest.y      -= radius;
	    subrequest.width  += 2 * radius;
	    subrequest.height += 2 * radius;
	}
    } $thing]

    pixels -state {
	aktive_histogram h;
    } -setup {
	state->h.bins   = param->bins;
	state->h.maxbin = param->bins - 1;
	state->h.count  = NALLOC (double, param->bins);
    } -cleanup {
	ckfree (state->h.count);
    } {
	TRACE("histogram actual %u bins", param->bins);
	aktive_rectangle_def_as (subrequest, request);
	@@subrequest@@

	TRACE_RECTANGLE_M("@@thing@@ hist", &subrequest);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	@@histogrammer@@

	TRACE_DO (__aktive_block_dump ("@@thing@@ histogram out", block));
    }
}

# # ## ### ##### ######## ############# #####################

operator op::row::histogram {
    section transform statistics

    int? 256 bins \
	The number of bins held by a single histogram. The pixel values are quantized \
	to fit. Only values in the range of \[0..1\] are considered valid. Values \
	outside of that range are placed into the smallest/largest bin. \
	\
	The default quantizes the image values to 8-bit.

    input

    note Returns image with input rows transformed into a histogram of `bins` values.

    note The result is an image of bin-sized histogram rows with height and depth of the input

    state -fields {
	aktive_uint      size;      // quick access to the original size of the reduced rows
	aktive_iveccache histogram; // cache, result histograms
    } -cleanup {
	aktive_iveccache_release (state->histogram);
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->size = domain->width;  domain->width  = param->bins;
	state->histogram = aktive_iveccache_new (domain->height * domain->depth, param->bins);
	// note: #(row vectors) takes bands into account
    }

    pixels -state {
	aktive_histogram h;
	aktive_iveccache histogram; // cache, result histograms, thread-shared
    } -setup {
	state->histogram = istate->histogram;
	state->h.bins    = param->bins;
	state->h.maxbin  = param->bins - 1;
	state->h.count   = NALLOC (double, param->bins);
    } -cleanup {
	ckfree (state->h.count);
    } {
	// Scan the rows of the request
	// - Get the associated histograms from the cache
	// - If needed, compute the histograms

	TRACE("histogram actual %u bins", param->bins);
	aktive_rectangle_def_as (subrequest, request);
	subrequest.width = istate->size; subrequest.x = idomain->x;
	TRACE_RECTANGLE_M("row hist", &subrequest);

	aktive_uint x, y, z, k, j;
	aktive_uint stride = block->domain.width * block->domain.depth;
	aktive_uint bands  = block->domain.depth;

	aktive_histogram_context context = {
	    // .z is set during the iteration. same for subrequest.y
	    .size    = subrequest.width,
	    .stride  = bands,
	    .request = &subrequest,
	    .src     = srcs->v[0],
	    .h       = &state->h
	};

	#define ITERZ for (z = 0; z < bands; z++)
	#define ITERX for (x = request->x, k = 0; k < request->width  ; x++, k++)
	#define ITERY for (y = request->y, j = 0; j < request->height ; y++, j++, py++)

	// 3 kinds of y-coordinates.
	//
	// 1. y  - logical coordinate of row
	// 2. j  - physical coordinate of row in memory block
	// 3. py - distance to logical y position -> cache index

	aktive_uint py = request->y - idomain->y;
	ITERY {
	    ITERZ {
		TRACE ("VEC INDEX (%u,%u,%u) (%u,%u) %u - vec %u", x,y,z, k,py, bands, py*bands+z);

		context.z = z;
		/* context->request */ subrequest.y = y;
		double* hist = aktive_iveccache_get (state->histogram, py*bands+z,
						     AKTIVE_HISTOGRAM_FILL, &context);
		// hist is full input width

		TRACE_HEADER(1); TRACE_ADD ("[y,z=%u,%u] row hist = {", y, z);
		for (int a = 0; a < param->bins; a++) { TRACE_ADD (" %f", hist[a]); }
		TRACE_ADD(" }", 0); TRACE_CLOSER;

		ITERX {
		    TRACE ("line [%u], band [%u] place k%u b%u j%u s%u -> %u (hist[%d] = %f)",
			   y, z, k, bands, j, stride, z+k*bands+j*stride, k, hist[k]);
		    block->pixel [z+k*bands+j*stride] = hist[k];
		}    // TODO :: ASSERT against capacity
	    }

	    TRACE_HEADER(1); TRACE_ADD ("[y=%u] line = {", y);
	    for (int a = 0; a < request->width; a++) { TRACE_ADD (" %f", block->pixel[a]); }
	    TRACE_ADD(" }", 0); TRACE_CLOSER;
	}


	#undef ITERX
	#undef ITERY
	#undef ITERZ

	TRACE_DO (__aktive_block_dump ("row histogram out", block));
    }
}

# # ## ### ##### ######## ############# #####################

operator op::column::histogram {
    section transform statistics

    int? 256 bins \
	The number of bins held by a single histogram. The pixel values are quantized \
	to fit. Only values in the range of \[0..1\] are considered valid. Values \
	outside of that range are placed into the smallest/largest bin. \
	\
	The default quantizes the image values to 8-bit.

    input

    note Returns image with input columns transformed into histograms of `bins` values.

    note The result is an image of bin-sized histogram columns with width and depth of the input

    state -fields {
	aktive_uint      size;      // quick access to the original size of the reduced colums
	aktive_iveccache histogram; // cache, result column histograms
    } -cleanup {
	aktive_iveccache_release (state->histogram);
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->size = domain->height; domain->height = param->bins;
	state->histogram = aktive_iveccache_new (domain->width * domain->depth, param->bins);
	// note: #(column vectors) takes bands into account
    }

    pixels -state {
	aktive_histogram h;
	aktive_iveccache histogram; // cache, result column histograms, thread-shared
    } -setup {
	state->histogram = istate->histogram;
	state->h.bins    = param->bins;
	state->h.maxbin  = param->bins - 1;
	state->h.count   = NALLOC (double, param->bins);
    } -cleanup {
	ckfree (state->h.count);
    } {
	TRACE("histogram actual %u bins", param->bins);

	// Scan the columns of the request
	// - Get the associated histogram from the cache
	// - If needed, compute the histogram

	aktive_rectangle_def_as (subrequest, request);
	subrequest.width = 1; subrequest.height = istate->size; subrequest.y = idomain->y;
	TRACE_RECTANGLE_M("column hist", &subrequest);

	aktive_uint x, y, z, k, q, j;
	aktive_uint stride = block->domain.width * block->domain.depth;
	aktive_uint bands  = block->domain.depth;

	// start each line in a different column, spread the threads across the width of the image
	// reduce chance of lock fighting over the column vectors during the creation phase

	aktive_uint xmin   = request->x;
	aktive_uint xmax   = request->x + request->width - 1;
	aktive_uint xoff   = aktive_fnv_step (request->y) % request->width;
	aktive_uint xstart = xmin + xoff;

	aktive_histogram_context context = {
	    // .z is set during the iteration. same for subrequest.x
	    .size    = subrequest.height,
	    .stride  = bands,
	    .request = &subrequest,
	    .src     = srcs->v[0],
	    .h       = &state->h
	};

	#define ITERZ for (z = 0; z < bands; z++)
	#define ITERX for (x = xstart, k = xoff, q = 0; q < request->width ; q++)
	#define ITERY for (y = request->y, j = 0; j < request->height ; y++, j++, py++)

	// 3 kinds of x-coordinates.
	//
	// 1. x,y   - logical  coordinate of column/row
	// 2. k,j   - physical coordinate of column/row -- memory block
	// 3. px,py - distance to logical x/y position  -- cache index, hist index

	aktive_uint xd = request->x - idomain->x;
	aktive_uint yd = request->y - idomain->y;
	aktive_uint px = xstart - idomain->x;
	ITERX {
	    ITERZ {
		TRACE ("VEC INDEX (%u,%u,%u) (%u,%u) %u - vec %u", x,y,z, px,j, bands, px*bands+z);

		context.z = z;
		/* context->request */ subrequest.x = x;
		double* hist = aktive_iveccache_get (state->histogram, px*bands+z,
						     AKTIVE_HISTOGRAM_FILL, &context);
		// hist is full input width

		TRACE_HEADER(1); TRACE_ADD ("[x,z=%u,%u] histogram = {", x, z);
		for (int a = 0; a < param->bins; a++) { TRACE_ADD (" %f", hist[a]); }
		TRACE_ADD(" }", 0); TRACE_CLOSER;

		aktive_uint py = yd;
		ITERY {
		    TRACE ("line [%u], band [%u] place k%u b%u j%u s%u -> %u (hist[%d] = %f)",
			   y, z, k, bands, j, stride, z+k*bands+j*stride, py, hist[py]);

		    block->pixel [z+k*bands+j*stride] = hist[py];
		}    // TODO :: ASSERT against capacity
	    }

	    // step the column with wrap around
	    x++ ; if (x > xmax) x = request->x;
	    px++;
	    k++ ; if (k >= request->width) { k = 0; px = xd; }
	}

	TRACE_HEADER(1); TRACE_ADD ("[y=%u] line = {", y);
	for (int a = 0; a < request->width; a++) { TRACE_ADD (" %f", block->pixel[a]); }
	TRACE_ADD(" }", 0); TRACE_CLOSER;

	#undef ITERX
	#undef ITERY
	#undef ITERZ

	TRACE_DO (__aktive_block_dump ("column histogram out", block));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
