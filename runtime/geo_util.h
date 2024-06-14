/* -*- c -*-
 * - - -- --- ----- -------- -------------
 * (c) 2024 Andreas Kupries
 *
 * -- Geometry utilities -- 2d lines, circles, intersections, distances, ...
 */
#ifndef AKTIVE_GEOMETRY_UTIL_H
#define AKTIVE_GEOMETRY_UTIL_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <tclpre9compat.h>
#include <base.h>
#include <geometry.h>

/*
 * - - -- --- ----- -------- -------------
 * Geometry utilities and attendant types
 */

/*
 * - - -- --- ----- -------- -------------
 *
 * Is a point P in/on the circle with radius R and stroke width W ?
 * The distance D of P to the circle center C already known.
 *
 * Plain:  The absolute distance between D and R is within the stroke width W.
 * Filled: The distance D is within radius R plus stroke width W.
 *
 * With aliasing the border B used (w vs r+w) is extended by 1, and the
 * result interpolated from 1 to 0 based on the fraction between B and B+1.
 * B+1 => 0, B => 1, with clipping to the proper values outside.
 */

double aktive_circle_distance (double x, double y, double cx, double cy);
double aktive_circle_bw       (double d, double r, double w);
double aktive_circle_grey     (double d, double r, double w);
double aktive_disc_bw         (double d, double r, double w);
double aktive_disc_grey       (double d, double r, double w);

// #define CLIP(v)   fmax(0,fmin(1,v))
#define AKTIVE_CIRCLE_P(d,r,w)   (fabs((d)-(r)) <= (w)  ? 1 : 0)
#define AKTIVE_CIRCLE_A(d,r,w)			\
    (fabs((d)-(r)) <= ((w)+1)			\
     ? CLIP(1-(fabs((d)-(r))-(w)))	\
     : 0)
#define AKTIVE_DISC_P(d,r,w)   ((d) <= ((r)+(w)) ? 1 : 0)
#define AKTIVE_DISC_A(d,r,w)			\
    ((d) <= ((r)+(w))				\
     ? CLIP(1-((d)-((r)+(w))))		\
     : 0)

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
#endif /* AKTIVE_GEOMETRY_UTIL_H */


/*
 * https://core.tcl-lang.org/tcllib/file?name=modules/math/geometry.tcl&ci=trunk
 * https://core.tcl-lang.org/tcllib/file?name=modules/math/geometry_circle.tcl&ci=trunk
 * https://core.tcl-lang.org/tcllib/file?name=modules/math/geometry_ext.tcl&ci=trunk
 *
 * Stuff useful for draw operations / images.
 *
 *	conjugate (p)
 *	x (p)
 *	y (p)
 *	length (p)
 *	scale (p, s)
 *	direction (angle)
 *	vertical (h)
 *	horizontal (w)
 *	octant (p)
 *
 *	pa + pb
 *	pa - pb
 *	dist  (pa, pb)
 *	angle (pa, pb)		// angle of line through pa, pb versus x-axis
 *	angle-between (pa, pb)
 *	interpolate (pa, pb, t)
 *      in-product (pa, pb)	// scalar product, point-wise multiplication
 *
 *	nwse (rect)		/might already be in geometry.h ?
 *	rect (pnw pse)
 *
 *	distance-to-line           (p, pa, pb)
 *	closest-point-on-line      (p, pa, pb)
 *	distance-to-segment        (p, pa, pb)	// only between the points, not outside
 *	closest-point-on-segment   (p, pa, pb)
 *	distance-to-poly-line      (p, pa, pb, ...)
 *	closest-point-on-poly-line (p, pa, pb, ...)
 *	distance-to-polygon        (p, pa, pb, ...)
 *	closest-point-on-polygon   (p, pa, pb, ...)
 *
 *	length-poly-line (pa, pb, ...)
 *
 *	translate-point (p, angle, distance)
 *	translate-poly  (poly.., vector)
 *	rotate-poly     (poly..., angle)	// pos angle is CCW, rotation center is 0,0
 *	reflect-poly    (poly..., angle)
 *
 *	segments-intersect-?      (p1a, p1b, p2a, p2b)
 *	poly-lines-intersect-?    (p1a, ...
 *                                 p2a, ...)
 *	line-intersects-circle-?    (line, circle)
 *	segment-intersects-circle-? (segment, circle)
 *
 *	find-segment-intersection (p1a, p1b, p2a, p2b)
 *	find-line-intersection    (p1a, p1b, p2a, p2b)
 *
 *	find-intersections-of-vertical-line-and-circle (line, circle)
 *	find-intersections-of-line-and-circle          (line, circle)
 *	find-intersections-of-circles-simple           (ca, cb)		// c1 at 0/0, c2 at x/0
 *	find-intersections-of-circles                  (ca, cb)		// transform to simple & back
 *
 *	ccw (pa, pb, pc)	- counter clock wise yes/no
 *
 *	intervals-overlap	// geometry.h ?
 *	rectangles-overlap
 *
 *	poly-line-bbox         (pa, pb, ...)
 *
 *	point-inside-polygon-?     (p, pa, pb, ...)
 *	rectangle-inside-polygon-? (rect, pa, pb, ...)
 *	point-inside-circle-?	   (p, pc, r)
 *
 *	area-of-polygon       (pa, pb, ...)
 *	area-of-parallelogram (pa, pb)
 *
 *	degree-to-radians
 *	radians-to-degree
 *
 *	circle (pa, pb)
 *
 *	tangent-lines-to-circle (p, circle)
 *
 *	cathetus-point (pa, pb, circle, location (a|b))
 *	parallel (line, offset, orient (right|left) - cathetus points)
 *
 *	rotate (center, angle, polyline)
 *
 *	unit-of (line)
 */
