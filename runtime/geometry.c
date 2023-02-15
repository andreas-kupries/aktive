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

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
