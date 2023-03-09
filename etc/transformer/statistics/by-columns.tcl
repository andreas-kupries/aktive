## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Statistics by columns.

# # ## ### ##### ######## ############# #####################
## Compress columns down to a statistic

operator {kind attr} {
    op::column::max         maximum              {}
    op::column::mean        {arithmetic mean}    {}
    op::column::min         minimum              {}
    op::column::stddev      {standard deviation} {}
    op::column::sum         sum                  {}
    op::column::sumsquared  sum                  squared
    op::column::variance    variance             {}
} {
    section transform statistics

    def kind [set kind [lindex [split $__op :] 2]]
    def fun  [set fun  [lindex [split $__op :] 4]]

    ## TODO :: input width == 1 => optimize
    ## min, max, mean, sum :: elide
    ## sumsquared          :: op math1 pow 2
    ##
    ## ?? variance, stddev

    import? ../simpler/stat_$fun.rules	;# queries @@kind@@ !!

    note Returns image with input columns compressed to a single value, \
	the $kind of the $attr column values. The result is a single-row \
	image with width and depth of the input.

    input

    state -fields {
	aktive_uint height; // quick access to input height
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->height = domain->height;
	domain->height = 1;
    }

    blit reducer {
	{DW {x 0 1 up} {x 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    } {raw reduce-column {
	// dstvalue = row/band start -
	// srcvalue = row/band start - srcpitch-strided column vector
	*dstvalue = REDUCE (srcvalue, SH, SW*SD);
    }}

    pixels {
	aktive_rectangle_def_as (subrequest, request);
	subrequest.height = istate->height;
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
