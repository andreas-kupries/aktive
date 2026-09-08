/* -*- c -*-
 *
 * -- Matrix operation support
 */
#ifndef AKTIVE_MATH_MATRIX_H
#define AKTIVE_MATH_MATRIX_H

#include <float.h>
#include <blit.h>

/*
 * - - -- --- ----- -------- -------------
 * Core of matrix inversion. Set of functions for direct calculation for small
 * matrices (1x1, 2x2, 3x3, 4x4), and a full LU decomposition for anything
 * larger than that.
 */

extern void aktive_matrix_invert_1x1 (aktive_block* mat, aktive_block* out);
extern void aktive_matrix_invert_2x2 (aktive_block* mat, aktive_block* out);
extern void aktive_matrix_invert_3x3 (aktive_block* mat, aktive_block* out);
extern void aktive_matrix_invert_4x4 (aktive_block* mat, aktive_block* out);
extern void aktive_matrix_invert_lup (aktive_block* mat, aktive_block* out);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_MATH_MATRIX_H */
