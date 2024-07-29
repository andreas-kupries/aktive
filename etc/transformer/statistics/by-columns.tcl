## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Statistics by columns.

# # ## ### ##### ######## ############# #####################
## Compress columns down to a statistic

operator {dexpr attr} {
    op::column::arg::max   {first index}        maximal
    op::column::arg::min   {first index}        minimal
    op::column::max         maximum              {}
    op::column::mean        {arithmetic mean}    {}
    op::column::min         minimum              {}
    op::column::stddev      {standard deviation} {}
    op::column::sum         sum                  {}
    op::column::sumsquared  sum                  squared
    op::column::variance    variance             {}
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

    ## simplifications
    ## - min, max, mean, sum :: elide (idempotent), and for input height == 1
    ## - sumsquared          :: op math1 pow 2 (power chaining)
    ## - variance, stddev    :: const 0

    import? ../simpler/stat_$fun.rules	;# queries kind !!

    note Returns image with input columns compressed to a single value, \
	the $dexpr of the {*}$attr column values. The result is a single-row \
	image with width and depth of the input.

    note The part about the `depth of the input` means that the bands \
	in each column are handled separately.

    input

    state -fields {
	aktive_uint height; // quick access to input height
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->height = domain->height;
	domain->height = 1;
    }

    # AH == 1. We care about AY here. TODO :: blitter - avoid loop, unroll
    blit reducer {
	{AW {x AX 1 up} {x 0 1 up}}
	{DD {z  0 1 up} {z 0 1 up}}
	{ 1 {y AY 1 up} {y 0 1 up}}
    } {raw reduce-column {
	// dstvalue = row/band start -
	// srcvalue = row/band start - srcpitch-strided column vector
	*dstvalue = REDUCE (srcvalue, SH, SW*SD, 0 /* client data, ignored */);
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
