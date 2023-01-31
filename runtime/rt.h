/* -*- c -*-
 */
#ifndef AKTIVE_RT_H
#define AKTIVE_RT_H

/* - - -- --- ----- -------- -------------
 * Runtime function declarations
 */

static aktive_image
aktive_image_new ( aktive_image_type*   opspec
		 , void*                param
	         , aktive_image_vector* srcs
		 );

static int  aktive_image_unused (aktive_image image);
static void aktive_image_unref  (aktive_image image);
static void aktive_image_ref    (aktive_image image);

static aktive_image aktive_image_check (Tcl_Interp* ip, aktive_image src);

static int      aktive_image_from_obj (Tcl_Interp* interp, Tcl_Obj* obj, aktive_image* image);
static Tcl_Obj* aktive_new_image_obj  (aktive_image image);

static Tcl_Obj* aktive_new_uint_obj  (aktive_uint x);
static Tcl_Obj* aktive_new_point_obj (aktive_point* p);

static void aktive_error_set (Tcl_Interp* interp);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_RT_H */
