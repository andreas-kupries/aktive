/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Utility functions. Lookup tables.
 */
#ifndef AKTIVE_LUT_H
#define AKTIVE_LUT_H

#include <rt.h>

/*
 * - - -- --- ----- -------- -------------
 *
 */

typedef struct aktive_lut_config {
    double*     pixel;
    aktive_uint width;
    aktive_uint depth;
    aktive_uint cap;
} aktive_lut_config;

/*
 * - - -- --- ----- -------- -------------
 * Core functionality
 */

extern double aktive_lut_index        (double x, aktive_lut_config* lut, aktive_uint z);
extern double aktive_lut_index_linear (double x, aktive_lut_config* lut, aktive_uint z);

/*
 * - - -- --- ----- -------- -------------
 */

#define AKTIVE_LUT_INDEX        ((aktive_unary_transformgz) aktive_lut_index)
#define AKTIVE_LUT_INDEX_LINEAR ((aktive_unary_transformgz) aktive_lut_index_linear)

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_LUT_H */
