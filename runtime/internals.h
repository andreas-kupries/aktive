/* -*- c -*-
 */
#ifndef AKTIVE_INTERNALS_H
#define AKTIVE_INTERNALS_H

#include <tclpre9compat.h>

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_image_content {
    // Private management

    int                 refcount ; // Number of images holding a reference to the same content
    aktive_image_type*  opspec   ; // Operational hooks, type identification, parameter metadata

    // Public information. Seen by image callbacks

    aktive_image_info   public   ; // Image content spec (parameters, sources, geometry, state)

} *aktive_image_content;

typedef struct aktive_image {
    // Private management information

    Tcl_Mutex            rclock   ; // Serialize access to ref count, happens from multiple threads.
    int                  refcount ; // Number of places holding a reference to the image

    // Private/public information

    aktive_image_content content  ; // Refcounted. Description of image content

    // Public information, accessible through generic API functions

    Tcl_Obj*             meta     ; // Meta data

} *aktive_image;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_region {
    // Private management information

    aktive_context        c;       // Operating context
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
