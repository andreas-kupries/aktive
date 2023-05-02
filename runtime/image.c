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
aktive_image_new ( aktive_image_type*   opspec
                 , void*                param
                 , aktive_image_vector* srcs
                 ) {
    TRACE_FUNC("((opspec) %p '%s', (param) %p, (srcs) %p)", opspec, opspec->name, param, srcs);

    /* Create new and clean image structures ... */

    aktive_image r = ALLOC(struct aktive_image);
    memset (r, 0, sizeof(struct aktive_image));
    // refcount == 0

    aktive_image_content c = ALLOC(struct aktive_image_content);
    memset (c, 0, sizeof(struct aktive_image_content));
    // refcount == 0

    r->content  = c;
    c->refcount = 1;

    /* Initialize input images, if any */

    if (srcs) {
	c->public.srcs = *srcs;
	aktive_image_vector_heapify (&c->public.srcs);
	for (aktive_uint i = 0; i < c->public.srcs.c; i++) {
	    aktive_image_ref (c->public.srcs.v [i]); }
    }

    /* Initialize parameters, if any */

    c->public.param = param;
    if (param) {
	void* p = NALLOC (char, opspec->sz_param);
	memcpy (p, param, opspec->sz_param);
	if (opspec->param_init) { opspec->param_init (p); }
	c->public.param = p;
    }

    /* Initialize geometry, meta data, and state, if any */

    int ok = opspec->setup (&c->public, &r->meta);

    if (!ok) {
	// Inlined pieces of `aktive_image_destroy`.
	//
	// Note, this assumes that the callback saved an error message via
	// `aktive_fail/f` for the caller of `aktive_image_new` to pick up.
	//
	// Note further that we can simply destroy the image content because
	// it cannot be shared, having been allocated unshared a few lines above.

	for (aktive_uint i = 0; i < c->public.srcs.c; i++) {
	    aktive_image_unref (c->public.srcs.v [i]); }
	aktive_image_vector_free (&c->public.srcs);

	if (c->public.param) {
	    if (opspec->param_finish) { opspec->param_finish (c->public.param); }
	    ckfree ((char*) c->public.param);
	}

	ckfree ((char*) c);

	TRACE_RETURN("(aktive_image) %p", 0);
    }

    /* Initialize type information and reference management */

    c->opspec = opspec;

    /* Meta data defaults. If the operator has not done any meta data
     * initialization in its setup hook then we inherit the meta data of the
     * first input by default, if any.
     */

    if (!r->meta && c->public.srcs.c) {
	r->meta = c->public.srcs.v [0]->meta;
    }
    if (r->meta) {
	Tcl_IncrRefCount (r->meta);
    }

    /* Done and return */
    TRACE_RETURN("(aktive_image) %p", r);
}

extern void
aktive_image_destroy (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);

    aktive_image_content c = image->content;

    if (c->refcount <= 1) {
	/* Release custom state, if any, and necessary */

	if (c->public.state) {
	    if (c->opspec->final) { c->opspec->final (c->public.state); }
	    ckfree ((char*) c->public.state);
	}

	/* Release parameters, if any, and necessary */

	if (c->public.param) {
	    if (c->opspec->param_finish) { c->opspec->param_finish (c->public.param); }
	    ckfree ((char*) c->public.param);
	}

	/* Release inputs, if any */

	for (aktive_uint i = 0; i < c->public.srcs.c; i++) {
	    aktive_image_unref (c->public.srcs.v [i]); }
	aktive_image_vector_free (&c->public.srcs);

	/* Nothing to do for location and geometry */

	ckfree ((char*) c);
    } else {
	c->refcount --;
    }

    if (image->meta) {
	Tcl_DecrRefCount (image->meta);
    }

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
    TRACE_FUNC("((aktive_image) %p '%s')", src, src ? src->content->opspec->name : 0);

    if (!src) { aktive_error_set (ip); }

    TRACE_RETURN ("(aktive_image) %p", src);
}

extern int
aktive_image_unused (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);

    Tcl_MutexLock (&image->rclock);
    int rc = image->refcount;
    Tcl_MutexUnlock (&image->rclock);

    TRACE_RETURN ("(unused) %d", rc <= 0);
}

extern void
aktive_image_ref (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p @ '%s'/%d)", image, image->content->opspec->name, image->refcount);

    Tcl_MutexLock (&image->rclock);
    image->refcount ++;
    Tcl_MutexUnlock (&image->rclock);

    TRACE_RETURN_VOID;
}

extern void
aktive_image_unref (aktive_image image) {
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);

    Tcl_MutexLock (&image->rclock);
    if (image->refcount > 1) {
	image->refcount --;

	TRACE ("refcount = %d", image->refcount);
	Tcl_MutexUnlock (&image->rclock);

	TRACE_RETURN_VOID;
    }

    Tcl_MutexUnlock (&image->rclock);
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
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(aktive_point*) %p", aktive_geometry_as_point (&image->content->public.domain));
}

extern aktive_rectangle*
aktive_image_get_domain (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(aktive_rectangle*) %p", aktive_geometry_as_rectangle (&image->content->public.domain));
}

extern aktive_geometry*
aktive_image_get_geometry (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(aktive_geometry*) %p", &image->content->public.domain);
}

extern int
aktive_image_get_x (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(x) %d", aktive_geometry_get_x (&image->content->public.domain));
}

extern int
aktive_image_get_xmax (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(xmax) %d", aktive_geometry_get_xmax (&image->content->public.domain));
}

extern int
aktive_image_get_y (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(y) %d", aktive_geometry_get_y (&image->content->public.domain));
}

