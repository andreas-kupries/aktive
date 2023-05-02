/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Images, types and methods
 */
#ifndef AKTIVE_IMAGE_H
#define AKTIVE_IMAGE_H

/*
 * - - -- --- ----- -------- -------------
 *
 * -- The info structure provides image callbacks with limited access to the
 *    information managed by the runtime for an image. The runtime maintains
 *    additional information for itself it will not provide access to.
 *
 *    ALL information is READ ONLY.
 */

typedef struct aktive_image_info {
    void*                param  ; // Operation parameters, heap located
    aktive_image_vector  srcs   ; // Input images, if any, heap-located array
    aktive_geometry      domain ; // 2D/3D domain (2D location, 3D dimensions)
    void*                state  ; // Image state, if any, operator dependent
} aktive_image_info;

/*
 * - - -- --- ----- -------- -------------
 */

typedef void     (*aktive_param_init)   (void* param);
typedef void     (*aktive_param_finish) (void* param);
typedef Tcl_Obj* (*aktive_param_value)  (Tcl_Interp* interp, void* value);

typedef struct aktive_image_parameter {
    const char*        name   ; // Index into `aktive_param_name`
    const char*        desc   ; // Index into `aktive_param_desc`
    aktive_param_value to_obj ; // Index into `aktive_type_descriptor`
    aktive_uint        offset ; // Offset of field in the parameter structure
} aktive_image_parameter;

/*
 * - - -- --- ----- -------- -------------
 * Initialization - param and srcs are already initialized - initialize state and geometry
 * Finalization   - other fields are already destroyed     - destroy state fields
 *
 * NOTE: We can perform geometry initialization in the main setup.
 */

typedef int  (*aktive_image_setup) (aktive_image_info* info, Tcl_Obj** meta);
typedef void (*aktive_image_final) (void* state);

typedef struct aktive_image_type {
    char*                   name         ; // Identification

    aktive_uint             sz_param     ; // Size of parameter block [bytes]
    aktive_uint             n_param      ; // Number of parameters in the block
    aktive_image_parameter* param        ; // Parameter descriptions
    aktive_param_init       param_init   ; // Parameter initialization hook
    aktive_param_finish     param_finish ; // Parameter finishing hook

    aktive_image_setup      setup        ; // Create  operator-specific image state
    aktive_image_final      final        ; // Release operator-specific image state

    aktive_region_setup     region_setup ; // Create  operator-specific region state
    aktive_region_final     region_final ; // Release operator-specific region state
    aktive_region_fetch     region_fetch ; // Get pixels for area of the region
} aktive_image_type;

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_image
aktive_image_new ( aktive_image_type*   opspec
		 , void*                param
	         , aktive_image_vector* srcs
		 );

extern int  aktive_image_unused (aktive_image image);
extern void aktive_image_unref  (aktive_image image);
extern void aktive_image_ref    (aktive_image image);

extern aktive_point*     aktive_image_get_location (aktive_image image);
extern aktive_rectangle* aktive_image_get_domain   (aktive_image image);
extern aktive_geometry*  aktive_image_get_geometry (aktive_image image);

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

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj*     aktive_image_meta_get (aktive_image image);
extern aktive_image aktive_image_meta_set (aktive_image image, Tcl_Obj* meta);

/*
 * - - -- --- ----- -------- -------------
 */

extern void aktive_meta_inherit     (Tcl_Obj** meta, aktive_image src);
extern void aktive_meta_set         (Tcl_Obj** meta, const char* key, Tcl_Obj*    value);
extern void aktive_meta_set_string  (Tcl_Obj** meta, const char* key, const char* value);
extern void aktive_meta_set_int     (Tcl_Obj** meta, const char* key, int         value);

extern int aktive_meta_has   (Tcl_Obj* meta, const char* key);
extern int aktive_meta_equal (Tcl_Obj* meta, const char* key, const char* value);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_IMAGE_H */
