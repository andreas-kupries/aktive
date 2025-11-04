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
    section transform structure

    if {$coordinate in {x y}} {
	example {
	    aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	    @1 from 20 to 50
	}
    }

    note Returns image containing a contiguous subset of the input's ${thing}s.

    note The result has a properly reduced $dimension.
    note The other two dimension are unchanged.
    note The 2D location of the first cell of the input going into the
    note result is the location of the result.

    uint       from The input's first $thing to be placed into the result.
    uint? from to   The input's last $thing to be placed into the result. \
	If not specified defaults to the first.

    input

    simplify for  \
	if {$from == 0} \
	src/attr $dimension __range if {$to == ($__range - 1)} \
	returns src

    # |---------------|
    #   |a-------b|
    #      |c--d|
    # => a+c .. b-d+1

    # Chained selects can be reduced to a single select combining the borders.
    simplify for \
	src/type @self \
	src/value from __f \
	calc __l {$__f + $to} \
	calc __f {$__f + $from} \
	src/pop \
	returns op select $coordinate : from __f to __l

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
	if (param->from >= range)      aktive_failf ("First @@thing@@ >= %d", range);
	if (param->to  >= range)       aktive_failf ("Last @@thing@@ >= %d",  range);
	if (param->from >  param->to) \
	    aktive_failf ("First @@thing@@ %d is after last %d",
			  param->from, param->to);

	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));

	// Modify dimension according to parameters
	domain->@@dimension@@ = param->to - param->from + 1;
    }

    switch -exact -- $thing {
	column - row {
	    state -setup {
		@@common-setup@@

		// ... and adjust location
		domain->@@coordinate@@ += param->from;
	    }
	    pixels {
		// @@thing@@ selection and blitting: Plain pass through, always
		aktive_blit_copy0 (block, dst, aktive_region_fetch_area (0, request));
	    }
	}
	band {
	    state -fields {
		aktive_uint passthrough; // Boolean flag controlling fetch behaviour
	    } -setup {
		@@common-setup@@

		// ... and switch the runtime to simpler behaviour when the operator is identity
		state->passthrough = (param->from == 0 && param->to == range);
	    }
	    pixels {
		// @@thing@@ selection and blitting
		aktive_block* src = aktive_region_fetch_area (0, request);
		if (istate->passthrough) {
		    // operator is identity, just blit everything through
		    aktive_blit_copy0 (block, dst, src);
		} else {
		    // non-identity, call the blitter handling just the desired bands
		    aktive_blit_copy0_bands (block, dst, src, param->from, param->to);
		}
	    }
	}
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
