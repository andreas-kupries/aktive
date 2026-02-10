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

# create testing commands for all implementation variants of a reducer operation
proc gen {name} {
    gen-band $name
}

# create testing commands for all implementation variants of a band reducer operation
proc gen-band {name} {
    lappend map @@ $name
    foreach impl {
	baseline perdepth unroll4
    } {
	critcl::cproc ::aktive::test::reduce-bands::${impl}::${name} {int w int d} void \
	    [string map [list @@ $name @impl@ $impl] {
		if (w > (N/d)-1) w = (N/d)-1;
		aktive_reduce_bands_@impl@_@@ (dst, src, w, d);
	    }]
    }
}

# create benchmark commands for all reducer operations
apply {{} {
    source data/reduce/spec.tcl
    foreach name $reducers { gen $name }
}}

# # ## ### ##### ######## #############

rename gen      {}
rename gen-band {}

# # ## ### ##### ######## #############
return
