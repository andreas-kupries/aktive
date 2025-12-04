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

# # ## ### ##### ######## #############
## baseline - emulate the inner loop of the existing blitter setup

set basedecl {extern void aktive_reduce_row_bands_base_@name@ (double *d, double* s, aktive_uint np, aktive_uint nb);}
set baseimpl [dedent {
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
}]

# # ## ### ##### ######## #############
## special - handle the common depths with custom code (fully unrolled inner/band loop)

set specialdecl {extern void aktive_reduce_row_bands_special_@name@ (double *d, double* s, aktive_uint np, aktive_uint nb);}
set specialimpl [dedent {
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
}]

# # ## ### ##### ######## #############

return
