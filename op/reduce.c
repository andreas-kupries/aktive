/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Reducer utility functions.
 */

/*
 * - - -- --- ----- -------- -------------
 */

#include <amath.h>
#include <kahan.h>
#include <reduce.h>

/*
 * - - -- --- ----- -------- -------------
 */

extern double
aktive_reduce_max (double* v, aktive_uint n, aktive_uint stride)
{
    double max = v[0];
    v += stride;
    for (aktive_uint k = 1; k < n; k++, v += stride) {
	double x = *v;
	max = MAX (max, x);
    }
    return max;
}

extern double
aktive_reduce_mean (double* v, aktive_uint n, aktive_uint stride)
{
    return aktive_reduce_sum (v, n, stride) / (double) n;
}

extern double
aktive_reduce_min (double* v, aktive_uint n, aktive_uint stride)
{
    double min = v[0];
    v += stride;
    for (aktive_uint k = 1; k < n; k++, v += stride) {
	double x = *v;
	min = MIN (min, x);
    }
    return min;
}

extern double
aktive_reduce_stddev (double* v, aktive_uint n, aktive_uint stride)
{
    return sqrt (aktive_reduce_variance (v, n, stride));
}

extern double
aktive_reduce_sum (double* v, aktive_uint n, aktive_uint stride)
{
    kahan sum;
    aktive_kahan_init (&sum);
    for (aktive_uint k = 0; k < n; k++, v += stride) { aktive_kahan_add (&sum, *v); }
    return aktive_kahan_final (&sum);
}

extern double
aktive_reduce_sumsquared (double* v, aktive_uint n, aktive_uint stride)
{
    kahan sum;
    aktive_kahan_init (&sum);
    for (aktive_uint k = 0; k < n; k++, v += stride) {
	double x = *v;
	aktive_kahan_add (&sum, x*x);
    }

    return aktive_kahan_final (&sum);
}

extern double
aktive_reduce_variance (double* v, aktive_uint n, aktive_uint stride)
{
    // Another equivalent formula is σ² = ( (Σ x²) / N ) - μ²

    kahan sum;     aktive_kahan_init (&sum);
    kahan squared; aktive_kahan_init (&squared);

    for (aktive_uint k = 0; k < n; k++, v += stride) {
	double x = *v;
	aktive_kahan_add (&sum, x);
	aktive_kahan_add (&squared, x*x);
    }

    double mean = aktive_kahan_final (&sum)     / (double) n;
    double sq   = aktive_kahan_final (&squared) / (double) n;

    return sq - mean*mean;
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
