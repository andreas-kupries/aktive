/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * -- Point methods
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
aktive_new_point_obj(aktive_point* p) {
    Tcl_Obj* el[2];

    el[0] = Tcl_NewIntObj (p->x);
    el[1] = Tcl_NewIntObj (p->y);

    return Tcl_NewListObj (2, el);
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_point_set (aktive_point* dst, int x, int y)
{
    TRACE_FUNC("((dst*) %p = %d, %d)", dst, x, y);

    dst->x = x;
    dst->y = y;

    TRACE_RETURN_VOID;
}

extern void
aktive_point_copy (aktive_point* dst, aktive_point* src)
{
    TRACE_FUNC("((dst*) %p = (src*) %p %d %d)", dst, src, src->x, src->y);

    *dst = *src;

    TRACE_RETURN_VOID;
}

extern void
aktive_point_from_rect (aktive_point* dst, aktive_rectangle* src)
{
    aktive_point_copy (dst, (aktive_point*) src);
}

extern void
aktive_point_from_geometry (aktive_point* dst, aktive_geometry* src)
{
    aktive_point_copy (dst, (aktive_point*) src);
}

/*
 * - - -- --- ----- -------- -------------
 */

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
