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

proc reducer-def {axis name impl} {
    global ${axis}_implementations ; lappend ${axis}_implementations $name

    switch -exact -- $axis {
	band {
	    set header [string map [list \n\t\t "\n    " \t\t "    " "\n\t    " "\n"] {
		// d [count]         - destination row start - single band
		// s [count, stride] - source      row start - `stride` bands
		// count  - row width, source and destination
		// stride - row depth, source only
	    }]
	}
	row     {
	    set header [string map [list \n\t\t "    " \t\t "    " "\n\t    " "\n"] {
		// d [1]             - destination value, row/band
		// s [count, stride] - source
		// count  - row width, source and destination
		// stride - row depth, source and destination
	    }]
	}
	column  { error NYI }
	default { error BAD }
    }

    set func "aktive_reduce_${axis}s_${name}_@name@"
    set sign "(double *d, double* s, aktive_uint count, aktive_uint stride)"
    set decl "extern void $func ${sign};"
    set trac "\n    TRACE_FUNC(\"(dst %p\[%d], src %p\[%dx%d])\", d, count, s, count, stride)"
    set impl "void $func $sign \{${trac};${header}${impl}    TRACE_RETURN_VOID;\n\}\n"

    global ${axis}_${name}_decl ; upvar 0 ${axis}_${name}_decl __decl ; set __decl [string trim $decl]
    global ${axis}_${name}_impl ; upvar 0 ${axis}_${name}_impl __impl ; set __impl $impl
    return
}

proc reducer-make {axis name op map} {
    global ${axis}_${name}_decl ; upvar 0 ${axis}_${name}_decl funcdecl
    global ${axis}_${name}_impl ; upvar 0 ${axis}_${name}_impl funcimpl

    upvar 1 decl decl defn defn link link

    lappend decl [string map $map $funcdecl]
    lappend defn [string map $map $funcimpl]
    set     link [lreplace $link end end]
    lappend link "#define aktive_reduce_${axis}s_$op aktive_reduce_${axis}s_${name}_$op"
    return
}

# # ## ### ##### ######## #############
## baseline - emulate the inner loop of the existing blitter setup

reducer-def band baseline {
    // iterate over the columns of the row and reduce each
    aktive_uint k;
    for (k = 0; k < count; k++, d ++, s += stride) {
	*d = aktive_reduce_@name@ (s, stride, 1, 0 /* client data, ignored */);
    }
}

reducer-def row baseline {
    // iterate over the bands of the row and reduce each
    aktive_uint k;
    for (k = 0; k < stride; k++, d ++, s ++) {
	*d = aktive_reduce_@name@ (s, count, stride, 0 /* client data, ignored */);
    }
}

# # ## ### ##### ######## #############
## perdepth - handle the common depths (1-4) with custom code (fully unrolled band loop)

reducer-def band perdepth {
    @once@
    #define PIXELS(step) aktive_uint k; for (k = 0; k < count; k++, d++, s += (step))
    #define BANDS        aktive_uint j; for (j = 0; j < stride; j++)

    switch (stride) {
	case 1: {
	    // note - due to highlevel simplifications this case should not be reached
	    // except in benchmarking
	    TRACE ("depth %d unrolled/none", stride);
	    PIXELS(1) { *d = @single@; }
	} ; break;
	case 2: {
	    TRACE ("depth %d unrolled/2", stride);
	    PIXELS(2) {
		@setup@
		@reduce0@
		@reduce1@
		@final@
	    }
	} ; break;
	case 3: {
	    TRACE ("depth %d unrolled/3", stride);
	    PIXELS(3) {
		@setup@
		@reduce0@
		@reduce1@
		@reduce2@
		@final@
	    }
	} ; break;
	case 4: {
	    TRACE ("depth %d unrolled/4", stride);
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
	    TRACE ("depth %d unrolled/none, generic", stride);
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
}

# # ## ### ##### ######## #############
## unroll4 - unroll the pixel loop as well to handle more than one pixel per iteration

reducer-def band unroll4 {
    @once@
    #define PIXELS4(step) for (k = count; k > 4; k-= 4, d += 4, s += 4*(step))
    #define PIXELS2(step) for (         ; k > 2; k-= 2, d += 2, s += 2*(step))
    #define PIXELS1(step) for (         ; k > 0; k--  , d ++  , s +=   (step))
    #define BANDS         aktive_uint j; for (j = 0; j < stride; j++)

    const aktive_uint d0 = 0;
    const aktive_uint d1 = d0 + stride;
    const aktive_uint d2 = d1 + stride;
    const aktive_uint d3 = d2 + stride;
    const aktive_uint d4 = d3 + stride;

    switch (stride) {
	case 1: {
	    // note - due to highlevel simplifications this case should not be reached
	    // except in benchmarking
	    TRACE ("depth %d unrolled/none", stride);
	    aktive_uint k;
	    PIXELS4(1) { d[0] = @single0@; d[1] = @single1@; d[2] = @single2@; d[3] = @single3@; }
	    PIXELS2(1) { d[0] = @single0@; d[1] = @single1@; }
	    PIXELS1(1) { *d   = @single@; }
	} ; break;
	case 2: {
	    TRACE ("depth %d unrolled/2", stride);
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
	    TRACE ("depth %d unrolled/3", stride);
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
	    TRACE ("depth %d unrolled/4", stride);
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
	    TRACE ("depth %d unrolled/none, generic", stride);
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
}

# # ## ### ##### ######## #############
## all - run all the implementations and compare results

reducer-def band crosscheck [string map [list @check@ [apply {{} {
    global band_implementations

    # run all implementations
    foreach name $band_implementations {
	lappend lines "double *$name = NALLOC (double, count); aktive_reduce_bands_${name}_@name@ ($name, s, count, stride);"
    }
    # cross check each against the first. first is not checked, seen as the ok reference
    foreach name [lassign $band_implementations first] {
	lappend lines "// check $name against $first"
	lappend lines "for (k = 0; k < count; k++) \{"
	lappend lines "    if (${name}\[k] == ${first}\[k]) continue;"
	lappend lines "    // difference found, failed, print source, results, then stop"
	lappend lines "    fprintf (stderr, \"$name\\n\");"
	lappend lines "    fprintf (stderr, \"width    = %d\\n\", count);"
	lappend lines "    fprintf (stderr, \"depth    = %d\\n\", stride);"
	lappend lines "    fprintf (stderr, \"mismatch @ %d %f != %f\\n\", k, ${first}\[k], ${name}\[k]);"
	lappend lines "    aktive_uint j;"
	lappend lines "    fprintf (stderr, \"src\[%d] = \{\", k);"
	lappend lines "    for (j = 0; j < stride; j++) \{"
	lappend lines "        fprintf (stderr, \" %f\", s\[k*stride+j]);"
	lappend lines "    \}"
	lappend lines "    fprintf (stderr, \" \}\\n\");"
	lappend lines "    ASSERT (0, \"MISMATCH\");"
	lappend lines "\}"
    }
    # use last implementation as actual result
    lappend lines "memcpy (d, [lindex $band_implementations end], count*sizeof(double));"
    # release the internal temp memory
    foreach name $band_implementations {
	lappend lines "FREE ($name);"
    }
    # deliver generated code
    return [join $lines "\n\t"]
}}]] {
    aktive_uint k, n = count * stride;
    @check@
}]

# # ## ### ##### ######## #############
return
