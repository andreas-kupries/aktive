/* -*- c -*-
 */

#include <rt.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>
#include <batch.h>

TRACE_OFF;

#define ALL   1		// single fetch all
#define ROWS  2		// sequential fetch rows
#define CROWS 3		// concurrent fetch rows
#define MODE  CROWS

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

static void          sink_completer (sink_batch_state* state,
				     aktive_block*     result);

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

    // Scan image by rows      -- TODO FUTURE -- ask image for prefered method
    // Scan image sequentially -- TODO FUTURE -- spread over multiple threads

    aktive_region rg = aktive_region_new (src);

    if (!rg) {
	aktive_image_unref (src);
	TRACE_RETURN_VOID;
    }

#if MODE == CROWS
    aktive_region_destroy (rg);

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

#elif MODE == ROWS
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

    aktive_region_destroy (rg); // Note that this invalidates `pixels` too.

#elif MODE == ALL
    aktive_rectangle_def_as (scan, aktive_image_get_domain (src));
    TRACE ("fetching all pixels", 0);

    aktive_block* pixels = aktive_region_fetch_area (rg, &scan);

    TRACE ("processing all pixels", 0);
    sink->process (state, pixels);

    aktive_region_destroy (rg); // Note that this invalidates `pixels` too.
#endif

    sink->final (state);

    aktive_image_unref (src);

    TRACE_RETURN_VOID;
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

    // first call, initialize state
    if (! *wstate) {
	TRACE ("initialize wstate", 0);
	*wstate = aktive_region_new (state->image);
	TRACE ("(region*) %p", *wstate);
    }

    // worker ends, release state
    if (!task) {
	aktive_region_destroy (*wstate);
	TRACE_RETURN ("", 0);
    }

    TRACE_RECTANGLE (task);
    (void) aktive_region_fetch_area (*wstate, task);

    aktive_block* p = ALLOC (aktive_block);

    aktive_region_export (*wstate, p);

    ckfree (task);
    TRACE_RETURN ("(active_block*) %p", p);
}

static void
sink_completer (sink_batch_state* state, aktive_block* result)
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
