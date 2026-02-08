# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############
## Code fragments for the vector functions

proc dedent {s} { string map \
		      [list \
			   "\t\t    " "\t\t"   \
			   "\t\t"     "\t    " \
			   "\t    "   "\t"   \
			   "\t"       "    " \
			   "    "     ""     \
			  ] $s }

proc reducer-def {name decl impl} {
    global rimplementations ; lappend rimplementations $name
    upvar 1 ${name}decl __decl ; set __decl [string trim $decl]
    upvar 1 ${name}impl __impl ; set __impl [dedent      $impl]
}

proc reducer-clear {} {
    global rimplementations ; set rimplementations {}
}

# # ## ### ##### ######## #############
## baseline - emulate the inner loop of the existing blitter setup

reducer-def base {
    extern void aktive_reduce_row_bands_base_@name@ (double *d, double* s, aktive_uint width, aktive_uint depth);
} {
    void aktive_reduce_row_bands_base_@name@ (double *d, double* s, aktive_uint width, aktive_uint depth) {
	TRACE_FUNC("(dst %p[%d], src %p[%dx%d])", d, width, s, width, depth);
	// d - destination row start - single band
	// s - source      row start - `depth` bands
	// width - row width, source and destination
	// depth - row depth, source only
	aktive_uint k;
	for (k = 0; k < width; k++, d ++, s += depth) {
	    *d = aktive_reduce_@name@ (s, depth, 1, 0 /* client data, ignored */);
	}
	TRACE_RETURN_VOID;
    }
}

# # ## ### ##### ######## #############
## special - handle the common depths with custom code (fully unrolled inner/band loop)

reducer-def special {
    extern void aktive_reduce_row_bands_special_@name@ (double *d, double* s, aktive_uint width, aktive_uint depth);
} {
    void aktive_reduce_row_bands_special_@name@ (double *d, double* s, aktive_uint width, aktive_uint depth) {
	TRACE_FUNC("(dst %p[%d], src %p[%dx%d])", d, width, s, width, depth);
	// d - destination row start - single band
	// s - source      row start - `depth` bands
	// width - row width, source and destination
	// depth - row depth, source only

	@once@

	#define PIXELS(step) aktive_uint k; for (k = 0; k < width; k++, d++, s += (step))
	#define BANDS aktive_uint j; for (j = 0; j < depth; j++)

	switch (depth) {
	    case 1: {
		// note - due to highlevel simplifications this case should not be reached
		// except in benchmarking
		TRACE ("depth %d unrolled/none", depth);
		PIXELS(1) { *d = @single@; }
	    } ; break;
	    case 2: {
		TRACE ("depth %d unrolled/2", depth);
		PIXELS(2) {
		    @setup@
		    @reduce0@
		    @reduce1@
		    @final@
		}
	    } ; break;
	    case 3: {
		TRACE ("depth %d unrolled/3", depth);
		PIXELS(3) {
		    @setup@
		    @reduce0@
		    @reduce1@
		    @reduce2@
		    @final@
	        }
	    } ; break;
	    case 4: {
		TRACE ("depth %d unrolled/4", depth);
		PIXELS(4) {
		    @setup@
		    @reduce0@
		    @reduce1@
		    @reduce2@
		    @reduce3@
		    @final@
	        }
	    } ; break;
	    default: {
		TRACE ("depth %d unrolled/none, generic", depth);
		PIXELS(1) {
		    @setup@
		    BANDS {
			@reduce@
		    }
		    @final@
	        }
	    } ; break;
	}

	#undef BANDS
	#undef PIXELS
	TRACE_RETURN_VOID;
    }
}

# # ## ### ##### ######## #############
## unroll4 - unroll the pixel loop as well to handle more than one pixel per iteration

