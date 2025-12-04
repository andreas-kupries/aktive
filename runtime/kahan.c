/*
 * = = == === ===== ======== ============= =====================
 * Structures and methods to encapsulate Kahan (aka compensated) summation.
 *
 * Ref:
 *  - https://en.wikipedia.org/wiki/Kahan_summation_algorithm#Further_enhancements
 *  - https://www.mat.univie.ac.at/~neum/scan/01.pdf
 *    (local copy: doc-internal/references/neumaier.pdf)
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

#ifdef KAHAN_FUNC
void
aktive_kahan_init_c (kahan* k)
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
aktive_kahan_add_kahan_c (kahan* k, kahan* v) {
    // note: with the neumaier variant I wonder if I can add sum and
    // correction separately, i.e. like a 2d vector
    aktive_kahan_add  (k, v->correction);
    aktive_kahan_add  (k, v->sum);
}

void
aktive_kahan_add_c (kahan* k, double v)
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
	k->correction += (v - t) + k->sum;	// low order digits of sum were lost
    }
    k->sum = t;

    /* ATTENTION: Algebraically, `correction` should always be zero. Beware
     * overly-aggressive optimizing compilers!
     */

    TRACE_RETURN_VOID;
}

#endif // KAHAN_FUNC
/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
