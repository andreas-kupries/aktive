/* -*- c -*-
 *
 * -- Direct operator support - formatting image as Tcl structure
 */
#ifndef AKTIVE_OP_H
#define AKTIVE_OP_H

#include <rt.h>
#include <math.h>
#include <complex.h>

/* - - -- --- ----- -------- -------------
 * Helper functions for the individual operators
 * Shared code, and large blocks
 */

static Tcl_Obj* aktive_op_astcl    (Tcl_Interp* ip, aktive_image src);
static Tcl_Obj* aktive_op_params   (Tcl_Interp* ip, aktive_image src);
static Tcl_Obj* aktive_op_pixels   (Tcl_Interp* ip, aktive_image src);
static Tcl_Obj* aktive_op_geometry (Tcl_Interp* ip, aktive_image src);

/* - - -- --- ----- -------- -------------
 * Math
 */

static double aktive_clamp          (double x);
static double aktive_exp10          (double x);
static double aktive_gamma_compress (double x);
static double aktive_gamma_expand   (double x);
static double aktive_invert         (double x);
static double aktive_neg            (double x);
static double aktive_reciprocal     (double x);
static double aktive_sign           (double x);
static double aktive_signb          (double x);
static double aktive_wrap           (double x);

static double aktive_shift  (double x, double offset);
static double aktive_nshift (double x, double offset);
static double aktive_scale  (double x, double factor);
static double aktive_rscale (double x, double factor);
static double aktive_fmod   (double x, double numerator);
static double aktive_pow    (double x, double base);
static double aktive_atan   (double x, double y);
static double aktive_sol    (double x, double threshold);

static double aktive_eq     (double x, double threshold);
static double aktive_ge     (double x, double threshold);
static double aktive_gt     (double x, double threshold);
static double aktive_le     (double x, double threshold);
static double aktive_lt     (double x, double threshold);
static double aktive_ne     (double x, double threshold);

static double aktive_inside_oo  (double x, double low, double high);
static double aktive_inside_oc  (double x, double low, double high);
static double aktive_inside_co  (double x, double low, double high);
static double aktive_inside_cc  (double x, double low, double high);

static double aktive_outside_oo (double x, double low, double high);
static double aktive_outside_oc (double x, double low, double high);
static double aktive_outside_co (double x, double low, double high);
static double aktive_outside_cc (double x, double low, double high);

static double aktive_add (double x, double y);
static double aktive_div (double x, double y);
static double aktive_mul (double x, double y);
static double aktive_sub (double x, double y);

static double complex aktive_cmath_add (double complex a, double complex b);
static double complex aktive_cmath_div (double complex a, double complex b);
static double complex aktive_cmath_mul (double complex a, double complex b);
static double complex aktive_cmath_sub (double complex a, double complex b);

static double complex aktive_cmath_cartesian  (double complex a);
static double complex aktive_cmath_cbrt       (double complex a);
static double complex aktive_cmath_exp10      (double complex a);
static double complex aktive_cmath_exp2       (double complex a);
static double complex aktive_cmath_log10      (double complex a);
static double complex aktive_cmath_log2       (double complex a);
static double complex aktive_cmath_neg        (double complex a);
static double complex aktive_cmath_polar      (double complex a);
static double complex aktive_cmath_reciprocal (double complex a);

static double aktive_cmath_sqabs   (double complex a);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_OP_H */
