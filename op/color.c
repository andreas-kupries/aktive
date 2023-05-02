/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Color utility functions.
 */

#include <color.h>

#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern int
aktive_colorspace (aktive_image src, const char* csname)
{
    Tcl_Obj* m = aktive_image_meta_get (src);
    if (!m)                                           { return 1; }
    if (!aktive_meta_has   (m, "colorspace"))         { return 1; }
    if ( aktive_meta_equal (m, "colorspace", csname)) { return 1; }
    // Match fails if and only if `colorspace` is specified and not equal desired (`csname`).
    return 0;
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
