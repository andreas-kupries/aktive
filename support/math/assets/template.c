/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Vector Operations. Scalar loops.
 *
 * Generated code. See
 *
 * - support/math/assets/template.c	Template
 * - support/math/generator.tcl		Generator
 */

#include <generated/math.h>
#include <math.h>
#include <complex.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

void aktive_vector_unary_const (double* dst, aktive_uint num, double value)
{
  TRACE_FUNC("((dst) %p, (num) %u, (value) %f)", dst, num, value);
  TRACE_RUN (double* dhead = dst);

  for (; num > 0; num--, dst ++) {
    TRACE("d[%u] = %f", dst-dhead, value);
    *dst = value;
  }

  TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 * definition support - gamma_compress/expand operators
 */

#define GAMMA  (2.4)
#define GLIMIT (0.04045)
#define IGAIN  (12.92)
#define ILIMIT (0.0031308)
#define OFFSET (0.055)
#define SCALE  (1.055)

/*
 * - - -- --- ----- -------- -------------
 * vector function definitions
 */

@definitions@

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
