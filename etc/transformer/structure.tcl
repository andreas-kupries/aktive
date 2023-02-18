## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
#
# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Split into rows, columns, or bands
## - Rotate in 90 degree increments
## - Transpose / transverse

tcl-operator op::split::x {src} {
    set end [aktive query width $src]
    set r {}
    for {set k 0} {$k < $end} {incr k} {
	lappend r [aktive op select x $k $k $src]
    }
    return $r
}

tcl-operator op::split::y {src} {
    set end [aktive query height $src]
    set r {}
    for {set k 0} {$k < $end} {incr k} {
	lappend r [aktive op select y $k $k $src]
    }
    return $r
}

tcl-operator op::split::z {src} {
    set end [aktive query depth $src]
    set r {}
    for {set k 0} {$k < $end} {incr k} {
	lappend r [aktive op select z $k $k $src]
    }
    return $r
}

tcl-operator op::rotate::cw   {src} { aktive op flip x [aktive op swap xy $src] }
tcl-operator op::rotate::ccw  {src} { aktive op flip y [aktive op swap xy $src] }
tcl-operator op::rotate::half {src} { aktive op flip x [aktive op flip  y $src] }

tcl-operator op::transpose    {src} { swap xy $src }
tcl-operator op::transverse   {src} { flip x [flip y [swap xy $src]] }

# # ## ### ##### ######## ############# #####################
## Select a range of rows, columns, bands

operator {thing coordinate dimension} {
    op::select::x column x width
    op::select::y row    y height
    op::select::z band   z depth
} {
    note Transformer. Structure. Returns image containing a contiguous subset of the input's ${thing}s.

    note The result has a properly reduced $dimension.
    note The other two dimension are unchanged.
    note The 2D location of the first cell of the input going into the
    note result is the location of the result.

    input keep

    uint first  Input's first $thing to be placed into the result
    uint last   Input's last $thing to be placed into the result
    # As an image follows and we simplify (see below) we cannot make `last` optional.
    # The simplification is done in a Tcl level wrapper, and proc do not support
    # optional arguments in the middle of the set. (critcl::cproc does).

    simplify for  \
	if {$first == 0} \
	src/attr $dimension __range if {$last == ($__range - 1)} \
	returns src

    # TODO :: simplify hints (const input => create const of reduced dimensions)

    # The /thing/ values are relative to the image /dimension/, rooted at 0.
    # They are not 2D plane coordinates !!

    # The implementation, including the need for state, depends somewhat on the /thing/
    #
    # - For columns and rows pixels can be directly blitted, always. No state is needed.
    #
    # - For bands we can directly blit if the operator devolves to identity. If not a more
    #   complex blit is needed to perform the band selection as part of its
    #   operation. This choise is recorded in the thus needed, image state.
    #
    # Full elision of a devolved operator can be done in a wrapper around this base
    # constructor.

    def common-setup {
	aktive_uint range = aktive_image_get_@@dimension@@ (srcs->v[0]);

	// could be moved into the cons wrapper created for simplification
	if (param->first >= range)       aktive_failf ("First @@thing@@ >= %d", range);
	if (param->last  >= range)       aktive_failf ("Last @@thing@@ >= %d",  range);
	if (param->first >  param->last) aktive_fail  ("First @@thing@@ is after last");

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));

	// Modify dimension according to parameters
	domain->@@dimension@@ = param->last - param->first + 1;
    }

    switch -exact -- $thing {
	column - row {
	    state -setup {
		@@common-setup@@

		// ... and adjust location
		domain->@@coordinate@@ += param->first;
	    }
	    pixels {
		// @@thing@@ selection and blitting: Plain pass through, always
		aktive_blit_copy0 (block, dst, aktive_region_fetch_area (srcs->v[0], request));
	    }
	}
	band {
	    state -fields {
		aktive_uint passthrough; // Boolean flag controlling fetch behaviour
	    } -setup {
		@@common-setup@@

		// ... and switch the runtime to simpler behaviour when the operator is identity
		state->passthrough = (param->first == 0 && param->last == range);
	    }
	    pixels {
		// @@thing@@ selection and blitting
		aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);
		if (istate->passthrough) {
		    // operator is identity, just blit everything through
		    aktive_blit_copy0 (block, dst, src);
		} else {
		    // non-identity, call the blitter handling just the desired bands
		    aktive_blit_copy0_bands (block, dst, src, param->first, param->last);
		}
	    }
	}
    }
}

