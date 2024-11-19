/* -*- c -*-
 */
#ifndef AKTIVE_RT_H
#define AKTIVE_RT_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <geometry.h>
#include <geo_util.h>
#include <blit.h>
#include <interpolate.h>
#include <region.h>
#include <image.h>
#include <writer.h>
#include <reader.h>
#include <sink.h>
#include <kahan.h>
#include <fnv.h>
#include <matrix.h>
#include <nproc.h>
#include <cache.h>
#include <veccache.h>
#include <iveccache.h>
#include <memory.h>
#include <rtgen/vector-funcs.h>
#include <rtgen/type-funcs.h>

/*
 * - - -- --- ----- -------- -------------
 */

extern Tcl_Obj* aktive_new_uint_obj (aktive_uint x);

/*
 * - - -- --- ----- -------- -------------
 * aktive_fail* is the public interface to be used.
 *
 * The `aktive_void_fail* forms are internal and automatically substituted in
 * by the DSL backend where needed.
 */

#define __afdone                 TRACE_RETURN ("(fail) %d", 0)
#define aktive_fail(message)     { aktive_error_add  (message); __afdone; }
#define aktive_failf(format,...) { aktive_error_addf (format, __VA_ARGS__); __afdone; }

extern int  aktive_error_raised (void);
extern void aktive_error_set    (Tcl_Interp* interp);
extern void aktive_error_add    (const char* message);
extern void aktive_error_addf   (const char* format, ...);

/*
 * - - -- --- ----- -------- -------------
 * Internal. Do not use directly. See notes above.
 */

#define __afdone_void                 TRACE_RETURN_VOID
#define aktive_void_fail(message)     { aktive_error_add  (message); __afdone_void; }
#define aktive_void_failf(format,...) { aktive_error_addf (format, __VA_ARGS__); __afdone_void; }

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
