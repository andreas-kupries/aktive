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

# initializer - invoke before the testing commands.
# fill source arrays and parameters with random values.
#critcl::msg \t::aktive::test::reduce-bands::init
critcl::cproc ::aktive::test::reduce::init {int {n N}} void {
    aktive_uint i;
    // heap allocate - lost on exit - this is ok for testing
    if (!dst) dst = NALLOC (double, N);
    if (!src) src = NALLOC (double, N);
    if (n > N) n = N;
    for (i = 0; i < n; i++) { src [i] = rand() ; }
}

# expose vector size
critcl::cconst ::aktive::test::reduce::size int N

# # ## ### ##### ######## #############
source support/reduce/db.tcl
source support/template.tcl

# create testing commands for all implementation variants of a reducer operation
proc reduce::gen-test-command {name} {
    gen-test-command-band $name
    gen-test-command-row  $name
}

# create testing commands for all implementation variants of a band reducer operation
proc reduce::gen-test-command-band {name} {
    foreach variant [without-xcheck [for-axis band]] {
	critcl::cproc ::aktive::test::reduce-bands::${variant}::${name} {int w int d} void \
	    [string map [list @@ $name @variant@ $variant] {
		if (w > (N/d)-1) w = (N/d)-1;
		aktive_reduce_bands_@variant@_@@ (dst, src, w, d);
	    }]
    }
}

# create testing commands for all implementation variants of a row reducer operation
proc reduce::gen-test-command-row {name} {
    foreach variant [without-xcheck [for-axis row]] {
	critcl::cproc ::aktive::test::reduce-rows::${variant}::${name} {int w int d} void \
	    [string map [list @@ $name @variant@ $variant] {
		if (w > (N/d)-1) w = (N/d)-1;
		aktive_reduce_rows_@variant@_@@ (dst, src, w, d);
	    }]
    }
}

# # ## ### ##### ######## #############

# create benchmark commands for all reducer operations
apply {{} {
    source support/reduce/assets/ops.tcl
    foreach entry [lsort -dict [glob support/reduce/assets/*/*/func.tcl]] {
	source $entry } ;# funcs & placeholders

    foreach name [names] { gen-test-command $name }
} reduce}

# # ## ### ##### ######## #############

namespace delete reduce

# # ## ### ##### ######## #############
return
