/* -*- c -*-
 */
#ifndef AKTIVE_RT_H
#define AKTIVE_RT_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <rectangle.h>
#include <block.h>
#include <region.h>
#include <image.h>
#include <rtgen/vector-funcs.h>
#include <rtgen/type-funcs.h>

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_uint_obj (aktive_uint x);

extern void aktive_error_set (Tcl_Interp* interp);

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
#endif /* AKTIVE_RT_H */
