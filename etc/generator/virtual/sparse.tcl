## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual image from set of points or deltas.

operator image::from::sparse::points {
    section generator virtual

    note Returns single-band image where pixels are set to white at exactly the \
	specified COORDS.

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

    note Returns single-band depth image where pixels are set to white at exactly the \
	specified points. Different to `sparse points` the points are specified as \
	linear distances from the origin.

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

##
# # ## ### ##### ######## ############# #####################
::return
