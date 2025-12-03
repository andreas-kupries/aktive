/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Vector Operations. Scalar loops.
 *
 * Generated code. See
 *
 * - data/math-gen.tcl
 * - data/mathfunc/spec.tcl
 * - data/mathfunc/fragments.tcl
 * - data/mathfunc/template-scalar.c
 */

#include <generated/vector_scalar.h>
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
 * definition support - gamma_compress/expand
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

@vdefn@

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
