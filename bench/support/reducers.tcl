# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2025 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#
##
# BENCHMARK support commands. Not created for production / testing.
##

critcl::msg "\t[dsl::reader::cyan "Benchmarking Support, Reducers"]"

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
	    if (w > N-1) w = N-1;
	    aktive_reduce_row_bands_base_@@ (dst, src, w, d);
	}]

    critcl::cproc ::aktive::bench::reduce::special::${name} {int w int d} void \
	[string map $map {
	    if (w > N-1) w = N-1;
	    aktive_reduce_row_bands_special_@@ (dst, src, w, d);
	}]
}

apply {{} {
    source data/reduce/spec.tcl
    foreach name $reducers { gen $name }
}}

# initializator - invoke before the benchmark commands.
# fill source arrays and parameters with random values.
#critcl::msg \t::aktive::bench::reduce::init
critcl::cproc ::aktive::bench::reduce::init {} void {
    aktive_uint i;
    // heap allocate - lost on exit - this is ok for benchmarks
    dst = NALLOC (double, N);
    src = NALLOC (double, N);
    for (i = 0; i < N; i++) { src [i] = rand() ; }
}

# # ## ### ##### ######## #############
rename gen {}

# # ## ### ##### ######## #############
return
