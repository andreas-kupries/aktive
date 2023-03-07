/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Matrix utility functions.
 */
#ifndef AKTIVE_PIXEL_H
#define AKTIVE_PIXEL_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 */

extern double aktive_scalar_mul (double* a, double* b, aktive_uint n, aktive_uint bstride);
extern void   aktive_matrix_mul (double* z, double* vec, double* mat, aktive_uint mwidth, aktive_uint mheight);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_PIXEL_H */
