# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2026 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#
##
# TESTING support commands. Not created for production / benchmarking
##

critcl::msg "\t[dsl::reader::cyan "Testing Support; Expose band reducer core"]"

critcl::ccode {
    // Max size vector to operate
    // log10 = 8 (100 Million) ~ 382 Megabyte (sizeof(double) = 4)
    #define N 100000000

    // Vectors to operate on ~ 1.1GB
    static double* src;
    static double* dst;
}

# create a testing command for each of the reducer functions.

proc gen {name} {
    lappend map @@ $name
    #critcl::msg \t::aktive::test::reduce-bands::____::$name

    critcl::cproc ::aktive::test::reduce-bands::base::${name} {int w int d} void \
	[string map $map {
	    if (w > (N/d)-1) w = (N/d)-1;
	    aktive_reduce_row_bands_base_@@ (dst, src, w, d);
	}]

    critcl::cproc ::aktive::test::reduce-bands::special::${name} {int w int d} void \
	[string map $map {
	    if (w > (N/d)-1) w = (N/d)-1;
	    aktive_reduce_row_bands_special_@@ (dst, src, w, d);
	}]

    critcl::cproc ::aktive::test::reduce-bands::unroll4::${name} {int w int d} void \
	[string map $map {
	    if (w > (N/d)-1) w = (N/d)-1;
	    aktive_reduce_row_bands_unroll4_@@ (dst, src, w, d);
	}]
}

apply {{} {
    source data/reduce/spec.tcl
    foreach name $reducers { gen $name }
}}

# initializator - invoke before the testing commands.
# fill source arrays and parameters with random values.
#critcl::msg \t::aktive::test::reduce-bands::init
critcl::cproc ::aktive::test::reduce-bands::init {int {n N}} void {
    aktive_uint i;
    // heap allocate - lost on exit - this is ok for testing
    if (!dst) dst = NALLOC (double, N);
    if (!src) src = NALLOC (double, N);
    if (n > N) n = N;
    for (i = 0; i < n; i++) { src [i] = rand() ; }
}

# expose vector size
critcl::cconst ::aktive::test::reduce-bands::size int N

# # ## ### ##### ######## #############
rename gen {}

# # ## ### ##### ######## #############
return