extern int
aktive_image_get_ymax (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(ymax) %d", aktive_geometry_get_ymax (&image->content->public.domain));
}

extern aktive_uint
aktive_image_get_width (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(width) %u", aktive_geometry_get_width (&image->content->public.domain));
}

extern aktive_uint
aktive_image_get_height (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(height) %u", aktive_geometry_get_height (&image->content->public.domain));
}

extern aktive_uint
aktive_image_get_depth (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(depth) %u", aktive_geometry_get_depth (&image->content->public.domain));
}

extern aktive_uint
aktive_image_get_pixels (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(pixels) %u", aktive_geometry_get_pixels (&image->content->public.domain));
}

extern aktive_uint
aktive_image_get_pitch (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(pitch) %u", aktive_geometry_get_pitch (&image->content->public.domain));
}

extern aktive_uint
aktive_image_get_size (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(size) %u", aktive_geometry_get_size (&image->content->public.domain));
}

extern aktive_image_type*
aktive_image_get_type (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(type) '%p'", image->content->opspec);
}

extern aktive_uint
aktive_image_get_nsrcs (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(nsrcs) %d", image->content->public.srcs.c);
}

extern aktive_image
aktive_image_get_src (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);

    if (i >= image->content->public.srcs.c) {
	TRACE_RETURN ("(src) %p", 0);
    }

    TRACE_RETURN ("(src) '%p'", image->content->public.srcs.v [i]);
}

extern aktive_uint
aktive_image_get_nparams (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(nparams) %d", image->content->opspec->n_param);
}

extern const char*
aktive_image_get_param_name (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);

    if (i >= image->content->opspec->n_param) {
	TRACE_RETURN ("(name) %p", 0);
    }

    const char* name = image->content->opspec->param [i].name;

    TRACE_RETURN ("(name) '%s'", name);
}

extern const char*
aktive_image_get_param_desc (aktive_image image, aktive_uint i)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);

    if (i >= image->content->opspec->n_param) {
	TRACE_RETURN ("(desc) %p", 0);
    }

    const char* desc = image->content->opspec->param [i].desc;

    TRACE_RETURN ("(desc) '%s'", desc);
}

extern Tcl_Obj*
aktive_image_get_param_value (aktive_image image, aktive_uint i, Tcl_Interp* interp)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);

    if (i >= image->content->opspec->n_param) {
	TRACE_RETURN ("(value) %p", 0);
    }

    void*              field  = image->content->public.param  + image->content->opspec->param [i].offset;
    aktive_param_value to_obj = image->content->opspec->param [i].to_obj;

    Tcl_Obj* obj = to_obj (interp, field);

    TRACE_RETURN ("(value) %p", obj);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj*
aktive_image_meta_get (aktive_image image)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);
    TRACE_RETURN ("(value) %p", image->meta);
}

extern aktive_image
aktive_image_meta_set (aktive_image image, Tcl_Obj* meta)
{
    TRACE_FUNC("((aktive_image) %p '%s'/%d)", image, image->content->opspec->name, image->refcount);

    // TODO :: See if there is a case of shared image where in-place edit is still possible.
    //             -- something for the meta edit operators to look at
    //                ?? ref as operator argument + ref to variable

    aktive_image r;

    if (image->refcount <= 1) {
	// Pass unshared image through, and replace meta in place.

	r = image;
	if (r->meta) { Tcl_DecrRefCount (r->meta); }

    } else {
	// New image structure with new meta data and using the content of the
	// input image.

	aktive_image r = ALLOC(struct aktive_image);
	memset (r, 0, sizeof(struct aktive_image));
	// refcount == 0

	r->content = image->content;
	r->content->refcount ++;
    }

    r->meta = meta;
    if (r->meta) {
	Tcl_IncrRefCount (r->meta);
    }

    TRACE_RETURN ("(aktive_image) %p", image);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_meta_inherit (Tcl_Obj** meta, aktive_image src)
{
    if (*meta) { Tcl_DecrRefCount (*meta); }
    *meta = src->meta;
    if (*meta) { Tcl_IncrRefCount (*meta); }
}

extern void
aktive_meta_set (Tcl_Obj** meta, const char* key, Tcl_Obj* value)
{
    if (! *meta) { *meta = Tcl_NewDictObj (); }
    if (Tcl_IsShared (*meta)) { *meta = Tcl_DuplicateObj (*meta); }

    Tcl_Obj* okey = Tcl_NewStringObj (key, -1);
    Tcl_DictObjPut (NULL, *meta, okey, value);
}

extern void
aktive_meta_set_string (Tcl_Obj** meta, const char* key, const char* value)
{
    aktive_meta_set (meta, key, Tcl_NewStringObj (value, -1));
}

extern void
aktive_meta_set_int (Tcl_Obj** meta, const char* key, int value)
{
    aktive_meta_set (meta, key, Tcl_NewIntObj (value));
}

extern int
aktive_meta_has (Tcl_Obj* meta, const char* key)
{
    Tcl_Obj* k = Tcl_NewStringObj (key, -1);
    Tcl_Obj* v;
    int      r = Tcl_DictObjGet(NULL, meta, k, &v);
    return (r == TCL_OK) && (v != NULL);
}

extern int
aktive_meta_equal (Tcl_Obj* meta, const char* key, const char* value)
{
    Tcl_Obj* k = Tcl_NewStringObj (key, -1);
    Tcl_Obj* v;
    int      r = Tcl_DictObjGet (NULL, meta, k, &v);

    if (r != TCL_OK) { return 0; }
    if (!v)          { return 0; }

    char* vs = Tcl_GetStringFromObj (v, NULL);

    return strcmp (value, vs) == 0;
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
