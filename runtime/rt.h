/* -*- c -*-
 */
#ifndef AKTIVE_RT_H
#define AKTIVE_RT_H

/* - - -- --- ----- -------- -------------
 * Runtime API -- Image management (construction, querying)
 *
 * Images form a forest of DAGs of operations, with generators as data sources
 * and others declaring the desired transformations on the data. This forest
 * is process global and passive. It holds descriptions, but no actual data,
 * and does only the minimal processing needed to initialize any image.
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

/* - - -- --- ----- -------- -------------
 * Runtime API -- Region management (construction, querying)
 *
 * Regions are the active element. Internally regions form a forest of DAGs
 * parallel to the forest of images. Processing happens when a region is asked
 * to fetch the pixels for an area, cascading down to the DAG from the queried
 * region to input regions until reaching the regions attached to the data
 * sources.
 *
 * Note that each image may have multiple regions referencing it. The data of
 * all regions for an image is generally completely separate. This enables the
 * use of threads to concurrently compute pixel data for multiple regions of
 * an image, without locking.
 *
 * There will be exception to this though. Mainly in file-based data sources,
 * where the underlying access libraries do not support concurrent access. The
 * format itself may force some kind of sequential reading as well.
 *
 * ATTENTION: The `aktive_block*` results out of a fetch are owned and managed
 * by the region. The region is responsible for allocation and release of the
 * structure and its contents. Any returned block will be valid only until the
 * next fetch operation on the same region.
 */

static aktive_region aktive_region_new        (aktive_image image);
static void          aktive_region_destroy    (aktive_region region);
static aktive_image  aktive_region_owner      (aktive_region region);
static aktive_block* aktive_region_fetch_area (aktive_region region, aktive_rectangle* area);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_RT_H */
