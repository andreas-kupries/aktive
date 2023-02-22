## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Stretch along one of the coordinate axes, by replicating input points

operator {coordinate dimension} {
    op::upsample::xrep  x width
    op::upsample::yrep  y height
    op::upsample::zrep  z depth
} {
    note Transformer. Structure. \
	Returns input stretched along the ${coordinate}-axis \
	according to the stretching factor (>= 1), replicating input.

    input

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
