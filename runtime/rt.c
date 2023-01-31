/* -*- c -*-
 */

#include <types_int.h>

/* - - -- --- ----- -------- -------------
 * Construction, destruction
 */

static aktive_image
aktive_image_new (aktive_image_type*   opspec,
		  void*                param ,
		  aktive_image_vector* srcs  ) {

  TRACE_FUNC("((opspec) %p '%s', (param) %p, (srcs) %p)", opspec, opspec->name, param, srcs);
  
  aktive_image r = ALLOC(struct aktive_image);

  if (srcs) {
    r->srcs = *srcs;
    aktive_image_vector_heapify (&r->srcs);
  } else {
    r->srcs.c = 0;
    r->srcs.v = 0;
  }

  if (param) {
    void* p = NALLOC (char, opspec->sz_param);
    memcpy (p, param, opspec->sz_param);
    if (opspec->init) { opspec->init (p); }
    param = p;
  }
  
  r->param    = param;
  r->opspec   = opspec;
  r->refcount = 0;

  // TODO geometry -- opspec hook taking param, srcs -- returning geometry
  // TODO meta     -- opspec hook taking param, srcs -- returning Tcl_Obj*

  TRACE_RETURN("(aktive_image) %p", r);
}

static void
aktive_image_destroy (aktive_image image) {
  TRACE_FUNC("((aktive_image) %p)", image);
  
  if (image->param) {
    if (image->opspec->finish) { image->opspec->finish (image->param); }
    ckfree ((char*) image->param);
  }

  // TODO geometry
  // TODO meta

  aktive_image_vector_free (&image->srcs);  
  ckfree ((char*) image);

  TRACE_RETURN_VOID;
}

/* - - -- --- ----- -------- -------------
 * Lifecycle management, including destruction
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

/*
 * - - -- --- ----- -------- -------------
 */
