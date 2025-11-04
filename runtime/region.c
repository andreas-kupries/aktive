/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * API implementation - Regions
 */

#include <tclpre9compat.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <rt.h>
#include <internals.h>

TRACE_OFF;

TRACE_TAG_OFF (fetch);

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_region_dump (aktive_region region, const char* label)
{
    TRACE("%s (region) %p : (image) %p = '%s'", label, region, region->origin, region->opspec->name);
    TRACE_PUSH_SCOPE(""); TRACE_RUN (int __scope__ = TRACE_SCOPE);
    for (unsigned int i = 0; i < region->public.srcs.c; i++) {
	aktive_region_dump (region->public.srcs.v [i], label);
    }
    TRACE_POP;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_region
aktive_region_new (aktive_image image, aktive_context c)
{
    TRACE_FUNC("((image) %p '%s'", image, image->content->opspec->name);

    // Reuse region from context, if any.

    if (c && aktive_context_has (c, image)) {
	TRACE ("image found in context, reusing region", 0);

	aktive_region region = aktive_context_get (c, image);
	region->rcap ++;

	TRACE_RETURN("KNW (aktive_region) %p", region);
    }

    // Create new and clean image structure ...

    aktive_region region = ALLOC(struct aktive_region);
    memset (region, 0, sizeof(struct aktive_region));

    region->context = c;

    // Reference origin

    region->origin = image; aktive_image_ref (image);

    // Generate regions representing the inputs, if any -- Passing the context

    aktive_image_content content = image->content;

    if (content->public.srcs.c) {
	aktive_region_vector_new (&region->public.srcs,  content->public.srcs.c);
	aktive_uint_vector_new   (&region->public.slots, content->public.srcs.c);
	for (unsigned int i = 0; i < region->public.srcs.c; i++) {
	    region->public.srcs.v  [i] = aktive_region_new (content->public.srcs.v [i], c);
	    region->public.slots.v [i] = 0; // default result slot, changes on conflict
	}
    }

    // Initialize local pointers to important structures

    region->public.domain = &content->public.domain;
    region->public.param  = content->public.param;
    region->opspec        = content->opspec;
    region->result        = 0;
    region->rcap          = 1;
    region->ruse          = 0;

    // Initialize region state, if any
    region->public.istate = content->public.state;

    if (region->opspec->region_setup) {
	region->opspec->region_setup (&region->public);
    }

    if (aktive_error_raised ()) {
	aktive_region_destroy (region);
	TRACE_RETURN("BAD (aktive_region) %p", 0);
    }

    // Save to context, if there is any
    if (c) {
	aktive_context_put (c, image, region);
    }

    // Done and return
    TRACE("((image) %p '%s' ==> (aktive_region) %p", image, image->content->opspec->name, region);
    TRACE_RETURN("NEW (aktive_region) %p", region);
}

extern void
aktive_region_destroy (aktive_region region)
{
    TRACE_FUNC("((region) %p '%s'", region, region->opspec->name);

    // Release inputs, if any

    if (region->public.srcs.c) {
	if (!region->context) {
	    // Without a context region construction created a tree of regions
	    // with no shared nodes. Simply recursively destroy our input
	    // regions as their sole user/owner.

	    for (unsigned int i = 0; i < region->public.srcs.c; i++) {
		aktive_region_destroy (region->public.srcs.v [i]);
	    }
	} else {
	    // With a context we may share our input regions with other users.
	    // Skip destruction of those not found in their context anymore.
	    // These were shared and destroyed already. Destroy the others and
	    // signal that to future users by removal from the context.

	    aktive_image*  ci = region->origin->content->public.srcs.v;
	    aktive_region* cr = region->public.srcs.v;

	    for (unsigned int i = 0; i < region->public.srcs.c; i++) {
		aktive_region sr = cr [i];
		aktive_image  si = ci [i];
		ASSERT_VA (sr->origin == si, "image mismatch region/image", "@[%d]", i);
		TRACE ("JOIN (context) %p (image) %p -> (region) %p", sr->context, si, sr);
		if (!aktive_context_has (sr->context, si)) continue;
		aktive_region_destroy (sr);
	    }
	}

	aktive_region_vector_free (&region->public.srcs);
    }

    // Release owner

    aktive_image_unref (region->origin);

    // Release pixel data from the internal blocks, if any
    for (unsigned int i = 0; i < region->ruse; i++) {
	aktive_blit_close (&region->result[i]);
    }

    /* Nothing to do for the remaining fields. These are only pointers to
     * image structures not owned by the region
     */

    // Release custom state, if any, and necessary

    if (region->public.state) {
	if (region->opspec->region_final) { region->opspec->region_final (region->public.state); }
	ckfree ((char*) region->public.state);
    }

    // Remove ourself from controlling context, if such is present
    if (region->context) {
	aktive_context_remove (region->context, region->origin);
    }

    // Release main structure
    ckfree ((char*) region);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_region_export (aktive_region region, aktive_block* dst, aktive_uint slot)
{
    TRACE_FUNC("((aktive_region) %p '%s' [%ud])", region, region->opspec->name, slot);

    // Shift pixel data into destination and squash unwanted backlinks.
    *dst = region->result [slot];
    dst->owner  = 0;
    dst->reader = 0;

    // Squash the now-bogus data references in the source
    region->result [slot].pixel    = 0;
    region->result [slot].capacity = 0;
    region->result [slot].used     = 0;

    TRACE_RETURN_VOID;
}

extern aktive_image
aktive_region_owner (aktive_region region)
{
    TRACE_FUNC("((aktive_region) %p '%s')", region, region->opspec->name);
    TRACE_RETURN ("(aktive_image) %p", region->origin);
}

extern aktive_context
aktive_region_context (aktive_region region)
{
    TRACE_FUNC("((aktive_region) %p '%s')", region, region->opspec->name);
    TRACE_RETURN ("(aktive_context) %p", region->context);
}

extern aktive_block*
aktive_region_fetch_area_core (aktive_region region, aktive_rectangle* request, aktive_region caller, aktive_uint* slotptr)
{
    aktive_uint slot = slotptr ? *slotptr : 0;
    TRACE_FUNC("((aktive_region) %p '%s' requested (@ %d..%d,%d..%d : %ux%u), caller %p (%p [%ud]))",
	       region, region->opspec->name,
	       request->x, aktive_geometry_get_xmax (request),
	       request->y, aktive_geometry_get_ymax (request),
	       request->width, request->height, caller, slotptr, slot);

    // Delayed result array setup
    if (!region->result) {
	aktive_block* first = region->result = NALLOC (aktive_block, region->rcap);
	// And setup of first result slot
	region->ruse = 1;
	ASSERT (region->ruse <= region->rcap, "region fetch for operator without callers");
	ASSERT (slot == 0,                    "bad slot for first caller");
	aktive_geometry_copy (&first->domain, &region->origin->content->public.domain);
	first->initialized = 0;
	first->owner       = region;
	first->reader      = caller;
	first->pixel       = 0;
	first->capacity    = 0;
	first->used        = 0;
    }

    // Check if the current request matches the last seen. If yes, we can and
    // do simply return what we already have in our memory. NOTE that this is
    // not full caching of pixel data, just a short circuit for a shared DAG
    // node receiving multiple requests for the same area with no other
    // request in between. Phansalkar local adaptive thresholding is an
    // example for such, for the `tile mean` operator.

    aktive_block* result = &region->result [slot];

    int same =
	result->initialized &&
	aktive_point_is_equal      (aktive_rectangle_as_point (request),   &result->location) &&
	aktive_rectangle_is_dim_eq (request, aktive_geometry_as_rectangle (&result->domain));

    if (same) {
	TRACE_TAG_HEADER (fetch, 0);
	TRACE_TAG_ADD    (fetch, "RAW REQUEST\tSAME\tSKIP", 0);
	TRACE_TAG_CLOSER (fetch);
	goto done;
    }

    // Not the same area as last time.
    // On first call, set the owning caller.
    // On subsequent calls compare callers to determine (non)conflict

    if (!result->reader) {
	result->reader = caller;
    } else if (result->reader != caller) {
	// conflict on this slot. provide the current caller with a new slot for its results.
	slot = region->ruse;
	region->ruse ++;
	ASSERT_VA (region->ruse <= region->rcap, "too many conflicts", "%d/%d", region->ruse, region->rcap);
	result = &region->result [slot];

	// basic setup of the new slot
	aktive_geometry_copy (&result->domain, &region->origin->content->public.domain);
	result->initialized = 0;
	result->owner       = region;
	result->reader      = caller;
	result->pixel       = 0;
	result->capacity    = 0;
	result->used        = 0;

	// update caller information to use this slot from now on
	*slotptr = slot;
    }

    // Normal request fulfillment

    TRACE_TAG_HEADER (fetch, 0);
    TRACE_TAG_ADD    (fetch, "RAW REQUEST\t%-18p\t%-18p\t%-18p\t%-30s\t%-8d\t%-8d\t%-8u\t%-8u",
		      region->origin, Tcl_GetCurrentThread(), region, region->opspec->name,
		      request->x, request->y, request->width, request->height);
    TRACE_TAG_CLOSER (fetch);

    // Update the storage per the request to match dimension and have enough
    // space.

    aktive_blit_setup (result, request);
    result->initialized = 1;

#define ID region->origin->content->public.domain
#define RD request
#define BL result->domain
#define MX(r) ((r).x+(r).width-1)
#define MY(r) ((r).y+(r).height-1)
#define PI(r) ((r).width*(r).depth)
    TRACE( ".......  x     xmax  y     ymax | w   h   d   | pit )", 0);
    TRACE( "image   (%3d .. %3d  %3d .. %3d | %3d %3d %3d | %3d )", ID.x,  MX(ID), ID.y,  MY(ID), ID.width,  ID.height, ID.depth, PI(ID));
    TRACE( "request (%3d .. %3d  %3d .. %3d | %3d %3d     |     )", RD->x, MX(*RD), RD->y, MY(*RD), RD->width, RD->height);
    TRACE( "block   (%3d .. %3d  %3d .. %3d | %3d %3d %3d | %3d )", BL.x,  MX(BL), BL.y,  MY(BL), BL.width,  BL.height, BL.depth, PI(BL));
#undef ID
#undef RD
#undef BL

    /* Computing the pixels is done in multiple phases:
     *
     * 1. Split the request into subareas inside and outside of the image domain.
     * 2. Clear the areas outside the domain.
     * 3. Invoke the fetch callback for the area inside the domain.
     *
     * Special cases are:
     * a. The request is a subset of the image's domain.
     * b. The request is fully outside of the image's domain.
     *
     * Coordinate systems
     *  domain, request are in the 2D plane with arbitrary location.
     *  pixel however is physical, rooted in (0,0).
     *
     * For blitting virtual locations have to be translated to physical.
     * As request.location maps to (0,0)
     * the translation is -(request.location).
     */

    aktive_rectangle domain;
    aktive_rectangle_from_geometry (&domain, &region->origin->content->public.domain);

    if (aktive_rectangle_is_subset (request, &domain)) {
	// Special case (a). The entire request has to be served by the fetcher.
	aktive_rectangle_def (dst, 0, 0, request->width, request->height);
	TRACE ( "dst     (%3d .. %3d  %3d .. %3d | %3d %3d     |     )",
		dst.x, MX(dst), dst.y, MY(dst), dst.width, dst.height);
	TRACE ( "fetch all (request <= domain)", 0);

	TRACE_TAG_HEADER (fetch, 0);
	TRACE_TAG_ADD (fetch, "IMG REQUEST\t%-18p\t%-18p\t%-18p\t%-30s\t%-8d\t%-8d\t%-8u\t%-8u",
		       region->origin, Tcl_GetCurrentThread(), region, region->opspec->name,
		       request->x, request->y, request->width, request->height);
	TRACE_TAG_CLOSER (fetch);

	region->opspec->region_fetch (&region->public, request, &dst, result);
	goto done;
    }

    /* Compute the inside and outside zones. The intersection, i.e. the inside
     * part, is always stored in zv[0].
     */

    aktive_rectangle zv [5];
    aktive_uint      zc;
    aktive_rectangle_outzones (&domain, request, &zc, zv);

    if (zc == 0) {
	// Special case (b). No data comes from the image itself.
	TRACE ( "fetch nothing", 0);
	aktive_blit_clear_all (result);
	goto done;
    }

    // Clear the outside zones, if any
    for (aktive_uint i = 1; i < zc; i++) { aktive_blit_clear (result, &zv [i]); }

    // The overlap is the only remaining part to handle, and this is done by
    // the fetcher.

    aktive_rectangle dst = zv[0];
    aktive_rectangle_move (&dst, -request->x, -request->y);

#define RD zv[0]
    TRACE ( "section (%3d .. %3d  %3d .. %3d | %3d %3d     |     )",
	    RD.x,  MX(RD),  RD.y,  MY(RD),  RD.width,  RD.height);
    TRACE ( "dst     (%3d .. %3d  %3d .. %3d | %3d %3d     |     )",
	    dst.x, MX(dst), dst.y, MY(dst), dst.width, dst.height);
    TRACE ( "fetch overlap", 0);
#undef MX
#undef MY
#undef PI

    TRACE_TAG_HEADER (fetch, 0);
    TRACE_TAG_ADD (fetch, "IMG REQUEST\t%-18p\t%-18p\t%-18p\t%-30s\t%-8d\t%-8d\t%-8u\t%-8u",
		   region->origin, Tcl_GetCurrentThread(), region, region->opspec->name,
		   RD.x, RD.y, RD.width, RD.height);
    TRACE_TAG_CLOSER (fetch);
#undef RD

    region->opspec->region_fetch (&region->public, &zv[0], &dst, result);

 done:
    TRACE_DO (__aktive_block_dump (region->opspec->name, result));
    // And return them
    TRACE_RETURN ("(aktive_block*) %p", result);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_region_fetch_interpolated_core (aktive_region        region,
				       aktive_interpolator* interpolator,
				       aktive_uint          depth,
				       double*              src,
				       double*              dst,
				       aktive_region        caller,
				       aktive_uint*         slot)
{
    TRACE_FUNC("((aktive_region) %p '%s', ispec %p, depth %ud, src %p, dst %p, caller %p [%ud])",
	       region, region->opspec->name, interpolator, depth, src, dst, caller, slot);

    // Phases:
    // 1. Compute the rectangle (window) to fetch from the input from which we
    //    can interpolate the result pixel
    // 2. Fetch the associated region
    // 3. Run the interpolation. This copies the resulting pixel data to the destination.

    // 1. Compute window
    // 1a. desired pixel
    double xf = src[0];
    double yf = src[1];

    // 1b. window location, and size, around the desired pixel
    int sz     = interpolator->size;
    int offset = interpolator->offset;
    if (offset < 0) { offset = sz/2 - 1; }

    int x = ((int) xf) - offset;
    int y = ((int) yf) - offset;

    // 1c. assemble ...
    aktive_rectangle_def (request, x, y, sz, sz);

    // 2. fetch
    aktive_block* window = aktive_region_fetch_area_core (region, &request, caller, slot);

    // 3. interpolate
    interpolator->run (window, xf - x, yf - y, dst, depth);
    TRACE_RETURN_VOID;
}

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
