/* -*- c -*-
 *
 * -- Direct operator support - formatting image as Tcl structure
 */
#ifndef AKTIVE_MATH_H
#define AKTIVE_MATH_H

#include <math.h>
#include <complex.h>

/*
 * - - -- --- ----- -------- -------------
 * min, max, (bi)linear interpolation
 */

#define MAX(a,b) ((a) > (b) ? (a) : (b))
#define MIN(a,b) ((a) < (b) ? (a) : (b))

/* Note:
 *       As implemented `a`, `b` are evaluated once, while `t` is evaluated twice.
 *       The alternate implementation "a + t*(b-a)" evaluates `a` twice.
 *
 *       For bilinear the `a` to `d` are evaluated once, `t1` twice, and `t0` four
 *       times.
 */

#define LINEAR(a,b,t)            ((1-(t))*(a) + (t)*(b))
#define BILINEAR(a,b,c,d,t0,t1)  LINEAR (LINEAR (a,b,t0), LINEAR (c,d,t0), t1)

/*
 * - - -- --- ----- -------- -------------
 */

// extern double aktive_linear   (double a, double b, double t);
// extern double aktive_bilinear (double a, double b, double c, double d, double t0, double t1);

extern double aktive_clamp          (double x);
extern double aktive_exp10          (double x);
extern double aktive_gamma_compress (double x);
extern double aktive_gamma_expand   (double x);
extern double aktive_invert         (double x);
extern double aktive_neg            (double x);
extern double aktive_reciprocal     (double x);
extern double aktive_sign           (double x);
extern double aktive_signb          (double x);
extern double aktive_square         (double x);
extern double aktive_wrap           (double x);

extern double aktive_shift  (double x, double offset);
extern double aktive_nshift (double x, double offset);
extern double aktive_scale  (double x, double factor);
extern double aktive_rscale (double x, double factor);
extern double aktive_fmod   (double x, double numerator);
extern double aktive_pow    (double x, double base);
extern double aktive_atan   (double x, double y);
extern double aktive_sol    (double x, double threshold);

extern double aktive_eq     (double x, double threshold);
extern double aktive_ge     (double x, double threshold);
extern double aktive_gt     (double x, double threshold);
extern double aktive_le     (double x, double threshold);
extern double aktive_lt     (double x, double threshold);
extern double aktive_ne     (double x, double threshold);

extern double aktive_inside_oo  (double x, double low, double high);
extern double aktive_inside_oc  (double x, double low, double high);
extern double aktive_inside_co  (double x, double low, double high);
extern double aktive_inside_cc  (double x, double low, double high);

extern double aktive_outside_oo (double x, double low, double high);
extern double aktive_outside_oc (double x, double low, double high);
extern double aktive_outside_co (double x, double low, double high);
extern double aktive_outside_cc (double x, double low, double high);

extern double aktive_add (double x, double y);
extern double aktive_div (double x, double y);
extern double aktive_mul (double x, double y);
extern double aktive_sub (double x, double y);

extern double aktive_not  (double x);
extern double aktive_and  (double x, double y);
extern double aktive_nand (double x, double y);
extern double aktive_or   (double x, double y);
extern double aktive_nor  (double x, double y);
extern double aktive_xor  (double x, double y);

extern double complex aktive_cmath_add (double complex a, double complex b);
extern double complex aktive_cmath_div (double complex a, double complex b);
extern double complex aktive_cmath_mul (double complex a, double complex b);
extern double complex aktive_cmath_sub (double complex a, double complex b);

extern double complex aktive_cmath_cartesian  (double complex a);
extern double complex aktive_cmath_cbrt       (double complex a);
extern double complex aktive_cmath_exp10      (double complex a);
extern double complex aktive_cmath_exp2       (double complex a);
extern double complex aktive_cmath_log10      (double complex a);
extern double complex aktive_cmath_log2       (double complex a);
extern double complex aktive_cmath_neg        (double complex a);
extern double complex aktive_cmath_polar      (double complex a);
extern double complex aktive_cmath_reciprocal (double complex a);
extern double complex aktive_cmath_sign       (double complex a);

extern double         aktive_cmath_sqabs      (double complex a);

extern double aktive_lanczos (int order, double x);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_MATH_H */
