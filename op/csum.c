
/*
 * - - -- --- ----- -------- -------------
 */

#include <csum.h>
#include <kahan.h>

#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_cumulative_sum (double* dst, aktive_uint n, double* src, aktive_uint stride)
{
    TRACE_FUNC ("(dst %p [%u] = sum (src %p [%u*%u]))", dst, n, src, n, stride);

    kahan running_sum;
    aktive_kahan_init (&running_sum);

    aktive_uint i;
    for (i = 0; i < n; i++) {
	double v = src [i*stride];
	aktive_kahan_add (&running_sum, v);
	dst[i] = aktive_kahan_final (&running_sum);
    }

    TRACE_HEADER(1); TRACE_ADD ("csum = {", 0);
    for (i = 0; i < n; i++) { TRACE_ADD (" %f", dst[i]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    TRACE_RETURN_VOID;

}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_csum_fill (aktive_csum_context* context, aktive_uint index, double* dst)
{
    TRACE_FUNC("([%d] %u,%u[%u] (dst) %p [%u])", index, context->request->y,
	       context->z, context->stride, dst, context->size);

    aktive_block* src = aktive_region_fetch_area (context->src, context->request);

    // compute the cumulative sum directly into the destination
    // properly offset into the requested band, with stride

    aktive_cumulative_sum (dst, context->size, src->pixel + context->z, context->stride);

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
