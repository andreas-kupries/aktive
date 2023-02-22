## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Stretch along one of the coordinate axes. No replication.
## Intermediate points are filled with a fixed value.

operator {coordinate dimension} {
    op::upsample::x  x width
    op::upsample::y  y height
    op::upsample::z  z depth
} {
    note Transformer. Structure. \
	Returns input stretched along the ${coordinate}-axis \
	according to the stretching factor (>= 1).

    note The gaps are set to the specified fill value.

    input

    uint   n     Stretch factor, range 2...
    double fill  Pixel fill value

    # Factor 1 stretching is no stretch at all
    simplify for  if {$n == 1}  returns src

    # Chains: stretch factors multiply, however if and only if the fill values match
    simplify for  src/type @self \
	src/value fill __fill \
	if {$__fill == $fill} \
	src/value n __n \
	calc __n {$__n * $n} \
	src/pop \
	returns op upsample $coordinate : __n __fill

    # Chains: stretching a decimation is __not__ identity. Stretching cannot recover the
    # information lost in the decimation.

    state -setup {
	// could be moved into the cons wrapper created for simplification
	if (param->n == 0) aktive_fail ("Rejecting undefined stretching by 0");

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	// Modify dimension according to parameter
	domain->@@dimension@@ *= param->n;
    }

    #
    # SRC 0     1     2     3     4     5     6		(gradient 7 1 1 0 6)
    # DST 0 . . 1 . . 2 . . 3 . . 4 . . 5 . . 6 . .	(upsample x 3 .)
    #     = = = = = = = = = = = = = = = = = = = = =
    #     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
    #                         1                   2
    #               |=========|
    #               . 2 . . 3 .				(select x 5 10)
    #               0 1 2 3 4 5
    #
    # select   request: 5..10 = 5,6
    # upsample request: 5..10 = 5,6
    # gradient request: 2..3  = 2,1 (grid to 6 (+1 = (-5 % 3) [1] = ((5 - (5 % 3)) % 3) [2])
    # note: different %-semantics for Tcl [1] and C [2].
    #
    # The actual dst x is shifted to align to the stretch grid in the destination.
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

    # base blitter setup
    set blitspec {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    }
    # ... stretch specific destination axis using source dimension, lock start to grid
    switch -exact -- $coordinate {
	y { lset blitspec 0 0 SH ; lset blitspec 0 1 2 n ; lset blitspec 0 1 1 grid }
	x { lset blitspec 1 0 SW ; lset blitspec 1 1 2 n ; lset blitspec 1 1 1 grid }
	z { lset blitspec 2 0 SD ; lset blitspec 2 1 2 n }
    }
    # ... generate code
    blit upsampler $blitspec copy

    def shrinkcore {
	// Note: C-semantics for `%`. Tcl semantics yield `(-i)%n`.
	#define CORR(i,n)  (((n) - ((i) % (n))) % (n))
	// Shift correction to snap request into the sample grid
	int grid = CORR (request->@@coordinate@@, n);
	#undef CORR
	TRACE ("Correction: %d (%d in %d)", grid, request->@@coordinate@@, n);

	// Rewrite request to the input coordinates and dimensions
	request->@@coordinate@@ = (request->@@coordinate@@ + grid) / n;
	if (request->@@dimension@@ < n) {
	    // The correction puts the input block outside of the requested range
	    // This means that the caller asked for gap data. This data is already
	    // in the result, as `aktive_blit_fill` was called above.
	    if (grid >= request->@@dimension@@) {
		TRACE_RETURN_VOID;
	    }
	    request->@@dimension@@ = 1;
	} else {
	    request->@@dimension@@ /= n;
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

	aktive_uint n = param->n;
	@@shrink@@
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	// The destination @@coordinate@@ axis is scanned N times faster than the source.
	// The destination location is snapped forward to the grid.
	@@upsampler@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