reducer-def unroll4 {
    extern void aktive_reduce_row_bands_unroll4_@name@ (double *d, double* s, aktive_uint width, aktive_uint depth);
} {
    void aktive_reduce_row_bands_unroll4_@name@ (double *d, double* s, aktive_uint width, aktive_uint depth) {
	TRACE_FUNC("(dst %p[%d], src %p[%dx%d])", d, width, s, width, depth);
	// d - destination row start - single band
	// s - source      row start - `depth` bands
	// width - row width, source and destination
	// depth - row depth, source only

	@once@

	#define PIXELS4(step) for (k = width; k > 4; k-= 4, d += 4, s += 4*(step))
	#define PIXELS2(step) for (         ; k > 2; k-= 2, d += 2, s += 2*(step))
	#define PIXELS1(step) for (         ; k > 0; k--  , d ++  , s +=   (step))
	#define BANDS aktive_uint j; for (j = 0; j < depth; j++)

	const aktive_uint d0 = 0;
	const aktive_uint d1 = d0 + depth;
	const aktive_uint d2 = d1 + depth;
	const aktive_uint d3 = d2 + depth;
	const aktive_uint d4 = d3 + depth;

	switch (depth) {
	    case 1: {
		// note - due to highlevel simplifications this case should not be reached
		// except in benchmarking
		TRACE ("depth %d unrolled/none", depth);
		aktive_uint k;
		PIXELS4(1) { d[0] = @single0@; d[1] = @single1@; d[2] = @single2@; d[3] = @single3@; }
		PIXELS2(1) { d[0] = @single0@; d[1] = @single1@; }
		PIXELS1(1) { *d   = @single@; }
	    } ; break;
	    case 2: {
		TRACE ("depth %d unrolled/2", depth);
		aktive_uint k;
		PIXELS4(2) {
		    @setup0@
		    @setup1@
		    @setup2@
		    @setup3@
		    @reduce0/0@
		    @reduce1/0@
		    @reduce2/0@
		    @reduce3/0@
		    @reduce0/1@
		    @reduce1/1@
		    @reduce2/1@
		    @reduce3/1@
		    @final0@
		    @final1@
		    @final2@
		    @final3@
		}
		PIXELS2(2) {
		    @setup0@
		    @setup1@
		    @reduce0/0@
		    @reduce1/0@
		    @reduce0/1@
		    @reduce1/1@
		    @final0@
		    @final1@
		}
		PIXELS1(2) {
		    @setup@
		    @reduce0@
		    @reduce1@
		    @final@
		}
	    } ; break;
	    case 3: {
		TRACE ("depth %d unrolled/3", depth);
		aktive_uint k;
		PIXELS4(3) {
		    @setup0@
		    @setup1@
		    @setup2@
		    @setup3@
		    @reduce0/0@
		    @reduce1/0@
		    @reduce2/0@
		    @reduce3/0@
		    @reduce0/1@
		    @reduce1/1@
		    @reduce2/1@
		    @reduce3/1@
		    @reduce0/2@
		    @reduce1/2@
		    @reduce2/2@
		    @reduce3/2@
		    @final0@
		    @final1@
		    @final2@
		    @final3@
		}
		PIXELS2(3) {
		    @setup0@
		    @setup1@
		    @reduce0/0@
		    @reduce1/0@
		    @reduce0/1@
		    @reduce1/1@
		    @reduce0/2@
		    @reduce1/2@
		    @final0@
		    @final1@
		}
		PIXELS1(3) {
		    @setup@
		    @reduce0@
		    @reduce1@
		    @reduce2@
		    @final@
	        }
	    } ; break;
	    case 4: {
		TRACE ("depth %d unrolled/4", depth);
		aktive_uint k;
		PIXELS4(4) {
		    @setup0@
		    @setup1@
		    @setup2@
		    @setup3@
		    @reduce0/0@
		    @reduce1/0@
		    @reduce2/0@
		    @reduce3/0@
		    @reduce0/1@
		    @reduce1/1@
		    @reduce2/1@
		    @reduce3/1@
		    @reduce0/2@
		    @reduce1/2@
		    @reduce2/2@
		    @reduce3/2@
		    @reduce0/3@
		    @reduce1/3@
		    @reduce2/3@
		    @reduce3/3@
		    @final0@
		    @final1@
		    @final2@
		    @final3@
		}
		PIXELS2(4) {
		    @setup0@
		    @setup1@
		    @reduce0/0@
		    @reduce1/0@
		    @reduce0/1@
		    @reduce1/1@
		    @reduce0/2@
		    @reduce1/2@
		    @reduce0/3@
		    @reduce1/3@
		    @final0@
		    @final1@
		}
		PIXELS1(4) {
		    @setup@
		    @reduce0@
		    @reduce1@
		    @reduce2@
		    @reduce3@
		    @final@
	        }
	    } ; break;
	    default: {
		TRACE ("depth %d unrolled/none, generic", depth);
		aktive_uint k;
		PIXELS4(1) {
		    @setup0@
		    @setup1@
		    @setup2@
		    @setup3@
		    BANDS {
			@reduce0*@
			@reduce1*@
			@reduce2*@
			@reduce3*@
		    }
		    @final0@
		    @final1@
		    @final2@
		    @final3@
	        }
		PIXELS2(1) {
		    @setup0@
		    @setup1@
		    BANDS {
			@reduce0*@
			@reduce1*@
		    }
		    @final0@
		    @final1@
	        }
		PIXELS1(1) {
		    @setup@
		    BANDS { @reduce@ }
		    @final@
	        }
	    } ; break;
	}

	#undef BANDS
	#undef PIXELS
	TRACE_RETURN_VOID;
    }
}

