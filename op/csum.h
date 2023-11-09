/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Utility functions. Cumulative sums. IOW Prefix sums.
 */
#ifndef AKTIVE_CSUM_H
#define AKTIVE_CSUM_H

/*
 * - - -- --- ----- -------- -------------
 * Vector prefix sum
 *
 *  - src[]	Vector of values to access.
 *  - dst[]	Vector to write the sums to.
 *  - n		Number of values in vector.
 *  - stride	distance between vector elements.
 */

#include <rt.h>

/*
 * - - -- --- ----- -------- -------------
 */

extern void aktive_cumulative_sum (double* dst, aktive_uint n, double* src, aktive_uint stride);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_CSUM_H */
