/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Geometry API -- Types and methods
 */
#ifndef AKTIVE_GEOMETRY_H
#define AKTIVE_GEOMETRY_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <tclpre9compat.h>
#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 */

#define TRACE_POINT(p)     TRACE (#p " @(%d,%d)",                  (p)->x, (p)->y)
#define TRACE_RECTANGLE(r) TRACE (#r " @(%d..%d,%d..%d %ux%u)",    (r)->x, (r)->x+(r)->width-1, (r)->y, (r)->y+(r)->height-1, (r)->width, (r)->height)
#define TRACE_GEOMETRY(g)  TRACE (#g " @(%d..%d,%d..%d %ux%ux%u)", (g)->x, (g)->x+(g)->width-1, (g)->y, (g)->y+(g)->height-1, (g)->width, (g)->height, (g)->depth)

#define TRACE_POINT_M(m,p)     TRACE (m " @(%d,%d)",                  (p)->x, (p)->y)
#define TRACE_RECTANGLE_M(m,r) TRACE (m " @(%d..%d,%d..%d %ux%u)",    (r)->x, (r)->x+(r)->width-1, (r)->y, (r)->y+(r)->height-1, (r)->width, (r)->height)
#define TRACE_GEOMETRY_M(m,g)  TRACE (m " @(%d..%d,%d..%d %ux%ux%u)", (g)->x, (g)->x+(g)->width-1, (g)->y, (g)->y+(g)->height-1, (g)->width, (g)->height, (g)->depth)

/*
 * - - -- --- ----- -------- -------------
 * -- Points	 :: 2D location
 * -- Rectangles :: 2D area   (location + dimensions)
 * -- Geometries :: 3D volume (dimensions)
 * -- Ranges     :: Degenerated Rectangle (Height 1) + Pixel value
 *
 * NOTE
 *
 *  - How `aktive_point`     is a proper prefix of `aktive_rectangle`, and
 *  - How `aktive_rectangle` is a proper prefix of `aktive_geometry`
 *
 *  - Looking into `block.h`, see that aktive_geometry is a proper prefix of
 *    `aktive_block too.
 */

A_STRUCTURE (aktive_point) {
    A_FIELD (int, x) ; // X coordinate, increasing to the right
    A_FIELD (int, y) ; // Y coordinate, increasing downward
} A_END (aktive_point);

A_STRUCTURE (aktive_rectangle) {
    A_FIELD (int,         x)      ; // X coordinate, increasing to the right
    A_FIELD (int,         y)      ; // Y coordinate, increasing downward
    A_FIELD (aktive_uint, width)  ; // Number of columns
    A_FIELD (aktive_uint, height) ; // Number of rows
} A_END (aktive_rectangle);

A_STRUCTURE (aktive_geometry) {
    A_FIELD (int,         x)      ; // X coordinate, increasing to the right
    A_FIELD (int,         y)      ; // Y coordinate, increasing downward
    A_FIELD (aktive_uint, width)  ; // Number of image columns
    A_FIELD (aktive_uint, height) ; // Number of image rows
    A_FIELD (aktive_uint, depth)  ; // Number of image bands
} A_END (aktive_geometry);

A_STRUCTURE (aktive_range) {
    A_FIELD (int,         xmin)   ; // X coordinate, start of range
    A_FIELD (int,         xmax)   ; // X coordinate, end of range
    A_FIELD (int,         y)      ; // Y coordinate
    A_FIELD (double,      value)  ; // Pixel value
} A_END (aktive_range);

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_range_obj (aktive_range* p);

#define aktive_range_set(dst,xa,xb,yv,pval) \
    { (dst)->xmin = (xa) ; (dst)->xmax = (xb) ; (dst)->y = (yv) ; (dst)->value = (pval) ; }

extern void aktive_range_union (aktive_rectangle* dst, aktive_uint c, aktive_range* v);
extern void aktive_range_sort  (aktive_uint c, aktive_range* v);

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_point_obj (aktive_point* p);

#define aktive_point_def(varname,xv,yv) \
    aktive_point varname = { .x = (xv), .y = (yv) }

