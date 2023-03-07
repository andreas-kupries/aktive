/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Matrix utility functions.
 */

#include <tcl.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <matrix.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_matrix_mul (double* z, double* vec, double* mat, aktive_uint mwidth, aktive_uint mheight)
{
    TRACE_FUNC ("(z) %p [%d], (vec) %p [%d], (mat) %p [%d x %d]",
		z, mheight, vec, mheight, mat, mwidth, mheight);
    
    for (aktive_uint col = 0; col < mwidth; col ++, mat++, z++) {
	*z = aktive_scalar_mul (vec, mat, mheight, mwidth);
    }

    TRACE_RETURN_VOID;
}

extern double
aktive_scalar_mul (double* a, double* b, aktive_uint n, aktive_uint bstride)
{
    TRACE_FUNC ("(a) %p [%d], (b) %p [%d|%d]", a, n, b, n, bstride);
    
    double sum = 0;
    for (aktive_uint i = 0; i < n; i++, a++, b += bstride) {
	TRACE ("* [%d]", i);
	sum += (*a) * (*b);
    }

    TRACE_RETURN ("%f", sum);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
