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
#include <types_int.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_region
aktive_region_new (aktive_image image)
{
    TRACE_FUNC("((image) %p '%s'", image, image->opspec->name);

    /* Create new and clean image structure ... */

    aktive_region r = ALLOC(struct aktive_region);
    memset (r, 0, sizeof(struct aktive_region));

    /* Reference origin */

    r->origin = image; aktive_image_ref (image);

    /* Generate regions representing the inputs, if any */

    if (image->srcs.c) {
	aktive_region_vector_new (&r->srcs, image->srcs.c);
	for (unsigned int i = 0; i < r->srcs.c; i++) {
	    r->srcs.v [i] = aktive_region_new (image->srcs.v [i]);
	}
    }

    /* Initialize local pointers to important structures */

    r->param    = image->param;
    r->opspec   = image->opspec;

    /* Note: The width and height values will be later replaced with data from
     * the area requested to be fetched
     */
    aktive_geometry_copy (&r->pixels.geo, &image->geometry);

    r->pixels.region = r;

    /* Initialize custom state, if any */

    if (image->opspec->region_setup) {
	r->state = image->opspec->region_setup (r->param,
						&r->srcs,
						image->state);
    }

    /* Done and return */
    TRACE_RETURN("(aktive_region) %p", r);
}

extern void
aktive_region_destroy (aktive_region region)
{
    TRACE_FUNC("((region) %p '%s'", region, region->opspec->name);

    /* Release custom state, if any, and necessary */

    if (region->state) {
	if (region->opspec->region_final) { region->opspec->final (region->state); }
	ckfree ((char*) region->state);
    }

    /* Release inputs, if any */

    aktive_region_vector_free (&region->srcs);

    /* Release owner */

    aktive_image_unref (region->origin);

    /* Release pixel data from the internal block, if any */

    if (region->pixels.pixel) { ckfree ((char*) region->pixels.pixel); }

    /* Nothing to do for the remaining fields. These are only pointers to
     * image structures not owned by the region
     */

    /* Release main structure */
    ckfree ((char*) region);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_image
aktive_region_owner (aktive_region region)
{
    TRACE_FUNC("((aktive_region) %p '%s')", region, region->opspec->name);
    TRACE_RETURN ("(aktive_image) %p", region->origin);
}

extern aktive_block*
aktive_region_fetch_area (aktive_region region, aktive_rectangle* request)
{    
    TRACE_FUNC("((aktive_region) %p '%s' (@ %d,%d : %ux%u))",
	       region, region->opspec->name,
	       request->x, request->y, request->width, request->height);

    // region
    //   pixels
    //	   geo	- block dimensions
    //   origin
    //     domain	area covered by the image
    // request		area to get pixels for

    //    fprintf(stderr,"FETCH %p (%s)\n", region, region->opspec->name);fflush (stderr);
    //    __aktive_rectangle_dump ("\trequest", request);
    //    __aktive_rectangle_dump ("\tdomain ", &region->origin->domain);

    /* Initialize or update the pixel block with the dimensions of the
     * requested area, and ensure that the pixel memory is large enough to
     * hald all the requested pixels.
     */

    /* Update the desired request to fill */

    aktive_geometry_set_rect (&region->pixels.geo, request);

    aktive_uint size = request->width * request->height * region->pixels.geo.depth;
    region->pixels.used = size;

    if (!region->pixels.pixel) {
	region->pixels.pixel    = NALLOC (double, size);
	region->pixels.capacity = size;
    } else if (region->pixels.capacity < size) {
	region->pixels.pixel    = REALLOC (region->pixels.pixel, double, size);
	region->pixels.capacity = size;
    } // else: have enough space already, do nothing
    //// future: maybe realloc down if used <= 1/2*capacity

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

    aktive_rectangle domain; aktive_rectangle_copy (&domain, &region->origin->domain);
    
    if (aktive_rectangle_is_subset (&domain, request)) {
	// fprintf(stderr,"SUBSET\n");fflush (stderr);
    
	// Special case (a). The entire request has to be served by the fetcher.
	aktive_rectangle phys = { 0, 0, request->width, request->height };

	// __aktive_rectangle_dump ("\t- full req ", request);
	// __aktive_rectangle_dump ("\t- full preq", &phys);

	region->opspec->region_fetch (region->param, &region->srcs,
				      region->state, request, &phys,
				      &region->pixels);
	goto done;
    }

    /* Compute the inside and outside zones. The intersection, i.e. the inside
     * part, is always stored in zv[0].
     */

    aktive_rectangle zv [5];
    aktive_uint      zc;
    aktive_rectangle_outzones (&domain, request, &zc, zv);

    if (zc == 0) {
	// fprintf(stderr,"OUTSIDE\n");fflush (stderr);
	
	// Special case (b). No data comes from the image itself.
	aktive_blit_clear_all (&region->pixels);
	goto done;
    }

    // fprintf(stderr,"IN PIECES\n");fflush (stderr);
    
    /* Clear the outside zones, if any */
    for (aktive_uint i = 1; i < zc; i++) { aktive_blit_clear (&region->pixels, &zv [i]); }
    
    // The overlap is the only remaining part to handle, and this is done by
    // the fetcher.

    aktive_rectangle phys;
    aktive_rectangle_copy (&phys, &zv [0]);
    aktive_rectangle_move (&phys, -request->x, -request->y);

    // __aktive_rectangle_dump ("\t- inside req ", &zv[0]);
    // __aktive_rectangle_dump ("\t- inside preq", &phys);
    
    region->opspec->region_fetch (region->param, &region->srcs, region->state,
				  &zv [0], &phys, &region->pixels);
 done:
    /* And return them */

    // __aktive_block_dump (region->opspec->name, &region->pixels);
    
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
