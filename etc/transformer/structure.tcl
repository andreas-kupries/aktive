## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Select a range of rows, columns, bands

operator {thing coordinate dimension} {
    op::select::x column x width
    op::select::y row    y height
    op::select::z band   z depth
} {
    note Choose and return a contiguous subset of the input's ${thing}s.
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
		state->passthrough = (param->first == 0 || param->last == range);
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
    input keep ;#-pass

    # flips are self-complementary
    simplify for   src/type @self   returns src/child

    # Set up the loop configuration.
    # Default is regular scan for all axes.
    # After that the flipped axis is configured for reverse scan.

    set xnext ++ ; set xinit SRC.x
    set ynext ++ ; set yinit SRC.y
    set znext ++ ; set zinit 0

    switch -exact -- $coordinate {
	x { set xnext -- ; set xinit "(SRC.x + SRC.width  - 1)" }
	y { set ynext -- ; set yinit "(SRC.y + SRC.height - 1)" }
	z { set znext -- ; set zinit "(SRC.depth - 1)"          }
    }

    state -setup {
	// The geometry and location are unchanged. Only the internal arrangement of the
	// pixels in memory changes.
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	// The @@coordinate@@ axis is scanned in reverse order.
	@@blitcore@@
    }   XSRC  srcx   YSRC  srcy   ZSRC  srcz   \
	XINIT $xinit YINIT $yinit ZINIT $zinit \
	XNEXT $xnext YNEXT $ynext ZNEXT $znext
}

##
# # ## ### ##### ######## ############# #####################
## Exchange two axes with each other

operator {coorda coordb coordc} {
    op::swap::xy x y z
    op::swap::xz x z y
    op::swap::yz y z x
} {
    input keep ;#-pass

    # swaps are self-complementary
    simplify for   src/type @self   returns src/child

    # A swap is a mirror along a diagonal. This exchanges two axes.
    # The location is mirrored as well. Mostly.
    # As the `z` location is fixed to `0`, swaps involving it do not
    # fully fit into that setup

    # Set up the loop configuration.
    switch -exact -- $coorda$coordb {
	xy {
	    lassign {srcy SRC.y ++} xsrc xinit xnext
	    lassign {srcx SRC.x ++} ysrc yinit ynext
	    lassign {srcz 0     ++} zsrc zinit znext
	}
	xz {
	    lassign {srcy SRC.y ++} ysrc yinit ynext
	    lassign {srcx SRC.x ++} zsrc zinit znext
	    lassign {srcz 0     ++} xsrc xinit xnext
	}
	yz {
	    lassign {srcy SRC.y ++} zsrc zinit znext
	    lassign {srcx SRC.x ++} xsrc xinit xnext
	    lassign {srcz 0     ++} ysrc yinit ynext
	}
    }

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
	// The last axis  @@coordc@@ maps as-is
	@@blitcore@@
    }   XSRC  $xsrc  YSRC  $ysrc  ZSRC  $zsrc  \
	XINIT $xinit YINIT $yinit ZINIT $zinit \
	XNEXT $xnext YNEXT $ynext ZNEXT $znext
}

##
# # ## ### ##### ######## ############# #####################
## Compress/stretch along one of the coordinate axes.
#
# BEWARE: The compression is a simple decimation. The user is responsible for running a
#         convolution beforehand to avoid/reduce aliasing artifacts.

nyi operator {
    op::downsample::x
    op::downsample::y
    op::downsample::z
} {
    input keep-pass

    uint n  Sampling factor, range 2...

    # %% TODO %% specify implementation
}

nyi operator {
    op::upsample::x
    op::upsample::y
    op::upsample::z
} {
    input keep-pass

    uint      n     Sampling factor, range 2...
    double? 0 fill  Pixel fill value

    # %% TODO %% specify implementation
}

nyi operator {
    op::upsample::xrep
    op::upsample::yrep
    op::upsample::zrep
} {
    input keep-pass

    uint n  Sampling factor, range 2...

    # %% TODO %% specify implementation
}

##
# # ## ### ##### ######## ############# #####################
::return
