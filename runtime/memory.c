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
#include <critcl_trace.h>

TRACE_OFF;

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
    void* memo = (void *) ((char *) mem + 16);

    // only the tracking requires serialization
    Tcl_MutexLock (&serial);
    amount += sz;
    Tcl_MutexUnlock (&serial);

    TRACE_FUNC("(sz %u) -> %u (%p)", sz-16, amount, mem);
    TRACE_RETURN ("(%p)", memo);
}

extern void
aktive_tracked_free (void* mem)
{
    // undo the actions of alloc, and retrieve the block size.
    void* memi = (void *) ((char *) mem - 16);
    size_t sz  = *((size_t *) mem);

    ckfree (memi);

    // only the tracking requires serialization
    Tcl_MutexLock (&serial);
    amount -= sz;
    Tcl_MutexUnlock (&serial);

    TRACE_FUNC("(%p %p sz %u) -> %u", mem, memi, sz-16, amount);
    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void*
aktive_tracked_dalloc (char* file, int line, size_t sz)
{
    // overallocate to have space to store the size of the tracked block.
    sz += 16;
    void* mem = ckalloc (sz);

    // stuff the size in, and return the actual block after
    *((size_t *) mem) = sz;
    void* memo = (void *) ((char *) mem + 16);

    // only the tracking requires serialization
    Tcl_MutexLock (&serial);
    amount += sz;
    Tcl_MutexUnlock (&serial);

    TRACE_FUNC("[%s:%d] (sz %u) -> %u (%p)", file, line, sz-16, amount, mem);
    TRACE_RETURN ("(%p)", memo);
}

extern void
aktive_tracked_dfree (char* file, int line, void* mem)
{
    // undo the actions of alloc, and retrieve the block size.
    void* memi = (void *) ((char *) mem - 16);
    size_t sz  = *((size_t *) mem);

    ckfree (memi);

    // only the tracking requires serialization
    Tcl_MutexLock (&serial);
    amount -= sz;
    Tcl_MutexUnlock (&serial);

    TRACE_FUNC("[%s:%d] (%p %p sz %u) -> %u", file, line, mem, memi, sz-16, amount);
    TRACE_RETURN_VOID;
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
