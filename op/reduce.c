/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Reducer utility functions.
 *
 * Note: The image level reduction use the batch processor API directly,
 *       instead of through a sink. The sink API is a bit restricted, as it
 *       assumes that the workers always return pixel blocks.
 *
 *       While the the reduction workers fetch pixel blocks as usual they do
 *       not return these, but the result of a partial reduction of that
 *       block.  That way the completer only has to merge small partial
 *       results into a final result.
 *
 *       Having the completer doing the reductions, as the sink would force us
 *       to would completely negate the reason for using batch processing,
 *       i.e. doing several expensive things concurrently.
 *
 * Note: The way the reduction are done make them independent of the
 *       demand-style. While the current task maker is row-based (thin strip)
 *       changing it to any other demand style does not change workers, nor
 *       completer.
 */

/*
 * - - -- --- ----- -------- -------------
 */

#include <amath.h>
#include <kahan.h>
#include <reduce.h>
#include <batch.h>

#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

static void sum_1           (kahan* rsum, double* v, aktive_uint n, aktive_uint stride);
static void sum_squared     (kahan* rsum, double* v, aktive_uint n, aktive_uint stride);
static void sum_and_squared (kahan* rsum, kahan* rsquared,
			     double* v, aktive_uint n, aktive_uint stride);

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
    sum_1 (&sum, v, n, stride);
    return aktive_kahan_final (&sum);
}

extern double
aktive_reduce_sumsquared (double* v, aktive_uint n, aktive_uint stride)
{
    kahan sum;
    sum_squared (&sum, v, n, stride);
    return aktive_kahan_final (&sum);
}

extern double
aktive_reduce_variance (double* v, aktive_uint n, aktive_uint stride)
{
    // wikipedia: [...] Another equivalent formula is σ² = ( (Σ x²) / N ) - μ²

    kahan sum;    
    kahan squared;

    sum_and_squared (&sum, &squared, v, n, stride);

    double mean = aktive_kahan_final (&sum)     / (double) n;
    double sq   = aktive_kahan_final (&squared) / (double) n;

    return sq - mean*mean;
}

/*
 * - - -- --- ----- -------- -------------
 */

static void
sum_1 (kahan* rsum, double* v, aktive_uint n, aktive_uint stride)
{
    kahan sum; aktive_kahan_init (&sum);

    for (aktive_uint k = 0; k < n; k++, v += stride) { aktive_kahan_add (&sum, *v); }

    *rsum = sum;
}

static void
sum_squared (kahan* rsum, double* v, aktive_uint n, aktive_uint stride)
{
    kahan sum; aktive_kahan_init (&sum);
    
    for (aktive_uint k = 0; k < n; k++, v += stride) {
	double x = *v;
	aktive_kahan_add (&sum, x*x);
    }

    *rsum = sum;
}

static void
sum_and_squared (kahan* rsum, kahan* rsquared, double* v, aktive_uint n, aktive_uint stride)
{
    kahan sum;     aktive_kahan_init (&sum);
    kahan squared; aktive_kahan_init (&squared);

    for (aktive_uint k = 0; k < n; k++, v += stride) {
	double x = *v;
	aktive_kahan_add (&sum, x);
	aktive_kahan_add (&squared, x*x);
    }

    *rsum     = sum;
    *rsquared = squared;
}

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct reduce_result {
    kahan main;	// sum
    kahan aux;	// sum-squared
} reduce_result;

typedef struct reduce_batch_state {
    // maker
    aktive_rectangle scan;
    aktive_uint      count;

    // worker
    aktive_image     image;
    
    // completer
    aktive_uint size;

    // notes on `acc`
    // - stddev, variance use `main` and `aux`
    // - mean, sum, sumsquared use only the `main`
    // - min, max use only `main.sum`.

    reduce_result acc;
    aktive_uint   initialized;
        
    double*     result;
} reduce_batch_state;

/*
 * - - -- --- ----- -------- -------------
 */

static void*
image_maker (reduce_batch_state* state)
{
    TRACE_FUNC("((reduce_batch_state*) %p, %d remaining)", state, state->count);
    
    // All rows scanned, stop
    if (!state->count) {
	TRACE_RETURN ("(rect*) %p, EOF", 0);
    }

    aktive_rectangle* r = ALLOC (aktive_rectangle);
    aktive_rectangle_copy (r, &state->scan); 

    state->count --;
    aktive_rectangle_move (&state->scan, 0, 1);

    TRACE_RECTANGLE (r);
    TRACE_RETURN ("(rect*) %p", r);
}

/*
 * - - -- --- ----- -------- -------------
 */

static double
image_reduce (const char*           name,
	      aktive_image          src,
	      aktive_batch_work     worker,
	      aktive_batch_complete completer)
{
    TRACE_FUNC ("(aktive_image) %p", src);

    double result;
    reduce_batch_state batch;					
    
    aktive_rectangle_copy (&batch.scan, aktive_image_get_domain (src));
    batch.count       = batch.scan.height;
    batch.scan.height = 1;
    //
    batch.image       = src;
    //
    batch.size        = aktive_image_get_size (src);
    aktive_kahan_init (&batch.acc.main);
    aktive_kahan_init (&batch.acc.aux);
    batch.initialized = 0;
    batch.result      = &result; // completer target on finalization

    aktive_batch_run (name,					
		      (aktive_batch_make) image_maker,
		      worker,
		      completer,
		      0, // statistics can be merged in any order
		      &batch);						

    TRACE_RETURN ("(result) %f", result);
}

/*
 * - - -- --- ----- -------- -------------
 */

#define PARTIAL (result->main)
#define P_AUX   (result->aux)
#define ACC     (state->acc.main)
#define AUX     (state->acc.aux)
#define FINAL   (*state->result)

#include <generated/reduce.c>

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
