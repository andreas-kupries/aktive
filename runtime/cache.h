/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Cache utility functions.
 *
 *    Management of a global memory area cache, with LRU eviction policy.
 *    The cache is oblivious to the data stored in the managed areas.
 *    Access to the cache from multiple concurrent threads is safe.
 *
 * Overview
 *
 *    The cache consists of a set of "areas" which are created, released,
 *    entered into tracking, and taken from tracking.
 *
 *    A "memory limit" aka "max size" limits the amount of caching. Going over
 *    this limit causes the cache to throw out older areas to get under the
 *    limit again. This is "trimming". The trimmed areas are selected by LRU.
 *
 *    Only the "tracked" area count towards the limit.
 *
 *    Concurrent access to the cache is allowed, and handled by mutexes,
 *    i.e. locking the critical sections.  To keep these sections small the
 *    areas to work are explicitly taken out of and entered into tracking
 *    (again). While they are not tracked they exclusively belong to the user
 *    for access.
 *
 *    Trimming is done cooperatively with the users in two phases,
 *
 *        Phase I, also known as "pre-trimming", happens whenever the cache
 *        drops old areas out of tracking. These areas are stored in a discard
 *        pile keyed by the area owners. Area owners are declared when
 *        creating areas.
 *
 *        Phase II happens whenever threads call the "trim" API to complete
 *        the clean up of the areas for a specific owner. This is cooperative
 *        because the cache code has no control over when and how often the
 *        user threads perform this finalization.
 *
 *    Trimming was done this way to avoid having one user thread A invoking
 *    trimming and then not only accessing the global cache structures, but
 *    also the areas of other user threads B as well.
 *
 *   In the chosen design only the pointers to the other thread's areas are
 *   moved between global cache structures (LRU list to discard pile) and each
 *   thread is responsible for cleaning up their invalidated areas.
 *
 * API
 *
 * - set_max, get_max
 *
 *   Set / query the memory limit. Setting the size may cause pre-trimming.
 *   Note: The cache management structures do not count towards the limit.
 *
 * - new, release
 *
 *   Create / destroy areas. Created areas are not tracked. This happens only
 *   on their first "enter". Destroying an area takes the area out of tracking
 *   before the memory is freed.
 *
 * - take, enter
 *
 *   Takes an area out of tracking, and returns it to tracking.  While the
 *   area is not tracked the taking thread has exclusive access without
 *   locking the cache management structures. Only the actions of taking out
 *   and entering back lock them. Entering an area may cause a pre-trim.
 *
 * - trim
 *
 *   Complete trimming of invalidated area with a specific owner.
 *   The `trimmer` function is provided to perform owner-specific actions.
 *   The `trimmer` function is __not__ permitted to call the "release" or
 *   "take" API entrypoints.
 *
 */
#ifndef AKTIVE_CACHE_H
#define AKTIVE_CACHE_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <tclpre9compat.h>
#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 * - Structure for a cached memory block, with embedded/appended payload.
 * - Function to call when trimming a cache area is completed.
 */

typedef struct aktive_cache_area {
    void*       context; // support information for the area's manager
    aktive_uint size;    // area size in bytes
    char        data[0]; // area data, allocated as part of the structure
} aktive_cache_area;

typedef void (*aktive_cache_trimmer)(void* owner, aktive_cache_area* area);

/*
 * - - -- --- ----- -------- -------------
 * - Set maximum cache size. This may cause cache pre-trimming.
 * - Query the max cache size.
 * - Generate a new cache block. The new block is __not__ tracked yet.
 * - Release the cache block. Takes it out of tracking before freeing the memory.
 * - Take block out of tracking for local access.
 * - Enter block into tracking. This may cause cache pre-trimming.
 * - Complete trimming for a specific block owner.
 *
 * Cache trimming is done in cooperation with users to reduce the amount and
 * time of locking needed by the various operations.
 *
 * Pre-trimming takes cache blocks out of the main tracking and places them
 * into a discard table keyed by owners. Owners have to regularly call the
 * trim API to complete cleaning up their invalidated blocks.
 *
 * The trimmer function is responsible for cleaning up and updating the owner
 * structures for the specific block. It is __not responsible__ for releasing
 * the block. Calling either of `aktive_cache_release` or `aktive_cache_take`
 * from the trimmer function is forbidden.
 */

extern void               aktive_cache_set_max (aktive_uint size);
extern aktive_uint        aktive_cache_get_max (void);
extern aktive_cache_area* aktive_cache_new     (aktive_uint size, void* owner, void* context);
extern void               aktive_cache_release (aktive_cache_area* area);
extern void               aktive_cache_take    (aktive_cache_area* area);
extern void               aktive_cache_enter   (aktive_cache_area* area);
extern void               aktive_cache_trim    (void* owner, aktive_cache_trimmer trimmer);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_CACHE_H */
