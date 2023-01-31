/* -*- c -*-
 */
#ifndef AKTIVE_TYPES_H
#define AKTIVE_TYPES_H

/* - - -- --- ----- -------- -------------
 * Unsigned integers
 */

typedef unsigned int aktive_uint;

/* - - -- --- ----- -------- -------------
 * 2D points for addressing arbitrary pixels in the infinite 2D plane
 */

typedef struct aktive_point {
  int x ; /* X coordinate, increasing to the right */
  int y ; /* Y coordinate, increasing downward     */
} aktive_point;

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

/* - - -- --- ----- -------- -------------
 * Public types for image operator specifications
 * - Generic information about the operator's parameter block
 *   - Size
 *   - Initialization from copied incoming block
 *   - Finalization of block
 *   - Array of parameter descriptions (names, descriptions, offsets, types)
 * - Hook to compute pixel data for an image region.
 */

typedef void     (*aktive_image_region_fill)  (aktive_region region);
typedef void     (*aktive_image_param_init)   (void* param);
typedef void     (*aktive_image_param_finish) (void* param);
typedef Tcl_Obj* (*aktive_param_value)        (Tcl_Interp* interp, void* value);

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
  char*                      name     ; /* Identification                    */
  aktive_uint                sz_param ; /* Size of parameter block [bytes]   */
  aktive_uint                n_param  ; /* Number of parameters in the block */
  aktive_image_parameter*    param    ; /* Parameter descriptions            */
  aktive_image_param_init    init     ; /* Parameter initialization hook     */
  aktive_image_param_finish  finish   ; /* Parameter finishing hook          */
  aktive_image_region_fill   fill     ; /* Region fill hook                  */
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
