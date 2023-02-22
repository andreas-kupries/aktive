## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Various virtual constant fields

operator image::constant {
    note Generator. Returns an image having the same value everywhere.

    uint   width   Width of the returned image
    uint   height  Height of the returned image
    uint   depth   Depth of the returned image
    double value   Pixel value

    state -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, param->depth);
    }
    pixels {
	aktive_blit_fill (block, dst, param->value);
    }
}

operator image::const::bands {
    note Generator. Returns an image having the same band values at all pixels.
    note Depth is len(value)

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    double... value   Pixel band values

    state -setup {
	// depth is number of band values
	aktive_geometry_set (domain, 0, 0, param->width, param->height, param->value.c);
    }
    pixels {
	// assert: param.value.c == block.geo.depth
	// assert: block.used % block.depth == 0
	aktive_blit_fill_bands (block, dst, &param->value);
    }
}

operator image::const::matrix {
    note Generator. Returns a depth 1 image holding the specified pixel values.

    note Less than width by height values are extended with zeroes.
    note Excess values are ignored.
    note Depth is fixed at 1.

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    double... value   Pixel values

    state -fields {
	aktive_block src;
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 1);

	// Note from the description that the `param.value` is allowed to not contain
	// enough values for all the pixels. When that is the case we resize the array
	// to be large enough, and clear the missing parts. This works because:
	//
	//  a. The `.value.v` became already heap-allocated when it was copied into the
	//     image. I.e. it belongs to us now.
	//
	//  b. The 0b'00000000 bitpattern represents `(double) 0`.

	aktive_uint sz = aktive_geometry_get_pixels (domain); // == size, due depth == 1
	if (param->value.c < sz) {
	    param->value.v = REALLOC (param->value.v, double, sz);
	    memset (param->value.v + param->value.c, 0, sz*sizeof (double));
	}

	// With that done it is now possible to create a pixel storage pointing to the
	// parameter data, to serve as source when fetching.

	aktive_geometry_copy (&state->src.domain, domain);
	state->src.capacity = sz;
	state->src.used     = sz;
	state->src.pixel    = param->value.v;

	// And while the pixel data in the state is technically heap-allocated it does not
	// belong to the state, wrt responsibility for cleanup. That is handled by the
	// parameter finalizer. Therefore no need for -cleanup.
    }
    pixels {
	// Just blit from the source to the destination
	aktive_blit_copy (block, dst, &istate->src, aktive_rectangle_as_point (request));
    }
}

## # # ## ### ##### ######## ############# #####################

operator image::const::sparse::points {

    note Generator. Returns depth 1 image with pixels set to 1 at exactly the specified points.

    point... points  Coordinates of the pixels to set in the image

    note Generally, the bounding box specifies the geometry, especially also the image origin
    note Width is implied by the bounding box of the points
    note Height is implied by the bounding box of the points
    note Depth is fixed at 1
    note Pixel value is fixed at 1.0

    state -setup {
	// Compute the bounding box from the points and use that for the geometry.
	aktive_rectangle bb;
	aktive_point_union (&bb, param->points.c, param->points.v);

	aktive_geometry_set_rectangle (domain, &bb);
	domain->depth = 1;
    }
    pixels {
	// First clear the destination area, then iterate over the points and set all
	// which are contained in the request.

	aktive_blit_clear (block, dst);

	aktive_point* base = aktive_rectangle_as_point (request);

	for (aktive_uint i = 0; i < param->points.c; i++) {
	    #define P param->points.v[i]
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

operator image::const::sparse::deltas {

    note Generator. Returns a depth 1 image with pixels set to 1 at exactly the specified points.
    note The height is infered from the points

    uint    width   Width of the returned image. This is needed for the index/point conversion
    uint... delta   Linear distances between points to set

    note The first delta is relative to index 0
    note Converts the deltas internally to points and then operates like sparse::points
    note Depth is fixed at 1
    note Pixel value is fixed at 1.0

    state -fields {
	aktive_point_vector points; // Points computed from the deltas
    } -setup {
	// deltas to points ... this is image state

	aktive_point_vector_new (&state->points, param->delta.c);

	aktive_uint index = 0;
	for (aktive_uint i = 0; i < param->delta.c; i++) {
	    index += param->delta.v[i];
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

## # # ## ### ##### ######## ############# #####################

operator image::gradient {
    note Generator. Returns image containing a linear gradient through all cells

    uint   width   Width of the returned image
    uint   height  Height of the returned image
    uint   depth   Depth of the returned image
    double first   First value
    double last    Last value

    state -fields {
	double delta;
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, param->depth);

	state->delta = (param->last - param->first)
		     / (double) (aktive_geometry_get_size (domain) - 1);
    }
    pixels {
	// idomain	image geometry
	// request	image area to get the pixels of
	// block.domain storage geometry (ignoring location)
	// dst		storage area to write the pixels to
	//
	// r.width      == dst.width  <= idomain.width  (Note: < possible)
	// r.height     == dst.height <= idomain.height (Note: < possible)
	// domain.depth == idomain.depth

	aktive_uint dstpos, dsty, dstx, dstz;
	aktive_uint srcpos, srcy, srcx, srcz;
	aktive_uint row, col;

	// Unoptimized loop nest to compute virtual pixel data and write to storage
	TRACE ("sy  sx  sz  | in  | dy  dx  dz  | out |", 0);

	for (srcy = request->y, dsty = dst->y, row = 0; row < request->height; srcy++, dsty++, row++) {
	    for (srcx = request->x, dstx = dst->x, col = 0; col < request->width; srcx++, dstx++, col++) {
		for (srcz = dstz = 0; srcz < idomain->depth; srcz++, dstz++) {
		    srcpos = srcy * idomain->width      * idomain->depth      + srcx * idomain->depth      + srcz;
		    dstpos = dsty * block->domain.width * block->domain.depth + dstx * block->domain.depth + dstz;

		    double value = param->first + srcpos * istate->delta;

		    TRACE ("%3d %3d %3d | %3d | %3d %3d %3d | %3d | %.2f",
			   srcy, srcx, srcz, srcpos, dsty, dstx, dstz, dstpos, value);

		    block->pixel [dstpos] = value; // inlined blit set, we already have the coordinates
		}
	    }
	}
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
