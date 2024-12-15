/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * API implementation - Interpolators
 */

#include <math.h>
#include <tclpre9compat.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <rt.h>
#include <internals.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 * Nearest neighbour interpolation
 * See
 * - https://en.wikipedia.org/wiki/Nearest-neighbor_interpolation
 */

static void
nn_run (aktive_block* window, double tx, double ty, double* dst, aktive_uint depth)
{
    // nearest neighbour interpolation
    // window->pixel contains dst data, the window calculation did the inteprolation for us.
    ASSERT (window->used == depth, "fetch depth mismatch");

    memcpy (dst, window->pixel, depth*sizeof(double));
}

extern aktive_interpolator*
aktive_interpolator_nneighbour (void)
{
    static aktive_interpolator interpolator = {
        .size   = 1,
	.offset = 0,
	.run    = &nn_run
    };

    return &interpolator;
}

/*
 * - - -- --- ----- -------- -------------
 * Bilinear interpolation
 * See
 * - https://en.wikipedia.org/wiki/Bilinear_interpolation
 */

#define LINEAR(a,b,t)            ((1-(t))*(a) + (t)*(b))
#define BILINEAR(a,b,c,d,t0,t1)  LINEAR (LINEAR (a,b,t0), LINEAR (c,d,t0), t1)

static void
bilinear_run (aktive_block* window, double tx, double ty, double* dst, aktive_uint depth)
{
    //            x
    // window = y|a b|, where * the location of the fractional pixel
    //           | * |
    //           |c d|
    //
    // Beware of the `depth`.
    // The values to use are `depth` distant from each other.
    //
    // The fractional pixel is at (x+tx, y+ty),
    // where (x,y) is the window location.

    ASSERT (window->used == 4*depth, "fetch window depth mismatch");

    // Iterate over the bands
    aktive_uint z;
    for (z =0; z < depth; z++) {
	double a = window->pixel [z+0*depth];
	double b = window->pixel [z+1*depth];
	double c = window->pixel [z+2*depth];
	double d = window->pixel [z+3*depth];

	dst [z] = BILINEAR (a, b, c, d, tx, ty);
    }
}

extern aktive_interpolator*
aktive_interpolator_bilinear (void)
{
    static aktive_interpolator interpolator = {
        .size   = 2,
	.offset = 0,
	.run    = &bilinear_run
    };

    return &interpolator;
}

/*
 * - - -- --- ----- -------- -------------
 * Bicubic interpolation.
 * See
 * (1) http://en.wikipedia.org/wiki/Bicubic_interpolation
 * (2) http://www.paulinternet.nl/?page=bicubic
 */

static double bicubic (double a, double b, double c, double d, double t)
{
    // window = |a b  *  c d|
    //           0 1 1+t 2 3 - window indexing
    //          -1 0  t  1 2 - interpolation indices
    //          p0 p1   p2 p3 (ref 2)
    //
    // f(x) = a'xxx + b'xx + c'x + d'
    //      = (axx + b'x + c')x + d'
    //      = ((a'x + b')x + c')x + d'	Horner form
    //
    //   a' = -1/2 p0 + 3/2 p1 - 3/2 p2 + 1/2 p3	= 1/2 (p3 - p0 + 3 (p1 - p2))
    //   b' =      p0 - 5/2 p1 +   2 p2 - 1/2 p3	= 1/2 (2(p0 + 2p2) - 5p1 - p3)
    //   c' = -1/2 p0 + 1/2 p2				= 1/2 (p2 - p0)
    //   d' = p1					= 1/2 (2p1)
    //
    //   p0 = a		map to function parameters
    //   p1 = b
    //   p2 = c
    //   p3 = d

    double at = d - a + 3*(b - c);
    double bt = 2*(a + 2*c) - 5*b - d;
    double ct = c - a;
    double dt = 2* b;

    return 0.5*(((at*t + bt)*t + ct)*t + dt);
}

static void
bicubic_run (aktive_block* window, double tx, double ty, double* dst, aktive_uint depth)
{
    //            x
    // window = y|a b c d|, where * the location of the fractional pixel
    //           |e f g h|
    //           |   *   |
    //           |i j k l|
    //           |m n o p|
    //            0 1 2 3
    //
    // Beware of the `depth`.
    // The values to use are `depth` distant from each other.
    //
    // The fractional pixel is at (x+1+tx, y+1+ty),
    // where (x,y) is the window location.

    ASSERT (window->used == 16*depth, "fetch window depth mismatch");

    // Iterate over the bands
    aktive_uint z;
    for (z = 0; z < depth; z++) {
	double a = window->pixel [z+ 0*depth];
	double b = window->pixel [z+ 1*depth];
	double c = window->pixel [z+ 2*depth];
	double d = window->pixel [z+ 3*depth];

	double e = window->pixel [z+ 4*depth];
	double f = window->pixel [z+ 5*depth];
	double g = window->pixel [z+ 6*depth];
	double h = window->pixel [z+ 7*depth];

	double i = window->pixel [z+ 8*depth];
	double j = window->pixel [z+ 9*depth];
	double k = window->pixel [z+10*depth];
	double l = window->pixel [z+11*depth];

	double m = window->pixel [z+12*depth];
	double n = window->pixel [z+13*depth];
	double o = window->pixel [z+14*depth];
	double p = window->pixel [z+15*depth];

	dst [z] = bicubic (bicubic (a, b, c, d, tx),
			   bicubic (e, f, g, h, tx),
			   bicubic (i, j, k, l, tx),
			   bicubic (m, n, o, p, tx), ty);
    }
}

