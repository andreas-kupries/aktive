/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Utility functions. Otsu thresholding
 *
 *    References:
 *
 *    - http://www.labbookpages.co.uk/software/imgProc/otsuThreshold.html
 *    - http://en.wikipedia.org/wiki/Otsu%27s_method
 */
#ifndef AKTIVE_OTSU_H
#define AKTIVE_OTSU_H

#include <rt.h>

/*
 * - - -- --- ----- -------- -------------
 *
 * - src    [] histogram data
 * - n         number of values expected in src
 * - stride    distance between values in src[]
 */

extern double aktive_otsu (double* src, aktive_uint n, aktive_uint stride);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_OTSU_H */
