/* -*- c -*-
 * (c) 2024 Andreas Kupries
 *
 * - - -- --- ----- -------- -------------
 * -- Geometry utilities
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

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
