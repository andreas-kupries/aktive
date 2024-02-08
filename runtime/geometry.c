/* -*- c -*-
 *
 * - - -- --- ----- -------- -------------
 * -- Geometry methods
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

extern Tcl_Obj*
aktive_new_geometry_obj(aktive_geometry* p) {
    Tcl_Obj* el[5];

    el[0] = Tcl_NewIntObj (p->x);	 /* OK tcl9 */
    el[1] = Tcl_NewIntObj (p->y);	 /* OK tcl9 */
    el[2] = Tcl_NewIntObj (p->width);	 /* OK tcl9 */
    el[3] = Tcl_NewIntObj (p->height);	 /* OK tcl9 */
    el[4] = Tcl_NewIntObj (p->depth);	 /* OK tcl9 */

    return Tcl_NewListObj (5, el); /* OK tcl9 */
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
