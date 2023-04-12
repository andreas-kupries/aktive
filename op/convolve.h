/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Convolver utility functions.
 */
#ifndef AKTIVE_CONVOLVE_H
#define AKTIVE_CONVOLVE_H

/*
 * - - -- --- ----- -------- -------------
 * Spatial convolution support.
 *
 *  - v[]	Tile center, values to access, part of a larger 2d block.
 *  - base	Tile center as index of `v` in the block. IOW v = block [base].
 *  - cap	Max legal index in the block.
 *  - pitch	Distance between rows of the block.
 *  - stride	Distance btween columns of the block.
 *
 *  - m[]       Convolution matrix values, from top-left.
 *  - mcap	Max legal index in the matrix.
 *  - mwidth    Matrix width.
 *  - mheight   Matrix height.
 *  - wradius   Matrix width radius (width/2).
 *  - hradius   Matrix height radius (height/2).
 *
 * Note that the matrix width and height are odd values.
 */

#include <rt.h>

/*
 * - - -- --- ----- -------- -------------
 */

extern double
aktive_tile_convolve (double*     v,
		      aktive_uint base,
		      aktive_uint cap,
		      aktive_uint pitch,
		      aktive_uint stride,
		      double*     m,
		      aktive_uint mcap,
		      aktive_uint mwidth,
		      aktive_uint mheight,
		      aktive_uint wradius,
		      aktive_uint hradius);

/*
 * - - -- --- ----- -------- -------------
 */

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_CONVOLVE_H */
