## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Statistics by rows.

# # ## ### ##### ######## ############# #####################
## Compress rows down to a statistic

operator {dexpr attr} {
    op::row::max         maximum              {}
    op::row::mean        {arithmetic mean}    {}
    op::row::min         minimum              {}
    op::row::stddev      {standard deviation} {}
    op::row::sum         sum                  {}
    op::row::sumsquared  sum                  squared
    op::row::variance    variance             {}
} {
    section transform statistics

    def kind [lindex [split $__op :] 2]
    def fun  [lindex [split $__op :] 4]

    ## simplifications
    ## - min, max, mean, sum :: elide idempotent, and for input width == 1
    ## - sumsquared          :: op math1 pow 2 (power chaining)
    ## - variance, stddev    :: const 0

    import? ../simpler/stat_$fun.rules	;# queries kind !!

    note Returns image with input rows compressed to a single value, \
	the $dexpr of the {*}$attr row values. The result is a single-column \
	image with height and depth of the input.

    note The part about the `depth of the input` means that the bands \
	in each row are handled separately.

    input

    state -fields {
	aktive_uint width; // quick access to input width
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->width = domain->width;
	domain->width = 1;
    }

    blit reducer {
	{DH {y 0 1 up} {y 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    } {raw reduce-row {
	// dstvalue = row/band start -
	// srcvalue = row/band start - SD-strided row vector
	*dstvalue = REDUCE (srcvalue, SW, SD, 0 /* client data, ignored */);
    }}

    pixels {
	aktive_rectangle_def_as (subrequest, request);
	subrequest.width = istate->width;
	TRACE_RECTANGLE_M("@@fun@@", &subrequest);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);
	#define REDUCE aktive_reduce_@@fun@@
	@@reducer@@
	#undef REDUCE
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
