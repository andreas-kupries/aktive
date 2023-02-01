/* -*- c -*-
 */

#include <types_int.h>

/* - - -- --- ----- -------- -------------
 * Images - Construction, Destruction
 */

static aktive_image
aktive_image_new (aktive_image_type*   opspec,
		  void*                param ,
		  aktive_image_vector* srcs  ) {

    TRACE_FUNC("((opspec) %p '%s', (param) %p, (srcs) %p)", opspec, opspec->name, param, srcs);

    /* Create new and clean image structure ... */

    aktive_image r = ALLOC(struct aktive_image);
    memset (r, 0, sizeof(struct aktive_image));

    /* Initialize input images, if any */

    if (srcs) { r->srcs = *srcs; aktive_image_vector_heapify (&r->srcs); }

    /* Initialize parameters, if any */

    r->param = param;
    if (param) {
	void* p = NALLOC (char, opspec->sz_param);
	memcpy (p, param, opspec->sz_param);
	if (opspec->param_init) { opspec->param_init (p); }
	r->param = p;
    }

    /* Initialize custom state, if any */

    if (opspec->setup) { r->state = opspec->setup (r->param, &r->srcs); }

    /* Initialize location and geometry */

    if (opspec->geo_setup) {
	opspec->geo_setup (r->param, &r->srcs, r->state, &r->location, &r->geometry);
    }

    /* Initialize type information and reference management */

    r->opspec   = opspec;
    r->refcount = 0;

    // TODO meta     -- opspec hook taking param, srcs -- returning Tcl_Obj*

    /* Done and return */
    TRACE_RETURN("(aktive_image) %p", r);
}

static void
aktive_image_destroy (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p)", image);

    /* Release custom state, if any, and necessary */

    if (image->state) {
	if (image->opspec->final) { image->opspec->final (image->state); }
	ckfree ((char*) image->state);
    }

    /* Release parameters, if any, and necessary */

    if (image->param) {
	if (image->opspec->param_finish) { image->opspec->param_finish (image->param); }
	ckfree ((char*) image->param);
    }

    // TODO meta

    /* Release inputs, if any */

    aktive_image_vector_free (&image->srcs);

    /* Nothing to do for location and geometry */

    /* Release main structure */
    ckfree ((char*) image);

    TRACE_RETURN_VOID;
}

/* - - -- --- ----- -------- -------------
 * Images - Lifecycle management, including destruction
 */

static aktive_image
aktive_image_check (Tcl_Interp* ip, aktive_image src) {
    if (!src) { aktive_error_set (ip); }
    return src;
}

static int
aktive_image_unused (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(used) %d", image->refcount <= 0);
}

static void
aktive_image_ref (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p)", image);

    image->refcount ++;

    TRACE_RETURN_VOID;
}

static void
aktive_image_unref (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p)", image);

    if (image->refcount > 1) {
	image->refcount --;

	TRACE ("refcount = %d", image->refcount);
	TRACE_RETURN_VOID;
    }

    aktive_image_destroy (image);

    TRACE_RETURN_VOID;
}

/* - - -- --- ----- -------- -------------
 */

#include <objtype_image.c>

/* - - -- --- ----- -------- -------------
 * Regions -- Construction, Destruction
 */

static aktive_region
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

    /* Initialize local pointers to and copies of important structures */

    r->param    = image->param;
    r->opspec   = image->opspec;
#if 0 /* REGION NOT NEEDED */
    r->location = &image->location;
    r->geometry = &image->geometry;
#endif
    r->pixels.depth = image->geometry.depth;

    /* Initialize custom state, if any */

    if (image->opspec->region_setup) {
	r->state = image->opspec->region_setup (r->param,
						&r->srcs,
						image->state);
    }

    /* Done and return */
    TRACE_RETURN("(aktive_region) %p", r);
}

static void
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

/* - - -- --- ----- -------- -------------
 * Error management
 */

static void
aktive_error_set (Tcl_Interp* interp) {
    // TODO: store collected errors into interpreter
}

/* - - -- --- ----- -------- -------------
 * Type support
 */

static Tcl_Obj* aktive_new_uint_obj (aktive_uint x) {
    Tcl_WideInt w = x;
    return Tcl_NewWideIntObj(w);
}

static Tcl_Obj* aktive_new_point_obj(aktive_point* p) {
    Tcl_Obj* el[2];

    el[0] = Tcl_NewIntObj(p->x);
    el[1] = Tcl_NewIntObj(p->y);

    return Tcl_NewListObj (2, el);
}

