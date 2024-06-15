/* -*- c -*-
 * (c) 2024 Andreas Kupries
 *
 * - - -- --- ----- -------- -------------
 * -- Geometry utilities
 *
 * Mainly (signed) distance functions for various 2D primitives.
 *
 * https://math.stackexchange.com/questions/3670465/calculate-distance-from-point-to-ellipse-edge
 * https://iquilezles.org/articles/ellipsedist/
 * https://iquilezles.org/articles/ellipses
 * https://iquilezles.org/articles
 * https://iquilezles.org/articles/distgradfunctions2d	!!
 * https://iquilezles.org/articles/distfunctions2d	!!
 * https://iquilezles.org/articles/distfunctions2dlinf	!!
 * https://iquilezles.org/articles/distfunctions

 */

#include <tclpre9compat.h>
#include <critcl_trace.h>

#include <geo_util.h>
#include <geometry.h>
#include <math.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 * Defined in the op/ layer.
 * Maybe also where these utils should go.
 */

extern double aktive_clamp (double x);

/*
 * - - -- --- ----- -------- -------------
 */

double
aktive_circle_distance (double x, double y, double cx, double cy)
{
  return hypot (x - cx, y - cy);
}

double
aktive_circle_bw (double d, double r, double w)
{
  double dtb = fabs (d - r);	// distance to circle border
  return dtb < (w + 0.5)
    ? 1
    : 0
    ;
}

double
aktive_circle_grey (double d, double r, double w)
{
    return 1 - aktive_clamp (fabs (d - r) - (w + 0.5));
}

double
aktive_disc_bw (double d, double r, double w)
{
  return d <= (r + w + 0.5)
    ? 1
    : 0
    ;
}

double
aktive_disc_grey (double d, double r, double w)
{
    return 1 - aktive_clamp (d - (r + w + 0.5));
}

/*
 * - - -- --- ----- -------- -------------
 */

double
aktive_line_segment_distance (double x, double y, aktive_point* a, aktive_point* b)
{
    // load points
    double ax = a->x;
    double ay = a->y;
    double bx = b->x;
    double by = b->y;

    // See also Tcllib modules/math/geometry.tcl (calculateDistanceToLineSegmentImpl)
    //
    // Solution based on FAQ 1.02 on comp.graphics.algorithms
    //
    // L = hypot( Bx-Ax, By-Ay )
    //
    //     (Ay-y)(Bx-Ax)-(Ax-x)(By-Ay)
    // s = -----------------------------
    //                 L^2
    //
    //      (x-Ax)(Bx-Ax) + (y-Ay)(By-Ay)
    // r = -------------------------------
    //                   L^2
    // dist = |s|*L
    //
    // =>
    //
    //        | (Ay-y)(Bx-Ax)-(Ax-x)(By-Ay) |
    // dist = ---------------------------------
    //                       L
    //
    // Cases for r:
    //
    // r == 0 : dist == 0,                  (x,y) == a,
    // r == 1 : dist == 0,		    (x,y) == b,
    // r  < 0 : dist == hypot (ax-x, ay-y), (x,y) on the backward extension of AB
    // r  > 1 : dist == hypot (bx-x, by-y), (x,y) on the forward extension of AB
    // else   : dist see above

    double l  = hypot (bx-ax, by-ay);

    if (l <= 0) return hypot (ax-x,ay-y);

    double ll = l*l;
    double r  = ((x-ax)*(bx-ax) + (y-ay)*(by-ay)) / ll;

    TRACE ("(%f,%f - %f,%f) l=%f // %f,%f //r %f", ax, ay, bx, by, l, x, y, r);

    if (r <  0) return hypot (ax-x,ay-y);
    if (r >  1) return hypot (bx-x,by-y);

    return fabs ((ay-y)*(bx-ax) - (ax-x)*(by-ay)) / l;
}

double
aktive_line_segment_bw (double d, double w)
{
    return d < (w + 0.5)
	? 1
	: 0
	;
}

double
aktive_line_segment_grey (double d, double w)
{
    return 1 - aktive_clamp (d - (w + 0.5));
}

/*
 * - - -- --- ----- -------- -------------
 */

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
