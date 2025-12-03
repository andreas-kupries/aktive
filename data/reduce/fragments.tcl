# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############
## Code fragments for the vector functions

proc dedent {s} { string map [list "\t    " "\t" "    " "" "\t" "    "] $s }

# # ## ### ##### ######## #############
## baseline - emulate the inner loop of the existing blitter setup

set basedecl {extern void aktive_reduce_row_bands_base_@name@ (double *d, double* s, aktive_uint np, aktive_uint nb);}
set baseimpl [dedent {
    void aktive_reduce_row_bands_base_@name@ (double *d, double* s, aktive_uint width, aktive_uint depth) {
	// d - destination row start - single band
	// s - source      row start - `depth` bands
	// width - row width, source and destination
	// depth - row depth, source only
	aktive_uint k;
	for (k = 0; k < width; k++, d ++, s += depth) {
	    *d = aktive_reduce_@name@ (s, depth, 1, 0 /* client data, ignored */);
	}
    }
}]

# # ## ### ##### ######## #############

return
