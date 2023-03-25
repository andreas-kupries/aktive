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

    note Returns image containing a contiguous subset of the input's ${thing}s.

    note The result has a properly reduced $dimension.
    note The other two dimension are unchanged.
    note The 2D location of the first cell of the input going into the
    note result is the location of the result.

    input

    uint first  Input's first $thing to be placed into the result
    uint last   Input's last $thing to be placed into the result

    # As an image follows and we simplify (see below) we cannot make `last` optional.
    # The simplification is done in a Tcl level wrapper, and `proc` does not support
    # optional arguments in the middle of the set. (critcl::cproc does).

    simplify for  \
	if {$first == 0} \
	src/attr $dimension __range if {$last == ($__range - 1)} \
	returns src

    # |---------------|
    #   |a-------b|
    #      |c--d|
    # => a+c .. b-d+1

    # Chained selects can be reduced to a single select combining the borders.
    simplify for \
	src/type @self \
	src/value first __f \
	calc __l {$__f + $last} \
	calc __f {$__f + $first} \
	src/pop \
	returns op select $coordinate : __f __l

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
	if (param->first >  param->last) \
	    aktive_failf ("First @@thing@@ %d is after last %d",
			  param->first, param->last);

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
::return
