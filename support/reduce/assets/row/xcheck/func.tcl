
# this row reducer will be used only for testing. it runs all the available
# implementations and verifies that their results matches the first (baseline)
# implementation. IOW it ensures that we do not use a fast yet wrong
# implementation.

def-func row crosscheck {
    lappend map @name@ $name
} [apply {{} {
    lappend lines {
	aktive_uint band, column, n = pixels * depth;
	double* rchecked;
	char*   rname;
    }
    # execute all preceding implementations
    foreach variant [for-axis row] {
	lappend lines "double *r$variant = NALLOC (double, count); aktive_reduce_rows_${variant}_@name@ (r$variant, src, pixels, depth);"
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
		rname    = "%%varian%%/@name@";
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
	    fprintf (stderr, "MISMATCH on band %d - (%f != %f)\n", band, rbaseline[band], rchecked[band]);
	    fprintf (stderr, "src[%d] = {", band);
	    for (column = 0; column < pixels; column++) {
		fprintf (stderr, " %f", src[column*depth+band]);
	    }
	    fprintf (stderr, " }\n");
	    ASSERT (0, "MISMATCH");
	}
    }
    # use the result from the last implementation as the actual result
    lappend lines "memcpy (dst, [lindex [for-axis row] end], depth*sizeof(double));"
    # release the internal temp memory
    foreach name [for-axis row] {
	lappend lines "FREE (r$name);"
    }
    # deliver generated code
    return [join $lines "\n\t"]
} reduce}]
