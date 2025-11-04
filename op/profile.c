
/*
 * - - -- --- ----- -------- -------------
 */

#include <profile.h>

#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_profile (double* dst, aktive_uint n, double* src, aktive_uint stride)
{
    TRACE_FUNC ("(dst %p [%u] = sum (src %p [%u*%u]))", dst, n, src, n, stride);

    TRACE_HEADER(1); TRACE_ADD ("src  = {", 0);
    for (int k = 0; k < n; k++) { TRACE_ADD (" %f", src[k*stride]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    aktive_uint i;
    dst[0] = (double) n;
    for (i = 0; i < n; i++) {
	double v = src [i*stride];

	if (v == 0) continue;

	dst[0] = (double) i;
	break;
    }

    TRACE ("profile = { %f }", dst[0]);
    TRACE_RETURN_VOID;
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