#define aktive_point_def_as(varname,src) \
    aktive_point_def(varname, (src)->x, (src)->y)

/*
 * - - -- --- ----- -------- -------------
 * extern void aktive_point_set           (aktive_point* dst, int x,  int y);
 * extern void aktive_point_copy          (aktive_point* dst, aktive_point*     src);
 * extern void aktive_point_from_rect     (aktive_point* dst, aktive_rectangle* src);
 * extern void aktive_point_from_geometry (aktive_point* dst, aktive_geometry*  src);
 * extern void aktive_point_move          (aktive_point* dst, int dx, int dy);
 * extern void aktive_point_add           (aktive_point* dst, aktive_point* delta);
 * extern void aktive_point_sub           (aktive_point* dst, aktive_point* delta);
 */

#define aktive_point_set(dst,xv,yv)         { (dst)->x = (xv) ; (dst)->y = (yv); }
#define aktive_point_copy(dst,src)          aktive_point_set (dst, (src)->x, (src)->y)
#define aktive_point_from_rect(dst,src)     aktive_point_copy (dst, src)
#define aktive_point_from_geometry(dst,src) aktive_point_copy (dst, src)
#define aktive_point_move(dst,dx,dy)        { (dst)->x += (dx) ; (dst)->y += (dy) ; }
#define aktive_point_add(dst,delta)         aktive_point_move(dst, (delta)->x, (delta)->y)
#define aktive_point_sub(dst,delta)         aktive_point_move(dst, - (delta)->x, - (delta)->y)
#define aktive_point_neg(dst)               { (dst)->x = - (dst)->x ; (dst)->y = - (dst)->y ; }
#define aktive_point_conj(dst)              { (dst)->y = - (dst)->y ; }

extern void aktive_point_union    (aktive_rectangle* dst, aktive_uint c, aktive_point* v);
extern int  aktive_point_is_equal (aktive_point* a, aktive_point* b);

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_rectangle_obj (aktive_rectangle* r);

#define aktive_rectangle_def(varname,xv,yv,wv,hv) \
    aktive_rectangle varname = { .x = (xv), .y = (yv), .width = (wv), .height = (hv) }

#define aktive_rectangle_def_as(varname,src) \
    aktive_rectangle_def(varname, (src)->x, (src)->y, (src)->width, (src)->height)

/*
 * - - -- --- ----- -------- -------------
 * extern void aktive_rectangle_set           (aktive_rectangle* dst, int x, int y, aktive_uint w, aktive_uint h);
 * extern void aktive_rectangle_copy          (aktive_rectangle* dst, aktive_rectangle* src);
 * extern void aktive_rectangle_set_point     (aktive_rectangle* dst, aktive_point*     src);
 * extern void aktive_rectangle_from_geometry (aktive_rectangle* dst, aktive_geometry*  src);
 * extern int  aktive_rectangle_get_x         (aktive_rectangle* src);
 * extern int  aktive_rectangle_get_xmax      (aktive_rectangle* src);
 * extern int  aktive_rectangle_get_y         (aktive_rectangle* src);
 * extern int  aktive_rectangle_get_ymax      (aktive_rectangle* src);
 */

#define aktive_rectangle_sub(dst,delta) aktive_rectangle_move(dst, - (delta)->x, - (delta)->y)

extern void aktive_rectangle_move         (aktive_rectangle* dst, int dx, int dy);
extern void aktive_rectangle_add          (aktive_rectangle* dst, aktive_point* delta);
extern void aktive_rectangle_grow         (aktive_rectangle* dst, int left, int right, int top, int bottom);

#define aktive_rectangle_set(dst, xv, yv, wv, hv) { (dst)->x = (xv) ; (dst)->y = (yv) ; (dst)->width = (wv) ; (dst)->height = (hv) ; }
#define aktive_rectangle_copy(dst, src)           aktive_rectangle_set  (dst, (src)->x, (src)->y, (src)->width, (src)->height)
#define aktive_rectangle_set_point(dst, src)      aktive_point_copy     (dst, src)
#define aktive_rectangle_from_geometry(dst, src)  aktive_rectangle_copy (dst, src)
#define aktive_rectangle_get_x(src)               ((src)->x)
#define aktive_rectangle_get_xmax(src)            ((src)->x + (src)->width - 1)
#define aktive_rectangle_get_y(src)               ((src)->y)
#define aktive_rectangle_get_ymax(src)            ((src)->y + (src)->height - 1)

