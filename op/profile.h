/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Utility functions. Profiling.
 */
#ifndef AKTIVE_PROFILE_H
#define AKTIVE_PROFILE_H

/*
 * - - -- --- ----- -------- -------------
 * Vector profile
 *
 *  - src[]	Vector of values to access.
 *  - dst[]	Vector to write the profile to. (Single value actually)
 *  - n		Number of values in src vector.
 *  - stride	distance between vector elements.
 */

#include <rt.h>

/*
 * - - -- --- ----- -------- -------------
 * Core functionality
 */

extern void aktive_profile (double* dst, aktive_uint n, double* src, aktive_uint stride);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_PROFILE_H */
