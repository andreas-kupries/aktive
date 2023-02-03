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

#include <block.h>

/*
 * - - -- --- ----- -------- -------------
 */

typedef void  (*aktive_region_final) ( void* state );

typedef void* (*aktive_region_setup) ( void*                    param      // Image parameters 
                                     , aktive_region_vector_ptr srcs       // Input regions    
                                     , void*                    imagestate // Image! state     
                                     );

typedef void  (*aktive_region_fetch) ( void*                    param   // Image parameters    
                                     , aktive_region_vector_ptr srcs    // Input regions       
                                     , void*                    state   // Region state        
                                     , aktive_rectangle*        request // Area to fill        
				     , aktive_rectangle*        physreq // Same, for pixels    
                                     , /* => */ aktive_block*   block   // out: Pixels to fill 
                                     );

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_region aktive_region_new        (aktive_image image);
extern void          aktive_region_destroy    (aktive_region region);
extern aktive_image  aktive_region_owner      (aktive_region region);
extern aktive_block* aktive_region_fetch_area (aktive_region region, aktive_rectangle* area);

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
