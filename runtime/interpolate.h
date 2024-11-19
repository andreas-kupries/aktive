/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Interpolation types and methods
 *
 * Interpolators specify how to create the value of a pixel at a fractional
 * location of the image.
 *
 * An interpolator specification contains information about the size of the
 * window around the fractional pixel, the left/up offset of that window from
 * the pixel, and the function performing the actual interpolation given the
 * pixel data of the window.
 */
#ifndef AKTIVE_INTERPOLATOR_H
#define AKTIVE_INTERPOLATOR_H

/*
 * - - -- --- ----- -------- -------------
 */

/*
 * - - -- --- ----- -------- -------------
 *
 * -- The interpolator structure specifies the characteristics of a single
 *     interpolator.
 */

typedef void (*aktive_interpolator_func) (aktive_block* window, double tx, double ty, double* dst, aktive_uint depth);

A_STRUCTURE (aktive_interpolator) {
    A_FIELD (int,                      size)   ; // Window size.
    A_FIELD (int,                      offset) ; // Window offset. < 0 => default to size/2-1
    A_FIELD (aktive_interpolator_func, run)    ; // Interpolation function
} A_END (aktive_interpolator);

/*
 * - - -- --- ----- -------- -------------
 * Access to the system interpolators
 */

extern aktive_interpolator* aktive_interpolator_bicubic   (void);
extern aktive_interpolator* aktive_interpolator_bilinear  (void);
extern aktive_interpolator* aktive_interpolator_lanczos   (void);
extern aktive_interpolator* aktive_interpolator_nneighbour(void);

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
#endif /* AKTIVE_INTERPOLATOR_H */
