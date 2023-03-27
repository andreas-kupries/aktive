/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Regions, types and methods
 *
 * Regions are the active element. Internally regions form a forest of DAGs
 * parallel to the forest of images. Processing happens when a region is asked
 * to fetch the pixels for an area, cascading down to the DAG from the queried
 * region to input regions until reaching the regions attached to the data
 * sources.
 *
 * Note that each image may have multiple regions referencing it. The data of
 * all regions for an image is generally completely separate. This enables the
 * use of threads to concurrently compute pixel data for multiple regions of
 * an image, without locking.
 *
 * There will be exception to this though. Mainly in file-based data sources,
 * where the underlying access libraries do not support concurrent access. The
 * format itself may force some kind of sequential reading as well.
 *
 * ATTENTION: The `aktive_block*` results out of a fetch are owned and managed
 * by the region. The region is responsible for allocation and release of the
 * structure and its contents. Any returned block will be valid only until the
 * next fetch operation on the same region.
 */
#ifndef AKTIVE_REGION_H
#define AKTIVE_REGION_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <blit.h>
#include <context.h>

/*
 * - - -- --- ----- -------- -------------
 *
 * -- The info structure provides region callbacks limited access to the
 *    information managed by the runtime for a region. The runtime maintains
 *    additional information for itself it will not provide access to.
 *
 *    The image derived information is READ ONLY. Only the region state can be
 *    written to.
 */

typedef struct aktive_region_info {
    // READ ONLY information coming from the image

    void*                param  ; // Operation parameters
    aktive_region_vector srcs   ; // Input regions, if any
    void*                istate ; // Image state, if any, operator dependent
    aktive_geometry*     domain ; // Image domain

    // RW information

    void*                state  ; // Region region state, if any, operator dependent
} aktive_region_info;

/*
 * - - -- --- ----- -------- -------------
 * -- Region callbacks
 *
 * Initialization - param, istate, and srcs are already initialized - Initialize state fields
 * Finalization   - other fields are already destroyed              - Destroy state fields
 * Pixel fetch    - all fields contain sensible information (if present for the operator)
 */

typedef void (*aktive_region_setup) (aktive_region_info* info);
typedef void (*aktive_region_final) (void* state);

typedef void (*aktive_region_fetch) ( aktive_region_info* info    // Region owning the request
                                    , aktive_rectangle*   request // Area requested from image
				    , aktive_rectangle*   dst     // Area in `block` to write to
                                    , aktive_block*       block   // Block to write to.
                                    );

/*
 * - - -- --- ----- -------- -------------
 * -- Shorthands for use in the callbacks
 */

#define SRCS (info->srcs)

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_region  aktive_region_new        (aktive_image image, aktive_context c);
extern void           aktive_region_destroy    (aktive_region region);
extern aktive_image   aktive_region_owner      (aktive_region region);
extern aktive_context aktive_region_context    (aktive_region region);
extern aktive_block*  aktive_region_fetch_area (aktive_region region, aktive_rectangle* request);
extern void           aktive_region_export     (aktive_region region, aktive_block* dst);

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
#endif /* AKTIVE_REGION_H */
