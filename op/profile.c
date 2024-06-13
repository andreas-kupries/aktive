
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
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_profile_fill (aktive_ivcache_context* context, aktive_uint index, double* dst)
{
    TRACE_FUNC("([%d] %u,%u[%u] (dst) %p [%u])", index, context->request->y,
	       context->z, context->stride, dst, context->size);

    TRACE_RECTANGLE_M("profile request", context->request);

    aktive_block* src = aktive_region_fetch_area (context->src, context->request);

    // compute the profile directly into the destination
    // properly offset into the requested band, with stride

    aktive_profile (dst, context->size, src->pixel + context->z, context->stride);

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
