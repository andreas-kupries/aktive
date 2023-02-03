/* -*- c -*-
 */
#ifndef AKTIVE_INTERNALS_H
#define AKTIVE_INTERNALS_H

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_image {
    int                  refcount ; // Number of places holding a reference to the image          
    aktive_image_type*   opspec   ; // Operational hooks, type identification, parameter metadata 
    void*                param    ; // Operation parameters, heap-located                         
    aktive_image_vector  srcs     ; // Input images, if any, heap-located array elements          
    void*                state    ; // Custom operator state, if any, heap-located                

    aktive_point         location ; // Location of image in the 2D plane                          
    aktive_geometry      geometry ; // 3D geometry (dimensions) of the image                      
    aktive_rectangle     domain   ; // Image domain, the area it covers in the 2D plane           
    //                              ** Derived as location + geometry - depth                     
    
    // %% TODO %% image meta data

} *aktive_image;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_region {
    aktive_region_info    public ; // Region information visible to the callbacks

    // Private management information
    
    aktive_image          origin ; // Image the region belongs to
    aktive_image_type*    opspec ; // Operator descriptor
    aktive_block          pixels ; // Pixel data 

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
