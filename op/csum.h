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
 * Core functionality
 */

extern void aktive_cumulative_sum (double* dst, aktive_uint n, double* src, aktive_uint stride);

/*
 * - - -- --- ----- -------- -------------
 * Operator support.
 * - Fill function for iveccache, and supporting
 * - context structure
 */

typedef struct aktive_csum_context {
    aktive_uint         z;       // requested band
    aktive_uint         stride;  // delta between band groups
    aktive_uint         size;    // number of values in the band
    aktive_rectangle*   request; // full request for input
    aktive_region       src;     // input region to pull from
} aktive_csum_context;

extern void aktive_csum_fill (aktive_csum_context* context, aktive_uint index, double* dst);

#define AKTIVE_CSUM_FILL ((aktive_iveccache_fill) aktive_csum_fill)

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_CSUM_H */
