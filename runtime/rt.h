/* -*- c -*-
 */
#ifndef AKTIVE_RT_H
#define AKTIVE_RT_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <geometry.h>
#include <blit.h>
#include <region.h>
#include <image.h>
#include <rtgen/vector-funcs.h>
#include <rtgen/type-funcs.h>

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_uint_obj (aktive_uint x);

/*
 * - - -- --- ----- -------- -------------
 */

#define __afdone                 TRACE_RETURN ("(fail) %d", 0)
#define aktive_fail(message)     { aktive_error_add  (message); __afdone; }
#define aktive_failf(format,...) { aktive_error_addf (format, __VA_ARGS__); __afdone; }

extern void aktive_error_set (Tcl_Interp* interp);
extern void aktive_error_add (const char* message);
extern void aktive_error_addf (const char* format, ...);

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
