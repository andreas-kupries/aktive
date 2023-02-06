## -*- mode: tcl ; fill-column: 90 -*-
# # # ## ### ##### ######## ############# #####################
## Image transformer - Single input image, possibly parameters
##
## Structural changes

## # # ## ### ##### ######## ############# #####################

## Note that this code does NOT check if the selection encompasses the entirety of the input.  It
## does optimize the pixel fetch behaviour (switching to pass through)
##
## Note however that nothing prevents the writing of a Tcl level wrapper which detetcs this
## condition and then passes the input through instead of creating the transformer.
##
## Having this kind of DAG optimization through eliding superfluous operators in the policy level
## should actually make the refcount management much easier (default mode `keep`, and the various
## pass/ignore combinations become irrelevant)

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

    input keep ;#-pass

    uint         first  Input's first $thing to be placed into the result
    uint? _first last   Input's last $thing to be placed into the result

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
## # # ## ### ##### ######## ############# #####################
::return
