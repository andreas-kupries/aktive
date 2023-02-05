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
#include <internals.h>

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
	r->public.srcs = *srcs;
	aktive_image_vector_heapify (&r->public.srcs);
	for (aktive_uint i = 0; i < r->public.srcs.c; i++) { aktive_image_ref (r->public.srcs.v [i]); }
    }

    /* Initialize parameters, if any */

    r->public.param = param;
    if (param) {
	void* p = NALLOC (char, opspec->sz_param);
	memcpy (p, param, opspec->sz_param);
	if (opspec->param_init) { opspec->param_init (p); }
	r->public.param = p;
    }

    /* Initialize geometry, and state, if any */

    opspec->setup (&r->public);
    
    /* Initialize type information and reference management */

    r->opspec   = opspec;
    r->refcount = 0;

    // TODO meta     -- opspec hook taking param, srcs -- returning Tcl_Obj*

    /* Done and return */
    TRACE_RETURN("(aktive_image) %p", r);
}

extern void
aktive_image_destroy (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);

    /* Release custom state, if any, and necessary */

    if (image->public.state) {
	if (image->opspec->final) { image->opspec->final (image->public.state); }
	ckfree ((char*) image->public.state);
    }

    /* Release parameters, if any, and necessary */

    if (image->public.param) {
	if (image->opspec->param_finish) { image->opspec->param_finish (image->public.param); }
	ckfree ((char*) image->public.param);
    }

    // TODO meta

    /* Release inputs, if any */

    aktive_image_vector_free (&image->public.srcs);
    for (aktive_uint i = 0; i < image->public.srcs.c; i++) { aktive_image_unref (image->public.srcs.v [i]); }

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
    TRACE_FUNC("((aktive_image) %p '%s')", src, src ? src->opspec->name : 0);

    if (!src) { aktive_error_set (ip); }

    TRACE_RETURN ("(aktive_image) %p", src);
}

extern int
aktive_image_unused (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(unused) %d", image->refcount <= 0);
}

extern void
aktive_image_ref (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p @ '%s'/%d)", image, image->opspec->name, image->refcount);

    image->refcount ++;

    TRACE_RETURN_VOID;
}

extern void
aktive_image_unref (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);

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

extern aktive_point*
aktive_image_get_location (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(aktive_point*) %p", aktive_geometry_as_point (&image->public.domain));
}

extern aktive_rectangle*
aktive_image_get_domain (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(aktive_rectangle*) %p", aktive_geometry_as_rectangle (&image->public.domain));
}

extern aktive_geometry*
aktive_image_get_geometry (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(aktive_geometry*) %p", &image->public.domain);
}

extern int
aktive_image_get_x (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(x) %d", aktive_geometry_get_x (&image->public.domain));
}

extern int
aktive_image_get_xmax (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(xmax) %d", aktive_geometry_get_xmax (&image->public.domain));
}

extern int
aktive_image_get_y (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(y) %d", aktive_geometry_get_y (&image->public.domain));
}

extern int
aktive_image_get_ymax (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(ymax) %d", aktive_geometry_get_ymax (&image->public.domain));
}

extern aktive_uint
aktive_image_get_width (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(width) %u", aktive_geometry_get_width (&image->public.domain));
}

extern aktive_uint
aktive_image_get_height (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(height) %u", aktive_geometry_get_height (&image->public.domain));
}

extern aktive_uint
aktive_image_get_depth (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(depth) %u", aktive_geometry_get_depth (&image->public.domain));
}

extern aktive_uint
aktive_image_get_pixels (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(pixels) %u", aktive_geometry_get_pixels (&image->public.domain));
}

extern aktive_uint
aktive_image_get_pitch (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(pitch) %u", aktive_geometry_get_pitch (&image->public.domain));
}

extern aktive_uint
aktive_image_get_size (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(size) %u", aktive_geometry_get_size (&image->public.domain));
}

extern aktive_image_type*
aktive_image_get_type (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(type) '%p'", image->opspec);
}

extern aktive_uint
aktive_image_get_nsrcs (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(nsrcs) %d", image->public.srcs.c);
}

extern aktive_image
aktive_image_get_src (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);

    if (i >= image->public.srcs.c) {
	TRACE_RETURN ("(src) %p", 0);
    }

    TRACE_RETURN ("(src) '%p'", image->public.srcs.v [i]);
}

extern aktive_uint
aktive_image_get_nparams (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);
    TRACE_RETURN ("(nparams) %d", image->opspec->n_param);
}

extern const char*
aktive_image_get_param_name (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(name) %p", 0);
    }

    const char* name = image->opspec->param [i].name;

    TRACE_RETURN ("(name) '%s'", name);
}

extern const char*
aktive_image_get_param_desc (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(desc) %p", 0);
    }

    const char* desc = image->opspec->param [i].desc;
    
    TRACE_RETURN ("(desc) '%s'", desc);
}

extern Tcl_Obj*
aktive_image_get_param_value (aktive_image image, aktive_uint i, Tcl_Interp* interp)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->opspec->name, image->refcount);

    if (i >= image->opspec->n_param) {
	TRACE_RETURN ("(value) %p", 0);
    }

    void*              field  = image->public.param  + image->opspec->param [i].offset;
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
