## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Various virtual images

operator image::from::value {
    section generator virtual

    note Returns image which has the same VALUE everywhere.

    example {width 64 height 64 depth 1 value 0.5}
    example {width 64 height 64 depth 3 value 0.5}

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

operator image::from::band {
    section generator virtual

    note Returns image where all pixels have the same band values.

    example {width 64 height 64 values 0.3}
    example {width 64 height 64 values 0.3 0.5 0.7}

    note Depth is len(value)

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    double... values  Pixel band values

    state -setup {
	// depth is number of band values
	aktive_geometry_set (domain, 0, 0, param->width, param->height, param->values.c);
    }
    pixels {
	// assert: param.values.c == block.geo.depth
	// assert: block.used % block.depth == 0
	aktive_blit_fill_bands (block, dst, &param->values);
    }
}

operator image::from::row {
    section generator virtual

    note Returns image of the specified height where all rows have the same set of values.
    note The image's width is the number of values.

    example {
	height 64 values 0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.6 0.7 0.75 0.8 0.85 0.9 0.95 1
    }

    uint      height  Height of the returned image
    double... values  Pixel row values

    state -setup {
	// width is number of row values
	aktive_geometry_set (domain, 0, 0, param->values.c, param->height, 1);
    }
    pixels {
	// assert: param.values.c == block.geo.width
	// assert: block.used % block.width == 0
	aktive_blit_fill_rows (block, dst, request->x, &param->values);
    }
}

operator image::from::column {
    section generator virtual

    note Returns image of the specified width where all columns have the same set of values.
    note The image's height is the number of values.

    example {
	width 64 values 0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.6 0.7 0.75 0.8 0.85 0.9 0.95 1
    }

    uint      width   Width of the returned image
    double... values  Pixel column values

    state -setup {
	// height is number of column values
	aktive_geometry_set (domain, 0, 0, param->width, param->values.c, 1);
    }
    pixels {
	// assert: param.values.c == block.geo.width
	// assert: block.used % block.width == 0
	aktive_blit_fill_columns (block, dst, request->y, &param->values);
    }
}

operator image::from::matrix {
    section generator virtual

    note Returns single-band image with the pixel VALUEs.

    note Less than width by height values are extended with zeroes.
    note Excess values are ignored.
    note Depth is fixed at 1.

    example -post {times 8} {width 16 height 16 values 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}

    uint      width   Width of the returned image
    uint      height  Height of the returned image
    double? 1 factor  Scaling factor
    double... values  Pixel values

    state -fields {
	aktive_block src;
    } -cleanup {
	aktive_blit_close (&state->src);
    } -setup {
	memset (state, 0, sizeof (*state));

	// Create a local copy of the pixel data found in the parameters.
	// This enables application of scale factor and adding missing values without
	// affecting the user-visible configuration.

	// Note from the description that the `param.values` is allowed to not contain
	// enough values for all the pixels. In that case the data is extended with zeroes.

	aktive_geometry_set  (domain, 0, 0, param->width, param->height, 1);
	aktive_geometry_copy (&state->src.domain, domain);
	aktive_blit_setup    (&state->src, aktive_geometry_as_rectangle (domain));
	memset (state->src.pixel, 0,               state->src.used * sizeof (double));
	memcpy (state->src.pixel, param->values.v, param->values.c * sizeof (double));

	// Apply the scaling factor, if not identity.
	if (param->factor != 1) {
	    aktive_uint i;
	    for (i = 0; i < param->values.c; i++) { state->src.pixel[i] *= param->factor; }
	}
    }
    pixels {
	// Just blit from the source to the destination
	aktive_blit_copy (block, dst, &istate->src, aktive_rectangle_as_point (request));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
