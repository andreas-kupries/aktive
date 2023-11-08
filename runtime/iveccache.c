/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Vector cache utility functions, independent vectors.
 *
 *    Management of a local vector cache on top of the global cache.
 *    The global cache handles evictions, in cooperation with this user.
 *
 *    A vector cache stores a fixed number of vectors of doubles, all the
 *    same size, i.e. same number of elements.
 *
 *    Vector was chosen as generic name, applying to both image rows, and columns.
 *
 *    Access to the vectorcache from multiple concurrent threads is safe.
 *
 *    So far this sounds the same as the facilities of `veccache.[ch]`.
 *
 *    The difference is in a low-level assumption.
 *
 *    VecCache assumes that the vectors to cache are stored sequentially in
 *    the input, and that getting the vector at a higher index requires
 *    reading the vectors at the lower indices at least once.
 *
 *    IVecCache here replaces that with the assumption that vectors at any
 *    index can be retrieved independent of each other from the input,
 *    i.e. that the input supports random access at least at vector level.
 */

/*
 * - - -- --- ----- -------- -------------
 */

#include <iveccache.h>
#include <micros.h>
#include <memory.h>
#include <inttypes.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

#define PTR2UINT(p) ((unsigned int)(uintptr_t)(p))
#define UINT2PTR(p) ((void *)(uintptr_t)(p))

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct ivecentry {
    Tcl_Mutex lock;	// sync access to this vector
    double*   area;	// memory block holding the cached vector
} ivecentry;

typedef struct aktive_iveccache_ {
    Tcl_Mutex   lock;		// sync access to entire cache
    aktive_uint nvectors;	// number of managed vectors
    aktive_uint nelems;		// number of elements per vector
    ivecentry   vec[0];		// vector management
} aktive_iveccache_;

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_iveccache
aktive_iveccache_new (aktive_uint nvecs,
		      aktive_uint nelems)
{
    TRACE_FUNC("(vecs %u, of %u)", nvecs, nelems);

    aktive_uint      sz = sizeof(aktive_iveccache_)   + nvecs*sizeof(ivecentry);
    aktive_iveccache vc = TR_ALLOC_PLUS(aktive_iveccache_, nvecs*sizeof(ivecentry));
    memset (vc, 0, sz);

    vc->nvectors = nvecs;
    vc->nelems   = nelems;
    vc->lock     = 0;

    TRACE_RETURN ("iveccache %p", vc);
}

extern void
aktive_iveccache_release (aktive_iveccache cache)
{
    TRACE_FUNC("(iveccache %p)", cache);

    aktive_uint k;
    for (k=0; k < cache->nvectors; k++) {
	if (!cache->vec[k].area) continue;
	TR_FREE (cache->vec[k].area);
    }

    TR_FREE (cache);

    TRACE_RETURN_VOID;
}

extern double*
aktive_iveccache_get (aktive_iveccache      cache,
		      aktive_uint           index,
		      aktive_iveccache_fill filler,
		      void*                 context)
{
    TRACE_FUNC("(iveccache %p, index %u, fill %p, ctx %p)", cache, index, filler, context);
    ASSERT (index < cache->nvectors, "out of bounds vector request");

    // The cached vectors are, once created, immutable. They are not freed
    // during execution either, only when the image itself is destroyed.
    //
    // This means that once the condition `area != NULL` holds access does not
    // require locking anymore.
    //
    // Locking is only required for `area == NULL`, to ensure that the vector
    // is created by a single thread, once. Note however that the condition
    // `area == NULL` has to be re-checked after entering, as some other
    // thread may have raced us through the critical section while we passed
    // through [x].

    if (!cache->vec[index].area) {
	// vector possibly not defined.
	// [x]

	TRACE_RUN (aktive_uint start = aktive_now());
	Tcl_MutexLock (&cache->vec[index].lock);
	TRACE_RUN (aktive_uint entrywait = aktive_now() - start);
	TRACE("micro index %u wait on entry %u", index, entrywait);

	if (!cache->vec[index].area) {
	    // vector definitely not defined (no other thread created it

	    double* area = TR_NALLOC (double, cache->nelems);
	    filler (context, index, area);
	    cache->vec[index].area = area;
	}

	Tcl_MutexUnlock (&cache->vec[index].lock);	// aquired in `take`
	TRACE_RUN(aktive_uint section = aktive_now() - start);
	TRACE("micro index %u in section %u", index, section);
    }

    TRACE_RETURN("double[] %p", cache->vec[index].area);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