# # ## ### ##### ######## #############
## all - run all the implementations and compare results

proc rimpl {} {
    global rimplementations
    # run all implementations
    foreach name $rimplementations {
	lappend lines "double *$name = NALLOC (double, width); aktive_reduce_row_bands_${name}_@name@ ($name, s, width, depth);"
    }
    # cross check each against the first. first is not checked, seen as the ok reference
    foreach name [lassign $rimplementations first] {
	lappend lines "// check $name against $first"
	lappend lines "for (k = 0; k < width; k++) \{"
	lappend lines "    if (${name}\[k] == ${first}\[k]) continue;"
	lappend lines "    // difference found, failed, print source, results, then stop"
	lappend lines "    fprintf (stderr, \"$name\\n\");"
	lappend lines "    fprintf (stderr, \"width    = %d\\n\", width);"
	lappend lines "    fprintf (stderr, \"depth    = %d\\n\", depth);"
	lappend lines "    fprintf (stderr, \"mismatch @ %d %f != %f\\n\", k, ${first}\[k], ${name}\[k]);"
	lappend lines "    aktive_uint j;"
	lappend lines "    fprintf (stderr, \"src\[%d] = \{\", k);"
	lappend lines "    for (j = 0; j < depth; j++) \{"
	lappend lines "        fprintf (stderr, \" %f\", s\[k*depth+j]);"
	lappend lines "    \}"
	lappend lines "    fprintf (stderr, \" \}\\n\");"
	lappend lines "    ASSERT (0, \"MISMATCH\");"
	lappend lines "\}"
    }
    # use last implementation as actual result
    lappend lines "memcpy (d, [lindex $rimplementations end], width*sizeof(double));"
    # release the internal temp memory
    foreach name $rimplementations {
	lappend lines "FREE ($name);"
    }
    # deliver generated code
    return [join $lines "\n\t"]
}

reducer-def crosscheck {
    extern void aktive_reduce_row_bands_crosscheck_@name@ (double *d, double* s, aktive_uint width, aktive_uint depth);
} [string map [list @rimpl@ [rimpl]] {
    void aktive_reduce_row_bands_crosscheck_@name@ (double *d, double* s, aktive_uint width, aktive_uint depth) {
	TRACE_FUNC("(dst %p[%d], src %p[%dx%d])", d, width, s, width, depth);
	// d - destination row start - single band
	// s - source      row start - `depth` bands
	// width - row width, source and destination
	// depth - row depth, source only

	aktive_uint k, n = width * depth;
	@rimpl@
	TRACE_RETURN_VOID;
    }
}]

# # ## ### ##### ######## #############
return
