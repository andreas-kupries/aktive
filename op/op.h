/* -*- c -*-
 *
 * -- Direct operator support - formatting image as Tcl structure
 */
#ifndef AKTIVE_OP_H
#define AKTIVE_OP_H

#include <rt.h>
#include <math.h>

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

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_OP_H */
