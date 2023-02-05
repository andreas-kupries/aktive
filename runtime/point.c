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

#define MIN(a,b) (((a) < (b)) ? (a) : (b))
#define MAX(a,b) (((a) > (b)) ? (a) : (b))

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

extern void
aktive_point_union (aktive_rectangle* dst, aktive_uint c, aktive_point* v)
{
    if (c == 0) {
	aktive_rectangle_set (dst, 0, 0, 0, 0);
	return;
    } else if (c == 1) {
	aktive_rectangle_set (dst, v[0].x, v[0].y, 1, 1);
	return;
    }
    
    int x, xmax, y, ymax;

    x = xmax = v[0].x;
    y = ymax = v[0].y;

    for (aktive_uint i = 1; i < c; i++) {
	x    = MIN (x,    v[i].x);	
	xmax = MAX (xmax, v[i].x);	
	y    = MIN (y,    v[i].y);	
	ymax = MAX (ymax, v[i].y);	
    }
    
    aktive_rectangle_set (dst, x, y, xmax - x + 1, ymax - y + 1);
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
