## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Functionally identity, in-memory cache, materialization

# # ## ### ##### ######## ############# #####################
##

operator op::cache {
    section cache

    note Returns the unchanged input.

    note However, this operator materializes and caches the input \
	in memory, for fast random access. Yet it is __not strict__, as \
	the materialization is deferred until the first access.

    note This is useful to put in front of a computationally expensive \
	pipeline, to avoid recomputing parts as upstream demands them. \
	The trade-off here is, of course, memory for time.

    input

    state -fields {
	aktive_block cache;	      /* Cache for the input's pixels */
	aktive_uint  cachefilled;     /* Flag, set when the cache is usable */
	Tcl_Mutex    cachefillactive; /* Serialize cache fill actions */
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	state->cachefilled = 0;
	state->cachefillactive = 0;
	memset (&state->cache, 0, sizeof(aktive_block));
	aktive_geometry_copy (&state->cache.domain, domain);
    } -cleanup {
	Tcl_MutexFinalize (&state->cachefillactive);
	if (!state->cachefilled) return;
	aktive_blit_close (&state->cache);
    }

    pixels -state {
	aktive_image src;
    } -setup {
	state->src = aktive_region_owner (srcs->v[0]);
    } {
	// Two step initialization.
	//
	// If the current thread T sees an unfilled cache T claims the lock to fill it. If
	// some other thread O is already filling it T stops, waits for O to complete, and
	// can then skip the fill step. If T manages to claim the lock and still sees an
	// unfilled cache, then T is first, and performs the fill op, blocking others while
	// doing so.

	TRACE("cachefilled = %d",istate->cachefilled);
	if (!istate->cachefilled) { /* ((A)) */
	    TRACE("attempt fill", 0);
	    Tcl_MutexLock (&istate->cachefillactive);

	    TRACE("locked, cachefilled = %d",istate->cachefilled);
	    if (!istate->cachefilled) {
		TRACE("do fill", 0);

		aktive_blit_setup (&istate->cache, aktive_geometry_as_rectangle (idomain));
		istate->cache.initialized = 1;

		aktive_sink_run (aktive_memory_sink (&istate->cache), state->src);
		// Note: The sink self-destroys in its state finalization.

		// we need a compiler barrier here to ensure that the flag is only set
		// after the cache is filled. So that other threads at ((A)) cannot
		// wrongly skip to ((B)) while the cache is only partially filled, or
		// not at all.
		asm volatile("" ::: "memory");
		istate->cachefilled = 1;
	    }

	    TRACE("release, cachefilled = %d",istate->cachefilled);
	    Tcl_MutexUnlock (&istate->cachefillactive);
	    TRACE("released", 0);
	}

	TRACE("read cache", 0);
	// ((B)) Deliver request from cache.
	aktive_blit_copy (block, dst, &istate->cache, aktive_rectangle_as_point(request));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
