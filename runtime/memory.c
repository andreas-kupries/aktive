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
 *
 * ATTENTION
 *
 *    To know on `free` how much was released the implementation stores the
 *    size of the allocated block in front of that block. While this requires
 *    only `sizeof(size_t)` bytes the code uses 16 bytes to also keep any
 *    alignment requirements the returned buffer may have.
 *
 *
 *  FUTURE - Track more statistics ?
 *
 *    High-water mark
 *    Allocation count / Free count
 */

#include <tcl.h>

/*
 * - - -- --- ----- -------- -------------
 *
 * All access is serialized through the `serial` mutex.
 * Only the core operations modifying/querying the counter are protected.
 * The alloc/free themselves are not.
 * It is assumed that the underlying allocator is thread-safe.
 *
 * NOTE: Waiting with using a (complex) distributed counter until actual perf
 *       issues make it necessary.
 */

static size_t amount = 0;
TCL_DECLARE_MUTEX(serial);

/*
 * - - -- --- ----- -------- -------------
 */

extern size_t
aktive_tracked_size  (void)
{
    Tcl_MutexLock (&serial);
    size_t n = amount;
    Tcl_MutexUnlock (&serial);

    return n;
}

extern void*
aktive_tracked_alloc (size_t sz)
{
    // overallocate to have space to store the size of the tracked block.
    sz += 16;
    void* mem = ckalloc (sz);

    // stuff the size in, and return the actual block after
    *((size_t *) mem) = sz;
    mem = (void *) ((char *) mem + 16);

    // only the tracking requires serialization
    Tcl_MutexLock (&serial);
    amount += sz;
    Tcl_MutexUnlock (&serial);

    return mem;
}

extern void
aktive_tracked_free (void* mem)
{
    // undo the actions of alloc, and retrieve the block size.
    mem       = (void *) ((char *) mem - 16);
    size_t sz = *((size_t *) mem);

    ckfree (mem);

    // only the tracking requires serialization
    Tcl_MutexLock (&serial);
    amount -= sz;
    Tcl_MutexUnlock (&serial);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
