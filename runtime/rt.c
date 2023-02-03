/* -*- c -*-
 */

#include <stdio.h>
#include <string.h>

#include <tcl.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <rt.h>
#include <internals.h>

#include <rtgen/vector-funcs.c>
#include <rtgen/type-funcs.c>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

/*
 * - - -- --- ----- -------- -------------
 * Error management
 */

extern void
aktive_error_set (Tcl_Interp* interp) {
    // TODO: store collected errors into interpreter
}

/*
 * - - -- --- ----- -------- -------------
 * Type support
 */

extern Tcl_Obj*
aktive_new_uint_obj (aktive_uint x) {
    Tcl_WideInt w = x;
    return Tcl_NewWideIntObj (w);
}

/*
 * - - -- --- ----- -------- -------------
 * Geometry operations
 */

extern Tcl_Obj*
aktive_new_point_obj(aktive_point* p) {
    Tcl_Obj* el[2];

    el[0] = Tcl_NewIntObj (p->x);
    el[1] = Tcl_NewIntObj (p->y);

    return Tcl_NewListObj (2, el);
}

extern void
aktive_point_set (aktive_point* dst, int x, int y)
{
    TRACE_FUNC("((dst*) %p = %d, %d)", dst, x, y);

    dst->x = x;
    dst->y = y;

    TRACE_RETURN_VOID;
}

extern void
aktive_point_set_rect (aktive_point* dst, aktive_rectangle* rect)
{
    TRACE_FUNC("((dst*) %p = (rect*) %p %d %d)", dst, rect, rect->x, rect->y);

    dst->x = rect->x;
    dst->y = rect->y;

    TRACE_RETURN_VOID;
}

extern void
aktive_point_move (aktive_point* dst, int dx, int dy)
{
    TRACE_FUNC("((dst*) %p += %d, %d)", dst, dx, dy);

    dst->x += dx;
    dst->y += dy;

    TRACE_RETURN_VOID;
}

extern void
aktive_point_add (aktive_point* dst, aktive_point* delta)
{
    TRACE_FUNC("((dst*) %p += (point*) %p %d %d)", dst, delta, delta->x, delta->y);

    dst->x += delta->x;
    dst->y += delta->y;

    TRACE_RETURN_VOID;
}

extern void
aktive_geometry_set (aktive_geometry* dst, aktive_uint w, aktive_uint h, aktive_uint d)
{
    TRACE_FUNC("((dst*) %p = %u %u %u)", dst, w, h, d);

    dst->width  = w;
    dst->height = h;
    dst->depth  = d;

    TRACE_RETURN_VOID;
}

extern void
aktive_geometry_set_rect (aktive_geometry* dst, aktive_rectangle* rect)
{
    TRACE_FUNC("((dst*) %p = (rect*) %p %u %u)", dst, rect, rect->width, rect->height);

    dst->width  = rect->width;
    dst->height = rect->height;

    TRACE_RETURN_VOID;
}

extern void
aktive_geometry_copy (aktive_geometry* dst, aktive_geometry* src)
{
    TRACE_FUNC("((dst*) %p = (src*) %p)", dst, src);
    
    *dst = *src;

    TRACE_RETURN_VOID;
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
