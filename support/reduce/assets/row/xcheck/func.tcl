
# this row reducer will be used only for testing. it runs all the available
# implementations and verifies that their results matches the first (baseline)
# implementation. IOW it ensures that we do not use a fast yet wrong
# implementation.

def-func row crosscheck [apply {{} {
    # signature = func (double* dst, double* src, uint count, uint stride)
    lappend lines {
	aktive_uint band, column, pixels = count, depth = stride, n = pixels * depth;
	double* rchecked;
	char*   rname;
    }
    #lappend lines { fprintf(stderr, "xcheck/<<<opname>>> (pix=%d, dep=%d) ______________________________________________\n", pixels, depth); }
    # execute all preceding implementations
    foreach variant [for-axis row] {
	set alloc "    double *r$variant = NALLOC (double, depth);"
	#set debuga " fprintf(stderr, \"${variant}/<<<opname>>> (pix=%d, dep=%d) ___ START\\n\", pixels, depth);"
	set debuga ""
	set run   " aktive_reduce_rows_${variant}_<<<opname>>> (r$variant, src, pixels, depth);"
	#set debugb " fprintf(stderr, \"${variant}/<<<opname>>> _________________________ DONE\\n\");"
	set debugb ""
	lappend lines "$alloc$debuga$run$debugb"
    }
    # cross check each implementation against the first, except the first. the
    # first is considered to be the good reference the others have to match.
    foreach variant [lassign [for-axis row] first] {
	#lappend lines "    fprintf(stderr, \"xcheck/<<<opname>>>: $variant versus baseline\\n\");"
	lappend lines [map {
	    // / / // /// ///// //////// ///////////// /////////////////////
	    // check %%variant%% against baseline
	    for (band = 0; band < depth; band ++) {
		if (r%%variant%%[band] == rbaseline[band]) continue; // OK
		// difference found, failed, print source, results, then stop
		rname    = "%%variant%%/<<<opname>>>";
		rchecked = r%%variant%%;
		goto dump;
	    }
	} %%variant%% $variant]
	#lappend lines "    fprintf(stderr, \"xcheck/${variant}/<<<opname>>> OK\\n\");"
    }
    lappend lines {
	if (0) {
	    // / / // /// ///// //////// ///////////// /////////////////////
	    // rchecked = pointer to result buffer of checked variant
	    // rname    = name of checked variant
	dump:
	    fprintf (stderr, "xcheck/%s/<<<opname>>> FAIL\n", rname);
	    fprintf (stderr, "    width  = %d\n", pixels);
	    fprintf (stderr, "    depth  = %d\n", depth);
	    fprintf (stderr, "for band   = %d\n", band);
	    fprintf (stderr, "MISMATCH (expected %f <> got %f)\n",
		     rbaseline[band], rchecked[band]);
	    // / / // /// ///// //////// ///////////// /////////////////////
	    // show input where baseline and variant disagreed
	    fprintf (stderr, "    src[%d] = {", band);
	    for (column = 0; column < pixels; column++) {
		fprintf (stderr, " %f", src[column*depth+band]);
	    }
	    fprintf (stderr, " }\n");
	    ASSERT (0, "MISMATCH");
	}
    }
    # use the result from the last implementation as the actual result, good or bad
    set chosen [lindex [for-axis row] end]
    #lappend lines "    fprintf(stderr, \"xcheck/${chosen}/<<<opname>>> SAVE AS RESULT\\n\");"
    lappend lines "    memcpy (dst, r$chosen, depth*sizeof(double));"
    # release the internal temp memory
    foreach variant [for-axis row] {
	#lappend lines "    fprintf(stderr, \"xcheck/${variant}/<<<opname>>> RELEASE\\n\");"
	lappend lines "    FREE (r$variant);"
    }
    # deliver generated code
    #lappend lines {    fprintf(stderr, "xcheck/<<<opname>>> RETURN\n"); }
    return [join $lines "\n\t"]
} reduce}]
