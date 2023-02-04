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
 */

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
