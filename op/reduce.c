/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Reducer utility functions.
 *
 * Note: The image level reductions use the batch processor API directly,
 *       instead of through a sink. The sink API is a bit restricted, as it
 *       assumes that the workers always return pixel blocks.
 *
 *       While the reduction workers fetch pixel blocks as usual they do
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

#include <stdlib.h>
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
static int  double_compare  (const void* a, const void* b);

/*
 * - - -- --- ----- -------- -------------
 */

extern double
aktive_select (double* v, aktive_uint n, aktive_uint stride, double* index)
{
    double      id = *index;
    aktive_uint i  = (id < 0
		      ? 0
		      : id >= n
		      ? n-1
		      : (int) id);
    return v [i*stride];
}

/*
 * - - -- --- ----- -------- -------------
 */

extern double
aktive_reduce_argmax (double* v, aktive_uint n, aktive_uint stride, void* __client__ /* ignored */)
{
    double      max    = v[0];
    aktive_uint argmax = 0;
    v += stride;
    for (aktive_uint k = 1; k < n; k++, v += stride) {
	double x = *v;
	if (x > max) { max = x; argmax = k; }
    }
    return (double) argmax;
}

extern double
aktive_reduce_argmin (double* v, aktive_uint n, aktive_uint stride, void* __client__ /* ignored */)
{
    double      min    = v[0];
    aktive_uint argmin = 0;
    v += stride;
    for (aktive_uint k = 1; k < n; k++, v += stride) {
	double x = *v;
	if (x < min) { min = x; argmin = k; }
    }
    return (double) argmin;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern double
aktive_reduce_argge (double* v, aktive_uint n, aktive_uint stride, void* __client__)
{
    double      threshold = *((double*) __client__);
    TRACE_FUNC("((n) %u, (stride) %u, (threshold) %f)", n, stride, threshold);
    aktive_uint k;

    TRACE_HEADER(1); TRACE_ADD ("bands = {", 0);
    for (int j = 0; j < n; j++) { TRACE_ADD (" %f", v[j*stride]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    for (k = 0; k < n; k++, v += stride) {
	double x = *v;
	TRACE ("[%3d] = %f", k , x);
	if (x >= threshold) break;
    }

    TRACE_RETURN ("(index) %f", (double) k);
}

extern double
aktive_reduce_arggt (double* v, aktive_uint n, aktive_uint stride, void* __client__)
{
    double      threshold = *((double*) __client__);
    TRACE_FUNC("((n) %u, (stride) %u, (threshold) %f)", n, stride, threshold);
    aktive_uint k;

    TRACE_HEADER(1); TRACE_ADD ("bands = {", 0);
    for (int j = 0; j < n; j++) { TRACE_ADD (" %f", v[j*stride]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    for (k = 0; k < n; k++, v += stride) {
	double x = *v;
	TRACE ("[%3d] = %f", k , x);
	if (x > threshold) break;
    }

    TRACE_RETURN ("(index) %f", (double) k);
}

extern double
aktive_reduce_argle (double* v, aktive_uint n, aktive_uint stride, void* __client__)
{
    double      threshold = *((double*) __client__);
    TRACE_FUNC("((n) %u, (stride) %u, (threshold) %f)", n, stride, threshold);
    aktive_uint k;

    TRACE_HEADER(1); TRACE_ADD ("bands = {", 0);
    for (int j = 0; j < n; j++) { TRACE_ADD (" %f", v[j*stride]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    for (k = 0; k < n; k++, v += stride) {
	double x = *v;
	TRACE ("[%3d] = %f", k , x);
	if (x <= threshold) break;
    }

    TRACE_RETURN ("(index) %f", (double) k);
}

extern double
aktive_reduce_arglt (double* v, aktive_uint n, aktive_uint stride, void* __client__)
{
    double      threshold = *((double*) __client__);
    TRACE_FUNC("((n) %u, (stride) %u, (threshold) %f)", n, stride, threshold);
    aktive_uint k;

    TRACE_HEADER(1); TRACE_ADD ("bands = {", 0);
    for (int j = 0; j < n; j++) { TRACE_ADD (" %f", v[j*stride]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    for (k = 0; k < n; k++, v += stride) {
	double x = *v;
	TRACE ("[%3d] = %f", k , x);
	if (x < threshold) break;
    }

    TRACE_RETURN ("(index) %f", (double) k);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern double
aktive_reduce_max (double* v, aktive_uint n, aktive_uint stride, void* __client__ /* ignored */)
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
aktive_reduce_mean (double* v, aktive_uint n, aktive_uint stride, void* __client__ /* ignored */)
{
    return aktive_reduce_sum (v, n, stride, 0) / (double) n;
}

extern double
aktive_reduce_min (double* v, aktive_uint n, aktive_uint stride, void* __client__ /* ignored */)
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
aktive_reduce_stddev (double* v, aktive_uint n, aktive_uint stride, void* __client__ /* ignored */)
{
    return sqrt (aktive_reduce_variance (v, n, stride, 0));
}

extern double
aktive_reduce_sum (double* v, aktive_uint n, aktive_uint stride, void* __client__ /* ignored */)
{
    kahan sum;
    sum_1 (&sum, v, n, stride);
    return aktive_kahan_final (&sum);
}

extern double
aktive_reduce_sumsquared (double* v, aktive_uint n, aktive_uint stride, void* __client__ /* ignored */)
{
    kahan sum;
    sum_squared (&sum, v, n, stride);
    return aktive_kahan_final (&sum);
}

extern double
aktive_reduce_variance (double* v, aktive_uint n, aktive_uint stride, void* __client__ /* ignored */)
{
    // wikipedia: [...] Another equivalent formula is σ² = ( (Σ x²) / N ) - μ²

    kahan sum;
    kahan squared;

    sum_and_squared (&sum, &squared, v, n, stride);

    double mean = aktive_kahan_final (&sum)     / (double) n;
    double sq   = aktive_kahan_final (&squared) / (double) n;

    return sq - mean*mean;
}

extern double
aktive_reduce_rank (double* v, aktive_uint n, aktive_uint stride, void* __client__)
{
    aktive_rank* rt = __client__;
    TRACE_FUNC("((n) %u, (stride) %u, (select) %u)", n, stride, rt->select);

    ASSERT (rt->select < n, "selection index out of range");

    for (aktive_uint k = 0; k < n; k++, v += stride) {
	rt->sorted [k] = *v;
	TRACE ("[%3d] = %f", k , *v);
    }
    qsort (rt->sorted, n, sizeof(double), double_compare);
    double res = rt->sorted [rt->select];

    TRACE_RETURN ("(rank) %f", res);
}

extern void
aktive_reduce_histogram (double* v, aktive_uint n, aktive_uint stride, void* __client__)
{
    aktive_histogram* h = __client__;
    TRACE_FUNC("((n) %u, (stride) %u, (bins) %u)", n, stride, h->bins);

    memset (h->count, 0, h->bins*sizeof(double));

    for (aktive_uint k = 0; k < n; k++, v += stride) {
	int bin = (*v) * h->bins;
	bin = MAX (0, bin);
	bin = MIN (h->maxbin, bin);

	h->count [bin] += 1;
	TRACE ("[%3d] = %f -> %d/%d => %f", k , *v, bin, h->bins, h->count [bin]);
    }

    TRACE_HEADER(1); TRACE_ADD ("histogram = {", 0);
    for (int j = 0; j < h->bins; j++) { TRACE_ADD (" %f", h->count[j]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 * Region reductions, used in per-tile statistics
 *
 * TODO :: blitter, note the explicit pitch/stride/pos/cap information
 */

extern double
aktive_tile_reduce_max (double* v, aktive_uint radius, aktive_uint base,
			aktive_uint cap, aktive_uint pitch, aktive_uint stride,
			void* __client__ /* ignored */)
{
    TRACE_FUNC("((double*) %p, [%u:%u], (radius) %u, (pitch) %u, (stride) %u)",
	       v, base, cap, radius, pitch, stride);

    double max = v[0];

    int r = radius;
    for (int y = -r ; y <= r; y++) {
	for (int x = -r; x <= r; x++) {
	    int index = y*pitch + x*stride;
	    int aindex = (int) base + index;

	    TRACE_HEADER (1); TRACE_ADD ("@(%d,%d) = %u[%d] = [%d]", x, y, base, index, aindex);
	    if ((aindex < 0) || (aindex >= cap)) {
		TRACE_CLOSER; TRACE("ASSERT", 0);
		ASSERT_VA (0, "src out of bounds", "%d / %d", aindex, cap);
	    }

	    double val = v [index];

	    TRACE_ADD ("=> %f", val); TRACE_CLOSER;

	    max = MAX (max, val);
	}
    }

    TRACE_RETURN ("(max) %f", max);
}

extern double
aktive_tile_reduce_mean (double* v, aktive_uint radius, aktive_uint base,
			 aktive_uint cap, aktive_uint pitch, aktive_uint stride,
			 void* __client__ /* ignored */)
{
    TRACE_FUNC("((double*) %p, [%u:%u], (radius) %u, (pitch) %u, (stride) %u)",
	       v, base, cap, radius, pitch, stride);

    aktive_uint n = 2*radius+1; n *= n;
    double      r = aktive_tile_reduce_sum (v, radius, base, cap, pitch, stride, 0) / (double) n;

    TRACE_RETURN ("(mean) %f", r);
}

extern double
aktive_tile_reduce_min (double* v, aktive_uint radius, aktive_uint base,
			aktive_uint cap, aktive_uint pitch, aktive_uint stride,
			void* __client__ /* ignored */)
{
    TRACE_FUNC("((double*) %p, [%u:%u], (radius) %u, (pitch) %u, (stride) %u)",
	       v, base, cap, radius, pitch, stride);

    double min = v[0];

    int r = radius;
    for (int y = -r ; y <= r; y++) {
	for (int x = -r; x <= r; x++) {
	    int index = y*pitch + x*stride;
	    int aindex = (int) base + index;

	    TRACE_HEADER (1); TRACE_ADD ("@(%d,%d) = %u[%d] = [%d]", x, y, base, index, aindex);
	    if ((aindex < 0) || (aindex >= cap)) {
		TRACE_CLOSER; TRACE("ASSERT", 0);
		ASSERT_VA (0, "src out of bounds", "%d / %d", aindex, cap);
	    }

	    double val = v [index];

	    TRACE_ADD ("=> %f", val); TRACE_CLOSER;

	    min = MIN (min, val);
	}
    }

    TRACE_RETURN ("(min) %f", min);
}

extern double
aktive_tile_reduce_stddev (double* v, aktive_uint radius, aktive_uint base,
			   aktive_uint cap, aktive_uint pitch, aktive_uint stride,
			   void* __client__ /* ignored */)
{
    TRACE_FUNC("((double*) %p, [%u:%u], (radius) %u, (pitch) %u, (stride) %u)",
	       v, base, cap, radius, pitch, stride);

    double r =  sqrt (aktive_tile_reduce_variance (v, radius, base, cap, pitch, stride, 0));

    TRACE_RETURN ("(stddev) %f", r);
}

extern double
aktive_tile_reduce_sum (double* v, aktive_uint radius, aktive_uint base,
			aktive_uint cap, aktive_uint pitch, aktive_uint stride,
			void* __client__ /* ignored */)
{
    TRACE_FUNC("((double*) %p, [%u:%u], (radius) %u, (pitch) %u, (stride) %u)",
	       v, base, cap, radius, pitch, stride);

    kahan sum; aktive_kahan_init (&sum);

    int r = radius;
    for (int y = -r ; y <= r; y++) {
	for (int x = -r; x <= r; x++) {
	    int index = y*pitch + x*stride;
	    int aindex = (int) base + index;

	    TRACE_HEADER (1); TRACE_ADD ("@(%d,%d) = %u[%d] = [%d]", x, y, base, index, aindex);
	    if ((aindex < 0) || (aindex >= cap)) {
		TRACE_CLOSER; TRACE("ASSERT", 0);
		ASSERT_VA (0, "src out of bounds", "%d / %d", aindex, cap);
	    }

	    double val = v [index];

	    TRACE_ADD ("=> %f", val); TRACE_CLOSER;

	    aktive_kahan_add (&sum, val);
	}
    }

    double res = aktive_kahan_final (&sum);
    TRACE_RETURN ("(sum) %f", res);
}

extern double
aktive_tile_reduce_sumsquared (double* v, aktive_uint radius, aktive_uint base,
			       aktive_uint cap, aktive_uint pitch, aktive_uint stride,
			       void* __client__ /* ignored */)
{
    TRACE_FUNC("((double*) %p, [%u:%u], (radius) %u, (pitch) %u, (stride) %u)",
	       v, base, cap, radius, pitch, stride);

    kahan sum; aktive_kahan_init (&sum);

    int r = radius;
    for (int y = -r ; y <= r; y++) {
	for (int x = -r; x <= r; x++) {
	    int index = y*pitch + x*stride;
	    int aindex = (int) base + index;

	    TRACE_HEADER (1); TRACE_ADD ("@(%d,%d) = %u[%d] = [%d]", x, y, base, index, aindex);
	    if ((aindex < 0) || (aindex >= cap)) {
		TRACE_CLOSER; TRACE("ASSERT", 0);
		ASSERT_VA (0, "src out of bounds", "%d / %d", aindex, cap);
	    }

	    double val = v [index];

	    TRACE_ADD ("=> %f", val); TRACE_CLOSER;

	    aktive_kahan_add (&sum, val*val);
	}
    }

    double res = aktive_kahan_final (&sum);
    TRACE_RETURN ("(sum-squared) %f", res);
}

extern double
aktive_tile_reduce_variance (double* v, aktive_uint radius, aktive_uint base,
			     aktive_uint cap, aktive_uint pitch, aktive_uint stride,
			     void* __client__ /* ignored */)
{
    TRACE_FUNC("((double*) %p, [%u:%u], (radius) %u, (pitch) %u, (stride) %u)",
	       v, base, cap, radius, pitch, stride);

    aktive_uint n = 2*radius+1; n *= n;

    kahan sum;     aktive_kahan_init (&sum);
    kahan squared; aktive_kahan_init (&squared);

    int r = radius;
    for (int y = -r ; y <= r; y++) {
	for (int x = -r; x <= r; x++) {
	    int index = y*pitch + x*stride;
	    int aindex = (int) base + index;

	    TRACE_HEADER (1); TRACE_ADD ("@(%d,%d) = %u[%d] = [%d]", x, y, base, index, aindex);
	    if ((aindex < 0) || (aindex >= cap)) {
		TRACE_CLOSER; TRACE("ASSERT", 0);
		ASSERT_VA (0, "src out of bounds", "%d / %d", aindex, cap);
	    }

	    double val = v [index];

	    TRACE_ADD ("=> %f", val); TRACE_CLOSER;

	    aktive_kahan_add (&sum, val);
	    aktive_kahan_add (&squared, val*val);
	}
    }

    double mean = aktive_kahan_final (&sum)     / (double) n;
    double sq   = aktive_kahan_final (&squared) / (double) n;
    double res  = sq - mean*mean;

    TRACE_RETURN ("(variance) %f", res);
}

extern double
aktive_tile_reduce_rank (double* v, aktive_uint radius, aktive_uint base,
			     aktive_uint cap, aktive_uint pitch, aktive_uint stride,
			     void* __client__)
{
    TRACE_FUNC("((double*) %p, [%u:%u], (radius) %u, (pitch) %u, (stride) %u)",
	       v, base, cap, radius, pitch, stride);

    aktive_rank* rt = __client__;
    aktive_uint  n  = 2*radius+1; n *= n;
    aktive_uint  k  = 0;

    ASSERT (rt->select < n, "selection index out of range");

    int r = radius;
    for (int y = -r ; y <= r; y++) {
	for (int x = -r; x <= r; x++) {
	    int index = y*pitch + x*stride;
	    int aindex = (int) base + index;

	    TRACE_HEADER (1); TRACE_ADD ("@(%d,%d) = %u[%d] = [%d]", x, y, base, index, aindex);
	    if ((aindex < 0) || (aindex >= cap)) {
		TRACE_CLOSER; TRACE("ASSERT", 0);
		ASSERT_VA (0, "src out of bounds", "%d / %d", aindex, cap);
	    }

	    double val = v [index];

	    TRACE_ADD ("=> %f", val); TRACE_CLOSER;

	    rt->sorted [k++] = val;
	}
    }

    //    TRACE_HEADER(1); TRACE_ADD ("collected = {", 0);
    //    for (int j = 0; j < n; j++) { TRACE_ADD (" %f", rt->sorted[j]); }
    //    TRACE_ADD(" }", 0); TRACE_CLOSER;

    qsort (rt->sorted, n, sizeof(double), double_compare);

    //    TRACE_HEADER(1); TRACE_ADD ("sorted    = {", 0);
    //    for (int j = 0; j < n; j++) { TRACE_ADD (" %f", rt->sorted[j]); }
    //    TRACE_ADD(" }", 0); TRACE_CLOSER;

    double res = rt->sorted [rt->select];

    TRACE_RETURN ("(rank) %f", res);
}

extern void
aktive_tile_reduce_histogram (double* v, aktive_uint radius, aktive_uint base,
			      aktive_uint cap, aktive_uint pitch, aktive_uint stride,
			      void* __client__)
{
    TRACE_FUNC("((double*) %p, [%u:%u], (radius) %u, (pitch) %u, (stride) %u)",
	       v, base, cap, radius, pitch, stride);

    aktive_histogram* h = __client__;
    aktive_uint  n  = 2*radius+1; n *= n;
    aktive_uint  k  = 0;

    memset (h->count, 0, h->bins*sizeof(double));

    int r = radius;
    for (int y = -r ; y <= r; y++) {
	for (int x = -r; x <= r; x++) {
	    int index = y*pitch + x*stride;
	    int aindex = (int) base + index;

	    TRACE_HEADER (1); TRACE_ADD ("@(%d,%d) = %u[%d] = [%d]", x, y, base, index, aindex);
	    if ((aindex < 0) || (aindex >= cap)) {
		TRACE_CLOSER; TRACE("ASSERT", 0);
		ASSERT_VA (0, "src out of bounds", "%d / %d", aindex, cap);
	    }

	    double val = v [index];

	    int bin = val * h->bins;
	    bin = MAX (0, bin);
	    bin = MIN (h->maxbin, bin);

	    h->count [bin] += 1;
	    TRACE_ADD ("[%3d] = %f -> %d/%d => %f", k , val, bin, h->bins, h->count [bin]);
	    TRACE_CLOSER;
	}
    }

    TRACE_RETURN_VOID;
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
	double val = *v;
	aktive_kahan_add (&sum, val);
	aktive_kahan_add (&squared, val*val);
    }

    *rsum     = sum;
    *rsquared = squared;
}

static int
double_compare (const void* a, const void* b)
{
    const double* av = a;
    const double* bv = b;
    int res = ((*av) < (*bv)) ? -1 : (((*av) > (*bv)) ? 1 : 0);
    // TRACE("(%f ~ %f) - %d", *av, *bv, res);
    return res;
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
    aktive_rectangle scan;	// area to scan over the image (one row)
    aktive_uint      count;	// number of scans to perform  (height)

    // worker
    aktive_image     image;	// image to getting scanned

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
 * ATTENTION :: the generated code does not include the `rank` reducer.
 *           :: nor the `histogram` reducer. both use client data, and
 *           :: will likely require a very different implementation than
 *           :: what is generated ...
 */

#define PARTIAL (result->main)
#define P_AUX   (result->aux)
#define ACC     (state->acc.main)
#define AUX     (state->acc.aux)
#define FINAL   (*state->result)

#include <generated/reduce.c>

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_histogram_fill (aktive_ivcache_context* context, aktive_uint index, double* dst)
{
    TRACE_FUNC("([%d] %u,%u[%u] (dst) %p [%u])", index, context->request->y,
	       context->z, context->stride, dst, context->size);

    aktive_block*     src = aktive_region_fetch_area (context->src, context->request);
    aktive_histogram* h   = (aktive_histogram*) context->client;

    // offset into requested band, stride
    aktive_reduce_histogram (src->pixel + context->z, context->size, context->stride, h);

    memcpy (dst, h->count, h->bins*sizeof(double));

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
