/* -*- c -*-
 */

#include <rt.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>
#include <batch.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct sink_batch_state {
    // maker
    aktive_rectangle scan;
    aktive_uint      count;

    // worker
    aktive_image     image;

    // completer
    aktive_sink*     sink;
    void*            state;
} sink_batch_state;

static void*         sink_maker     (sink_batch_state* state);

static aktive_block* sink_worker    (const sink_batch_state* state,
				     aktive_rectangle*       task,
				     aktive_region*          wstate);

static void          sink_completer (aktive_batch      __ignored,
				     sink_batch_state* state,
				     aktive_block*     result);

static void          sink_concurrent (void*        state,
				      aktive_sink* sink,
				      aktive_image src);

static void          sink_sequential (aktive_region rg,
				      void*         state,
				      aktive_sink*  sink,
				      aktive_image  src);

static void          sink_all        (aktive_region rg,
				      void*         state,
				      aktive_sink*  sink,
				      aktive_image  src);
/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_sink_run (aktive_sink* sink,
		 aktive_image src)
{
    TRACE_FUNC ("((aktive_sink*) %p '%s', (aktive_image) src)",
		sink, sink->name, src);

    void* state = sink->setup (sink->state, src);

    // Some errors may appear only very late.
    if (!state) { TRACE_RETURN_VOID; }

    // Ensure that the image is alive across the whole operation, especially
    // when it goes multi-threaded, and workers release their references
    // (through their regions) during completion.
    aktive_image_ref (src);

    // Scan image by rows      -- TODO FUTURE -- ask pipeline for prefered method
    // Scan image sequentially -- TODO FUTURE -- spread over multiple threads

    aktive_context c = aktive_context_new ();
    aktive_region rg = aktive_region_new (src, c);

    if (!rg) {
	aktive_image_unref (src);
	TRACE_RETURN_VOID;
    }

    // TODO :: heuristic to ignore threading based on shape and size
    // TODO :: heuristics to tile the input differently (rows, columns, tiles)
    //         based on size, shape, and hints

    if (aktive_processors()) {
	aktive_region_destroy (rg);
	aktive_context_destroy (c);

	sink_concurrent (state, sink, src);
	goto done;
    }

    // No threading.
    // TODO :: heuristic to decide between single call vs. per-row vs tiles.
    // sink_all (rg, state, sink, src);

    sink_sequential (rg, state, sink, src);

    aktive_region_destroy (rg); // Note that this invalidates `pixels` too.
    aktive_context_destroy (c);

 done:
    sink->final (state);

    aktive_image_unref (src);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

static void
sink_concurrent (void*        state,
		 aktive_sink* sink,
		 aktive_image src)
{
    aktive_rectangle_def_as (scan, aktive_image_get_domain (src));
    TRACE ("fetching pixels by rows, concurrently", 0);

    sink_batch_state batch;
    aktive_rectangle_copy (&batch.scan, aktive_image_get_domain (src));
    batch.count       = batch.scan.height;
    batch.scan.height = 1;
    batch.image       = src;
    batch.sink        = sink;
    batch.state       = state;

    aktive_batch_run (sink->name,
		      (aktive_batch_make)     sink_maker,
		      (aktive_batch_work)     sink_worker,
		      (aktive_batch_complete) sink_completer,
		      sink->sequential,
		      &batch);
}

static void
sink_sequential (aktive_region rg,
		 void*         state,
		 aktive_sink*  sink,
		 aktive_image  src)
{
    aktive_rectangle_def_as (scan, aktive_image_get_domain (src));
    TRACE ("fetching pixels by rows, sequentially", 0);

    scan.height = 1;
    aktive_uint height = aktive_image_get_height (src);
    aktive_uint row;

    for (row = 0; row < height; row ++) {
	TRACE ("fetching row %d", row);
	TRACE_RECTANGLE(&scan);

	aktive_block* pixels = aktive_region_fetch_area (rg, &scan);

	TRACE ("processing row %d pixels", row);
	sink->process (state, pixels);

	aktive_rectangle_move (&scan, 0, 1);
    }
}

static void
sink_all (aktive_region rg,
	  void*         state,
	  aktive_sink*  sink,
	  aktive_image  src)
{
    aktive_rectangle_def_as (scan, aktive_image_get_domain (src));
    TRACE ("fetching all pixels", 0);

    aktive_block* pixels = aktive_region_fetch_area (rg, &scan);

    TRACE ("processing all pixels", 0);
    sink->process (state, pixels);
}

/*
 * - - -- --- ----- -------- -------------
 */

static void*
sink_maker (sink_batch_state* state)
{
    TRACE_FUNC("((sink_batch_state*) %p, %d remaining)", state, state->count);

    // All rows scanned, stop
    if (!state->count) {
	TRACE_RETURN ("(rect*) %p, EOF", 0);
    }

    aktive_rectangle* r = ALLOC (aktive_rectangle);
    aktive_rectangle_copy (r, &state->scan);

    state->count --;
    aktive_rectangle_move (&state->scan, 0, 1);

    TRACE_RECTANGLE (r);
    TRACE_RETURN ("(rect*) %p", r);
}

static aktive_block*
sink_worker (const sink_batch_state* state, aktive_rectangle* task, aktive_region* wstate)
{
    TRACE_FUNC("((sink_batch_state*) %p, (task) %p, (ws) %p)", state, task, wstate);

    // worker ends, release state - that includes the context
    // account for possibility that there is no worker state (first call is also EOF signal).
    if (!task) {
	if (*wstate) {
	    aktive_context c = aktive_region_context (*wstate);
	    aktive_region_destroy (*wstate);
	    aktive_context_destroy (c);
	}
	TRACE_RETURN ("", 0);
    }

    // first call with a task, initialize state - each worker has its own context
    if (! *wstate) {
	TRACE ("initialize wstate", 0);
	aktive_context c = aktive_context_new ();
	*wstate = aktive_region_new (state->image, c);
	TRACE ("(region*) %p", *wstate);
    }

    TRACE_RECTANGLE (task);
    (void) aktive_region_fetch_area (*wstate, task);

    aktive_block* p = ALLOC (aktive_block);

    aktive_region_export (*wstate, p);

    ckfree (task);
    TRACE_RETURN ("(active_block*) %p", p);
}

static void
sink_completer (aktive_batch __ignored, sink_batch_state* state, aktive_block* result)
{
    TRACE_FUNC("((sink_batch_state*) %p, (active_block*) %p)", state, result);

    if (!result) {
	TRACE("no data %p", result);
	TRACE_RETURN_VOID;
    }

    TRACE("process %p", result);
    state->sink->process (state->state, result);

    aktive_blit_close (result);
    ckfree            (result);

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
