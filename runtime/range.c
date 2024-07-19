/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * -- Range methods
 */

#include <tclpre9compat.h>
#include <stdlib.h>
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
aktive_new_range_obj(aktive_range* p) {
    Tcl_Obj* el[4];

    el[0] = Tcl_NewIntObj    (p->y);     /* OK tcl9 */
    el[1] = Tcl_NewIntObj    (p->xmin);  /* OK tcl9 */
    el[2] = Tcl_NewIntObj    (p->xmax);  /* OK tcl9 */
    el[3] = Tcl_NewDoubleObj (p->value);

    return Tcl_NewListObj (4, el); /* OK tcl9 */
}

static int range_compare (const void* a, const void* b)
{
    const aktive_range* ar = a;
    const aktive_range* br = b;
    if (ar->y    < br->y)    { return -1; }
    if (ar->y    > br->y)    { return  1; }
    if (ar->xmin < br->xmin) { return -1; }
    if (ar->xmin > br->xmin) { return  1; }
    return 0;
}

extern void
aktive_range_sort (aktive_uint c, aktive_range* v)
{
    qsort (v, c, sizeof(aktive_range), range_compare);
}

extern void
aktive_range_union (aktive_rectangle* dst, aktive_uint c, aktive_range* v)
{
    if (c == 0) {
	aktive_rectangle_set (dst, 0, 0, 0, 0);
	return;
    } else if (c == 1) {
	aktive_rectangle_set (dst, v[0].xmin, v[0].y, v[0].xmax-v[0].xmin+1, 1);
	return;
    }

    int xmin, xmax, ymin, ymax;

    xmin = v[0].xmin;
    xmax = v[0].xmax;
    ymin = v[0].y;
    ymax = v[0].y;

    for (aktive_uint i = 1; i < c; i++) {
	xmin = MIN (xmin, v[i].xmin);
	xmax = MAX (xmax, v[i].xmax);
	ymin = MIN (ymin, v[i].y);
	ymax = MAX (ymax, v[i].y);
    }

    aktive_rectangle_set (dst, xmin, ymin, xmax - xmin + 1, ymax - ymin + 1);
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
