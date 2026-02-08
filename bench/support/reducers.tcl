# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2025-2026 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#
##
# BENCHMARK support commands. Not created for production / testing.
##

critcl::msg "\t[dsl::reader::cyan "Benchmarking Support; Expose reducer core"]"

critcl::ccode {
    // Max size vector to operate
    // log10 = 8 (100 Million) ~ 382 Megabyte (sizeof(double) = 4)
    #define N 100000000

    // Vectors to operate on ~ 1.1GB
    static double* src;
    static double* dst;
}

# create a benchmark command for each of the reducer functions.

proc gen {name} {
    lappend map @@        $name
    #critcl::msg \t::aktive::bench::reduce::base::$name

    critcl::cproc ::aktive::bench::reduce::base::${name} {int w int d} void \
	[string map $map {
	    if (w > (N/d)-1) w = (N/d)-1;
	    aktive_reduce_row_bands_base_@@ (dst, src, w, d);
	}]

    critcl::cproc ::aktive::bench::reduce::special::${name} {int w int d} void \
	[string map $map {
	    if (w > (N/d)-1) w = (N/d)-1;
	    aktive_reduce_row_bands_special_@@ (dst, src, w, d);
	}]

    critcl::cproc ::aktive::bench::reduce::unroll4::${name} {int w int d} void \
	[string map $map {
	    if (w > (N/d)-1) w = (N/d)-1;
	    aktive_reduce_row_bands_unroll4_@@ (dst, src, w, d);
	}]
}

apply {{} {
    source data/reduce/spec.tcl
    foreach name $reducers { gen $name }
}}

# initializator - invoke before the benchmark commands.
# fill source arrays and parameters with random values.
#critcl::msg \t::aktive::bench::reduce::init
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
rename gen {}

# # ## ### ##### ######## #############
return
