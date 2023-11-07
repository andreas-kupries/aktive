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
 */

typedef struct ivecentry {
    Tcl_Mutex          lock;	// sync access to this vector
    aktive_cache_area* area;	// memory block holding the cached vector
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

static void trim      (aktive_iveccache cache);
static void trim_area (aktive_iveccache cache, aktive_cache_area* area);

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_iveccache
aktive_iveccache_new (aktive_uint nvecs,
		      aktive_uint nelems)
{
    TRACE_FUNC("(vecs %u, of %u)", nvecs, nelems);

    aktive_uint      sz = sizeof(aktive_iveccache_)   + nvecs*sizeof(ivecentry);
    aktive_iveccache vc = ALLOC_PLUS(aktive_iveccache_, nvecs*sizeof(ivecentry));
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

    aktive_cache_trim (cache, (aktive_cache_trimmer) trim);

    aktive_uint k;
    for (k=0; k < cache->nvectors; k++) {
	if (!cache->vec[k].area) continue;
	aktive_cache_release (cache->vec[k].area);
    }

    TRACE_RETURN_VOID;
}

extern double*
aktive_iveccache_take (aktive_iveccache      cache,
		       aktive_uint           index,
		       aktive_iveccache_fill filler,
		       void*                 context)
{
    TRACE_FUNC("(iveccache %p, index %u, fill %p, ctx %p)", cache, index, filler, context);
    ASSERT (index < cache->nvectors, "out of bounds vector request");

    trim (cache);

    Tcl_MutexLock (&cache->vec[index].lock);	// released in `done`
    if (!cache->vec[index].area) {
	aktive_cache_area* area = aktive_cache_new (cache->nelems*sizeof(double),
						    cache,
						    UINT2PTR (index));
	filler (context, index, (double*) area->data);
	cache->vec[index].area = area;
    } else {
	aktive_cache_take (cache->vec[index].area);
    }

    TRACE_RETURN("double[] %p", (double*) cache->vec[index].area->data);
}

extern void
aktive_iveccache_done (aktive_iveccache cache,
		       aktive_uint      index)
{
    TRACE_FUNC("(iveccache %p, index %d)", cache, index);

    aktive_cache_enter (cache->vec[index].area);
    Tcl_MutexUnlock (&cache->vec[index].lock);	// aquired in `take`

    trim (cache);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 ** Trim support. During trimming the entire cache is locked
 */

static void
trim (aktive_iveccache cache)
{
    TRACE_FUNC("(iveccache %p)", cache);

    Tcl_MutexLock (&cache->lock);
    aktive_cache_trim  (cache, (aktive_cache_trimmer) trim_area);
    Tcl_MutexUnlock (&cache->lock);

    TRACE_RETURN_VOID;
}

static void
trim_area (aktive_iveccache cache, aktive_cache_area* area)
{
    TRACE_FUNC("(iveccache %p, area %p)", cache, area);

    aktive_uint index = PTR2UINT (area->context);

    // Trimmed vectors are locked, in case other threads still use them.

    Tcl_MutexLock (&cache->vec[index].lock);
    cache->vec[index].area = NULL;
    Tcl_MutexUnlock (&cache->vec[index].lock);

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
