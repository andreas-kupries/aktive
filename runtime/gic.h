/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- In-memory cache for global image operators.
 *
 * Takes a function to compute the result from the entire input image.  The
 * function is run once, from the first pixel fetcher thread encountering an
 * uninitialized cache. It may internally operate thread for speed, assuming
 * the operation is actually threadable in some way.
 */
#ifndef AKTIVE_GIC_H
#define AKTIVE_GIC_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <tclpre9compat.h>
#include <critcl_trace.h>

#include <base.h>
#include <blit.h>

/*
 * - - -- --- ----- -------- -------------
 * - Structure for a cached in-memory pixel block
 */

typedef struct aktive_gicache {
  aktive_block cache;	       // pixel block, actual cache
  aktive_uint  isfilled;       // flag, indicates fill status
  Tcl_Mutex    fillinprogress; // mutex serializing fill op
} aktive_gicache;

typedef void (*aktive_gicache_filler)(aktive_block* out, void* context);

/*
 * - - -- --- ----- -------- -------------
 * API
 */

extern void aktive_gicache_init        (aktive_gicache* gic);
extern void aktive_gicache_drop        (aktive_gicache* gic);
extern void aktive_gicache_fill        (aktive_gicache* gic, aktive_gicache_filler filler, void* context);
extern void aktive_gicache_mark_filled (aktive_gicache* gic);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_GIC_H */
