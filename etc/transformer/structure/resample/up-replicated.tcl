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
    section transform structure

    note Returns image where the input is stretched along the ${coordinate}-axis \
	according to the stretching factor (>= 1), and the gaps are filled by \
	replicating the preceding non-gap pixel.

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

    state -fields {
	aktive_uint max; // original max
    } -setup {
	// could be moved into the cons wrapper created for simplification
	if (param->n == 0) aktive_fail ("Rejecting undefined stretching by 0");

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	// Modify dimension according to parameter
	state->max = aktive_geometry_get_@@coordinate@@max (domain);
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

    def phasor-core {
	aktive_uint phase = subrequest.@@coordinate@@ % n;

	TRACE ("Phase: %d (%d in %d)", phase, subrequest.@@coordinate@@, n);

	// Rewrite request along the @coordinate@@-axis to get enough from the source
	subrequest.@@coordinate@@ /= n;
	subrequest.@@dimension@@ /= n;
	subrequest.@@dimension@@ ++;

	// And prevent overshooting the upper border of the input
	int excess = aktive_rectangle_get_@@coordinate@@max (&subrequest) - istate->max;
	if (excess > 0) { subrequest.@@dimension@@ -= excess; }
    }

    def phasor [dict get {
	x {
	    #define PHASE1 phase
	    @@phasor-core@@
	}
	y {
	    #define PHASE0 phase
	    @@phasor-core@@
	}
	z {
	    #define PHASE2 0
	}
    } $coordinate]

    pixels {
	aktive_uint n = param->n;
	aktive_rectangle_def_as (subrequest, request);
	@@phasor@@
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], &subrequest);

	// The source @@coordinate@@ axis is scanned N times slower
	// than the source via fractional stepping.
	// The destination location is snapped backward to the grid.
	@@upsampler@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
