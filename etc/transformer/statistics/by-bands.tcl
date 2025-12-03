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
    #
    ## - arg::max   :: const 0 (single value is max, at index 0)
    ## - arg::min   :: const 0 (single value is min, at index 0)
    ## - max        :: elide (idempotent / identity)
    ## - mean       :: elide (idempotent / identity)
    ## - min        :: elide (idempotent / identity)
    ## - stddev     :: const 0
    ## - sum        :: elide (idempotent / identity)
    ## - sumsquared :: op math1 pow 2 (power chaining)
    ## - variance   :: const 0

    import? ../simpler/stat_$fun.rules	;# queries kind !!

    note Returns an image with the input bands compressed to a single value, \
	the ${dexpr} of the {*}$attr band values. The result is a single-band \
	image with the same width and height as the input.

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
    ## __UNROLL__ note: single band is simplified, see above, not relevant here.
    ##
    ## __UNROLL__ option: specialized code handling 2,3,many bands, for the pixel
    ## __UNROLL__ issue:  still 1 function call per pixel
    ##
    ## __UNROLL__ option: specialized code handling 2,3,many bands, for the entire row
    ## __UNROLL__         single call for the entire row, per row
    ## __UNROLL__         hide specializations in a single function
    ##
    ## __UNROLL__ note: look into code generation for the reducers

    pixels {
	TRACE_RECTANGLE_M("@@fun@@", request);
	aktive_block* src = aktive_region_fetch_area (0, request);
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

    note Returns the source image with its bands compressed to a single value, \
	the first index where the band value is $attr than the threshold. \
	The result is a single-band image with the same width and height as the \
	inputs.

    # TODO simplification: for a single-band image the operation is a ternary
    # specifically:   (src REL threshold) ? 0 : DEPTH
    # or:             (src anti-REL threshold) ? DEPTH : 0
    # <=>             (src anti-REL threshold) * DEPTH
    #                 aktive op math1 scale (aktive op math <anti-REL> SRC T) factor DEPTH
    #
    # relation anti-relation
    # -------- -------------
    # ge       lt
    # gt       le
    # le       gt
    # lt       ge
    # -------- -------------

    note The result is suitable for use by "<!xref: aktive op take z>."

    note At the pixels where no band matches the condition the result is the \
	depth of the data image.

    note Both images have to have the same width and height.

    note The threshold image has to be single-band.

    input thresholds	Single-band image of thresholds.
    input src		Source to scan and compress.

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
	TRACE_RECTANGLE_M("arg@@fun@@ data", request);
	aktive_block* srcb = aktive_region_fetch_area (1, request);
	TRACE_GEOMETRY_M("srcb geometry (d)", &srcb->domain);

	TRACE_RECTANGLE_M("arg@@fun@@ thresholds", request);
	aktive_block* srca = aktive_region_fetch_area (0, request);
	TRACE_GEOMETRY_M("srca geometry (t)", &srca->domain);

	/**/
	TRACE_GEOMETRY_M("p srcb geometry (d)", &srcb->domain);
	TRACE_GEOMETRY_M("p srca geometry (t)", &srca->domain);
	#define REDUCE aktive_reduce_arg@@fun@@
	@@reducer@@
	#undef REDUCE
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
