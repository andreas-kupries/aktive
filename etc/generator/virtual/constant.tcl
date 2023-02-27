## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Various virtual images

operator image::constant {
    note Generator. \
	Virtual image. Returns an image having the same value everywhere.

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
    note Generator. \
	Virtual image. Returns an image having the same band values at all pixels.

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
    note Generator. \
	In-memory image. Returns a depth 1 image holding the specified pixel values.

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

##
# # ## ### ##### ######## ############# #####################
::return