#define aktive_rectangle_as_point(src)     ((aktive_point*) (src))

extern int aktive_rectangle_is_equal  (aktive_rectangle* a, aktive_rectangle* b);
extern int aktive_rectangle_is_dim_eq (aktive_rectangle* a, aktive_rectangle* b);
extern int aktive_rectangle_is_subset (aktive_rectangle* a, aktive_rectangle* b);
extern int aktive_rectangle_is_empty  (aktive_rectangle* r);
extern int aktive_rectangle_contains  (aktive_rectangle* r, aktive_point* p);

/* Both `union` and `intersection operations allow one of the input rectangles
 * to be used as `dst` without issue, due to modifying the destination only
 * after the result is fully calculated and no data from the input is required
 * anymore.
 */
extern void aktive_rectangle_union     (aktive_rectangle* dst, aktive_rectangle* a, aktive_rectangle* b);
extern void aktive_rectangle_intersect (aktive_rectangle* dst, aktive_rectangle* a, aktive_rectangle* b);

// Compute intersection of request with domain, and the zones of request outside of the domain.
// The array `v` has to have enough space for 5 results (intersection + at most 4 zones.
// The intersection is always stored in v[0].
extern void aktive_rectangle_outzones  (aktive_rectangle* domain, aktive_rectangle* request,
					aktive_uint* c, aktive_rectangle* v);

/*
 * - - -- --- ----- -------- -------------
 *
 * debug support -- -------- -------------
 *
 * - - -- --- ----- -------- -------------
 */

extern void __aktive_rectangle_dump (char* prefix, aktive_rectangle* r);

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_geometry_obj (aktive_geometry* r);

#define aktive_geometry_def(varname,xv,yv,wv,hv,dv) \
    aktive_geometry varname = { .x = (xv), .y = (yv), .width = (wv), .height = (hv), .depth = (dv) }

/*
 * - - -- --- ----- -------- -------------
 * extern void        aktive_geometry_set           (aktive_geometry* dst, int x, int y, aktive_uint w, aktive_uint h, aktive_uint d);
 * extern void        aktive_geometry_copy          (aktive_geometry* dst, aktive_geometry*  src);
 * extern void        aktive_geometry_set_point     (aktive_geometry* dst, aktive_point*     src);
 * extern void        aktive_geometry_set_rectangle (aktive_geometry* dst, aktive_rectangle* src);
 * extern int         aktive_geometry_get_x         (aktive_geometry* src);
 * extern int         aktive_geometry_get_xmax      (aktive_geometry* src);
 * extern int         aktive_geometry_get_y         (aktive_geometry* src);
 * extern int         aktive_geometry_get_ymax      (aktive_geometry* src);
 * extern aktive_uint aktive_geometry_get_width     (aktive_geometry* src);
 * extern aktive_uint aktive_geometry_get_height    (aktive_geometry* src);
 * extern aktive_uint aktive_geometry_get_depth     (aktive_geometry* src);
 * extern aktive_uint aktive_geometry_get_pitch     (aktive_geometry* src);
 * extern aktive_uint aktive_geometry_get_pixels    (aktive_geometry* src);
 * extern aktive_uint aktive_geometry_get_size      (aktive_geometry* src);
 */

