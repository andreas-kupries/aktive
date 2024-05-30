## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Histogram Statistics

## Not handled in the by-* specs. Histogram statistics are sufficiently different in the
## details of their calculation from the others (aktive_histogram* client data, etc.) to
## warrant separate handling. Therefore sliced on the operation instead.
#
## NOTES
##
## - Caches are used to hold full row|column histograms. While this requires more memory
##   we get higher speed as no histogram is computed more than once.  Should we find that
##   memory usage is too high we can
##   (1) limit the cache size, at the at the cost of having to re-compute some histograms.
##   (2) spill to and reload from disk. Beware that this may be slower than a re-compute.
##
## - For band and tile histograms caches are not needed, as both return per-pixel results
##   and automatically do not re-compute anything.
#
## This is a place where future management of request types (i.e. by rows, by columns, by
## tiles, etc.) could be useful.

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
    op -> _ kind _
    section transform statistics

    if {$kind eq "tile"} {
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

    note Returns image with input ${kind}s transformed into a histogram of `bins` values.

    switch -exact -- $kind {
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
    } $kind]

    state -fields {
	aktive_uint size; // quick access to the original size of the reduced @@kind@@s
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	@@fieldsetup@@
    }

    switch -exact -- $kind {
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
    } $kind]

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

	TRACE_RECTANGLE_M("@@kind@@ hist", &subrequest);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	@@histogrammer@@

	TRACE_DO (__aktive_block_dump ("@@kind@@ histogram out", block));
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

    note Returns image with input rows transformed into a histogram of `bins` values.

    note The result is an image of `bins`-sized histogram rows with height and depth of the input.

    cached row histogram AKTIVE_HISTOGRAM_FILL -fields {
	aktive_histogram h;
    } -setup {
	state->h.bins    = param->bins;
	state->h.maxbin  = param->bins - 1;
	state->h.count   = NALLOC (double, param->bins);

	TRACE("histogram actual %u bins", param->bins);
    } -cleanup {
	ckfree (state->h.count);
    } -rsize bins -cdata "&state->h"
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

    note Returns image with input columns transformed into histograms of `bins` values.

    note The result is an image of `bins`-sized histogram columns with width and depth of the input.

    cached column histogram AKTIVE_HISTOGRAM_FILL -fields {
	aktive_histogram h;
    } -setup {
	state->h.bins    = param->bins;
	state->h.maxbin  = param->bins - 1;
	state->h.count   = NALLOC (double, param->bins);

	TRACE("histogram actual %u bins", param->bins);
    } -cleanup {
	ckfree (state->h.count);
    } -rsize bins -cdata "&state->h"
}

##
# # ## ### ##### ######## ############# #####################
::return
