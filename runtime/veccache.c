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
#include <cache.h>
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
 */

typedef struct vecentry {
    aktive_uint        offset;	// start of vector in input. `0` indicates `unknown`
    aktive_cache_area* area;	// memory block holding the cached vector
} vecentry;

typedef struct aktive_veccache_ {
    Tcl_Mutex   lock;		// sync access to entire cache
    aktive_uint nvectors;	// number of managed vectors
    aktive_uint nelems;		// number of elements per vector
    vecentry    vec[0];		// vector management
} aktive_veccache_;

/*
 * - - -- --- ----- -------- -------------
 */

static void trim (aktive_veccache cache, aktive_cache_area* area);

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_veccache
aktive_veccache_new     (aktive_uint nvecs,
			 aktive_uint nelems,
			 aktive_uint start)
{
    TRACE_FUNC("(vecs %u, of %u, at %u)", nvecs, nelems, start);

    // (NOTE) Allocating one more entry than specified to ensure that there is
    // no special case in `take` when filling in the last row, jsut space.
    aktive_uint     sz = sizeof(aktive_veccache_) + (nvecs+1)*sizeof(vecentry);
    aktive_veccache vc = ALLOC_PLUS(aktive_veccache_, (nvecs+1)*sizeof(vecentry));
    memset (vc, 0, sz);

    vc->nvectors = nvecs;
    vc->nelems   = nelems;
    vc->lock     = 0;

    vc->vec[0].offset = start;

    TRACE_RETURN ("veccache %p", vc);
}

extern void
aktive_veccache_release (aktive_veccache cache)
{
    TRACE_FUNC("(veccache %p)", cache);

    aktive_cache_trim (cache, (aktive_cache_trimmer) trim);

    aktive_uint k;
    for (k=0; k < cache->nvectors; k++) {
	if (!cache->vec[k].area) continue;
	aktive_cache_release (cache->vec[k].area);
    }

    TRACE_RETURN_VOID;
}

extern double*
aktive_veccache_take (aktive_veccache      cache,
		      aktive_uint          index,
		      aktive_veccache_fill filler,
		      void*                context)
{
    TRACE_FUNC("(veccache %p, index %u, fill %p, ctx %p)", cache, index, filler, context);
    ASSERT (index < cache->nvectors, "out of bounds vector request");

    Tcl_MutexLock (&cache->lock);	// Released in `aktive_veccache_done`
    aktive_cache_trim (cache, (aktive_cache_trimmer) trim);

    if (!cache->vec[index].area) {
	aktive_cache_area* area;
	aktive_uint k = index;

	while (!cache->vec[k].offset) k--;

	while (k <= index) {
	    area = aktive_cache_new (cache->nelems*sizeof(double), cache, UINT2PTR (k));
	    cache->vec[k].area = area;
	    /* (NOTE) */
	    cache->vec[k+1].offset = filler (context, cache->vec[k].offset, (double*) area->data);
	    if (k == index) break;
	    aktive_cache_enter (area);
	    k++;
	}
    } else {
	aktive_cache_take (cache->vec[index].area);
    }

    TRACE_RETURN("double[] %p", (double*) cache->vec[index].area->data);
}

extern void
aktive_veccache_done (aktive_veccache cache,
		      aktive_uint     index)
{
    TRACE_FUNC("(veccache %p, index %d)", cache, index);

    aktive_cache_enter (cache->vec[index].area);
    aktive_cache_trim  (cache, (aktive_cache_trimmer) trim);

    Tcl_MutexUnlock (&cache->lock);	// Aquired in `aktive_veccache_take`

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

static void
trim (aktive_veccache cache, aktive_cache_area* area)
{
    TRACE_FUNC("(veccache %p, area %p)", cache, area);

    aktive_uint index = PTR2UINT (area->context);
    cache->vec[index].area = NULL;

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
