## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Statistics by bands.

# # ## ### ##### ######## ############# #####################
## Compress bands down to a statistic

operator {dexpr attr} {
    op::band::max         maximum              {}
    op::band::mean        {arithmetic mean}    {}
    op::band::min         minimum              {}
    op::band::stddev      {standard deviation} {}
    op::band::sum         sum                  {}
    op::band::sumsquared  sum                  squared
    op::band::variance    variance             {}
} {
    section transform statistics

    def kind [lindex [split $__op :] 2]
    def fun  [lindex [split $__op :] 4]

    ## TODO :: input depth == 1 => optimize
    #
    ## simplifications
    ## - min, max, mean, sum :: elide idempotent
    ## - sumsquared          :: op math1 pow 2 (power chaining)
    ## - variance, stddev    :: const 0

    import? ../simpler/stat_$fun.rules	;# queries kind !!

    note Returns image with input bands compressed to a single value, \
	the $dexpr of the $attr band values. The result is a single-band \
	image with width and height of the input.

    input

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	domain->depth = 1;
    }

    blit reducer {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
    } {raw reduce-band {
	// dstvalue = row/col start -
	// srcvalue = row/col start - 1-strided band vector
	*dstvalue = REDUCE (srcvalue, SD, 1);
    }}

    pixels {
	TRACE_RECTANGLE_M("@@fun@@", request);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);
	#define REDUCE aktive_reduce_@@fun@@
	@@reducer@@
	#undef REDUCE
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