##
# # ## ### ##### ######## ############# #####################
## Mirror the image along one of the coordinate axes

operator coordinate {
    op::flip::x x
    op::flip::y y
    op::flip::z z
} {
    note Transformer. Structure. Mirrors the input along the ${coordinate}-axis.

    input keep

    # flips are self-complementary
    simplify for   src/type @self   returns src/child

    # base blitter setup
    set blitspec {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    }
    # ... invert specific axis
    switch -exact -- $coordinate {
	y { lset blitspec 0 2 3 down }
	x { lset blitspec 1 2 3 down }
	z { lset blitspec 2 2 3 down }
    }
    # ... generate code
    blit flipper $blitspec copy

    def rewrite [dict get {
	x {
	    // Flip the request before passing it on.
	    int newx = idomain->width - 1 - aktive_rectangle_get_xmax (request);
	    TRACE ("flip x %d --> (%d-1-%d) %d", request->x, idomain->width, aktive_rectangle_get_xmax (request), newx);
	    request->x = newx;
	}
	y {
	    // Flip the request before passing it on.
	    int newy = idomain->height - 1 - aktive_rectangle_get_ymax (request);
	    TRACE ("flip y %d --> (%d-1-%d) %d", request->y, idomain->width, aktive_rectangle_get_ymax (request), newy);
	    request->y = newy;
	}
	z {
	    // Nothing to flip, depth requests are never partial
	}
    } $coordinate]

    state -setup {
	// The geometry and location are unchanged. Only the internal arrangement of the
	// pixels in memory changes.
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	@@rewrite@@
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	// The @@coordinate@@ axis is scanned in reverse order.
	@@flipper@@
    }
}

##
# # ## ### ##### ######## ############# #####################
## Exchange two axes with each other

operator {coorda coordb coordc} {
    op::swap::xy x y z
    op::swap::xz x z y
    op::swap::yz y z x
} {
    note Transformer. Structure. Exchanges the ${coorda}- and ${coordb}-axes of the input.

    input keep

    # swaps are self-complementary
    simplify for   src/type @self   returns src/child

    # A swap is a mirror along a diagonal. This exchanges two axes.
    # The location is mirrored as well. Mostly.
    # As the `z` location is fixed to `0`, swaps involving it do not
    # fully fit into that setup

    # base blitter setup
    set blitspec {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    }
    # ... swap two axes
    switch -exact -- $coorda$coordb {
	xy { lset blitspec 0 2 0 x ; lset blitspec 1 2 0 y }
	xz { lset blitspec 1 2 0 z ; lset blitspec 2 2 0 x }
	yz { lset blitspec 0 2 0 z ; lset blitspec 2 2 0 y }
    }
    # ... generate code
    blit swapper $blitspec copy

    state -setup {
	// The locations and dimensions for the swapped axes (@@coorda@@, @@coordb@@) are exchanged.

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	aktive_geometry_swap_@@coorda@@@@coordb@@ (domain);
    }
    pixels {
	// Rewrite request
	aktive_rectangle_swap_@@coorda@@@@coordb@@ (request, idomain->depth);

	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	// The        dst @@coorda@@-axis is fed from the src @@coordb@@-axis
	// Vice versa dst @@coordb@@-axis is fed from the src @@coorda@@-axis
	// The @@coordc@@-axis maps as-is
	@@swapper@@
    }
}

