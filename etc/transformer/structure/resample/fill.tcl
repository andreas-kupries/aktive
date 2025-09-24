## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Zero-stuff along one of the coordinate axes. No replication.
## Intermediate points are filled with a fixed value.
##
## The stuffing factor S is also the scale factor, i.e.
##
##   result width = input width * S
##
## and S-1 pixel gaps to be set to the chosen fill value.

operator op::sample::fill::xy {

    section transform structure

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 by 4 fill 0.5
    }

    note Returns image where the input is \"zero-stuffed\" \
	along both x and y axes according to the stuffing \
	factor S (>= 1). The S-1 gaps in the result are set to \
	the given fill value, with zero, i.e. 0, used by default.

    input

    uint? 2 by Stuff factor, range 2...
    double? 0 fill  Pixel fill value

    body {
	set src [x $src by $by fill $fill]
	set src [y $src by $by fill $fill]
    }
}

operator {coordinate dimension} {
    op::sample::fill::x  x width
    op::sample::fill::y  y height
    op::sample::fill::z  z depth
} {
    section transform structure

    if {$coordinate in {x y}} {
	example {
	    aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	    @1 by 4 fill 0.5
	}
    }

    note Returns image where the input is \"zero-stuffed\" \
	along the ${coordinate}-axis according to the stuffing \
	factor S (>= 1). The S-1 gaps in the result are set to \
	the given fill value, with zero, i.e. 0, used by default.

    # Factor 0 - Undefined. Rejected.
    #        1 - No gaps -> Identity, no operation
    #        2 - Gap 1, fill every other value
    #        3 - Gap 2.

    input

    uint      by    Stuff factor, range 2...
    double? 0 fill  Pixel fill value

    # Factor 1 stuffing is no stuffing at all
    simplify for \
	if {$by == 1} \
	returns src

    # Chains: stuff factors multiply, however if and only if the fill values match
    simplify for  src/type @self \
	src/value fill __fill \
	if {$__fill == $fill} \
	src/value by __by \
	calc __by {$__by * $by} \
	src/pop \
	returns op sample fill $coordinate : by __by fill __fill

    # Chains: stuffing a sampling is __not__ identity.
    #         The stuffing cannot recover the information lost in the sampling.

    state -setup {
	// could be moved into the cons wrapper created for simplification
	if (param->by == 0) aktive_fail ("Rejecting undefined stuffing by factor 0");

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	// Modify dimension according to parameter
	domain->@@dimension@@ *= param->by;
    }

    #
    # SRC 0     1     2     3     4     5     6		(gradient    7 1 1 0 6)
    # DST 0 . . 1 . . 2 . . 3 . . 4 . . 5 . . 6 . .	(sample fill x 3 .)
    #     = = = = = = = = = = = = = = = = = = = = =
    #     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
    #                         1                   2
    #               |=========|
    #               . 2 . . 3 .				(select x 5 10)
    #               0 1 2 3 4 5
    #
    # select      request: 5..10 = 5,6
    # sample fill request: 5..10 = 5,6
    # gradient    request: 2..3  = 2,1 (grid to 6 (+1 = (-5 % 3) [1] = ((5 - (5 % 3)) % 3) [2])
    # note: different %-semantics for Tcl [1] and C [2].
    #
    # The actual dst x is shifted to align to the stretched grid in the destination.
    #
    # X % 5 | Correction -x  % 5 == (5 - x%5) % 5
    # ----- + ------------------ -- -------------
    # 0     | 0           0  0
    # 1     | 4          -1  4
    # 2     | 3          -2  3
    # 3     | 2          -3  2
    # 4     | 1          -4  1
    # ----- + -------------------

    if 0 {
	foreach x {0 1 2 3 4 5 6 7 8 9} z {0 4 3 2 1 0 4 3 2 1} {
	    puts $x\t$z\t[expr {(-$x) % 5}]\t[expr {(5 - (($x) % 5)) % 5}]
	}
    }

    blit filler [dict get {
	y {
	    {SH {y grid n up} {y 0 1 up}}
	    {DW {x 0    1 up} {x 0 1 up}}
	    {DD {z 0    1 up} {z 0 1 up}}
	}
	x {
	    {DH {y 0    1 up} {y 0 1 up}}
	    {SW {x grid n up} {x 0 1 up}}
	    {DD {z 0    1 up} {z 0 1 up}}
	}
	z {
	    {DH {y 0 1 up} {y 0 1 up}}
	    {DW {x 0 1 up} {x 0 1 up}}
	    {SD {z 0 n up} {z 0 1 up}}
	}
    } $coordinate] copy

    def shrinkcore {
	// Note: C-semantics for `%`. Tcl semantics yield `(-i)%n`.
	#define CORRECTION(i,n)  (((n) - ((i) % (n))) % (n))
	// Shift correction to snap request into the sample grid
	int grid = CORRECTION (subrequest.@@coordinate@@, n);
	#undef CORRECTION
	TRACE ("Correction: %d (%d in %d)", grid, subrequest.@@coordinate@@, n);

	// Rewrite request to the input coordinates and dimensions
	subrequest.@@coordinate@@ = (subrequest.@@coordinate@@ + grid) / n;
	if (subrequest.@@dimension@@ < n) {
	    // The correction puts the input block outside of the requested range
	    // This means that the caller asked for gap data. This data is already
	    // in the result, as `aktive_blit_fill` was called above.
	    if (grid >= subrequest.@@dimension@@) {
		TRACE_RETURN_VOID;
	    }
	    subrequest.@@dimension@@ = 1;
	} else {
	    subrequest.@@dimension@@ /= n;
	}

	TRACE_RECTANGLE_M ("rewritten", request);

	// Note: grid is the starting point in the destination area (rooted at 0).
    }

    def shrink [dict get {
	x { @@shrinkcore@@ }
	y { @@shrinkcore@@ }
	z { // Nothing to rewrite for z, depth }
    } $coordinate]

    pixels {
	// Blank the region with the fill value first. This way the coming blitter
	// does not have to concern itself with the gaps, just the values to set.
	aktive_blit_fill (block, dst, param->fill);

	aktive_uint n = param->by;
	aktive_rectangle_def_as (subrequest, request);
	@@shrink@@
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	// The destination @@coordinate@@ axis is scanned N times faster than the source.
	// The destination location is snapped forward to the grid.
	@@filler@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
