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
    #define N 100000

    // Vectors to operate on
    static double srca[N];
    static double srcb[N];
    static double dst[N];

    // Parameters to use
    static double a;
    static double b;
}

# create a benchmark command for each of the math functions
# we assume that everything has a direct mode function.
# highway is optional
apply {{} {
    source data/mathfunc/spec.tcl

    foreach {name spec} $unary0 {
	lappend map @@ $name
	#critcl::msg \t::aktive::bench::vecops::unary::$name

	critcl::cproc ::aktive::bench::vecops::unary::$name {int n} void [string map $map {
	    if (n > N) n = N;
	    aktive_vector_unary_@@ (dst, srca, n);
	}]

	if {[dict exists $spec highway]} {
	    critcl::cproc ::aktive::bench::highway::unary::$name {int n} void [string map $map {
		if (n > N) n = N;
		aktive_highway_unary_@@ (dst, srca, n);
	    }]
	}
	unset map
    }

    foreach {name spec} $unary1 {
	lappend map @@ $name
	#critcl::msg \t::aktive::bench::vecops::unary::$name

	critcl::cproc ::aktive::bench::vecops::unary::$name {int n} void [string map $map {
	    if (n > N) n = N;
	    aktive_vector_unary_@@ (dst, srca, n, a);
	}]

	if {[dict exists $spec highway]} {
	    critcl::cproc ::aktive::bench::highway::unary::$name {int n} void [string map $map {
		if (n > N) n = N;
		aktive_highway_unary_@@ (dst, srca, n, a);
	    }]
	}
	unset map
    }

    foreach {name spec} $unary2 {
	lappend map @@ $name
	#critcl::msg \t::aktive::bench::vecops::unary::$name

	critcl::cproc ::aktive::bench::vecops::unary::$name {int n} void [string map $map {
	    if (n > N) n = N;
	    aktive_vector_unary_@@ (dst, srca, n, a, b);
	}]
	if {[dict exists $spec highway]} {
	    critcl::cproc ::aktive::bench::highway::unary::$name {int n} void [string map $map {
		if (n > N) n = N;
		aktive_highway_unary_@@ (dst, srca, n, a, b);
	    }]
	}
	unset map
    }

    foreach {name spec} $binary {
	lappend map @@ $name
	#critcl::msg \t::aktive::bench::vecops::binary::$name

	critcl::cproc ::aktive::bench::vecops::binary::$name {int n} void [string map $map {
	    if (n > N) n = N;
	    aktive_vector_binary_@@ (dst, srca, srcb, n);
	}]

	if {[dict exists $spec highway]} {
	    critcl::cproc ::aktive::bench::highway::binary::$name {int n} void [string map $map {
		if (n > N) n = N;
		aktive_highway_binary_@@ (dst, srca, srcb, n);
	    }]
	}
	unset map
    }
}}

# initializator - invoke before the benchmark commands.
# fill source arrays and parameters with random values.
#critcl::msg \t::aktive::bench::vecops::init
critcl::cproc ::aktive::bench::vecops::init {} void {
    aktive_uint i;
    for (i = 0; i < N; i++) { srca [i] = rand() ; srcb [i] = rand() ; }
    a = rand();
    b = rand();
}

return
