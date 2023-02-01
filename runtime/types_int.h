/* -*- c -*-
 */
#ifndef AKTIVE_TYPES_INT_H
#define AKTIVE_TYPES_INT_H

/* - - -- --- ----- -------- -------------
 */

typedef struct aktive_image {
    int                  refcount ; /* Number of places holding a reference to the image          */
    aktive_image_type*   opspec   ; /* Operational hooks, type identification, parameter metadata */
    void*                param    ; /* Operation parameters, heap-located */
    aktive_image_vector  srcs     ; /* Input images, if any, heap-located array elements */
    void*                state    ; /* Custom operator state, if any, heap-located */
    aktive_point         location ; /* Location of image in the 2D plane */
    aktive_geometry      geometry ; /* 3D geometry of the image */

    // %% TODO %% image meta data

} *aktive_image;

/* - - -- --- ----- -------- -------------
 */

typedef struct aktive_region {
    aktive_image          origin ; /* Image / Operation the region is part of */
    aktive_region_vector  srcs   ; /* Input regions, if any */
    void                 *state  ; /* Custom region state */
    aktive_block          pixels ; /* Pixel data */

    /* Local copies of image instance information */

    void*                param    ; /* Operation parameters */
    aktive_image_type*   opspec   ; /* Operational hooks, type identification, parameter metadata */
#if 0 /* REGION NOT NEEDED */
    aktive_point*        location ; /* Location of image in the 2D plane */
    aktive_geometry*     geometry ; /* 3D geometry of the image */
#endif
} *aktive_region;

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_TYPES_INT_H */