##
# # ## ### ##### ######## ############# #####################
## Compress/stretch along one of the coordinate axes.
#
# BEWARE: The compression is a simple decimation. The user is responsible for running a
#         convolution beforehand to avoid/reduce aliasing artifacts.
#
## TODO OPTIMIZATION :: do not query input for full rectangle - ask just for desired points
##                   :: -- because most of the input data is thrown away --
##                   :: NOTE - placement of decimation into runtime functions
##                   :: i.e. ...fetch_decimated ... complicates inputs, making them
##                   :: aware of decimation, i.e. load is on them.

operator {coordinate dimension} {
    op::downsample::x  x width
    op::downsample::y  y height
    op::downsample::z  z depth
} {
    note Transformer. Structure. \
	Return input decimated along the ${coordinate}-axis \
	according to the decimation factor (>= 1).

    input keep

    uint n  Decimation factor, range 2...

    # Factor 1 decimation is no decimation at all
    simplify for  if {$n == 1}  returns src

    # Chains: decimation factors multiply
    simplify for  src/type @self \
	src/value n __n \
	calc __n {$__n * $n} \
	src/pop \
	returns op downsample $coordinate : __n

    # Chains: decimation of a stretch with the same factor is identity
    # The reverse is __not__ true (unrecoverable information loss in the decimation)
    simplify for  src/type op::upsample::$coordinate \
	src/value n __n \
	if {$__n == $n}	src/pop   returns src

    simplify for  src/type op::upsample::${coordinate}rep \
	src/value n __n \
	if {$__n == $n}	src/pop   returns src

    # base blitter setup
    set blitspec {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    }
    # ... stretch specific source axis
    switch -exact -- $coordinate {
	y { lset blitspec 0 2 2 n }
	x { lset blitspec 1 2 2 n }
	z { lset blitspec 2 2 2 n }
    }
    # ... generate code
    blit subsampler $blitspec copy

    def expansion [dict get {
	x {
	    // Rewrite request along X to get enough data from the source
	    request->x     *= n;
	    request->width *= n;
	}
	y {
	    // Rewrite request along Y to get enough data from the source
	    request->y      *= n;
	    request->height *= n;
	}
	z {
	    // Nothing to rewrite for z, depth
	}
    } $coordinate]

    state -setup {
	// could be moved into the cons wrapper created for simplification
	if (param->n == 0) aktive_fail ("Rejecting undefined decimation by 0");

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	// Modify dimension according to parameter
	domain->@@dimension@@ = (domain->@@dimension@@ / param->n) +
		(0 != (domain->@@dimension@@ % param->n));
    }
    # NOTE: At higher sampling factors it becomes more sensible to fetch individual points
    # from the source, as an ever higher percentage of the generated data will be thrown
    # away here. And if the input is expensive efficiency will be a botch.
    pixels {
	aktive_uint n = param->n;
	@@expansion@@
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	// The source @@coordinate@@ axis is scanned N times faster than the destination
	@@subsampler@@
    }
}

operator {coordinate dimension} {
    op::upsample::x  x width
    op::upsample::y  y height
    op::upsample::z  z depth
} {
    note Transformer. Structure. \
	Returns input stretched along the ${coordinate}-axis \
	according to the stretching factor (>= 1).

    note The gaps are set to the specified fill value.

    input keep

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

    def shrink [dict get {
	x {
	    // Note: C-semantics for `%`. Tcl semantics yield `(-i)%n`.
	    #define CORR(i,n)  (((n) - ((i) % (n))) % (n))
	    // Shift correction to snap request into the sample grid
	    int grid = CORR (request->x, n);
	    #undef CORR
	    TRACE ("Correction: %d (%d in %d)", grid, request->x, n);

	    // Rewrite request to the input coordinates and dimensions
	    request->x      = (request->x + grid) / n;
	    request->width /= n;

	    // Note: grid is the starting point in the destination area (rooted at 0).
	}
	y {
	    // Note: C-semantics for `%`. Tcl semantics yield `(-i)%n`.
	    #define CORR(i,n)  (((n) - ((i) % (n))) % (n))
	    // Shift correction to snap request into the sample grid
	    int grid = CORR (request->y, n);
	    #undef CORR
	    TRACE ("Correction: %d (%d in %d)", grid, request->y, n);

	    // Rewrite request to the input coordinates and dimensions
	    request->y       = (request->y + grid) / n;
	    request->height /= n;

	    // Note: grid is the starting point in the destination area (rooted at 0).
	}
	z {
	    // Nothing to rewrite for z, depth
	}
    } $coordinate]

    pixels {
	aktive_uint n = param->n;

	@@shrink@@
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	// Blank the region with the fill value first. This way the coming blitter
	// does not have to concern itself with the gaps, just the values to set.
	aktive_blit_fill (block, dst, param->fill);

	// The destination @@coordinate@@ axis is scanned N times faster than the source.
	// The destination location is snapped forward to the grid.
	@@upsampler@@
    }
}