extern aktive_interpolator*
aktive_interpolator_bicubic (void)
{
    static aktive_interpolator interpolator = {
        .size   = 4,
	.offset = 1,
	.run    = &bicubic_run
    };

    return &interpolator;
}

/*
 * - - -- --- ----- -------- -------------
 * See
 * - [1] https://mazzo.li/posts/lanczos.html
 * - [2] https://en.wikipedia.org/wiki/Lanczos_resampling
 * - [3] https://github.com/jeffboody/Lanczos
 */

static double
lanczos3 (double x)
{
    const double a = 3;	// order
    if (x <  0) x = -x;
    if (x >= a) return 0;
    if (x == 0) return 1;
    x *= M_PI;
    double r = a * sin(x) * sin(x/a) / (x*x);
    return r;
}

static double lanczos (double a, double b, double c, double d, double e, double f, double t)
{
    // window = | a    b   c   * d   e   f |
    //           -2   -1   0   t 1   2   3
    //           -2-t -1-t 0-t 0 1-t 2-t 3-t => weight factors from lanczos core function.

    double wa = lanczos3 (-2-t);
    double wb = lanczos3 (-1-t);
    double wc = lanczos3 ( 0-t);
    double wd = lanczos3 ( 1-t);
    double we = lanczos3 ( 2-t);
    double wf = lanczos3 ( 3-t);

    return a*wa + b* wb + c*wc + d*wd + e*we + f*wf;
}

static void
lanczos_run (aktive_block* window, double tx, double ty, double* dst, aktive_uint depth)
{
    // window = | aa ab ac ad ae af |, where * the location of the fractional pixel
    //          | ba bb bc bd be bf |
    //          | ca cb cc cd ce cf |
    //          |         *         |
    //          | da db dc dd de df |
    //          | ea eb ec ed ee ef |
    //          | fa fb fc fd fe ff |
    //
    // Beware of the `depth`.
    // The values to use are `depth` distant from each other.

    ASSERT (window->used == 36*depth, "fetch window depth mismatch");

    // Iterate over the bands
    aktive_uint z;
    for (z =0; z < depth; z++) {
	double aa = window->pixel [z+ 0*depth];
	double ba = window->pixel [z+ 1*depth];
	double ca = window->pixel [z+ 2*depth];
	double da = window->pixel [z+ 3*depth];
	double ea = window->pixel [z+ 4*depth];
	double fa = window->pixel [z+ 5*depth];

	double ab = window->pixel [z+ 6*depth];
	double bb = window->pixel [z+ 7*depth];
	double cb = window->pixel [z+ 8*depth];
	double db = window->pixel [z+ 9*depth];
	double eb = window->pixel [z+10*depth];
	double fb = window->pixel [z+11*depth];

	double ac = window->pixel [z+12*depth];
	double bc = window->pixel [z+13*depth];
	double cc = window->pixel [z+14*depth];
	double dc = window->pixel [z+15*depth];
	double ec = window->pixel [z+16*depth];
	double fc = window->pixel [z+17*depth];

	double ad = window->pixel [z+18*depth];
	double bd = window->pixel [z+19*depth];
	double cd = window->pixel [z+20*depth];
	double dd = window->pixel [z+21*depth];
	double ed = window->pixel [z+22*depth];
	double fd = window->pixel [z+23*depth];

	double ae = window->pixel [z+24*depth];
	double be = window->pixel [z+25*depth];
	double ce = window->pixel [z+26*depth];
	double de = window->pixel [z+27*depth];
	double ee = window->pixel [z+28*depth];
	double fe = window->pixel [z+29*depth];

	double af = window->pixel [z+30*depth];
	double bf = window->pixel [z+31*depth];
	double cf = window->pixel [z+32*depth];
	double df = window->pixel [z+33*depth];
	double ef = window->pixel [z+34*depth];
	double ff = window->pixel [z+35*depth];

	dst [z] = lanczos (lanczos (aa, ab, ac, ad, ae, af, tx),
			   lanczos (ba, bb, bc, bd, be, bf, tx),
			   lanczos (ca, cb, cc, cd, ce, cf, tx),
			   lanczos (da, db, dc, dd, de, df, tx),
			   lanczos (ea, eb, ec, ed, ee, ef, tx),
			   lanczos (fa, fb, fc, fd, fe, ff, tx), ty);
    }
}

extern aktive_interpolator*
aktive_interpolator_lanczos (void)
{
    static aktive_interpolator interpolator = {
        .size   = 6,
	.offset = 2,
	.run    = &lanczos_run
    };

    return &interpolator;
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
