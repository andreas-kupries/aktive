/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Geometry API -- Types
 */
#ifndef AKTIVE_GEOMETRY_H
#define AKTIVE_GEOMETRY_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 * -- Points	 :: 2D location
 * -- Rectangles :: 2D area   (location + dimensions)
 * -- Geometries :: 3D volume (dimensions)
 */

typedef struct aktive_point {
    int x ; // X coordinate, increasing to the right 
    int y ; // Y coordinate, increasing downward     
} aktive_point;

typedef struct aktive_rectangle {
    int         x      ; // X coordinate, increasing to the right 
    int         y      ; // Y coordinate, increasing downward     
    aktive_uint width  ; // Number of columns 
    aktive_uint height ; // Number of rows    
} aktive_rectangle;

typedef struct aktive_geometry {
    aktive_uint width  ; // Number of image columns 
    aktive_uint height ; // Number of image rows    
    aktive_uint depth  ; // Number of image bands   
} aktive_geometry;

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_point_obj (aktive_point* p);

extern void aktive_point_set      (aktive_point* dst, int x,  int y);
extern void aktive_point_set_rect (aktive_point* dst, aktive_rectangle* rect);
extern void aktive_point_move     (aktive_point* dst, int dx, int dy);
extern void aktive_point_add      (aktive_point* dst, aktive_point* delta);

/*
 * - - -- --- ----- -------- -------------
 */

extern void aktive_geometry_set       (aktive_geometry* dst, aktive_uint w, aktive_uint h, aktive_uint d);
extern void aktive_geometry_set_rect  (aktive_geometry* dst, aktive_rectangle* rect);
extern void aktive_geometry_copy      (aktive_geometry* dst, aktive_geometry* src);
// reshape (w,h,d)

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
#endif /* AKTIVE_GEOMETRY_H */
