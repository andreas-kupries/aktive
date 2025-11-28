# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2025 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#
##
# Commands for use in benchmarks. Do not create when in a non-benchmark environment
##

critcl::ccode {
    // Max size vector to operate
    // log10 = 8 (100 Million) ~ 382 Megabyte (sizeof(double) = 4)
    #define N 100000000

    // Vectors to operate on ~ 1.1GB
    static double* srca;
    static double* srcb;
    static double* dst;

    // Parameters to use
    static double a;
    static double b;
}

# create a benchmark command for each of the math functions.
# for direct mode handle the various loop unrolling levels.
# highway is optional

proc direct {section name spec arguments} {
    if {![dict exists $spec direct]} return
    direct-gen $section $name 1 $arguments
    direct-gen $section $name 2 $arguments
    direct-gen $section $name 4 $arguments
}

proc direct-gen {section name unroll arguments} {
    lappend map @@        $name
    lappend map @unroll@  $unroll
    lappend map @args@    $arguments
    lappend map @section@ $section
    #critcl::msg \t::aktive::bench::vecops${unroll}::${section}::$name

    critcl::cproc ::aktive::bench::vecops${unroll}::${section}::$name {int n} void [string map $map {
	if (n > N) n = N;
	aktive_vector@unroll@_@section@_@@ (@args@);
    }]
}

proc highway {section name spec arguments} {
    if {![dict exists $spec highway]} return

    lappend map @@        $name
    lappend map @args@    $arguments
    lappend map @section@ $section
    #critcl::msg \t::aktive::bench::highway::${section}::$name

    critcl::cproc ::aktive::bench::highway::${section}::$name {int n} void [string map $map {
	if (n > N) n = N;
	aktive_highway_@section@_@@ (@args@);
    }]
}

apply {{} {
    source data/mathfunc/spec.tcl

    foreach {name spec} $unary0 {
	direct  unary $name $spec {dst, srca, n}
	highway unary $name $spec {dst, srca, n}
    }

    foreach {name spec} $unary1 {
	direct  unary $name $spec {dst, srca, n, a}
	highway unary $name $spec {dst, srca, n, a}
    }

    foreach {name spec} $unary2 {
	direct  unary $name $spec {dst, srca, n, a, b}
	highway unary $name $spec {dst, srca, n, a, b}
    }

    foreach {name spec} $binary {
	direct  binary $name $spec {dst, srca, srcb, n}
	highway binary $name $spec {dst, srca, srcb, n}
    }
}}

# initializator - invoke before the benchmark commands.
# fill source arrays and parameters with random values.
#critcl::msg \t::aktive::bench::vecops::init
critcl::cproc ::aktive::bench::vecops::init {} void {
    aktive_uint i;

    // heap allocate - lost on exit - ok for benchmarks
    dst  = NALLOC (double, N);
    srca = NALLOC (double, N);
    srcb = NALLOC (double, N);

    for (i = 0; i < N; i++) { srca [i] = rand() ; srcb [i] = rand() ; }
    a = rand();
    b = rand();
}

# # ## ### ##### ######## #############
rename direct {}
rename direct-gen {}
rename highway {}

# # ## ### ##### ######## #############
return
