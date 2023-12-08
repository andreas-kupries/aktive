/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Vector cache utility functions.
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
 */

/*
 * - - -- --- ----- -------- -------------
 */

#include <veccache.h>
#include <micros.h>
#include <memory.h>
#include <inttypes.h>
#include <critcl_alloc.h>
#include <critcl_trace.h>
#include <critcl_assert.h>

TRACE_OFF;

#define PTR2UINT(p) ((unsigned int)(uintptr_t)(p))
#define UINT2PTR(p) ((void *)(uintptr_t)(p))

/*
 * - - -- --- ----- -------- -------------
 * Cache structures, per vector, and cache itself
 *
 * The cached vectors are, once created, immutable. They are not freed during
 * execution either, only when the image itself is destroyed.
 *
 * This means that once the condition `area != NULL` holds access does not
 * require locking anymore.
 *
 * Locking is only required for `area == NULL`, to ensure that the vector is
 * only created by a single thread, once. Note however that the condition
 * `area == NULL` has to be re-checked after entering, as some other thread
 * may have raced the the first check and entering the section.
 *
 * Similar conditions apply to the `start` field of entries. I.e. when the
 * condition `start > 0` is true, it will be immutable. Further, creation of
 * `area[k]` ensures setting of `start[k+1]`.
 *
 * Note: To make this work the vector table has a sentinel entry at the end
 * giving the last vector `n-1` a place to store the returned offset. No need
 * to have special case code for it.
 */

typedef struct vecentry {
    Tcl_Mutex   lock;	// sync access to this vector
    aktive_uint start;	// start offset of vector in input. `0` indicates `unknown`
    double*     area;	// memory block holding the cached vector
} vecentry;

typedef struct aktive_veccache_ {
    aktive_uint nvectors;	// number of managed vectors
    aktive_uint nelems;		// number of elements per vector
    vecentry    vec[0];		// vector management
} aktive_veccache_;

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_veccache
aktive_veccache_new     (aktive_uint nvecs,
			 aktive_uint nelems,
			 aktive_uint start)
{
    TRACE_FUNC("(vecs %u, elements %u, at %u)", nvecs, nelems, start);

    // (NOTE) Allocating a sentinel entry ensures that there is no special
    // case in `get` when filling in the last row, just space.
    aktive_uint     sz = sizeof(aktive_veccache_) + (nvecs+1)*sizeof(vecentry);
    aktive_veccache vc = TR_ALLOC_PLUS(aktive_veccache_, (nvecs+1)*sizeof(vecentry));
    memset (vc, 0, sz);

    vc->nvectors = nvecs;
    vc->nelems   = nelems;

    vc->vec[0].start = start;	// [x] Sentinel for the recursive down-scan part of `get`

    TRACE_RETURN ("veccache %p", vc);
}

extern void
aktive_veccache_release (aktive_veccache cache)
{
    TRACE_FUNC("(veccache %p)", cache);

    aktive_uint k;
    for (k=0; k < cache->nvectors; k++) {
	if (!cache->vec[k].area) continue;
	TR_FREE (cache->vec[k].area);
    }

    TR_FREE (cache);

    TRACE_RETURN_VOID;
}

extern double*
aktive_veccache_get (aktive_veccache      cache,
		     aktive_uint          index,
		     aktive_veccache_fill filler,
		     void*                context)
{
    TRACE_FUNC("((veccache) %p, (index) %u, (fill) %p, (ctx) %p)", cache, index, filler, context);
    ASSERT (index < cache->nvectors, "out of bounds vector request");

    TRACE ("1. [%u] = (%u, %p)", index, cache->vec[index].start, cache->vec[index].area);
    if (!cache->vec[index].area) {
	// vector possibly not defined.

	while (!cache->vec[index].start) {
	    // previous vector possibly not defined.
	    // if it were it would have set the start offset of this one.
	    // recurse to get the previous vector, and thus our start offset.
	    // See [x] for why this recursion will stop.
	    (void) aktive_veccache_get (cache, index-1, filler, context);
	}
	// looping, as the thread may not immediatey see the updated value for `start`.

	TRACE ("2. [%u] = (%u, %p)", index, cache->vec[index].start, cache->vec[index].area);
	ASSERT_VA (cache->vec[index].start, "recursion failed to provide start offset",
		   "[%d].start = %d", index, cache->vec[index].start);

	// Enter critical section of this vector now, to fill it
	TRACE_RUN (aktive_uint start = aktive_now());
	Tcl_MutexLock (&cache->vec[index].lock);
	TRACE_RUN (aktive_uint entrywait = aktive_now() - start);
	TRACE("micro index %u wait on entry %u", index, entrywait);

	// remember however, another thread may have raced us and created the
	// vector. i.e. recheck the condition.
	TRACE ("3. [%u] = (%u, %p)", index, cache->vec[index].start, cache->vec[index].area);
	if (!cache->vec[index].area) {
	    double*     area  = TR_NALLOC (double, cache->nelems);
	    aktive_uint start = filler (context, cache->vec[index].start, area);

	    cache->vec[index].area    = area;
	    cache->vec[index+1].start = start;

	    TRACE ("(double*) %p next %u", area, start);
	}

	Tcl_MutexUnlock (&cache->vec[index].lock);
	TRACE_RUN(aktive_uint section = aktive_now() - start);
	TRACE("micro index %u in section %u", index, section);
    }

    TRACE_RETURN("(double*) %p", (double*) cache->vec[index].area);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
