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
 * Note: While all reducers have a client data argument, currently
 * only the `rank` reducer actually makes use of it, and interprets
 * the value as `aktive_rank*`.
 */

#include <rt.h>

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_rank {
    double*     sorted;	// Buffer to collect pixels into, and sort.
    aktive_uint select; // Index in `sorted` to return.
} aktive_rank;

/*
 * - - -- --- ----- -------- -------------
 */

#define REDUCER(fun)					\
    extern double					\
    aktive_reduce_ ## fun (double*     v,		\
			   aktive_uint n,		\
			   aktive_uint stride,		\
			   void*       client);		\
							\
    extern double					\
    aktive_image_ ## fun (aktive_image src,		\
			  void*        client);		\
							\
    extern double					\
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

REDUCER (max);
REDUCER (mean);
REDUCER (min);
REDUCER (stddev);
REDUCER (sum);
REDUCER (sumsquared);
REDUCER (variance);
REDUCER (rank);

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
