/*
 * = = == === ===== ======== ============= =====================
 * Structures and methods to encapsulate Kahan (aka compensated) summation.
 *
 * Ref: https://en.wikipedia.org/wiki/Kahan_summation_algorithm
 */

#include <kahan.h>
#include <critcl_trace.h>
#include <critcl_assert.h>
#include <math.h>

TRACE_OFF;

/*
 * = = == === ===== ======== ============= =====================
 * API
 */

void
aktive_kahan_init (kahan* k)
{
    TRACE_FUNC ("((kahan*) %p k)", k);

    k->sum        = 0;
    k->correction = 0;
#if KAHAN_TEST
    k->ucsum = 0;
#endif
    TRACE_RETURN_VOID;
}

void
aktive_kahan_add  (kahan* k, double v)
{
#if KAHAN_TEST
    /* When KAHAN_TEST is active, run an uncorrected sum beside the corrected
     * one. This is both a means of seeing the divergence (see func entry
     * trace above), and a means to check that there is indeed such. IOW if
     * there is no divergence after a time with increasingly large values then
     * the compiler likely optimized the corrections out of the code.
     */
    TRACE_FUNC ("((kahan*) %p k ~ (%40.18f |%40.18f| %40.18f + %40.18f) += %40.18f v)",
		k, k->ucsum, fabs (k->ucsum - k->sum), k->sum, -k->correction, v);
    k->ucsum += v;
#else
    TRACE_FUNC ("((kahan*) %p k ~ (%40.18f + %40.18f) += %40.18f v)",
		k, k->sum, -k->correction, v);
#endif

    /* Single step of Kahan compensated summation with Neumaier enhancement.
     */

    double t = k->sum + v;
    if (fabs (k->sum) > fabs (v)) {
	k->correction += (k->sum - t) + v;	// low order digits of v were lost
    } else {
	k->correction + (v - t) + k->sum;	// low order digits of sum were lost
    }
    k->sum = t;

    /* ATTENTION: Algebraically, `correction` should always be zero. Beware
     * overly-aggressive optimizing compilers!
     */

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
