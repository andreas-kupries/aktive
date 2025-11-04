/* -*- c -*-
 */
#ifndef AKTIVE_INTERNALS_H
#define AKTIVE_INTERNALS_H

#include <tclpre9compat.h>

/*
 * - - -- --- ----- -------- -------------
 */

A_STRUCTURE (aktive_image_content) {
    // Private management

    A_FIELD (int,                 refcount) ; // Number of images holding a reference to the same content
    A_FIELD (aktive_image_type*,  opspec)   ; // Operational hooks, type identification, parameter metadata

    // Public information. Seen by image callbacks

    A_FIELD (aktive_image_info,   public)   ; // Image content spec (parameters, sources, geometry, state)

} A_END_PTR (aktive_image_content);

/*
 * - - -- --- ----- -------- -------------
 */

A_STRUCTURE (aktive_image) {
    // Private management information

    A_FIELD (Tcl_Mutex,            rclock)   ; // Serialize access to ref count, happens from multiple threads.
    A_FIELD (int,                  refcount) ; // Number of places holding a reference to the image

    // Private/public information

    A_FIELD (aktive_image_content, content)  ; // Refcounted. Description of image content

    // Public information, accessible through generic API functions

    A_FIELD (Tcl_Obj*,             meta)     ; // Meta data

} A_END_PTR (aktive_image);

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_region* aktive_region;

A_STRUCTURE (aktive_region) {
    // Private management information

    A_FIELD (aktive_context,     context); // Operating context
    A_FIELD (aktive_image,       origin) ; // Image the region belongs to
    A_FIELD (aktive_image_type*, opspec) ; // Operator descriptor
    A_FIELD (aktive_block*,      result) ; // Result pixel data, possibly multiple
    A_FIELD (aktive_uint,        rcap)   ; // Result capacity
    A_FIELD (aktive_uint,        ruse)   ; // Result slots used

    // Public information as seen by region callbacks

    A_FIELD (aktive_region_info, public) ;

} A_END_PTR (aktive_region);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_INTERNALS_H */
