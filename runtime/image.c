/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * API implementation - Images
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

extern aktive_image
aktive_image_new (aktive_image_type*   opspec,
		  void*                param ,
		  aktive_image_vector* srcs  ) {

    TRACE_FUNC("((opspec) %p '%s', (param) %p, (srcs) %p)", opspec, opspec->name, param, srcs);

    /* Create new and clean image structure ... */

    aktive_image r = ALLOC(struct aktive_image);
    memset (r, 0, sizeof(struct aktive_image));

    /* Initialize input images, if any */

    if (srcs) {
	r->srcs = *srcs;
	aktive_image_vector_heapify (&r->srcs);
	for (aktive_uint i = 0; i++; i < r->srcs.c) { aktive_image_ref (r->srcs.v [i]); }
    }

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

    /* Initialize location, geometry, and domain */

    opspec->geo_setup (r->param, &r->srcs, r->state, &r->location, &r->geometry);

    aktive_rectangle_set_location (&r->domain, &r->location);
    aktive_rectangle_set_geometry (&r->domain, &r->geometry);
    
    /* Initialize type information and reference management */

    r->opspec   = opspec;
    r->refcount = 0;

    // TODO meta     -- opspec hook taking param, srcs -- returning Tcl_Obj*

    /* Done and return */
    TRACE_RETURN("(aktive_image) %p", r);
}

extern void
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
    for (aktive_uint i = 0; i++; i < image->srcs.c) { aktive_image_unref (image->srcs.v [i]); }

    /* Nothing to do for location and geometry */

    /* Release main structure */
    ckfree ((char*) image);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 * Lifecycle management, including destruction
 */

extern aktive_image
aktive_image_check (Tcl_Interp* ip, aktive_image src) {
    if (!src) { aktive_error_set (ip); }
    return src;
}

extern int
aktive_image_unused (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(used) %d", image->refcount <= 0);
}

extern void
aktive_image_ref (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p)", image);

    image->refcount ++;

    TRACE_RETURN_VOID;
}

extern void
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

/*
 * - - -- --- ----- -------- -------------
 * -- Image accessors
 */

extern int
aktive_image_get_x (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(x) %d", image->location.x);
}

extern int
aktive_image_get_xmax (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(xmax) %d", image->location.x + image->geometry.width - 1);
}

extern int
aktive_image_get_y (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(y) %d", image->location.y);
}

extern int
aktive_image_get_ymax (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(ymax) %d", image->location.y + image->geometry.height -1);
}

extern aktive_uint
aktive_image_get_width (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(width) %u", image->geometry.width);
}

extern aktive_uint
aktive_image_get_height (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(height) %u", image->geometry.height);
}

extern aktive_uint
aktive_image_get_depth (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(depth) %u", image->geometry.depth);
}

extern aktive_uint
aktive_image_get_pixels (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    aktive_uint pixels =
	image->geometry.width *
	image->geometry.height;

    TRACE_RETURN ("(pixels) %u", pixels);
}

extern aktive_uint
aktive_image_get_pitch (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    aktive_uint pitch =
	image->geometry.width *
	image->geometry.depth;

    TRACE_RETURN ("(pitch) %u", pitch);
}

extern aktive_uint
aktive_image_get_size (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    aktive_uint size =
	image->geometry.width  *
	image->geometry.height *
	image->geometry.depth;

    TRACE_RETURN ("(size) %u", size);
}

extern aktive_image_type*
aktive_image_get_type (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(type) '%p'", image->opspec);
}

extern aktive_uint
aktive_image_get_nsrcs (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(nsrcs) %d", image->srcs.c);
}

extern aktive_image
aktive_image_get_src (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->srcs.c) {
	TRACE_RETURN ("(src) %p", 0);
    }

    TRACE_RETURN ("(src) '%p'", image->srcs.v [i]);
}

extern aktive_uint
aktive_image_get_nparams (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p)", image);
    TRACE_RETURN ("(nparams) %d", image->opspec->n_param);
}

extern const char*
aktive_image_get_param_name (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(name) %p", 0);
    }

    const char* name = image->opspec->param [i].name;

    TRACE_RETURN ("(name) '%s'", name);
}

extern const char*
aktive_image_get_param_desc (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(desc) %p", 0);
    }

    const char* desc = image->opspec->param [i].desc;
    
    TRACE_RETURN ("(desc) '%s'", desc);
}

extern Tcl_Obj*
aktive_image_get_param_value (aktive_image image, aktive_uint i, Tcl_Interp* interp)
{
    TRACE_FUNC("((aktive_image) %p)", image);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(value) %p", 0);
    }

    void*              field  = image->param  + image->opspec->param [i].offset;
    aktive_param_value to_obj = image->opspec->param [i].to_obj;

    Tcl_Obj* obj = to_obj (interp, field);

    TRACE_RETURN ("(value) %p", obj);
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