operator {coordinate dimension} {
    op::upsample::xrep  x width
    op::upsample::yrep  y height
    op::upsample::zrep  z depth
} {
    note Transformer. Structure. \
	Returns input stretched along the ${coordinate}-axis \
	according to the stretching factor (>= 1), replicating input.

    input keep

    uint n  Stretch factor, range 2...

    # Factor 1 stretching is no stretch at all
    simplify for  if {$n == 1}  returns src

    # Chains: stretch factors multiply
    simplify for  src/type @self \
	src/value n __n \
	calc __n {$__n * $n} \
	src/pop \
	returns op upsample ${coordinate}rep : __n

    state -setup {
	// could be moved into the cons wrapper created for simplification
	if (param->n == 0) aktive_fail ("Rejecting undefined stretching by 0");

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	// Modify dimension according to parameter
	domain->@@dimension@@ *= param->n;
    }

    # The gridding here is more complex because we have fill the gaps ourselves. We cannot
    # fast-step in dst, under control of src. Instead we have to step normal in dst, and
    # step fractionally in the source. IOW step the source once for every N steps in the
    # dst. The modulo of the start value in the interval N provides the initial fraction
    # (called the `phase` below).
    ##
    # DST - example: x, factor 5
    #
    # 0         1         2         3         4
    # 0123456789012345678901234567890123456789
    # S....S....S....S....S....S....S....S....
    # 0    1111122222333334    5    6    7
    #        |--------|
    # 01234567
    #  |-|
    #
    # Request: 7,10 = 7..16
    # /5:      1,3  = 1..3
    # Phase:   2           (7%5)
    # NOTE: Input range is +1 wider than a plain /N results in.

    # base blitter setup
    set blitspec {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
	{DD {z 0 1 up} {z 0 1 up}}
    }
    # ... fractionalize source of specific axis
    switch -exact -- $coordinate {
	y { lset blitspec 0 2 2 1/n }
	x { lset blitspec 1 2 2 1/n }
	z { lset blitspec 2 2 2 1/n }
    }
    # ... generate code
    blit upsampler $blitspec copy

    def phasor [dict get {
	x {
	    #define PHASE1 phase
	    aktive_uint phase = request->x % n;

	    TRACE ("Phase: %d (%d in %d)", phase, request->x, n);

	    // Rewrite request along X to get enough from the source
	    request->x     /= n;
	    request->width /= n; request->width ++;
	}
	y {
	    #define PHASE0 phase
	    aktive_uint phase = request->y % n;

	    TRACE ("Phase: %d (%d in %d)", phase, request->y, n);

	    // Rewrite request along Y to get enough from the source
	    request->y      /= n;
	    request->height /= n; request->height ++;
	}
	z {
	    #define PHASE2 0
	}
    } $coordinate]

    pixels {
	aktive_uint n = param->n;

	@@phasor@@
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	// The source @@coordinate@@ axis is scanned N times slower
	// than the source via fractional stepping.
	// The destination location is snapped backward to the grid.
	@@upsampler@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
