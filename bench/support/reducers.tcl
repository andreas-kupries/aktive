# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2025-2026 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#
##
# BENCHMARK support commands. Not created for production / testing.
##

critcl::msg "\t[dsl::reader::cyan "Benchmarking Support; Expose band reducer core"]"

critcl::ccode {
    // Max size vector to operate
    // log10 = 8 (100 Million) ~ 382 Megabyte (sizeof(double) = 4)
    #define N 100000000

    // Vectors to operate on ~ 1.1GB
    static double* src;
    static double* dst;
}

# initializator - invoke before the benchmark commands.
# fill source arrays and parameters with random values.
critcl::cproc ::aktive::bench::reduce::init {int {n N}} void {
    aktive_uint i;
    // heap allocate - lost on exit - this is ok for benchmarks
    if (!dst) dst = NALLOC (double, N);
    if (!src) src = NALLOC (double, N);
    if (n > N) n = N;
    for (i = 0; i < n; i++) { src [i] = rand() ; }
}

# expose vector size
critcl::cconst ::aktive::bench::reduce::size int N

# # ## ### ##### ######## #############

# create benchmark commands for all implementation variants of a reducer operation
proc gen {name} {
    gen-band $name
}

# create benchmark commands for all implementation variants of a band reducer operation
proc gen-band {name} {
    foreach impl {
	baseline perdepth unroll4
    } {
	critcl::cproc ::aktive::bench::reduce-bands::${impl}::${name} {int w int d} void \
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
