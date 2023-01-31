/* -*- c -*-
 */
#ifndef AKTIVE_RT_H
#define AKTIVE_RT_H

/* - - -- --- ----- -------- -------------
 * Runtime API -- Image construction and querying
 */

static aktive_image
aktive_image_new ( aktive_image_type*   opspec
		 , void*                param
	         , aktive_image_vector* srcs
		 );

static int  aktive_image_unused (aktive_image image);
static void aktive_image_unref  (aktive_image image);
static void aktive_image_ref    (aktive_image image);

static int         aktive_image_get_x      (aktive_image image);
static int         aktive_image_get_xmax   (aktive_image image);
static int         aktive_image_get_y      (aktive_image image);
static int         aktive_image_get_ymax   (aktive_image image);
static aktive_uint aktive_image_get_width  (aktive_image image);
static aktive_uint aktive_image_get_height (aktive_image image);
static aktive_uint aktive_image_get_depth  (aktive_image image);
static aktive_uint aktive_image_get_pitch  (aktive_image image); /* width * depth  */
static aktive_uint aktive_image_get_pixels (aktive_image image); /* width * height */
static aktive_uint aktive_image_get_size   (aktive_image image); /* pixels * depth */

static const aktive_image_type* aktive_image_get_type (aktive_image image);

static aktive_uint  aktive_image_get_nsrcs (aktive_image image);
static aktive_image aktive_image_get_src   (aktive_image image, aktive_uint i);

static aktive_uint aktive_image_get_nparams     (aktive_image image);
static const char* aktive_image_get_param_name  (aktive_image image, aktive_uint i);
static const char* aktive_image_get_param_desc  (aktive_image image, aktive_uint i);
static Tcl_Obj*    aktive_image_get_param_value (aktive_image image, aktive_uint i,
						 Tcl_Interp* interp);

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
