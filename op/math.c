/* -*- c -*-
 *
 * -- Direct operator support
 *    -- formatting image as Tcl structure
 *
 * -- Math for the transformers
 */

#include <amath.h>

#include <tcl.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern double aktive_clamp      (double x) { return (x < 0) ? 0 : (x > 1) ? 1 : x; }
extern double aktive_invert     (double x) { return 1 - x; }
extern double aktive_neg        (double x) { return -x; }
extern double aktive_reciprocal (double x) { return 1.0/x; }
extern double aktive_sign       (double x) { return (x < 0) ? -1 : (x > 0) ? 1 : 0; }
extern double aktive_signb      (double x) { return (x < 0) ? -1 : 1; }
extern double aktive_wrap       (double x) { return (x > 1) ? fmod(x, 1) : (x < 0) ? (1 + fmod(x - 1, 1)) : x; }

// apparently `exp10` is a GNU thing, whereas exp2 is not, nor is log10
extern double aktive_exp10      (double x) { return pow (10, x); }

/* sRGB specification
 * - gamma transfer functions
 *   https://en.wikipedia.org/wiki/SRGB#The_sRGB_transfer_function_(%22gamma%22)
 *
 * compress :: (scRGB) linear light -> sRGB
 * expand   :: sRGB -> linear light (scRGB)
 */

#define GAMMA  (2.4)
#define IGAMMA (1.0/GAMMA)
#define IGAIN  (12.92)
#define GAIN   (1.0/IGAIN)
#define GLIMIT (0.4045)
#define ILIMIT (0.0031308)
#define OFFSET (0.055)
#define SCALE  (1.055)

extern double
aktive_gamma_compress (double x) {
    /* BEWARE :: Assumes x in [0..1] */
    TRACE_FUNC ("((double) %f)", x);
    double value =
        (x <= ILIMIT)
        ? x * IGAIN
        : SCALE * pow (x, IGAMMA) - OFFSET
        ;
    TRACE_RETURN ("(double) %f", value);
}

extern double
aktive_gamma_expand (double x) {
    TRACE_FUNC ("((double) %f)", x);
    double value =
        (x <= GLIMIT)
        ? x * GAIN
        : pow ((x + OFFSET) / SCALE, GAMMA)
        ;
    TRACE_RETURN ("(double) %f", value);
}

/*
 * - - -- --- ----- -------- -------------
 * TODO research :: C builtin math operators available as functions ?
 */

extern double aktive_shift  (double x, double offset)    { return x + offset; }
extern double aktive_nshift (double x, double offset)    { return offset - x; }
extern double aktive_scale  (double x, double factor)    { return x * factor; }
extern double aktive_rscale (double x, double factor)    { return factor / x; }
extern double aktive_fmod   (double x, double numerator) { return fmod (numerator, x); }
extern double aktive_pow    (double x, double base)      { return pow (base, x); }
extern double aktive_atan   (double x, double y)         { return atan2 (y, x); }
extern double aktive_sol    (double x, double threshold) { return (x <= threshold) ? x : 1-x; }

extern double aktive_eq     (double x, double threshold) { return (x == threshold) ? 1 : 0; }
extern double aktive_ge     (double x, double threshold) { return (x >= threshold) ? 1 : 0; }
extern double aktive_gt     (double x, double threshold) { return (x >  threshold) ? 1 : 0; }
extern double aktive_le     (double x, double threshold) { return (x <= threshold) ? 1 : 0; }
extern double aktive_lt     (double x, double threshold) { return (x <  threshold) ? 1 : 0; }
extern double aktive_ne     (double x, double threshold) { return (x != threshold) ? 1 : 0; }

/*
 * - - -- --- ----- -------- -------------
 */

extern double aktive_inside_oo  (double x, double low, double high) { return (low <  x) && (x <  high) ? 1 : 0; }
extern double aktive_inside_oc  (double x, double low, double high) { return (low <  x) && (x <= high) ? 1 : 0; }
extern double aktive_inside_co  (double x, double low, double high) { return (low <= x) && (x <  high) ? 1 : 0; }
extern double aktive_inside_cc  (double x, double low, double high) { return (low <= x) && (x <= high) ? 1 : 0; }
extern double aktive_outside_oo (double x, double low, double high) { return (low <  x) && (x <  high) ? 0 : 1; }
extern double aktive_outside_oc (double x, double low, double high) { return (low <  x) && (x <= high) ? 0 : 1; }
extern double aktive_outside_co (double x, double low, double high) { return (low <= x) && (x <  high) ? 0 : 1; }
extern double aktive_outside_cc (double x, double low, double high) { return (low <= x) && (x <= high) ? 0 : 1; }

/*
 * - - -- --- ----- -------- -------------
 * TODO research :: C builtin math operators available as functions ?
 */

extern double aktive_add (double x, double y) { return x + y; }
extern double aktive_div (double x, double y) { return x / y; }
extern double aktive_mul (double x, double y) { return x * y; }
extern double aktive_sub (double x, double y) { return x - y; }

/*
 * - - -- --- ----- -------- -------------
 */

extern double complex aktive_cmath_div (double complex a, double complex b) { return a / b; }
extern double complex aktive_cmath_mul (double complex a, double complex b) { return a * b; }
extern double complex aktive_cmath_add (double complex a, double complex b) { return a + b; }
extern double complex aktive_cmath_sub (double complex a, double complex b) { return a - b; }

extern double complex aktive_cmath_neg        (double complex a) { return -a; }
extern double complex aktive_cmath_log2       (double complex a) { return clog (a) / log(2);  }
extern double complex aktive_cmath_log10      (double complex a) { return clog (a) / log(10); }
extern double complex aktive_cmath_cbrt       (double complex a) { return cpow (a, 1./3.); }
extern double complex aktive_cmath_exp10      (double complex a) { return cpow (10, a); }
extern double complex aktive_cmath_exp2       (double complex a) { return cpow (2, a); }
extern double complex aktive_cmath_reciprocal (double complex a) { return 1 / a; }
extern double complex aktive_cmath_polar      (double complex a) { return CMPLX (cabs (a), carg (a)); }
extern double complex aktive_cmath_cartesian  (double complex a) { return CMPLX (creal(a) * cos(cimag (a)),
										 creal(a) * sin(cimag (a))); }
extern double aktive_cmath_sqabs (double complex a)
{
    double r = creal (a);
    double i = cimag (a);
    return r*r + i*i;
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