#define aktive_geometry_set(dst, xv, yv, wv, hv, dv) { (dst)->x = (xv) ; (dst)->y = (yv) ; (dst)->width = (wv) ; (dst)->height = (hv) ; (dst)->depth = (dv) ; }
#define aktive_geometry_copy(dst, src)               aktive_geometry_set (dst, (src)->x, (src)->y, (src)->width, (src)->height, (src)->depth)
#define aktive_geometry_set_point(dst, src)          aktive_point_copy(dst, src)
#define aktive_geometry_set_rectangle(dst, src)      aktive_rectangle_copy(dst, src)
#define aktive_geometry_get_x(src)                   ((src)->x)
#define aktive_geometry_get_xmax(src)                ((src)->x + (src)->width - 1)
#define aktive_geometry_get_y(src)                   ((src)->y)
#define aktive_geometry_get_ymax(src)                ((src)->y + (src)->height - 1)
#define aktive_geometry_get_width(src)	             ((src)->width)
#define aktive_geometry_get_height(src)	             ((src)->height)
#define aktive_geometry_get_depth(src)	             ((src)->depth)
#define aktive_geometry_get_pitch(src)	             ((src)->width * (src)->depth)
#define aktive_geometry_get_pixels(src)	             ((src)->width * (src)->height)
#define aktive_geometry_get_size(src)	             ((src)->width * (src)->height * (src)->depth)

#define aktive_geometry_get_z(src)        (0)
#define aktive_geometry_get_zmax(src)     ((src)->depth - 1)
#define aktive_geometry_as_point(src)     ((aktive_point*)     (src))
#define aktive_geometry_as_rectangle(src) ((aktive_rectangle*) (src))

/*
 * - - -- --- ----- -------- -------------
 */

#define AKTIVE_SWIVEL(s,a,b) { aktive_uint tmp = (s)->a ; (s)->a = (s)->b ; (s)->b = tmp; }

/*
 * - - -- --- ----- -------- -------------
 * Variants of points and rectangles supporting (f)ractional locations.
 *
 * -- Points	 :: 2D location
 * -- Rectangles :: 2D area   (location + dimensions)
 *
 * NOTE
 *
 *  - How `aktive_fpoint` is a proper prefix of `aktive_frectangle`
 */

A_STRUCTURE (aktive_fpoint) {
    A_FIELD (double, x) ; // X coordinate, increasing to the right
    A_FIELD (double, y) ; // Y coordinate, increasing downward
} A_END (aktive_fpoint);

A_STRUCTURE (aktive_frectangle) {
    A_FIELD (double, x)      ; // X coordinate, increasing to the right
    A_FIELD (double, y)      ; // Y coordinate, increasing downward
    A_FIELD (double, width)  ; // Number of columns
    A_FIELD (double, height) ; // Number of rows
} A_END (aktive_frectangle);

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_fpoint_obj (aktive_fpoint* p);

#define aktive_fpoint_def(varname,xv,yv) \
    aktive_fpoint varname = { .x = (xv), .y = (yv) }

#define aktive_fpoint_def_as(varname,src) \
    aktive_fpoint_def(varname, (src)->x, (src)->y)

#define aktive_fpoint_set(dst,xv,yv)         { (dst)->x = (xv) ; (dst)->y = (yv); }
#define aktive_fpoint_copy(dst,src)          aktive_fpoint_set (dst, (src)->x, (src)->y)
#define aktive_fpoint_from_rect(dst,src)     aktive_fpoint_copy (dst, src)
#define aktive_fpoint_from_geometry(dst,src) aktive_fpoint_copy (dst, src)
#define aktive_fpoint_move(dst,dx,dy)        { (dst)->x += (dx) ; (dst)->y += (dy) ; }
#define aktive_fpoint_add(dst,delta)         aktive_fpoint_move(dst, (delta)->x, (delta)->y)
#define aktive_fpoint_sub(dst,delta)         aktive_fpoint_move(dst, - (delta)->x, - (delta)->y)
#define aktive_fpoint_neg(dst)               { (dst)->x = - (dst)->x ; (dst)->y = - (dst)->y ; }
#define aktive_fpoint_conj(dst)              { (dst)->y = - (dst)->y ; }

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_frectangle_obj (aktive_frectangle* r);

#define aktive_frectangle_def(varname,xv,yv,wv,hv) \
    aktive_frectangle varname = { .x = (xv), .y = (yv), .width = (wv), .height = (hv) }

#define aktive_frectangle_def_as(varname,src) \
    aktive_frectangle_def(varname, (src)->x, (src)->y, (src)->width, (src)->height)

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_GEOMETRY_H */
