## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Statistics by bands.

# # ## ### ##### ######## ############# #####################
## Compress bands down to a statistic

operator {dexpr attr} {
    op::band::arg::max   {first index}        maximal
    op::band::arg::min   {first index}        minimal
    op::band::max         maximum              {}
    op::band::mean        {arithmetic mean}    {}
    op::band::min         minimum              {}
    op::band::stddev      {standard deviation} {}
    op::band::sum         sum                  {}
    op::band::sumsquared  sum                  squared
    op::band::variance    variance             {}
} {
    op -> _ kind fun extra
    if {$fun eq "arg"} { def fun $fun$extra }

    section transform statistics

    ## simplifications (also apply for input depth == 1)
    ## - min, max, mean, sum :: elide (idempotent)
    ## - sumsquared          :: op math1 pow 2 (power chaining)
    ## - variance, stddev    :: const 0

    import? ../simpler/stat_$fun.rules	;# queries kind !!

    note Returns image with input bands compressed to a single value, \
	the $dexpr of the {*}$attr band values. The result is a single-band \
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
	*dstvalue = REDUCE (srcvalue, SD, 1, 0 /* client data, ignored */);
    }}

    pixels {
	TRACE_RECTANGLE_M("@@fun@@", request);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);
	#define REDUCE aktive_reduce_@@fun@@
	@@reducer@@
	#undef REDUCE
    }
}

# # ## ### ##### ######## ############# #####################
## More `arg.*` operators. These take a threshold as controlling argument.

operator {attr} {
    op::band::arg::ge {greater than or equal}
    op::band::arg::gt {greater than}
    op::band::arg::le {lesser than or equal}
    op::band::arg::lt {lesser than}
} {
    op -> _ _ _ fun

    section transform statistics

    note Returns the second image with its input bands compressed to a single value, \
	the first index where the band value is $attr than the threshold provided by \
	the first image. The result is a single-band image with width and height \
	of the inputs.

    note If no band matches the condition the result is the depth of the data image.

    note Both images have to have the same width and height.
    note The threshold image has to be single-band.

    input	;# thresholds
    input	;# data

    state -setup {
	aktive_image     thresholds = srcs->v[0];
	aktive_image     data       = srcs->v[1];
	aktive_geometry* tg         = aktive_image_get_geometry (thresholds);
	aktive_geometry* dg         = aktive_image_get_geometry (data);

	if (tg->width  != dg->width)  aktive_failf ("width mismatch, %d != %d",  tg->width,  dg->width);
	if (tg->height != dg->height) aktive_failf ("height mismatch, %d != %d", tg->height, dg->height);
	if (tg->depth != 1) aktive_failf ("bad threshold input has depth %d != 1", tg->depth);

	aktive_geometry_copy (domain, tg);
    }

    blit reducer {
	{DH {y 0 1 up} {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up} {x 0 1 up}}
    } {raw reduce-band {
	// dstvalue    = row/col start -
	// src0value = row/col start - single-band           | threshold
	// src1value = row/col start - 1-strided band vector | data
	*dstvalue = REDUCE (src1value, S1D, 1, src0value);
    }}

    pixels {
	TRACE_RECTANGLE_M("arg@@fun@@", request);
	aktive_block* srca = aktive_region_fetch_area (srcs->v[0], request);
	aktive_block* srcb = aktive_region_fetch_area (srcs->v[1], request);
	#define REDUCE aktive_reduce_arg@@fun@@
	@@reducer@@
	#undef REDUCE
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
