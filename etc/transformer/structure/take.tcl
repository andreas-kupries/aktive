## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Select a row, column, or band, per an index image.

operator {kind coordinate dimension other1 other2} {
    op::take::x column x width       height depth
    op::take::y row    y height      width  depth
    op::take::z band   z depth       width  height
} {
    op -> _ _ direction
    section transform structure

    note Selects $kind values from the source under the control of the single-${kind} index.

    note Takes two inputs of the same $other1 and ${other2}. \
	The index is single-${kind}. \
	Its $other1 and $other2 match the source. \
	The result image has the same geometry as the index.

    note The stored indices select, per result pixel, the \
	$kind value to take from the source and place into \
	the result.

    note Indices are clamped to the interval 0 ... \#(${kind}s-1) of the source. \
	Fractional indices are rounded down to integer.

    note The locations of index and source are ignored. \
	The result is placed at the coordinate origin/zero.

    input index	Indices selecting the per-pixel ${kind} of the source.
    input src	Source the data is selected from.

    # Memory usage notes ...
    #
    # take z, selecting band values per pixel can pass requests as-is to its data source.
    #         no trouble with memory regardless of how the sink queries the result.
    #
    # take x, selecting column values per row/band has to amplify incoming requests,
    #         i.e. query __full rows__ from the data source.
    #
    #         This is ok for sinks scanning by row(-stripes).
    #
    #         Scanning by columns however forces the entire data source into memory,
    #         even multiple times (number of active threads!)
    #
    # take y, has the same issues as take x with amplification and scanning, excrept for
    #         rows and columns swapped. Scanning by rows forces the entire data source
    #         into memory, times the active threads.
    #
    # As the standard sink currently scans by rows `take y` is currently a bad operation.

    ## TODO : Rework the internals of take x|y to reduce memory requirements under any scan schema.
    ##        Half-baked thoughts
    #
    ##        - Scan the index by element and query the data source for just the part needed to
    ##          satify the selection operation.
    ##
    ##          Cons: One request per result cell, instead of a single request.
    ##                Less memory, more time.
    #
    ##        - ...

    # x: blit y: blit z: select x
    # y: blit x: blit z: select y
    # z: blit y: blit x: select z

    switch -exact $coordinate {
	x {
	    # AW == 1. We care about AX here.
	    blit selector {
		{AH {y AY 1 up} {y 0 1 up} {y 0 1 up}}
		{DD {z  0 1 up} {z 0 1 up} {z 0 1 up}}
		{ 1 {x AX 1 up} {x 0 1 up} {x 0 1 up}}
	    } {raw select-row {
		// dstvalue  = row/band start -
		// src0value = row/band start - S1D-strided row vector, 1 row => 1 value, index
		// src1value = row/band start - S1D-strided row vector
		*dstvalue = aktive_select (src1value, S1W, S1D, src0value);
	    }}
	    def dataquest {
		dataquest.width = istate->full;
	    }
	}
	y {
	    # AH == 1. We care about AY here.
	    blit selector {
		{AW {x AX 1 up} {x 0 1 up} {x 0 1 up}}
		{DD {z  0 1 up} {z 0 1 up} {z 0 1 up}}
		{ 1 {y AY 1 up} {y 0 1 up} {y 0 1 up}}
	    } {raw select-column {
		// dstvalue  = row/band start -
		// src0value = row/band start - src1pitch-strided column vector, 1 column => 1 value, index
		// src1value = row/band start - src1pitch-strided column vector
		*dstvalue = aktive_select (src1value, S1H, S1W*S1D, src0value);
	    }}
	    def dataquest {
		dataquest.height = istate->full;
	    }
	}
	z {
	    blit selector {
		{DH {y 0 1 up} {y 0 1 up}  {y 0 1 up}}
		{DW {x 0 1 up} {x 0 1 up}  {x 0 1 up}}
	    } {raw select-band {
		// dstvalue  = row/col start -
		// src0value = row/col start - 1-strided band vector, 1 band => 1 value, index
		// src1value = row/col start - 1-strided band vector
		*dstvalue = aktive_select (src1value, S1D, 1, src0value);
	    }}

	    def dataquest {}
	}
    }

    state -fields {
	aktive_uint full;
    } -setup {
	aktive_geometry* index_geo = aktive_image_get_geometry (srcs->v[0]);
	aktive_geometry* data_geo  = aktive_image_get_geometry (srcs->v[1]);

	if (index_geo->@@dimension@@ > 1)                  aktive_fail ("Not single-@@kind@@");
	if (index_geo->@@other1@@ != data_geo->@@other1@@) aktive_failf ("Index/data @@other1@@ mismatch %d != %d", index_geo->@@other1@@, data_geo->@@other1@@);
	if (index_geo->@@other2@@ != data_geo->@@other2@@) aktive_failf ("Index/data @@other2@@ mismatch %d != %d", index_geo->@@other2@@, data_geo->@@other2@@);

	state->full = data_geo->@@dimension@@;

	aktive_geometry_copy (domain, index_geo);
    }

    pixels {
	aktive_rectangle_def_as (dataquest, request);
	@@dataquest@@
	TRACE_RECTANGLE_M("take @@coordinate@@ index rq", request);
	TRACE_RECTANGLE_M("take @@coordinate@@ data  rq", &dataquest);

	aktive_block* srca = aktive_region_fetch_area (srcs->v[0], request);
	aktive_block* srcb = aktive_region_fetch_area (srcs->v[1], &dataquest);
	@@selector@@
    }
}


# # ## ### ##### ######## ############# #####################
## Choose between two images based on a condition images / mask

operator op::if-then-else {
    input selector	Binary selections
    input then		Image chosen where `selector == 1`.
    input else		Image chosen where `selector == 0`.

    section transform structure

    note Choose between inputs `then` and `else`, based on the content \
	of the `selector`.

    note All images have to have the same width and height. \
	The `selector` has to be single-band. \
	The other images may have arbitrary depth, as long as both have the same.

    note The `selector` content is clamped to `0..1`, \
	and fractional values are rounded down to integer. \
	1-pixels in the `selector` pass the same pixel from `then` \
	into the result, whereas 0-pixels in the `selector` pass the \
	same pixel from `else` instead.

    body {
	lassign [aktive query geometry $selector] _ _ ws hs ds
	lassign [aktive query geometry $then]     _ _ wt ht dt
	lassign [aktive query geometry $else]     _ _ we he de

	if {($ws != $wt) ||
	    ($hs != $ht)} { aktive error "Domain mismatch selector/then" }
	if {($ws != $we) ||
	    ($hs != $he)} { aktive error "Domain mismatch selector/else" }
	if {($dt != $de)} { aktive error "Depth mismatch then/else" }
	if {($ds != 1)}   { aktive error "Selector is not single-band" }

	set selector $selector
	set then     [aktive op split z $then]
	set else     [aktive op split z $else]

	# band-wise application of choice, then rejoin the bands
	set bands [lmap t $then e $else {
	       aktive op take z $selector [aktive op montage z $e $t]
	}]
	aktive op montage z {*}$bands
    }
}


##
# # ## ### ##### ######## ############# #####################
::return
