/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * -- Geometry methods
 */

#include <tcl.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <geometry.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj*
aktive_new_geometry_obj(aktive_geometry* p) {
    Tcl_Obj* el[5];

    el[0] = Tcl_NewIntObj (p->x);
    el[1] = Tcl_NewIntObj (p->y);
    el[2] = Tcl_NewIntObj (p->width);
    el[3] = Tcl_NewIntObj (p->height);
    el[4] = Tcl_NewIntObj (p->depth);

    return Tcl_NewListObj (5, el);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_geometry_set (aktive_geometry* dst, int x, int y, aktive_uint w, aktive_uint h, aktive_uint d)
{
    TRACE_FUNC("((dst*) %p = %d %d : %u %u %u)", dst, x, y, w, h, d);

    dst->x      = x;
    dst->y      = y;
    dst->width  = w;
    dst->height = h;
    dst->depth  = d;

    TRACE_RETURN_VOID;
}

extern void
aktive_geometry_copy (aktive_geometry* dst, aktive_geometry* src)
{
    TRACE_FUNC("((dst*) %p = (src*) %p)", dst, src);
    
    *dst = *src;

    TRACE_RETURN_VOID;
}

extern void
aktive_geometry_set_point (aktive_geometry* dst, aktive_point* src)
{
    aktive_point_copy ((aktive_point*) dst, src);
}

extern void
aktive_geometry_set_rectangle (aktive_geometry* dst, aktive_rectangle* src)
{
    aktive_rectangle_copy ((aktive_rectangle*) dst, src);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_geometry_get_x (aktive_geometry* src)
{
    TRACE_FUNC("((aktive_geometry*) %p)", src);
    TRACE_RETURN ("(x) %d", src->x);
}

extern int
aktive_geometry_get_xmax (aktive_geometry* src)
{
    TRACE_FUNC("((aktive_geometry*) %p)", src);
    TRACE_RETURN ("(xmax) %d", src->x + src->width - 1);
}

extern int
aktive_geometry_get_y (aktive_geometry* src)
{
    TRACE_FUNC("((aktive_geometry*) %p)", src);
    TRACE_RETURN ("(y) %d", src->y);
}

extern int
aktive_geometry_get_ymax (aktive_geometry* src)
{
    TRACE_FUNC("((aktive_geometry*) %p)", src);
    TRACE_RETURN ("(ymax) %d", src->y + src->height -1);
}

extern aktive_uint
aktive_geometry_get_width (aktive_geometry* src)
{
    TRACE_FUNC("((aktive_geometry*) %p)", src);
    TRACE_RETURN ("(width) %u", src->width);
}

extern aktive_uint
aktive_geometry_get_height (aktive_geometry* src)
{
    TRACE_FUNC("((aktive_geometry*) %p)", src);
    TRACE_RETURN ("(height) %u", src->height);
}

extern aktive_uint
aktive_geometry_get_depth (aktive_geometry* src)
{
    TRACE_FUNC("((aktive_geometry*) %p)", src);
    TRACE_RETURN ("(depth) %u", src->depth);
}

extern aktive_uint
aktive_geometry_get_pixels (aktive_geometry* src)
{
    TRACE_FUNC("((aktive_geometry*) %p)", src);

    aktive_uint pixels =
	src->width *
	src->height;

    TRACE_RETURN ("(pixels) %u", pixels);
}

extern aktive_uint
aktive_geometry_get_pitch (aktive_geometry* src)
{
    TRACE_FUNC("((aktive_geometry*) %p)", src);

    aktive_uint pitch =	src->width * src->depth;

    TRACE_RETURN ("(pitch) %u", pitch);
}

extern aktive_uint
aktive_geometry_get_size (aktive_geometry* src)
{
    TRACE_FUNC("((aktive_geometry*) %p)", src);

    aktive_uint size = src->width * src->height * src->depth;

    TRACE_RETURN ("(size) %u", size);
}

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
