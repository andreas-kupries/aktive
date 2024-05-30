## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Cumulations along the various axes
##                 (rows, columns, bands), and the entire image.
##                 Tiled does not make sense.
##
## Note: Cumulation of the entire image is also known as `Sum Area Table`.
##
##       Due to the wrap around from one row to the next the SAT is __not separable__ into
##       a combination of row and column csums. It might be possible to use a veccache for
##       some perf boost.

# # ## ### ##### ######## ############# #####################

operator op::row::cumulative {
    section transform statistics

    note Returns image with the input rows transformed into cumulative sums.

    note This means that each pixel in a row is the sum of the values in the \
	columns before it, having the same row.

    note The result has the same geometry as the input. Only the contents change.

    cached row \
	cumulation AKTIVE_CSUM_FILL
}

# # ## ### ##### ######## ############# #####################

operator op::column::cumulative {
    section transform statistics

    note Returns image with the input columns transformed into cumulative sums.

    note This means that each pixel in a column is the sum of the values in the \
	rows before it, having the same column.

    note The result has the same geometry as the input. Only the contents change.

    cached column \
	cumulation AKTIVE_CSUM_FILL
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

	// Applies only when src can be assumed to contain only positive or negative values
	// If a mix is present the result can return to the initial value
	// ASSERT (dstvalue[DD-1] > dstvalue[0], "bad cumulation is flat");
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
