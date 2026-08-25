
# this band reducer will be used only for testing. it runs all the available
# implementations and verifies that their results matches the first (baseline)
# implementation. IOW it ensures that we do not use a fast yet wrong
# implementation.

def-func band crosscheck {
    lappend map @name@ $name
} [apply {{} {
    lappend lines "aktive_uint k, n = count * stride;"
    # execute all preceding implementations
    foreach name [for-axis band] {
	lappend lines "double *$name = NALLOC (double, count); aktive_reduce_bands_${name}_@name@ ($name, src, count, stride);"
    }
    # cross check each implementation against the first, except the first. the
    # first is considered to be the good reference the others have to match.
    foreach name [lassign [for-axis band] first] {
	lappend lines "// check band `$name` against `$first`"
	lappend lines "for (k = 0; k < count; k++) \{"
	lappend lines "    if (${name}\[k] == ${first}\[k]) continue; // OK"
	lappend lines "    // difference found, failed, print source, results, and stop"
	lappend lines "    fprintf (stderr, \"$name\\n\");"
	lappend lines "    fprintf (stderr, \"width    = %d\\n\", count);"
	lappend lines "    fprintf (stderr, \"depth    = %d\\n\", stride);"
	lappend lines "    fprintf (stderr, \"mismatch ! %d %f != %f\\n\", k, ${first}\[k], ${name}\[k]);"
	lappend lines "    aktive_uint j;"
	lappend lines "    fprintf (stderr, \"src\[%d] = \{\", k);"
	lappend lines "    for (j = 0; j < stride; j++) \{"
	lappend lines "        fprintf (stderr, \" %f\", src\[k*stride+j]);"
	lappend lines "    \}"
	lappend lines "    fprintf (stderr, \" \}\\n\");"
	lappend lines "    ASSERT (0, \"MISMATCH\");"
	lappend lines "\}"
    }
    # use the result from the last implementation as the actual result
    lappend lines "memcpy (dst, [lindex [for-axis band] end], count*sizeof(double));"
    # release the internal temp memory
    foreach name [for-axis band] {
	lappend lines "FREE ($name);"
    }
    # deliver generated code
    return [join $lines "\n\t"]
} reduce}]
