
# this row reducer will be used only for testing. it runs all the available
# implementations and verifies that their results matches the first (baseline)
# implementation. IOW it ensures that we do not use a fast yet wrong
# implementation.

def-func row crosscheck {
    placeholder @name@ $name
} [apply {{} {
    lappend lines {
	aktive_uint band, column, depth = stride, pixels = count, n = pixels * depth;
	double* rchecked;
	char*   rname;
    }
    # lappend lines { fprintf(stderr, "xcheck/@name@ (pix=%d, dep=%d) ______________________________________________\n", pixels, depth); }
    # execute all preceding implementations
    foreach variant [for-axis row] {
	set alloc "double *r$variant = NALLOC (double, count);"
	#set debug " fprintf(stderr, \"${variant}/@name@ (pix=%d, dep=%d)\\n\", pixels, depth);"
	set debug ""
	set run   " aktive_reduce_rows_${variant}_@name@ (r$variant, src, pixels, depth);"
	lappend lines "$alloc$debug$run"
    }
    # cross check each implementation against the first, except the first. the
    # first is considered to be the good reference the others have to match.
    foreach variant [lassign [for-axis row] first] {
	lappend lines [map {
	    // / / // /// ///// //////// ///////////// /////////////////////
	    // check %%variant%% against baseline
	    for (band = 0; band < depth; band++) {
		if (r%%variant%%[band] == rbaseline[band]) continue; // OK
		// difference found, failed, print source, results, then stop
		rname    = "%%variant%%/@name@";
		rchecked = r%%variant%%;
		goto dump;
	    }
	} %%variant%% $variant]
    }
    lappend lines {
	if (0) {
	    // / / // /// ///// //////// ///////////// /////////////////////
	    // rchecked = pointer to result buffer of checked variant
	    // rname    = name of checked variant
	dump:
	    fprintf (stderr, "FAIL %s\n",       rname);
	    fprintf (stderr, "  width  = %d\n", pixels);
	    fprintf (stderr, "  depth  = %d\n", depth);
	    fprintf (stderr, "  band   = %d\n", band);
	    fprintf (stderr, "MISMATCH (expected %f != got %f)\n",
		     rbaseline[band], rchecked[band]);
	    fprintf (stderr, "src[%d] = {", band);
	    for (column = 0; column < pixels; column++) {
		fprintf (stderr, " %f", src[column*depth+band]);
	    }
	    fprintf (stderr, " }\n");
	    ASSERT (0, "MISMATCH");
	}
    }
    # use the result from the last implementation as the actual result
    lappend lines "memcpy (dst, r[lindex [for-axis row] end], depth*sizeof(double));"
    # release the internal temp memory
    foreach name [for-axis row] {
	lappend lines "FREE (r$name);"
    }
    # deliver generated code
    return [join $lines "\n\t"]
} reduce}]
