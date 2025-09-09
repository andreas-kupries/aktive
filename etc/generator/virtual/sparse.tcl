## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual image from set of points, deltas, or row ranges.

operator image::from::sparse::points {
    section generator virtual

    example {
	coords {0 0} {4 3} {5 5} {6 2} | ; times 8
    }

    note Returns a single-band image where pixels are set to white at exactly the \
	specified coordinates.

    point... coords  Coordinates of the pixels to set in the image

    note Generally, the bounding box specifies the geometry, especially also the image origin
    note Width is implied by the bounding box of the points
    note Height is implied by the bounding box of the points
    note Depth is fixed at 1
    note Pixel value is fixed at 1.0

    state -setup {
	// Compute the bounding box from the points and use that for the geometry.
	aktive_rectangle bb;
	aktive_point_union (&bb, param->coords.c, param->coords.v);

	aktive_geometry_set_rectangle (domain, &bb);
	domain->depth = 1;
    }
    pixels {
	// First clear the destination area, then iterate over the points and set all
	// which are contained in the request.

	aktive_blit_clear (block, dst);

	aktive_point* base = aktive_rectangle_as_point (request);

	for (aktive_uint i = 0; i < param->coords.c; i++) {
	    #define P param->coords.v[i]
	    TRACE ("check [%d] @(%d,%d)", i, P.x, P.x);
	    if (!aktive_rectangle_contains (request, &P)) continue;

	    // P is in the image domain. Translate it into the request/dst/block domain
	    aktive_point_def_as (rdst, &P);
	    aktive_point_sub (&rdst, base);

	    TRACE ("set", 0);
	    aktive_blit_set (block, &rdst, 1.0);
	    #undef P
        }
    }
}

operator image::from::sparse::deltas {
    section generator virtual

    example {
	width 7 deltas 0 20 5 15 | ; times 8
    }

    note Returns a single-band image where pixels are set to white at exactly the \
	specified points. In contrast to `sparse points` the points are specified \
	as linear distances from the origin.

    note The height is infered from the points

    uint    width   Width of the returned image. This is needed for the conversion \
	of the linear indices to (x,y) coordinates.

    uint... deltas  Linear distances between points to set

    note The first delta is relative to index 0
    note Converts the deltas internally to points and then operates like `sparse points`
    note Depth is fixed at 1
    note Pixel value is fixed at 1.0

    state -fields {
	aktive_point_vector points; // Points computed from the deltas
    } -setup {
	// deltas to points ... this is image state

	aktive_point_vector_new (&state->points, param->deltas.c);

	aktive_uint index = 0;
	for (aktive_uint i = 0; i < param->deltas.c; i++) {
	    index += param->deltas.v[i];
	    state->points.v[i].x = index % param->width;
	    state->points.v[i].y = index / param->width;
	}

	// sparse points ... forced to given width!
	aktive_rectangle bb;
	aktive_point_union (&bb, state->points.c, state->points.v);

	aktive_geometry_set_rectangle (domain, &bb);
	domain->width = param->width;
	domain->depth = 1;
    } -cleanup {
	aktive_point_vector_free (&state->points);
    }
    pixels {
	// First clear the destination area, then iterate over the points and set all
	// which are contained in the request.

	aktive_blit_clear (block, dst);

	aktive_point* base = aktive_rectangle_as_point (request);

	for (aktive_uint i = 0; i < istate->points.c; i++) {
	    #define P istate->points.v[i]
	    TRACE ("check [%d] @(%d,%d)", i, P.x, P.y);
	    if (!aktive_rectangle_contains (request, &P)) continue;

	    // P is in the image domain. Translate it into the request/dst/block domain
	    aktive_point_def_as (rdst, &P);
	    aktive_point_sub (&rdst, base);

	    TRACE ("set", 0);
	    aktive_blit_set (block, &rdst, 1.0);
	    #undef P
        }
    }
}

