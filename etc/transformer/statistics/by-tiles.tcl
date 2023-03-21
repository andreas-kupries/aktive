## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Statistics by tiles.

# # ## ### ##### ######## ############# #####################
## Compute statistics by tiles (quadratic regions), overlapping!

operator {dexpr attr prefered_embedding} {
    op::tile::max         maximum              {}	mirror
    op::tile::mean        {arithmetic mean}    {}	mirror
    op::tile::min         minimum              {}	mirror
    op::tile::stddev      {standard deviation} {}	mirror
    op::tile::sum         sum                  {}	black
    op::tile::sumsquared  sum                  squared	black
    op::tile::variance    variance             {}	mirror
} {
    section transform statistics

    def fun [lindex [split $__op :] 4]

    # Simplifications are not easy. Results depend not only on the operator, but also the
    # chossen embedding. Note that without an embedding the results continue to shrink, so
    # no idempotency, etc. at all.

    note Returns image containing the $dexpr of the {*}$attr tile values, \
	for all tiles of radius R in the input.

    note Beware, {"all tiles"} means that the operator consumes overlapping \
	tiles, not just adjacent.

    note Beware, the result image is shrunken by 2*R in width and height \
	relative to the input. If this is not desired add a border to the \
	input using one of the `aktive op embed ...` operators before \
	applying this operator.

    note The prefered embedding for $dexpr is $prefered_embedding. \
	It is chosen to have minimal to no impact on the statistics \
	at the original input's borders.

    note Inputs with not enough width or height are rejected.

    note The input bands are handled separately.

    input

    uint radius	\
	Tile size as radius from center. \
	Full width and height of the tile are `2*radius+1`.

    state -setup {
	aktive_uint len = 2*param->radius+1;

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));

	if ((domain->width  < len) ||
	    (domain->height < len)) {
	    aktive_failf ("Image %dx%d too small for %d-radius tiles",
			  domain->width, domain->height, param->radius);
	}

	domain->x      += param->radius;
	domain->y      += param->radius;
	domain->width  -= 2*param->radius;
	domain->height -= 2*param->radius;
    }

    blit reducer {
	{DH {y 0 1 up} {y R 1 up}}
	{DW {x 0 1 up} {x R 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    } [list raw reduce-tile-$fun {
	// dstvalue = cell to set
	// srcvalue = center cell of tile
	*dstvalue = REDUCE (srcvalue, R, srcpos, SRCCAP, srcpitch, srcstride);
    }]

    pixels {
	aktive_rectangle_def_as (subrequest, request);

	subrequest.x      -= param->radius;
	subrequest.y      -= param->radius;
	subrequest.width  += 2*param->radius;
	subrequest.height += 2*param->radius;

	TRACE_RECTANGLE_M("@@fun@@", &subrequest);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	// TRACE_DO (__aktive_block_dump ("tile max in", src));

	#define R (param->radius)
	#define REDUCE aktive_tile_reduce_@@fun@@
	@@reducer@@
	#undef REDUCE

	// TRACE_DO (__aktive_block_dump ("tile max out", block));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
