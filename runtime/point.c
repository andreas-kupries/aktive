/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * -- Point methods
 */

#include <tclpre9compat.h>
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

    el[0] = Tcl_NewIntObj (p->x); /* OK tcl9 */
    el[1] = Tcl_NewIntObj (p->y); /* OK tcl9 */

    return Tcl_NewListObj (2, el); /* OK tcl9 */
}

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_point_is_equal (aktive_point* a, aktive_point* b)
{
    TRACE_FUNC("((point*) %p == (point*) %p)", a, b);

    int is_equal =
	(a->x == b->x) &&
	(a->y == b->y)
	;

    TRACE_RETURN("(bool) %d", is_equal);
}

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

extern Tcl_Obj*
aktive_new_fpoint_obj(aktive_fpoint* p) {
    Tcl_Obj* el[2];

    el[0] = Tcl_NewDoubleObj (p->x);
    el[1] = Tcl_NewDoubleObj (p->y);

    return Tcl_NewListObj (2, el); /* OK tcl9 */
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
