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
 *
 * EXAMPLE USER
 *
 *	NETPBM reader for the "text" and "etext" formats. These formats do not
 *	allow direct seeking to a specific pixel, as each pixel is stored as
 *	text, with arbitrary whitespace and comments before and within it.
 *
 *      Reading of data has to be row-sequential. Putting a vector cache in
 *      front of it then allows arbitrary access to rows and columns, while
 *      the caches ensures initial row-sequential access and then row access
 *      of the input.
 *
 * API
 *
 * - new, release
 *
 *   Create and destroy vector caches. The cache has space for "nvecs" vectors
 *   of "nelems" double elements each. This cannot change over the lifetime of
 *   the cache. The last parameter, "start", tells the cache where double
 *   start in the input. The nature of the input data is read from, and thus
 *   the exact meaning of "start" is encoded into the "filler" function vector
 *   used in calls to "take".
 *
 *   BEWARE: The cache assumes that "start == 0" cannot occur and uses this
 *           value internally to signal "undefined" rows.
 *
 *           For channels containing image data this should be trivially
 *           true. I certainly do not remember any image file format which
 *           starts with the pixel data. AFAIR all have some kind of header in
 *           front of them.
 *
 *           Even so, inputs where "start == 0" is possible can be used here.
 *           It is simply necessary to +1 the actual start on cache creation,
 *           and hdo a compensating -1 in the filler function.
 *
 *   Another assumption made by the cache is that the data associated for
 *   vectors 0, 1, ... occurs sequentially in the input, in this order.
 *
 * - take, done
 *
 *   Take from and return a specific vector to the cache, keyed by index.
 *   While the vector is taken the thread has exclusive access.
 *
 *   BEWARE: `take`/`done` lock and unlock the entire cache. They have to come
 *           in pairs and the activity between them should be kept short. Just
 *           copying copying the returned area to some thread-local space is
 *           likely best.
 *
 *   Asking for an undefined vector causes the cache to fill this and all
 *   preceding undefined vectors from the input, using the provided "filler"
 *   function vector and its "context".
 *
 *   The "filler" is given the start offset for the vector, and has to return
 *   the start offset of the next vector after it. These starting points are
 *   never forgotten.
 *
 *   It is this last which enables proper handling of invalidated vectors. The
 *   cache simply refills the vector from the memorized starting point,
 *   without have to re-read all preceding vectors again.
 *
 *   Trimming if vectors is done in cooperation with the underlyng global cache.
 *   The vector cache performs trim completion at the beginning of each "take"
 *   and the end of each "done" operation, as well as during cache destruction.
 */
#ifndef AKTIVE_VECTORCACHE_H
#define AKTIVE_VECTORCACHE_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <tcl.h>
#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_veccache_ *aktive_veccache;

typedef aktive_uint (*aktive_veccache_fill)(void* context, aktive_uint offset, double* dst);

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_veccache aktive_veccache_new     (aktive_uint nvecs,
						aktive_uint nelems,
						aktive_uint start);
extern void            aktive_veccache_release (aktive_veccache cache);
extern double*         aktive_veccache_take    (aktive_veccache      cache,
						aktive_uint          index,
						aktive_veccache_fill filler,
						void*                context);
extern void            aktive_veccache_done    (aktive_veccache cache,
						aktive_uint     index);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_VECTORCACHE_H */
