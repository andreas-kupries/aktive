/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Pixel blocks, types and methods
 */
#ifndef AKTIVE_IMAGE_H
#define AKTIVE_IMAGE_H

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
 */

typedef void  (*aktive_image_final)    ( void* state );
typedef void* (*aktive_image_setup)    ( void*                   param // Image parameters 
                                       , aktive_image_vector_ptr srcs  // Input images     
                                       );
typedef void  (*aktive_image_geometry) ( void*                     param // Image parameters 
                                       , aktive_image_vector_ptr   srcs  // Input images     
                                       , void*                     state // Image state      
                                       , /* => */ aktive_point*    loc   // out: Location    
                                       , /* => */ aktive_geometry* geo   // out: Dimensions  
                                       );

typedef struct aktive_image_type {
    char*                   name         ; // Identification                    

    aktive_uint             sz_param     ; // Size of parameter block [bytes]   
    aktive_uint             n_param      ; // Number of parameters in the block 
    aktive_image_parameter* param        ; // Parameter descriptions            
    aktive_param_init       param_init   ; // Parameter initialization hook     
    aktive_param_finish     param_finish ; // Parameter finishing hook          

    aktive_image_setup      setup        ; // Create  custom image state        
    aktive_image_final      final        ; // Release custom image state        

    aktive_image_geometry   geo_setup    ; // Initialize location and geometry  

    aktive_region_setup     region_setup ; // Create  custom region state       
    aktive_region_final     region_final ; // Release custom region state       
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

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_IMAGE_H */
