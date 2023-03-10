/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Reducer utility functions.
 */
#ifndef AKTIVE_REDUCE_H
#define AKTIVE_REDUCE_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <rt.h>

/*
 * - - -- --- ----- -------- -------------
 * Vector reductions, used in per-row, -column, and -band statistics
 */

extern double aktive_reduce_max        (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_mean       (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_min        (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_stddev     (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_sum        (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_sumsquared (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_variance   (double* v, aktive_uint n, aktive_uint stride);

/*
 * - - -- --- ----- -------- -------------
 * Image-level reductions, used in image statistics.
 */

extern double aktive_image_max        (aktive_image src);
extern double aktive_image_mean       (aktive_image src);
extern double aktive_image_min        (aktive_image src);
extern double aktive_image_stddev     (aktive_image src);
extern double aktive_image_sum        (aktive_image src);
extern double aktive_image_sumsquared (aktive_image src);
extern double aktive_image_variance   (aktive_image src);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_REDUCE_H */
