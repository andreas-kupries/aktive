/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Vector Operations. Direct implementation (C `for`)
 */

#include <generated/vector_direct.h>
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
 * vector function definitions
 */

@vdefs@

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
