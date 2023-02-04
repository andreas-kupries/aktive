/* -*- c -*-
 */
#ifndef AKTIVE_INTERNALS_H
#define AKTIVE_INTERNALS_H

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_image {
    // Private management information

    int                  refcount ; // Number of places holding a reference to the image          
    aktive_image_type*   opspec   ; // Operational hooks, type identification, parameter metadata 

    // Public information as seen by image callbacks

    aktive_image_info    public;
    
    // %% TODO %% image meta data

} *aktive_image;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_region {
    // Private management information
    
    aktive_image          origin ; // Image the region belongs to
    aktive_image_type*    opspec ; // Operator descriptor
    aktive_block          pixels ; // Pixel data 

    // Public information as seen by region callbacks

    aktive_region_info    public ;

} *aktive_region;

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_INTERNALS_H */
