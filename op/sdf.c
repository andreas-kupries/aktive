/*
 * - - -- --- ----- -------- -------------
 ** (c) 2024-2025 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
 *
 * -- signed distance functions
 */

#include <sdf.h>
#include <amath.h>

#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

// static double length (double x, double y)
#define VLENGTH(x,y) (hypot ((x), (y)))

// static double dot (double xa, double ya, double xb, double yb)
#define DOT(ax,ay,bx,by) ((ax)*(bx) + (ay)*(by))

// static double ndot (double xa, double ya, double xb, double yb)
#define NDOT(ax,ay,bx,by) ((ax)*(bx) - (ay)*(by))

// static double dot (double x, double y)
#define DOTSELF(x,y) ((x)*(x) + (y)*(y))

// static double clamp(v) -- inlined aktive_clamp
#define CLAMP(v) (fmax (0, fmin (1, (v))))

// static double clampr(v)
#define CLAMP_RANGE(v,min,max) (fmax ((min), fmin ((max), (v))))

/*
 * - - -- --- ----- -------- -------------
 */

double aktive_sdf_box (double x, double y, double w, double h)
{
    // ref https://www.youtube.com/watch?v=62-pRVZuS5c
    //
    // axis aligned rectangular box of width w, height h, centered at the
    // cordinate origin, all corners have radius 0, i.e. are not rounded.

    double dx = fabs(x) - w;
    double dy = fabs(y) - h;

    return VLENGTH (fmax (dx, 0),
		    fmax (dy, 0))
	+ fmin (fmax (dx, dy), 0);
}

double aktive_sdf_box_rounded (double x, double y, double w, double h, double r[4])
{
    // https://www.shadertoy.com/view/4llXD7 A box of width W and height H,
    // centered on the origin, with rounded corners per the specified 4 radii.
    //
    // r[3]...r[1]
    // .      .
    // .      .
    // .      .
    // r[2]...r[0]

    // VIPS decoding of the SL code.

    // determine the radius of the nearest corner
    //
    //	r.xy = (x > 0.0) ? r.xy : r.zw;
    //	r.x  = (y > 0.0) ? r.x  : r.y;

    double r_down = x > 0 ? r[0] : r[2];
    double r_up   = x > 0 ? r[1] : r[3];
    double rnear  = y > 0 ? r_down : r_up;

    //	vec2 q = abs(p)-b+r.x;

    double qx = fabs (x) - w + rnear;
    double qy = fabs (y) - h + rnear;

    // return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;

    return VLENGTH (fmax (qx, 0),
		    fmax (qy, 0))
	+ fmin (fmax (qx, qy), 0)
	- rnear;
}

double aktive_sdf_circle (double x, double y, double radius)
{
    return VLENGTH (x, y) - radius;
}

double aktive_sdf_polycircle (double x, double y, double radius, aktive_fpoint_vector* centers)
{
    double mindist = INFINITY;
    aktive_uint k;
    for (k = 0; k < centers->c; k++) {
    	double d = aktive_sdf_circle (aktive_sdf_translate (x, y, centers->v[k].x, centers->v[k].y),
				      radius);
	mindist = MIN (mindist, d);
    }
    return mindist;
}

double aktive_sdf_parallelogram (double x, double y, double w, double h, double skew)
{
    // https://www.shadertoy.com/view/7dlGRf

    double ex = skew;
    double ey = h;

    x = (y < 0) ? -x : x;
    y = (y < 0) ? -y : y;

    double wx = x - ex;
    double wy = y - ey;

    wx -= CLAMP_RANGE (wx, -w, w);

    double dx = DOTSELF (wx, wy);
    double dy = -wy;

    double s = x*ey - y*ex;

    x = (s < 0) ? -x : x;
    y = (s < 0) ? -y : y;

    double vx = x - w;
    double vy = y - 0;

    double hh = CLAMP_RANGE (DOT (vx,vy,ex,ey) / DOTSELF(ex,ey), -1, 1);

    vx -= ex * hh;
    vy -= ey * hh;

    dx = fmin (dx, DOTSELF (vx, vy));
    dy = fmin (dy, w*h - fabs (s));

    return sqrt (dx) * aktive_sign (-dy);
}

