/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Reducer utility functions.
 */
#ifndef AKTIVE_REDUCE_H
#define AKTIVE_REDUCE_H

/*
 * - - -- --- ----- -------- -------------
 * Vector, image, and region reduction operations.
 * The vector reducers are used in the per-row, -column, and -band statistics.
 * Image reducers for per-image statistics.
 * Region reducers for tile statistics.
 *
 * Vector reductions:
 *
 *  - v[]	Vector of values to access.
 *  - n		Number of values in vector.
 *  - stride	distance between vector elements.
 *
 * Tile reductions:
 *
 *  - v[]	Tile center, values to access, part of a larger 2d block
 *  - radius	Tile radius, tile is [-radius ... radius] in both X and Y.
 *  - base	Tile center as index of `v` in the block. IOW v = block [base].
 *  - cap	Max legal index in the block.
 *  - pitch	Distance between rows of the block.
 *  - stride	Distance btween columns of the block.
 *
 * Note: While all reducers have a client data argument, currently only the
 * `rank` and `histogram` reducers actually make use of it, and interpret the
 * value as `aktive_rank*` and `aktive_histogram*` respectively.
 */

#include <rt.h>

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_rank {
    double*     sorted;	// Buffer to collect pixels into, and sort.
    aktive_uint select; // Index in `sorted` to return.
} aktive_rank;

typedef struct aktive_histogram {
    aktive_uint bins;	// Histogram size, count of bins
    aktive_uint maxbin;	// Derived, index of highest bin.
    double*     count;	// Counter array for histogram data
} aktive_histogram;

/*
 * - - -- --- ----- -------- -------------
 ** A selector is a special form of reducer, returning the vector element
 ** addressed by the index.
 */

extern double
aktive_select (double*     v,
	       aktive_uint n,
	       aktive_uint stride,
	       double*     index);

/*
 * - - -- --- ----- -------- -------------
 ** General reducer setup
 */

#define REDUCER(rtype,fun)				\
    extern rtype					\
    aktive_reduce_ ## fun (double*     v,		\
			   aktive_uint n,		\
			   aktive_uint stride,		\
			   void*       client);		\
							\
    extern rtype					\
    aktive_image_ ## fun (aktive_image src,		\
			  void*        client);		\
							\
    extern rtype					\
    aktive_tile_reduce_ ## fun (double*     v,		\
				aktive_uint radius,	\
				aktive_uint base,	\
				aktive_uint cap,	\
				aktive_uint pitch,	\
				aktive_uint stride,	\
				void*       client)

/*
 * - - -- --- ----- -------- -------------
 */

REDUCER (double, argmax);
REDUCER (double, argmin);
REDUCER (double, max);
REDUCER (double, mean);
REDUCER (double, min);
REDUCER (double, stddev);
REDUCER (double, sum);
REDUCER (double, sumsquared);
REDUCER (double, variance);
REDUCER (double, rank);
REDUCER (void,   histogram);

/*
 * - - -- --- ----- -------- -------------
 */

#undef REDUCER
/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_REDUCE_H */
