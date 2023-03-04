/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * API implementation - Regions
 */

#include <tcl.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <rt.h>
#include <internals.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_region
aktive_region_new (aktive_image image)
{
    TRACE_FUNC("((image) %p '%s'", image, image->opspec->name);

    // Create new and clean image structure ... 

    aktive_region region = ALLOC(struct aktive_region);
    memset (region, 0, sizeof(struct aktive_region));

    // Reference origin 

    region->origin = image; aktive_image_ref (image);

    // Generate regions representing the inputs, if any 

    if (image->public.srcs.c) {
	aktive_region_vector_new (&region->public.srcs, image->public.srcs.c);
	for (unsigned int i = 0; i < region->public.srcs.c; i++) {
	    region->public.srcs.v [i] = aktive_region_new (image->public.srcs.v [i]);
	}
    }

    // Initialize local pointers to important structures 

    region->public.domain = &image->public.domain;
    region->public.param  = image->public.param;
    region->opspec        = image->opspec;

    /* Note: The width and height values will be later replaced with data from
     * the area requested to be fetched
     */
    aktive_geometry_copy (&region->pixels.domain, &image->public.domain);
    region->pixels.region = region;

    // Initialize region state, if any 
    region->public.istate = image->public.state;

    if (image->opspec->region_setup) {
	image->opspec->region_setup (&region->public);
    }

    if (aktive_error_raised ()) {
	aktive_region_destroy (region);
	TRACE_RETURN("(aktive_region) %p", 0);
    }
    
    // Done and return 
    TRACE_RETURN("(aktive_region) %p", region);
}

extern void
aktive_region_destroy (aktive_region region)
{
    TRACE_FUNC("((region) %p '%s'", region, region->opspec->name);
    
    // Release inputs, if any 

    if (region->public.srcs.c) {
	for (unsigned int i = 0; i < region->public.srcs.c; i++) {
	    aktive_region_destroy (region->public.srcs.v [i]);
	}
	aktive_region_vector_free (&region->public.srcs);
    }

    // Release owner 

    aktive_image_unref (region->origin);

    // Release pixel data from the internal block, if any 

    aktive_blit_close (&region->pixels);

    /* Nothing to do for the remaining fields. These are only pointers to
     * image structures not owned by the region
     */

    // Release custom state, if any, and necessary 

    if (region->public.state) {
	if (region->opspec->region_final) { region->opspec->region_final (region->public.state); }
	ckfree ((char*) region->public.state);
    }

    // Release main structure 
    ckfree ((char*) region);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_region_export (aktive_region region, aktive_block* dst)
{
    // Shift pixel data into destination, and squash unwanted backlink.
    *dst = region->pixels;
    dst->region = 0;

    // Squash the old references
    region->pixels.pixel    = 0;
    region->pixels.capacity = 0;
    region->pixels.used     = 0;
}

extern aktive_image
aktive_region_owner (aktive_region region)
{
    TRACE_FUNC("((aktive_region) %p '%s')", region, region->opspec->name);
    TRACE_RETURN ("(aktive_image) %p", region->origin);
}

extern aktive_block*
aktive_region_fetch_area (aktive_region region, aktive_rectangle* request)
{    
    TRACE_FUNC("((aktive_region) %p '%s' requested (@ %d..%d,%d..%d : %ux%u))",
	       region, region->opspec->name,
	       request->x, aktive_geometry_get_xmax (request),
	       request->y, aktive_geometry_get_ymax (request),
	       request->width, request->height);

    // Update the storage per the request to match dimension and have enough
    // space

    aktive_blit_setup (&region->pixels, request);

#define ID region->origin->public.domain
#define RD request
#define BL region->pixels.domain
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
     * a. Request is a subset of the image's domain.
     * b. Request is fully outside of the image's domain.
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
    aktive_rectangle_from_geometry (&domain, &region->origin->public.domain);
    
    if (aktive_rectangle_is_subset (request, &domain)) {
	// Special case (a). The entire request has to be served by the fetcher.
	aktive_rectangle_def (dst, 0, 0, request->width, request->height);
	TRACE ( "dst     (%3d .. %3d  %3d .. %3d | %3d %3d     |     )", dst.x, MX(dst), dst.y, MY(dst), dst.width, dst.height);
	TRACE ( "fetch all (request <= domain)", 0);
	region->opspec->region_fetch (&region->public, request, &dst, &region->pixels);
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
	aktive_blit_clear_all (&region->pixels);
	goto done;
    }

    // Clear the outside zones, if any 
    for (aktive_uint i = 1; i < zc; i++) { aktive_blit_clear (&region->pixels, &zv [i]); }
    
    // The overlap is the only remaining part to handle, and this is done by
    // the fetcher.

    aktive_rectangle dst = zv[0];
    aktive_rectangle_move (&dst, -request->x, -request->y);

#define RD zv[0]
    TRACE ( "section (%3d .. %3d  %3d .. %3d | %3d %3d     |     )", RD.x,  MX(RD),  RD.y,  MY(RD),  RD.width,  RD.height);
    TRACE ( "dst     (%3d .. %3d  %3d .. %3d | %3d %3d     |     )", dst.x, MX(dst), dst.y, MY(dst), dst.width, dst.height);
    TRACE ( "fetch overlap", 0);
#undef RD
#undef MX
#undef MY
#undef PI
    
    region->opspec->region_fetch (&region->public, &zv[0], &dst, &region->pixels);
 done:
    TRACE_DO (__aktive_block_dump (region->opspec->name, &region->pixels));
    // And return them 
    TRACE_RETURN ("(aktive_block*) %p", &region->pixels);
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
