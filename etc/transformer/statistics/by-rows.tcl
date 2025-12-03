## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Statistics by rows.

# # ## ### ##### ######## ############# #####################
## Compress rows down to a statistic

operator {dexpr attr} {
    op::row::arg::max    {first index}        maximal
    op::row::arg::min    {first index}        minimal
    op::row::max         maximum              {}
    op::row::mean        {arithmetic mean}    {}
    op::row::min         minimum              {}
    op::row::profile     {left profile}       {}
    op::row::rprofile    {right profile}      {}
    op::row::stddev      {standard deviation} {}
    op::row::sum         sum                  {}
    op::row::sumsquared  sum                  squared
    op::row::variance    variance             {}
} {
    op -> _ kind fun extra
    if {$fun eq "arg"} { def fun $fun$extra }

    set int [expr {$fun in {mean stddev variance} ? "" : "-int"}]
    example [string map [list INT $int] {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 32 height 32 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 | -matrix INT
    }]
    unset int

    section transform statistics

    ## simplifications (also apply for input width == 1)
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
    ## - profile    :: NONE
    ## - rprofile   :: NONE

    import? ../simpler/stat_$fun.rules	;# queries kind !!

    note Returns image with input rows compressed to a single value, \
	the $dexpr of the {*}$attr row values. The result is a single-column \
	image with height and depth of the input.

    switch -exact -- $fun {
	profile {
	    note The __left__ profile of each row is the index of the \
		__first__ column with a __non-zero__ value. Or the \
		width of the image, if there are no such in the row.
	}
	rprofile {
	    note The __right__ profile of each row is the index of the \
		__last__ column with a __non-zero__ value. Or `-1`, if \
		there are no such in the row.
	}
    }

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

    # AW == 1. We care about AX here. TODO :: blitter - avoid loop, unroll
    blit reducer {
	{AH {y AY 1 up} {y 0 1 up}}
	{DD {z  0 1 up} {z 0 1 up}}
	{ 1 {x AX 1 up} {x 0 1 up}}
    } {raw reduce-row {
	// dstvalue = row/band start -
	// srcvalue = row/band start - SD-strided row vector
	*dstvalue = REDUCE (srcvalue, SW, SD, 0 /* client data, ignored */);
    }}
    ## __UNROLL__ option1: compute all bands together (1/2/3/many specialization)
    ## __UNROLL__ note: differs from by-band in the scope of the aggregation

    pixels {
	aktive_rectangle_def_as (subrequest, request);
	subrequest.width = istate->width;
	TRACE_RECTANGLE_M("@@fun@@", &subrequest);
	aktive_block* src = aktive_region_fetch_area (0, &subrequest);
	#define REDUCE aktive_reduce_@@fun@@
	@@reducer@@
	#undef REDUCE
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
