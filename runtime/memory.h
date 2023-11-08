/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Memory utility functions.
 *
 *    Tracking of memory allocations to guide evictions of a cache.
 *
 *    Provides alloc/free functions which track the allocated amount.
 *    The functions are wrapers around the system functions.
 *    Usage from multiple concurrent threads is safe.
 *
 *    BEWARE: Any memory block allocated through the function here has to be
 *            released through the function here too, and vice versa. Not
 *            doing so will break tracking, either over- or underestimating
 *            the allocated amount.
 */
#ifndef AKTIVE_MEMORY_H
#define AKTIVE_MEMORY_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <tcl.h>

/*
 * - - -- --- ----- -------- -------------
 * - Query size of tracked allocated memory
 * - Allocate with tracking
 * - release with tracking
 */

extern size_t aktive_tracked_size  (void);
extern void*  aktive_tracked_alloc (size_t sz);
extern void   aktive_tracked_free  (void* mem);

/*
 * Helper macros for easy allocation of structures and arrays. These are
 * copied from `critcl-cutil`: critcl_alloc.h and modified to use the tracking
 * functions.
 */

#define TR_ALLOC(type)        (type *) aktive_tracked_alloc (sizeof (type))
#define TR_ALLOC_PLUS(type,n) (type *) aktive_tracked_alloc (sizeof (type) + (n))
#define TR_NALLOC(type,n)     (type *) aktive_tracked_alloc (sizeof (type) * (n))

#define TR_FREE(p) aktive_tracked_free ((void*)(p))

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_MEMORY_H */
