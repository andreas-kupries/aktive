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
 *
 *    This changes the interface between cache and input somewhat (See filler).
 *
 * EXAMPLE USER
 *
 *      `op column histogram` caches the calculated histograms to avoid
 *      recalculation in the face of row scans.
 *
 * API
 *
 * - new, release
 *
 *   Create and destroy vector caches. The cache has space for "nvecs" vectors
 *   of "nelems" double elements each. This cannot change over the lifetime of
 *   the cache.
 *
 * - get
 *
 *   Get the indexed vector.
 *
 *   Asking for an undefined vector causes the cache to fill the vector from
 *   the input, using the provided "filler" function vector and its "context".
 *   The vector is locked during this specific action.
 *
 *   Once the vector is defined no locking is performed any more. The data is
 *   considered immutable and read-only.
 *
 *   The "filler" is given the index of vector to fill.
 */
#ifndef AKTIVE_IVECTORCACHE_H
#define AKTIVE_IVECTORCACHE_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <tclpre9compat.h>
#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_iveccache_ *aktive_iveccache;

typedef void (*aktive_iveccache_fill)(void* context, aktive_uint index, double* dst);

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_iveccache aktive_iveccache_new    (aktive_uint nvecs,
						 aktive_uint nelems);
extern void            aktive_iveccache_release (aktive_iveccache cache);
extern double*         aktive_iveccache_get     (aktive_iveccache      cache,
						 aktive_uint           index,
						 aktive_iveccache_fill filler,
						 void*                 context);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_IVECTORCACHE_H */
