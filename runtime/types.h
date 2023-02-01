/* -*- c -*-
 */
#ifndef AKTIVE_TYPES_H
#define AKTIVE_TYPES_H

/* - - -- --- ----- -------- -------------
 * Unsigned integers
 */

typedef unsigned int aktive_uint;

/* - - -- --- ----- -------- -------------
 * 2D points for addressing arbitrary pixels in the ((not really) infinite) 2D plane
 */

typedef struct aktive_point {
    int x ; /* X coordinate, increasing to the right */
    int y ; /* Y coordinate, increasing downward     */
} aktive_point;

/* - - -- --- ----- -------- -------------
 * 2D area in the plane, location and dimensions
 */

typedef struct aktive_rectangle {
    int         x      ; /* X coordinate, increasing to the right */
    int         y      ; /* Y coordinate, increasing downward     */
    aktive_uint width  ; /* Number of rectangle columns */
    aktive_uint height ; /* Number of rectangle rows    */
} aktive_rectangle;

/* - - -- --- ----- -------- -------------
 * 3D geometry (width x height x depth = columns, rows, and bands)
 */

typedef struct aktive_geometry {
    aktive_uint width  ; /* Number of image columns */
    aktive_uint height ; /* Number of image rows    */
    aktive_uint depth  ; /* Number of image bands   */
} aktive_geometry;

/* - - -- --- ----- -------- -------------
 * Opaque types for images and rectangular image regions.
 */

typedef struct aktive_image  *aktive_image;
typedef struct aktive_region *aktive_region;

/* Forward declaration for pointers to image and region vectors. The actual
 * structures are defined through the dynamically generated part of the runtime.
 */
typedef struct aktive_image_vector  *aktive_image_vector_ptr;
typedef struct aktive_region_vector *aktive_region_vector_ptr;

/* - - -- --- ----- -------- -------------
 * Open type for a pixel block, i.e. rectangular area from an image, with a
 * contiguous memory block holding the actual pixel data of that area.
 */

typedef struct aktive_block {
    aktive_rectangle  rect     ; /* Image area. Dimensions + depth below inform `pixel` layout */
    aktive_uint       depth    ; /* Number of bands in the pixel data                          */
    aktive_region     region   ; /* Region owning and managing the block.                      */
    double*           pixel    ; /* Pixel data in row-major order (row, column, band)          */
    aktive_uint       capacity ; /* Allocated size of the pixel data. in elements              */
    aktive_uint       used     ; /* Used part (width * height * depth)                         */
} aktive_block;

/* - - -- --- ----- -------- -------------
 * Public types for image operator specifications
 * - Generic information about the operator's parameter block
 *   - Size
 *   - Initialization from copied incoming block
 *   - Finalization of block
 *   - Array of parameter descriptions (names, descriptions, offsets, types)
 * - Compute pixel data for an image region.
 * - Create/release custom image  state, from parameters and inputs.
 * - Create geometry and location,       s.a
 */

typedef void     (*aktive_param_init)   (void* param);
typedef void     (*aktive_param_finish) (void* param);
typedef Tcl_Obj* (*aktive_param_value)  (Tcl_Interp* interp, void* value);

typedef void*    (*aktive_image_setup)    (void* param, aktive_image_vector_ptr srcs);
typedef void     (*aktive_image_final)    (void* state);
typedef void     (*aktive_image_geometry) (void* param, aktive_image_vector_ptr srcs, void* state,
					   /* => */ aktive_point* loc, aktive_geometry* geo);

typedef void*    (*aktive_region_setup) (void* param, aktive_region_vector_ptr srcs, void* imagestate);
typedef void     (*aktive_region_final) (void* state);
typedef void     (*aktive_region_fetch) (void* param, aktive_region_vector_ptr srcs, void* state,
					 /* => */ aktive_block* block);

typedef struct aktive_type_spec {
    aktive_param_value to_obj ; /**/
} aktive_type_spec;

typedef struct aktive_image_parameter {
    aktive_uint name   ; /* Index into `aktive_param_name` */
    aktive_uint desc   ; /* Index into `aktive_param_desc` */
    aktive_uint type   ; /* Index into `aktive_type_descriptor` */
    aktive_uint offset ; /* Offset of field in the parameter structure */
} aktive_image_parameter;

typedef struct aktive_image_type {
    char*                   name         ; /* Identification                    */

    aktive_uint             sz_param     ; /* Size of parameter block [bytes]   */
    aktive_uint             n_param      ; /* Number of parameters in the block */
    aktive_image_parameter* param        ; /* Parameter descriptions            */
    aktive_param_init       param_init   ; /* Parameter initialization hook     */
    aktive_param_finish     param_finish ; /* Parameter finishing hook          */

    aktive_image_setup      setup        ; /* Create  custom image state        */
    aktive_image_final      final        ; /* Release custom image state        */

    aktive_image_geometry   geo_setup    ; /* Initialize location and geometry  */

    aktive_region_setup     region_setup ; /* Create  custom region state       */
    aktive_region_final     region_final ; /* Release custom region state       */
    aktive_region_fetch     region_fetch ; /* Get pixels for area of the region */
} aktive_image_type;

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_TYPES_H */
