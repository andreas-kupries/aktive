/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Utility functions. Cumulative sums. IOW Prefix sums.
 */
#ifndef AKTIVE_DOTPRODUCT_H
#define AKTIVE_DOTPRODUCT_H
/*
 * - - -- --- ----- -------- -------------
 */
#include <rt.h>

/*
 * - - -- --- ----- -------- -------------
 * dot product / scalar product
 *
 *  - srca[]	Vector of values to access.
 *  - srcb[]	Vector of values to access.
 *  - dst[]	Vector of dot products to write
 *  - n		Number of pixels in src* vectors.
 *  - bands	number of bands per value
 *
 * The src* arrays contain `n*bands` values.
 * The dst array has space for `bands` dot-products, one per band in the src's
 */

extern void aktive_dotproduct_base (double* dst, double* srca, double* srcb, aktive_uint n, aktive_uint bands);
extern void aktive_dotproduct_u4   (double* dst, double* srca, double* srcb, aktive_uint n, aktive_uint bands);

/*
 * System integration
 */

#define aktive_dotproduct aktive_dotproduct_base

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_DOTPRODUCT_H */
