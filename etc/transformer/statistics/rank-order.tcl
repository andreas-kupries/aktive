## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Rank Order Statistics

## Not handled in the by-* specs as it is sufficiently different in the details from the
## others (aktive_rank* client data, etc). So, sliced on the operation.

# # ## ### ##### ######## ############# #####################
## Compress bands/rows/columns/tiles down to a statistic (rank order selection)

operator {dim unchanged} {
    op::band::median   band   {width and height}
    op::column::median row    {width and depth}
    op::row::median    column {height and depth}
    op::tile::median   {}     {}
} {
    # convenience wrapper around the general rank filter.

    section transform statistics

    def thing [lindex [split $__op :] 2]

    if {$thing eq "tile"} {
	uint radius Tile size as radius from center. \
	    Full width and height of the tile are `2*radius+1`.
    }

    input

    # look into shared documentation code/text blocks ...

    note Returns image with input ${thing}s compressed to a single value, \
	the median of the sorted $thing values.

    switch -exact -- $thing {
	band   -
	column -
	row    { note The result is a single-$dim image with {*}$unchanged of the input }
	tile   {
	    note Beware, the operator consumes overlapping tiles, not just adjacent.

	    note Beware, the result image is shrunken by 2*radius in width and height \
		relative to the input. Inputs smaller than that are rejected.

	    note If shrinkage is not desired add a border to the input using one of \
		the `aktive op embed ...` operators before applying this operator.

	    note The prefered embedding for rank is mirror. \
		It is chosen to have minimal to no impact on the statistics \
		at the original input's borders.

	    note The input bands are handled separately.
	}
    }

    # The median of the single-value median is the same value.
    # import ../simpler/idempotent.rules -- C
    ## TODO :: allow simplification for Tcl operators as well.

    switch -exact -- $thing {
	band   -
	column -
	row    {
	    lappend map %%%% [dict get {
		band   depth
		column height
		row    width
	    } $thing]
	    body [string map $map {
		aktive simplify do \
		    src/type op::@@thing@@::rank \
		    src/value rank __rank \
		    iff {$__rank == -1} \
		    /src
		#
		aktive simplify do \
		    src/attr %%%% __size iff {$__size == 1} \
		    /src
		#
		rank $src rank -1
	    }]
	    unset map
	}
	tile   {
	    body {
		aktive simplify do \
		    src/type op::@@thing@@::rank \
		    src/value rank __rank \
		    iff {$__rank == -1} \
		    /src
		#
		rank $src radius $radius rank -1
	    }
	}
    }
}

operator {dim unchanged} {
    op::band::rank   band   {width and height}
    op::column::rank row    {width and depth}
    op::row::rank    column {height and depth}
    op::tile::rank   {}     {}
} {
    section transform statistics

    def thing [lindex [split $__op :] 2]

    if {$thing eq "tile"} {
	uint radius Tile size as radius from center. \
	    Full width and height of the tile are `2*radius+1`.
    }

    int? -1 rank \
	Index of the sorted values to return. \
	Default creates a median filter. 0 creates min-filter.

    input

    note Returns image with input ${thing}s compressed to a single value, \
	the chosen rank of the sorted $thing values.

    switch -exact -- $thing {
	band   -
	column -
	row    { note The result is a single-$dim image with {*}$unchanged of the input }
	tile   {
	    note Beware, the operator consumes overlapping tiles, not just adjacent.

	    note Beware, the result image is shrunken by 2*radius in width and height \
		relative to the input. Inputs smaller than that are rejected.

	    note If shrinkage is not desired add a border to the input using one of \
		the `aktive op embed ...` operators before applying this operator.

	    note The prefered embedding for rank is mirror. \
		It is chosen to have minimal to no impact on the statistics \
		at the original input's borders.

	    note The input bands are handled separately.
	}
    }

    note Beware. While it is possible to use the rank filter for max/min extractions \
	it is recommended to use the specific max/min operators instead, as they \
	should be faster (linear scan of region, no gather, no sorting of the region).

    def fieldsetup [dict get {
	band   { state->size = domain->depth;  domain->depth  = 1; }
	column { state->size = domain->height; domain->height = 1; }
	row    { state->size = domain->width;  domain->width  = 1; }
	tile   {
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
	}
    } $thing]

    state -fields {
	aktive_uint size; // quick access to the size of reduced @@thing@@s
	aktive_uint rank; // rank selector, with default resolved
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	@@fieldsetup@@

	state->rank = (param->rank < 0) ? state->size/2 : param->rank;

	if (state->rank >= state->size) {
	    aktive_failf ("Rank %d too large for @@thing@@ size %u",
			  param->rank, state->size);
	}
    }

    switch -exact -- $thing {
	band {
	    blit reducer {
		{DH {y 0 1 up} {y 0 1 up}}
		{DW {x 0 1 up} {x 0 1 up}}
	    } {raw reduce-band {
		// dstvalue = row/col start -
		// srcvalue = row/col start - 1-strided band vector
		*dstvalue = REDUCE (srcvalue, SD, 1, &state->rt);
	    }}
	}
	column {
	    blit reducer {
		{DW {x 0 1 up} {x 0 1 up}}
		{DD {z 0 1 up} {z 0 1 up}}
	    } {raw reduce-column {
		// dstvalue = row/band start -
		// srcvalue = row/band start - srcpitch-strided column vector
		*dstvalue = REDUCE (srcvalue, SH, SW*SD, &state->rt);
	    }}
	}
	row {
	    blit reducer {
		{DH {y 0 1 up} {y 0 1 up}}
		{DD {z 0 1 up} {z 0 1 up}}
	    } {raw reduce-row {
		// dstvalue = row/band start -
		// srcvalue = row/band start - SD-strided row vector
		*dstvalue = REDUCE (srcvalue, SW, SD, &state->rt);
	    }}
	} tile {
	    blit reducer {
		{DH {y 0 1 up} {y radius 1 up}}
		{DW {x 0 1 up} {x radius 1 up}}
		{DD {z 0 1 up} {z 0 1 up}}
	    } [list raw reduce-tile {
		// dstvalue = cell to set
		// srcvalue = center cell of tile
		*dstvalue = REDUCE (srcvalue, radius, srcpos, SRCCAP,
				    srcpitch, srcstride, &state->rt);
	    }]
	}
    }

    def rfunction [dict get {
	band   { aktive_reduce_rank      }
	column { aktive_reduce_rank      }
	row    { aktive_reduce_rank      }
	tile   { aktive_tile_reduce_rank }
    } $thing]

    def subrequest [dict get {
	band   {}
	column { subrequest.height = istate->size; }
	row    { subrequest.width = istate->size; }
	tile {
	    aktive_uint radius = param->radius;
	    subrequest.x      -= radius;
	    subrequest.y      -= radius;
	    subrequest.width  += 2 * radius;
	    subrequest.height += 2 * radius;
	}
    } $thing]

    pixels -state {
	aktive_rank rt;
    } -setup {
	state->rt.sorted = NALLOC (double, istate->size);
	state->rt.select = istate->rank;
    } -cleanup {
	ckfree (state->rt.sorted);
    } {
	TRACE("rank actual %u in %u", state->rt.select, istate->size);
	aktive_rectangle_def_as (subrequest, request);
	@@subrequest@@
	TRACE_RECTANGLE_M("rank", &subrequest);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	#define REDUCE @@rfunction@@
	@@reducer@@
	#undef REDUCE

	TRACE_DO (__aktive_block_dump ("@@thing@@ rank out", block));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
