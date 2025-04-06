/* -*- c -*-
 *
 * -- Direct operator support - Column profiles
 */
#ifndef AKTIVE_CPROFILE_H
#define AKTIVE_CPROFILE_H

/* - - -- --- ----- -------- -------------
 * Data structures describing a (partial) column profile for an image, or part of it.
 */

typedef struct aktive_cprofile* aktive_cprofile_ptr;

A_STRUCTURE(aktive_cprofile) {
    A_FIELD (aktive_uint,       ymin)      ; // Bounding row
    A_FIELD (aktive_uint,       ymax)      ; //  ditto
    A_FIELD (aktive_uint,       n)         ; // Profile size = image width
    A_FIELD (double*,           profile)   ; // Profile data
} A_END (aktive_cprofile);

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_cprofile* aktive_cprofile_find    (aktive_image      src,
						 aktive_uint       bottom,
						 aktive_rectangle* rq);
extern void             aktive_cprofile_release (aktive_cprofile* cprofile);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_CPROFILE_H */
