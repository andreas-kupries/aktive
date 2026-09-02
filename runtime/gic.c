/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- In-memory cache for global image operators.
 *
 * Takes a function to compute the result from the entire input image.  The
 * function is run once, from the first pixel fetcher thread encountering an
 * uninitialized cache. It may internally operate thread for speed, assuming
 * the operation is actually threadable in some way.
 */

#include <string.h>
#include <gic.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 * - Structure for a cached in-memory pixel block
 *
 */

extern void
aktive_gicache_init (aktive_gicache* cache)
{
  TRACE_FUNC("((aktive_gicache*) %p)", cache);

  cache->isfilled = 0;
  cache->fillinprogress = 0;
  memset (&cache->cache, 0, sizeof(aktive_block));

  TRACE_RETURN_VOID;
}

extern void
aktive_gicache_drop (aktive_gicache* cache) {
  TRACE_FUNC("((aktive_gicache*) %p)", cache);

  Tcl_MutexFinalize (&cache->fillinprogress);
  if (!cache->isfilled) return;
  aktive_blit_close (&cache->cache);

  TRACE_RETURN_VOID;
}

extern void
aktive_gicache_fill (aktive_gicache* cache, aktive_gicache_filler filler, void* context)
{
  TRACE_FUNC("((aktive_gicache*) %p, (filler*) %p, (void*) %p)",
	     cache, filler, context);

  // Two step initialization.
  //
  // If the current thread T sees an unfilled cache T it claims the lock to fill
  // it. It rechecks the flag after the lock in case it was preempted by some
  // other thread O, and if yes, waits for O to complete, after which it skip
  // the fill step. If T manages to claim the lock and still sees an unfilled
  // cache, then T is the first thread reaching the cache, forcing it to perform
  // the fill op, blocking the other threads while doing so.

  TRACE("check, isfilled = %d", cache->isfilled);
  if (cache->isfilled) TRACE_RETURN_VOID;
  /* ((A)) */

  TRACE("attempt to claim for filling", 0);
  Tcl_MutexLock (&cache->fillinprogress);

  TRACE("claimed, rechecking isfilled = %d", cache->isfilled);
  if (cache->isfilled) goto unlock;

  TRACE("invoke filler", 0);
  filler (&cache->cache, context);
  TRACE("fill complete", 0);

  // we need a compiler barrier here to ensure that the flag is only set after
  // the cache is filled. So that other threads at ((A)) cannot wrongly skip
  // over the initialization while the cache is only partially filled, or not at
  // all.
  asm volatile("" ::: "memory");
  cache->isfilled = 1;
 unlock:
  TRACE("release lock", 0);
  Tcl_MutexUnlock (&cache->fillinprogress);
  TRACE("done", 0);
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
