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

#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 */

extern double aktive_reduce_max        (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_mean       (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_min        (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_stddev     (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_sum        (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_sumsquared (double* v, aktive_uint n, aktive_uint stride);
extern double aktive_reduce_variance   (double* v, aktive_uint n, aktive_uint stride);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_REDUCE_H */