operator image::from::sparse::ranges {
    section generator virtual

    example {
	ranges {1 24 30 1} {2 23 31 1} {3 22 32 1} {4 22 24 0.75} {4 30 32 0.75} {5 22 23 0.75} {5 31 32 0.75} {6 23 24 0.5} {6 30 31 0.5} {7 24 25 0.5} {7 29 30 0.5} | ; times 8
    }

    note Returns a single-band image where the pixels are set to the specified values as per the provided row ranges.

    note A single row range is specified by 4 numbers.
    note These are, in order, the row index, a range of columns, and the pixel value.
    note The latter is a floating point value, while the others are integers.

    note The bounding box over all provided the ranges specifies the result's geometry, including the origin.
    note The image depth is fixed at 1, i.e. the result is single-band.

    rect? {{0 0 0 0}} geometry	Image geometry. Defaults to the bounding box of the ranges.

    range...          ranges    The ranges to set in the result, and their values.

    state -fields {
	aktive_uint* rowstart; // index of where each row starts in the ranges.
	aktive_uint  isize;    // size of the index
    } -cleanup {
	FREE (state->rowstart);
    } -setup {
	// Either use the provided geometry, or compute the bounding box from the ranges
	// and use the result as the image geometry.
	if (aktive_rectangle_is_empty (&param->geometry)) {
	    aktive_rectangle bb;
	    aktive_range_union (&bb, param->ranges.c, param->ranges.v);
	    aktive_geometry_set_rectangle (domain, &bb);
	} else {
	    aktive_geometry_set_rectangle (domain, &param->geometry);
	}
	domain->depth = 1;

	// pre-sort the ranges for better iteration
	aktive_range_sort (param->ranges.c, param->ranges.v);

	// similarly, compute an index of row starts.

	state->rowstart = NALLOC (aktive_uint, param->ranges.c);
	aktive_uint i, top = 0;
	int row = param->ranges.v[0].y - 1;

	for (i=0; i < param->ranges.c; i++) {
	    if (row == param->ranges.v[i].y) continue;
	    state->rowstart[top] = i;
	    row = param->ranges.v[i].y;
	    top++;
	}

	// Shrink the index to actually used size.
	if (top < param->ranges.c) {
	    state->rowstart = REALLOC (state->rowstart, aktive_uint, top);
	}
	state->isize = top;
    }

    pixels {
	// First clear the destination area, then iterate over the ranges and set all
	// which are contained in the request.

	aktive_blit_clear (block, dst);

	int xmin = aktive_rectangle_get_x    (request);
	int xmax = aktive_rectangle_get_xmax (request);
	int ymin = aktive_rectangle_get_y    (request);
	int ymax = aktive_rectangle_get_ymax (request);

	aktive_point* base = aktive_rectangle_as_point (request);

	// locate start of first row in the request within the param ranges, via the index
	aktive_uint i, k = 0;
	for (i=0; i < istate->isize; i++) {
	    k = istate->rowstart[i];
	    if (param->ranges.v[k].y >= ymin) break;
	}

	// no rows overlapping the request
	if (i >= istate->isize) TRACE_RETURN_VOID;

	// iterate over the ranges until we fall out of the request, row-wise, or run out of ranges
	for ( ; (param->ranges.v[k].y <= ymax) &&
	        (k < param->ranges.c) ; k++) {
	    // Check for each range if they are in the proper x-range as well.

	    int ry    = param->ranges.v[k].y;
	    int rxmin = param->ranges.v[k].xmin;
	    int rxmax = param->ranges.v[k].xmax;

	    if ((rxmax < xmin) || (xmax < rxmin)) continue;
	    // range at least overlaps request

	    // contract to intersection of range and request
	    rxmin  = MAX (rxmin, xmin);
	    rxmax  = MIN (rxmax, xmax);
	    int rw = rxmax - rxmin + 1;

	    // compute blit destination in the request/dst/block domain
	    aktive_rectangle_def (rdst, rxmin, ry, rw, 1);
	    aktive_point_sub (aktive_rectangle_as_point (&rdst), base);

	    // and fill
	    double rvalue = param->ranges.v[k].value;
	    aktive_blit_fill (block, &rdst, rvalue);
	}
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
