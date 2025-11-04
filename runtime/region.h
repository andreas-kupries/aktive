/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Regions, types and methods
 *
 * Regions are the active element. Internally regions form a forest of DAGs
 * parallel to the forest of images. Processing happens when a region is asked
 * to fetch the pixels for an area, cascading down the DAG from the queried
 * region to input regions until reaching the regions attached to the data
 * sources.
 *
 * Note that each image may have multiple regions referencing it. The data of
 * all regions for an image is generally completely separate. This enables the
 * use of threads to concurrently compute pixel data for multiple regions of
 * an image, without locking.
 *
 * There will be exceptions to this though. Mainly in file-based data sources,
 * where the underlying access libraries do not support concurrent access. The
 * format itself may force some kind of sequential reading as well.
 *
 * ATTENTION:  The `aktive_block*` results returned by a fetch are owned and
 *             managed by the region. The region is responsible for allocation
 *             and release of the structure and its contents. Any returned
 *             block will be valid only until the next fetch operation on the
 *             same region.
 *
 * BEWARE:     This is a problem when a region is for a shared DAG node S and
 *             the different branches reaching S fetch different areas,
 *             expecting separate blocks. This is solved by a system for the
 *             automatic detection and resolution such situations. This system
 *             automatically unshares the contested region and its
 *             predecessors on demand, locally undoing the DAG property.
 *
 * BACKGROUND: The tricky part to sharing regions in a runtime DAG happens
 *             when we use an operation `T` which
 *
 *             (a) transforms the requested rectangle/area and then
 *             (b) reaches a shared operation `S`.
 *
 *             In that case `S` will see requests for different areas of the
 *             image from different callers, while having only a single pixel
 *             block to store the results in. IOW later requests to `S`
 *             overwrite the data of earlier requests, causing the operation
 *             `O`, from which the multiple requests originated, to see bad
 *             data and compute bogus results.
 *
 * DIAGRAMS:    /------>\   - (1) Fetches area 1.
 *             O         S
 *              \-> T ->/   - (2) Fetches area 2, overwrites data of (1)
 *                                in the single region for `S`.
 *
 *             The system may inadvertently slide past the danger when `O`
 *
 *             (a) uses/copies the data of (1) before fetching from branch (2), or
 *             (b) `T` is in branch (1), with its separate copy of transformed data.
 *
 *             See the alternate DAG below.
 *
 *              /-> T ->\   - (1) Fetches area 1, processed into `T`'s result,
 *             O         S        separate storage.
 *              \------>/   - (2) Fetches area 2, overwrites data of (1) in `S`,
 *                                but `T` has run already, so its ok.
 *
 *             In general we do not know whether (a) or (b) are in effect when
 *             `S` is called on.
 *
 * SOLUTION:   A manual solution to mark dangerous operations or similar was
 *             discarded, as such a duty placed on the developer of operations
 *             is easy to forget, regardless of documentation.
 *
 *             An automatic solution was chosen instead.
 *
 *             The initial solution was to essentially unshare the regions
 *             where a conflict is detected, i.e. locally undoing the DAG
 *             property of the runtime structures. Proven to be working it
 *             also came with the explosion of nodes due to the duplication
 *             caused by the unsharing.
 *
 *             The current solution uses the experience gained from it,
 *             especially how to access and rewrite the caller of a node with
 *             a conflict. Instead of unsharing/duplicating the entire region
 *             this solution only allocates additional pixel storage for the
 *             conflicting result and ensures that the caller will use that
 *             store for its requests from then on. Instead of undoing DAG the
 *             problematic regions simply expand their memory footprint a bit.
 *
 *             Retained from the initial solution is the means of tracking
 *             callers to a region and when a conflict occurs (*). Different
 *             from it is that the tracking is done on the pixel storage, not
 *             the region.
 *
 *             (*) Blocks make a record of their first caller, who become the
 *                 owner of the pixel storage.
 *
 *                 Future requests of the same caller are safe by definition,
 *                 regardless of changes to the area stored in the block. It
 *                 is assumed that the owning caller has already processed
 *                 everything from the preceding calls.
 *
 *                 Future requests for the same area are also safe, regardless
 *                 of caller.
 *
 *                 A future request for a different area by a non-owner is a
 *                 conflict though. At this point the conflict for the pixel
 *                 storage is detected and resolved by creating a new block of
 *                 pixel storage, making the current caller the owner and
 *                 filling this with the desired area. The rewrite machinery
 *                 further updates the caller itself to use this new block
 *                 from now on, separating its requests from the owner's
 *                 requests to the original block until the pipeline is torn
 *                 down.
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

A_STRUCTURE (aktive_region_info) {
    // READ ONLY information coming from the image

    A_FIELD (A_OP_DEPENDENT,       param)  ; // Operation parameters
    A_FIELD (aktive_region_vector, srcs)   ; // Input regions, if any
    A_FIELD (aktive_uint_vector,   slots)  ; // Result slots in the input regions, if any
    A_FIELD (A_OP_DEPENDENT,       istate) ; // Image state, if any, operator dependent
    A_FIELD (aktive_geometry*,     domain) ; // Image domain

    // RW information

    A_FIELD (A_OP_DEPENDENT,       state)  ; // Region region state, if any, operator dependent
} A_END (aktive_region_info);

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
                                    , aktive_block*       block   // Block to write to. Caller.
                                    );

/*
 * - - -- --- ----- -------- -------------
 * -- Shorthands for use in the callbacks
 */

#define SRCS (info->srcs)

/*
 * - - -- --- ----- -------- -------------
 * lifecycle
 */

extern aktive_region  aktive_region_new        (aktive_image image, aktive_context c);
extern void           aktive_region_destroy    (aktive_region region);

/*
 * - - -- --- ----- -------- -------------
 * debug support
 */

extern void aktive_region_dump (aktive_region region, const char* label);

/*
 * - - -- --- ----- -------- -------------
 * accessors
 */

extern aktive_image   aktive_region_owner      (aktive_region region);
extern aktive_context aktive_region_context    (aktive_region region);

/*
 * - - -- --- ----- -------- -------------
 * pipeline operations
 */

extern void           aktive_region_export          (aktive_region region, aktive_block* dst, aktive_uint slot);
extern aktive_block*  aktive_region_fetch_area_core (aktive_region region, aktive_rectangle* request,
						     aktive_region caller, aktive_uint* slot);

// core support for generic warping. interpolated fetch of pixels.
extern void aktive_region_fetch_interpolated_core (aktive_region        region,
						   aktive_interpolator* interpolator,
						   aktive_uint          depth,
						   double*              src,
						   double*              dst,
						   aktive_region        caller,
						   aktive_uint*         slot);

// These macros keep the fetch API visible to most call sites unchanged
// despite the changes to the function signatures.
//
// NOTE: The `block->owner` is standard information available in the
// generated operator-dependent fetch functions.  The block is the pixel
// storage of the operator, with its owning region. IOW, the desired caller.
//
// Note that most call sites is not all. Everything at the beginning of a
// pipeline, driving it, i.e. all the various sinks and related, had to be
// adapted.

#define aktive_region_fetch_area(srcindex, request)		\
    aktive_region_fetch_area_core (srcs->v[srcindex], request, block->owner, &slots->v[srcindex])

#define aktive_region_fetch_area_head(dstregion, request) \
    aktive_region_fetch_area_core (dstregion, request, 0, 0)

#define aktive_region_fetch_interpolated(srcindex, interpolator, depth, src, dst) \
    aktive_region_fetch_interpolated_core (srcs->v[srcindex], interpolator, depth, src, dst, block->owner, &slots->v[srcindex])

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