double aktive_sdf_rhombus (double x, double y, double w, double h)
{
    // https://www.shadertoy.com/view/XdXcRB

    x = fabs (x);
    y = fabs (y);

    double bx = w - 2 * x;
    double by = h - 2 * y;

    double hh = CLAMP_RANGE (NDOT (bx, by, w, h) / DOTSELF (w,h), -1, 1);

    double d  = VLENGTH (x - 0.5 * w * (1 - hh),
			 y - 0.5 * h * (1 + hh));

    return d * aktive_sign ( x*h + y*w - w*h );
}

double aktive_sdf_segment (double x, double y, APD from, APD to)
{
    // ref https://www.shadertoy.com/view/3tdSDj
    // ref https://www.youtube.com/watch?v=PMltMdi1Wzg
    //
    // line segment between the points FROM and TO
    //
    // optimization: pre-compute to-from, DOTSELF(to-from)
    //
    // See `aktive_sdf_segment_precoded()` below.

    double dx  = to->x - from->x;
    double dy  = to->y - from->y;
    double pax = x - from->x;
    double pay = y - from->y;
    double h   = CLAMP (DOT(pax,pay,dx,dy) / DOTSELF(dx,dy));

    return VLENGTH (pax - dx*h, pay - dy*h);
}

double aktive_sdf_polysegment_precoded (double x, double y, aktive_uint n, aktive_segment_spec* seg)
{
    double mindist = INFINITY;
    aktive_uint k;
    for (k=0; k < n; k++) {
	double d = aktive_sdf_segment_precoded (x, y, &seg[k]);
	mindist = MIN (mindist, d);
    }
    return mindist;
}

double aktive_sdf_segment_precoded (double x, double y, aktive_segment_spec* seg)
{
    // ref https://www.shadertoy.com/view/3tdSDj
    // ref https://www.youtube.com/watch?v=PMltMdi1Wzg
    //
    // line segment between the points FROM and TO.
    // direction and limit are pre-coded in DELTA and DDOT.

    double fx   = seg->from.x;
    double fy   = seg->from.y;
    double dx   = seg->delta.x;
    double dy   = seg->delta.y;
    double ddot = seg->ddot;

    double pax  = x - fx;
    double pay  = y - fy;
    double h    = CLAMP (DOT(pax, pay, dx, dy) / ddot);

    return VLENGTH (pax - dx*h, pay - dy*h);
}

double aktive_sdf_triangle_precoded (double x, double y, aktive_triangle_spec* tri)
{
    // https://www.shadertoy.com/view/XsXSz4

    double e0x = tri->ba.x;	double p0x = tri->a.x;	double badot   = tri->badot;
    double e0y = tri->ba.y;	double p0y = tri->a.y;	double cbdot   = tri->cbdot;
    double e1x = tri->cb.x;	double p1x = tri->b.x;	double acdot   = tri->acdot;
    double e1y = tri->cb.y;	double p1y = tri->b.y;
    double e2x = tri->ac.x;	double p2x = tri->c.x;	double bacsign = tri->bacsign;
    double e2y = tri->ac.y;	double p2y = tri->c.y;

    double v0x = x - p0x;
    double v0y = y - p0y;
    double v1x = x - p1x;
    double v1y = y - p1y;
    double v2x = x - p2x;
    double v2y = y - p2y;

    double c0 = CLAMP (DOT (v0x,v0y,e0x,e0y) / badot);
    double c1 = CLAMP (DOT (v1x,v1y,e1x,e1y) / cbdot);
    double c2 = CLAMP (DOT (v2x,v2y,e2x,e2y) / acdot);

    double pq0x = v0x - e0x * c0;
    double pq0y = v0y - e0y * c0;
    double pq1x = v1x - e1x * c1;
    double pq1y = v1y - e1y * c1;
    double pq2x = v2x - e2x * c2;
    double pq2y = v2y - e2y * c2;

    double s = bacsign;

    double dx = fmin (fmin (DOTSELF (pq0x,pq0y), DOTSELF (pq1x,pq1y)), DOTSELF (pq2x,pq2y));
    double dy = fmin (fmin (s*(v0x*e0y-v0y*e0x), s*(v1x*e1y-v1y*e1x)), s*(v2x*e2y-v2y*e2x));

    return - sqrt(dx) * aktive_sign (dy);
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
