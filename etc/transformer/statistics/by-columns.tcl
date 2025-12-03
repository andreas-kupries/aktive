## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Statistics by columns.

# # ## ### ##### ######## ############# #####################
## Compress columns down to a statistic

operator {dexpr attr} {
    op::column::arg::max    {first index}        maximal
    op::column::arg::min    {first index}        minimal
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
    # __UNROLL__ option 1: compute all the bands of the column together, 1/2/3/many
    # __UNROLL__ option 2: compute multiple columns together
    # __UNROLL__           (restrict to single band images ?)
    # __UNROLL__ NOTE: each band can be seen as its own column
    # __UNROLL__       no true difference between 1 and 2.

    pixels {
	aktive_rectangle_def_as (subrequest, request);
	subrequest.height = istate->height;
	TRACE_RECTANGLE_M("@@fun@@", &subrequest);
	aktive_block* src = aktive_region_fetch_area (0, &subrequest);
	#define REDUCE aktive_reduce_@@fun@@
	@@reducer@@
	#undef REDUCE
    }
}

operator {edge which out} {
    op::column::profile  top    first {the height of the image}
    op::column::rprofile bottom last  {`-1`}
} {

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 32 height 32 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 | -matrix -int
    }

    section transform statistics

    note Returns image with input columns compressed to a single value, \
	the $edge profile of the column values. The result is a single-row \
	image with width and depth of the input. The bands of the image are \
	handled independently.

    note The __${edge}__ profile of each column is the index of the \
	__${which}__ row with a __non-zero__ value. Or ${out}, \
	if there are no such in the column.

    input

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	domain->height = 1;
    }

    def isbottom [string equal $edge bottom]

    pixels -state {
	aktive_image src;
    } -setup {
	state->src = aktive_region_owner (srcs->v[0]);
    } {
	aktive_cprofile* cprofile = aktive_cprofile_find (state->src, @@isbottom@@, request);

	TRACE ("cprofile [%d]", cprofile->n);

	ASSERT (block->used == cprofile->n, "block/profile mismatch");

	// blitting profile into result block
	memcpy (block->pixel, cprofile->profile, cprofile->n * sizeof(double));

	aktive_cprofile_release (cprofile);
    }

}

##
# # ## ### ##### ######## ############# #####################
::return
