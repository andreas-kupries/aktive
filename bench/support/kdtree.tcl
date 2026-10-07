# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2026 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#
##
# BENCHMARKING support commands. Not created for production / testing
##

critcl::msg "\t[dsl::reader::cyan "Benchmarking Support; Expose KD-Tree And a Linear Scan"]"

critcl::include kdtree.h

critcl::ccode {
    // Max size fpoint vector to operate
    // log10 = 8 (100 Million) ~ 764 Megabyte (sizeof(double) == 4, times 2)
    #define N 100000000

    // Vectors to operate on ~ 1.1GB
    static aktive_fpoint* points;
    static aktive_uint    np;
    static aktive_kdtree  kd;

    // result state, not exposed
    aktive_fpoint best;
    double        mindistance;
}

# initializers - invoke before the benchmarking commands.
# - fill source array with random values
# - create kd tree.
#
# separate, to be able to measure time for KD-tree generation, separate from linear
# filling of the array.
#
# NOTE: as the final tree has to contain all the elements of the array this is expected to
# be O(n) at least. It might be around O(n log n), instead of O(n^2), because of the quick
# select median.

# BEWARE: the memory of both points array and tree are leaked. considered acceptable for
# benchmarking.

#critcl::msg \t::aktive::bench::kdtree-bands::init
critcl::cproc ::aktive::bench::kdtree::init {int {n N}} void {
    aktive_uint i;
    // heap allocate - lost on exit - this is ok for benchmarking
    if (!points) points = NALLOC (aktive_fpoint, N);
    if (n > N) n = N;
    for (i = 0; i < n; i++) {
	points [i].x = ((double) rand()) * (10000.0 / ((double) RAND_MAX)) ;
	points [i].y = ((double) rand()) * (10000.0 / ((double) RAND_MAX)) ;
    }
    np = n;
}

critcl::cproc ::aktive::bench::kdtree::setup {} void {
    // heap allocate - lost on exit - this is ok for benchmarking
    kd = aktive_kdtree_setup (np, points);
}

critcl::cproc ::aktive::bench::kdtree::clear {} void {
    aktive_kdtree_release (kd);
}

# expose the max vector size
critcl::cconst ::aktive::bench::kdtree::size int N

# # ## ### ##### ######## #############

critcl::cproc ::aktive::bench::kdtree::visited {} aktive_uint {
    return aktive_kdtree_visit_count();
}

critcl::cproc ::aktive::bench::kdtree::scan {double x double y} void {
    /* Perform linear search of points, for reference */

    mindistance = INFINITY;
    best.x      = 0;
    best.y      = 0;

    aktive_uint i;
    for (i = 0; i < np; i++) {
	double dx = points[i].x - x;
	double dy = points[i].y - y;
	double d  = dx*dx + dy*dy;
	if (d >= mindistance) continue;
	mindistance = d;
	best        = points[i];
    }
}

critcl::cproc ::aktive::bench::kdtree::recurse {double x double y} void {
    /* Perform proper tree search */
    aktive_fpoint t;
    t.x = x;
    t.y = y;
    aktive_kdtree_find_nearest (kd, &t, &best, &mindistance);
}

# # ## ### ##### ######## #############
return
