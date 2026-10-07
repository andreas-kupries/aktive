# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2026 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#
##
# TESTING support commands. Not created for production / benchmarking
##

critcl::msg "\t[dsl::reader::cyan "Testing Support; Expose KD-Tree"]"

critcl::include kdtree.h

critcl::ccode {
    // Max size fpoint vector to operate
    // log10 = 8 (100 Million) ~ 764 Megabyte (sizeof(double) == 4, times 2)
    #define N 100000000

    // Vectors to operate on ~ 1.1GB
    static aktive_fpoint* points;
    static aktive_uint    np;
    static aktive_kdtree  kd;

    // result state
    aktive_fpoint best;
    double        mindistance;
}

# initializer - invoke before the testing commands.
# fill source array with random values, create kd tree.

# BEWARE: the memory of both points array and tree are leaked. considered acceptable for
# testing.

#critcl::msg \t::aktive::test::kdtree-bands::init
critcl::cproc ::aktive::test::kdtree::init {int {n N}} void {
    aktive_uint i;
    // heap allocate - lost on exit - this is ok for testing
    if (!points) points = NALLOC (aktive_fpoint, N);
    if (n > N) n = N;
    for (i = 0; i < n; i++) {
	points [i].x = ((double) rand()) * (10000.0 / ((double) RAND_MAX)) ;
	points [i].y = ((double) rand()) * (10000.0 / ((double) RAND_MAX)) ;
    }
    np = n;
    // heap allocate - lost on exist - this is ok for testing
    kd = aktive_kdtree_setup (n, points);
}

# expose max vector size
critcl::cconst ::aktive::test::kdtree::size int N

# # ## ### ##### ######## #############

critcl::cproc ::aktive::test::kdtree::min {} double {
    return mindistance;
}

critcl::cproc ::aktive::test::kdtree::best {} aktive_fpoint {
    return best;
}

critcl::cproc ::aktive::test::kdtree::scan {double x double y} void {
    /* Perform linear search of points, for reference */

    mindistance = INFINITY;
    best.x      = 0;
    best.y      = 0;

    aktive_uint i;
    for (i=0; i < np; i++) {
	double dx = points[i].x - x;
	double dy = points[i].y - y;
	double d  = dx*dx + dy*dy;
	if (d >= mindistance) continue;
	mindistance = d;
	best        = points[i];
    }
}

critcl::cproc ::aktive::test::kdtree::recurse {double x double y} void {
    /* Perform proper tree search */
    aktive_fpoint t;
    t.x = x;
    t.y = y;
    aktive_kdtree_find_nearest (kd, &t, &best, &mindistance);
}

# # ## ### ##### ######## #############
return
