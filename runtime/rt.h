/* -*- c -*-
 */
#ifndef AKTIVE_RT_H
#define AKTIVE_RT_H

/* - - -- --- ----- -------- -------------
 * API types
 */

#include <types.h>

/* - - -- --- ----- -------- -------------
 * Runtime API -- Image management (construction, querying)
 *
 * Images form a forest of DAGs of operations, with generators as data sources
 * and others declaring the desired transformations on the data. This forest
 * is process global and passive. It holds descriptions, but no actual data,
 * and does only the minimal processing needed to initialize any image.
 */

extern aktive_image
aktive_image_new ( aktive_image_type*   opspec
		 , void*                param
	         , aktive_image_vector* srcs
		 );

extern int  aktive_image_unused (aktive_image image);
extern void aktive_image_unref  (aktive_image image);
extern void aktive_image_ref    (aktive_image image);

extern int         aktive_image_get_x      (aktive_image image);
extern int         aktive_image_get_xmax   (aktive_image image);
extern int         aktive_image_get_y      (aktive_image image);
extern int         aktive_image_get_ymax   (aktive_image image);
extern aktive_uint aktive_image_get_width  (aktive_image image);
extern aktive_uint aktive_image_get_height (aktive_image image);
extern aktive_uint aktive_image_get_depth  (aktive_image image);
extern aktive_uint aktive_image_get_pitch  (aktive_image image); /* width * depth  */
extern aktive_uint aktive_image_get_pixels (aktive_image image); /* width * height */
extern aktive_uint aktive_image_get_size   (aktive_image image); /* pixels * depth */

extern aktive_image_type* aktive_image_get_type (aktive_image image);

extern aktive_uint  aktive_image_get_nsrcs (aktive_image image);
extern aktive_image aktive_image_get_src   (aktive_image image, aktive_uint i);

extern aktive_uint aktive_image_get_nparams     (aktive_image image);
extern const char* aktive_image_get_param_name  (aktive_image image, aktive_uint i);
extern const char* aktive_image_get_param_desc  (aktive_image image, aktive_uint i);
extern Tcl_Obj*    aktive_image_get_param_value (aktive_image image, aktive_uint i,
						 Tcl_Interp* interp);

extern aktive_image aktive_image_check (Tcl_Interp* ip, aktive_image src);

extern int      aktive_image_from_obj (Tcl_Interp* interp, Tcl_Obj* obj, aktive_image* image);
extern Tcl_Obj* aktive_new_image_obj  (aktive_image image);

extern Tcl_Obj* aktive_new_uint_obj      (aktive_uint x);
extern Tcl_Obj* aktive_new_point_obj     (aktive_point* p);
extern Tcl_Obj* aktive_new_rectangle_obj (aktive_rectangle* r);

extern void aktive_error_set (Tcl_Interp* interp);

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

extern aktive_region aktive_region_new        (aktive_image image);
extern void          aktive_region_destroy    (aktive_region region);
extern aktive_image  aktive_region_owner      (aktive_region region);
extern aktive_block* aktive_region_fetch_area (aktive_region region, aktive_rectangle* area);

/* - - -- --- ----- -------- -------------
 * Runtime API -- Operations on and with locations, geometries, and rectangles
 */

extern void aktive_point_set      (aktive_point* dst, int x,  int y);
extern void aktive_point_set_rect (aktive_point* dst, aktive_rectangle* rect);
extern void aktive_point_move     (aktive_point* dst, int dx, int dy);
extern void aktive_point_add      (aktive_point* dst, aktive_point* delta);

extern void aktive_geometry_set       (aktive_geometry* dst, aktive_uint w, aktive_uint h, aktive_uint d);
extern void aktive_geometry_set_rect  (aktive_geometry* dst, aktive_rectangle* rect);
extern void aktive_geometry_copy      (aktive_geometry* dst, aktive_geometry* src);
// reshape (w,h,d)

extern void aktive_rectangle_copy         (aktive_rectangle* dst, aktive_rectangle* src);
extern void aktive_rectangle_set          (aktive_rectangle* dst, int x, int y, aktive_uint w, aktive_uint h);
extern void aktive_rectangle_set_geometry (aktive_rectangle* dst, aktive_geometry* src);
extern void aktive_rectangle_set_location (aktive_rectangle* dst, aktive_point* src);

extern void aktive_rectangle_move         (aktive_rectangle* dst, int dx, int dy);
extern void aktive_rectangle_grow         (aktive_rectangle* dst, int left, int right, int top, int bottom);

extern void aktive_rectangle_union     (aktive_rectangle* dst, aktive_rectangle* a, aktive_rectangle* b);
extern void aktive_rectangle_intersect (aktive_rectangle* dst, aktive_rectangle* a, aktive_rectangle* b);

extern int aktive_rectangle_is_equal  (aktive_rectangle* a, aktive_rectangle* b);
extern int aktive_rectangle_is_subset (aktive_rectangle* a, aktive_rectangle* b);
extern int aktive_rectangle_is_empty  (aktive_rectangle* r);

// Compute intersection of request with domain, and the zones of request outside of the domain.
// The array `v` has to have enough space for 5 results (intersection + at most 4 zones.
// The intersection is always stored in v[0].
extern void aktive_rectangle_outzones  (aktive_rectangle* domain, aktive_rectangle* request,
					aktive_uint* c, aktive_rectangle* v);

/* - - -- --- ----- -------- -------------
 * Runtime API -- Blitter ops for pixels blocks
 */

extern void aktive_blit_clear_all  (aktive_block* block);
extern void aktive_blit_clear      (aktive_block* block, aktive_rectangle* area);
extern void aktive_blit_fill       (aktive_block* block, aktive_rectangle* area, double v);
extern void aktive_blit_fill_bands (aktive_block* block, aktive_rectangle* area,
				    aktive_double_vector* bands);

extern void aktive_blit_copy (aktive_block* dst, aktive_rectangle* dstarea,
			      aktive_block* src, aktive_point*     srcloc);

extern void aktive_blit_copy0 (aktive_block* dst, aktive_rectangle* dstarea,
			       aktive_block* src);

/*
 * - - -- --- ----- -------- -------------
 *
 * debug support -- -------- -------------
 *
 * - - -- --- ----- -------- -------------
 */

extern void __aktive_block_dump (char* prefix, aktive_block* block);
extern void __aktive_rectangle_dump (char* prefix, aktive_rectangle* r);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_RT_H */