/* - - -- --- ----- -------- -------------
 * -- Image accessors
 *
 * Notes:
 *  - `image->opspec` references generated variables
 *    See `*_opspec` in file `generated/op-funcs.c`
 *
 *  - `aktive_param_name` is a generated variable
 *     See file `generated/param-names.c`

 *  - `aktive_param_desc` is a generated variable
 *     See file `generated/param-descriptions.c`

 *  - `aktive_type_descriptor` is a generated variable
 *     See file `generated/type-descriptor.c`
 */

static int
aktive_image_get_x (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(x) %d", image->location.x);
}

static int
aktive_image_get_xmax (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(xmax) %d", image->location.x + image->geometry.width - 1);
}

static int
aktive_image_get_y (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(y) %d", image->location.y);
}

static int
aktive_image_get_ymax (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(ymax) %d", image->location.y + image->geometry.height -1);
}

static aktive_uint
aktive_image_get_width (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(width) %u", image->geometry.width);
}

static aktive_uint
aktive_image_get_height (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(height) %u", image->geometry.height);
}

static aktive_uint
aktive_image_get_depth (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(depth) %u", image->geometry.depth);
}

static aktive_uint
aktive_image_get_pixels (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    aktive_uint pixels = image->geometry.width * image->geometry.height;

    TRACE_RETURN ("(pixels) %u", pixels);
}

static aktive_uint
aktive_image_get_pitch (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    aktive_uint pitch = image->geometry.width * image->geometry.depth;

    TRACE_RETURN ("(pitch) %u", pitch);
}

static aktive_uint
aktive_image_get_size (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    aktive_uint size = image->geometry.width * image->geometry.height * image->geometry.depth;

    TRACE_RETURN ("(size) %u", size);
}

static const aktive_image_type*
aktive_image_get_type (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(type) '%p'", image->opspec);
}

static aktive_uint
aktive_image_get_nsrcs (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(nsrcs) %d", image->srcs.c);
}

static aktive_image
aktive_image_get_src (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->srcs.c) {
	TRACE_RETURN ("(src) %p", 0);
    }

    TRACE_RETURN ("(src) '%p'", image->srcs.v [i]);
}

static aktive_uint
aktive_image_get_nparams (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(nparams) %d", image->opspec->n_param);
}

static const char*
aktive_image_get_param_name (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(name) %p", 0);
    }

    const char* name = aktive_param_name [image->opspec->param [i].name];

    TRACE_RETURN ("(name) '%s'", name);
}

static const char*
aktive_image_get_param_desc (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(desc) %p", 0);
    }

    const char* desc = aktive_param_desc [image->opspec->param [i].desc];
    /* generated ------^^^^^^^^^^^^^^^^^ */

    TRACE_RETURN ("(desc) '%s'", desc);
}

static Tcl_Obj*
aktive_image_get_param_value (aktive_image image, aktive_uint i, Tcl_Interp* interp)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(value) %p", 0);
    }

    void*              field  = image->param  + image->opspec->param [i].offset;
    aktive_param_value to_obj = aktive_type_descriptor [image->opspec->param [i].type].to_obj;

    Tcl_Obj* obj = to_obj (interp, field);

    TRACE_RETURN ("(value) %p", obj);
}

/*
 * - - -- --- ----- -------- -------------
 * -- Region accessors
 */

static aktive_image
aktive_region_owner (aktive_region region)
{
    TRACE_FUNC("((aktive_region) %p '%s')", region, region->opspec->name);
    TRACE_RETURN ("(aktive_image) %p", region->origin);
}

static aktive_block*
aktive_region_fetch_area (aktive_region region, aktive_rectangle* area)
{
    TRACE_FUNC("((aktive_region) %p '%s' (@ %d,%d : %ux%u))", region, region->opspec->name,
	       area->x, area->y, area->width, area->height);

    /* Allocate area for the pixel data. Possibly reuse if already existing. */

    aktive_uint size = area->width * area->height * region->pixels.depth;

    if (!region->pixels.pixel) {
	region->pixels.pixel    = NALLOC (double, size);
	region->pixels.capacity = size;
    } else if (region->pixels.capacity < size) {
	region->pixels.pixel    = REALLOC (region->pixels.pixel, double, size);
	region->pixels.capacity = size;
    }

    /* Saved desired area to the block for the fetch callback to see */

    region->pixels.rect = *area;
    region->pixels.used = size;

    /* Compute the pixels */

    region->opspec->region_fetch (region->param, &region->srcs, region->state, &region->pixels);

    /* And return them */

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
