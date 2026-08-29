
# this band reducer will be used only for testing. it runs all the available
# implementations and verifies that their results matches the first (baseline)
# implementation. IOW it ensures that we do not use a fast yet wrong
# implementation.

def-func band crosscheck [apply {{} {
    lappend lines "aktive_uint pixels = count, depth = stride, n = pixels * depth;"
    # execute all preceding implementations
    foreach variant [for-axis band] {
	lappend lines "double *r$variant = NALLOC (double, pixels); aktive_reduce_bands_${variant}_<<<opname>>> (r$variant, src, pixels, depth);"
    }
    lappend lines "aktive_uint pix;"
    # cross check each implementation against the first, except the first. the
    # first is considered to be the good reference the others have to match.
    foreach variant [lassign [for-axis band] first] {
	lappend lines "// check band `$variant` against `$first`"
	lappend lines "for (pix = 0; pix < pixels; pix ++) \{"
	lappend lines "    if (r${variant}\[pix] == r${first}\[pix]) continue; // OK"
	lappend lines "    // difference found, failed, print source, results, and stop"
	lappend lines "    fprintf (stderr, \"band/$variant/<<<opname>>>\\n\");"
	lappend lines "    fprintf (stderr, \"width    = %d\\n\", pixels);"
	lappend lines "    fprintf (stderr, \"depth    = %d\\n\", depth);"
	lappend lines "    fprintf (stderr, \"MISMATCH @ %d expected %f != got %f\\n\", pix, r${first}\[pix], r${variant}\[pix]);"
	lappend lines "    fprintf (stderr, \"src\[%d] = \{\", pix);"
	lappend lines "    aktive_uint band; for (band = 0; band < depth; band ++) \{ fprintf (stderr, \" %f\", src\[pix*depth+band]); \}"
	lappend lines "    fprintf (stderr, \" \}\\n\");"
	lappend lines "    ASSERT (0, \"MISMATCH\\n\");"
	lappend lines "\}"
    }
    # use the result from the last implementation as the actual result
    set chosen [lindex [for-axis band] end]
    lappend lines "memcpy (dst, r$chosen, pixels*sizeof(double));"
    # release the internal temp memory
    foreach variant [for-axis band] {
	lappend lines "FREE (r$variant);"
    }
    # deliver generated code
    return [join $lines "\n\t"]
} reduce}]
