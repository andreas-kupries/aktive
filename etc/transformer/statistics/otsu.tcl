## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Otsu threshold calculation along the axes
##                 (rows, columns, bands).
#
## Note: This operation is only sensible for histogram inputs.
#
## Getting the otsu thresholds for arbitrary images is therefore
## a 2-step process. Convert the image to a suitable (set of)
## histograms, then apply the transformers defined here.
#
## Tile thresholds:       This is a band otsu applied to a tile histogram.
## Full image thresholds: This is a row  otsu applied to an image histogram.
#
# # ## ### ##### ######## ############# #####################

operator op::row::otsu {
    section transform statistics

    example -matrix -int \
	{aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 32 height 32 a {10 10} b {50 80} c {80 30}] thickness 4]} \
	{[aktive op row histogram @1]}

    input

    note Returns image with the input rows compressed into an otsu threshold.
    note This assumes as input an image of row histograms.

    note The result has the same height and depth as the input.
    note The result has a single column.

    state -fields {
	aktive_uint width; // quick access to input width
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->width = domain->width;
	domain->width = 1;
    }

    blit reducer {
	{AH {y AY 1 up} {y 0 1 up}}
	{DD {z  0 1 up} {z 0 1 up}}
	{ 1 {x AX 1 up} {x 0 1 up}}
    } {raw reduce-row {
	// dstvalue = row/band start -
	// srcvalue = row/band start - SD-strided row vector
	*dstvalue = aktive_otsu (srcvalue, SW, SD);
    }}

    pixels {
	aktive_rectangle_def_as (subrequest, request);
	subrequest.width = istate->width;
	TRACE_RECTANGLE_M("otsu", &subrequest);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);
	@@reducer@@
    }
}

# # ## ### ##### ######## ############# #####################

operator op::column::otsu {
    section transform statistics

    example -matrix -int \
	{aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 32 height 32 a {10 10} b {30 80} c {80 30}] thickness 4]} \
	{[aktive op column histogram @1]}

    input

    note Returns image with the input columns compressed into an otsu threshold.
    note This assumes as input an image of column histograms.

    note The result has the same width and depth as the input.
    note The result has a single row.

    state -fields {
	aktive_uint height; // quick access to input height
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->height = domain->height;
	domain->height = 1;
    }

    blit reducer {
	{AW {x AX 1 up} {x 0 1 up}}
	{DD {z  0 1 up} {z 0 1 up}}
	{ 1 {y AY 1 up} {y 0 1 up}}
    } {raw reduce-column {
	// dstvalue = column/band start -
	// srcvalue = column/band start - srcpitch-strided column vector
	*dstvalue = aktive_otsu (srcvalue, SH, SW*SD);
    }}

    pixels {
	aktive_rectangle_def_as (subrequest, request);
	subrequest.height = istate->height;
	TRACE_RECTANGLE_M("otsu", &subrequest);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);
	@@reducer@@
    }
}

# # ## ### ##### ######## ############# #####################

operator op::band::otsu {
    section transform statistics

    input

    note Returns image with the input bands compressed into an otsu threshold.
    note This assumes as input an image of band histograms.

    note The result has the same width and height as the input.
    note The result is single-band.

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	domain->depth = 1;
    }

    blit reducer {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
    } {raw reduce-band {
	// dstvalue = band/band start -
	// srcvalue = band/band start - 1-strided band vector
	*dstvalue = aktive_otsu (srcvalue, SD, 1);
    }}

    pixels {
	aktive_rectangle_def_as (subrequest, request);
	TRACE_RECTANGLE_M("otsu", &subrequest);
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);
	@@reducer@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
