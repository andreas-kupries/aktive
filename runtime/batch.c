/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Batch processing
 *
 * Batch processors handle a task by spawning a number of threads operating
 * concurrently on independent parts of the whole.
 *
 * A batch processor is specified through 3 functions
 *
 *  - maker ... Generates the tasks to process, each specifying the part of
 *              the whole to work on.
 *
 *  - worker .. Processes a task, generating a result.
 *
 *  - completer Integrates the partial results coming from the workers into a
 *              final result.
 *
 * Each batch processer runs a single maker, several workers and a single
 * completer, each in their own thread. The completer actually runs in the
 * main thread which spawns maker and workers.
 *
 * A separate coordinator handles the interaction between all the threads.
 * Each thread uses coordinator functions to execute their responsibilities.
 *
 * The system currently supports the choice of two coordinators, `unordered` and
 * `sequential`. `Unordered` should be used if the order in which results are
 * completed does not matter to the final result. `Sequential` has to be used if
 * the order of completion does matter. `Sequential` ensures that results are
 * processed in the same order as the tasks are generated in.
 *
 * A second difference between the two coordinators is that only `unordered`
 * also supports high priority tasks which can be injected from other parts of
 * the system, outside of the maker. See the processing of connected
 * components for an example of this.
 */
#ifndef AKTIVE_BATCH_I_H
#define AKTIVE_BATCH_I_H

#include <stdlib.h>
#include <tclpre9compat.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <base.h>
#include <batch.h>
#include <nproc.h>
#include <coordinator.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_batch {
    // -- read only configuration --

    const char*           name       ; // Identification
    aktive_batch_make     maker      ; // Batch task generation
    aktive_batch_work     worker     ; // Batch task processing
    aktive_batch_complete completer  ; // Batch task completion
    aktive_uint           sequential ;
    void*                 state      ; // User state/configuration
    aktive_coordinator    coordinator; // Behaviour manager: Unordered or sequential

    // -- worker only -- state per-worker --
    //                -- to be initialized in first call of `worker`.
    //                -- to be released in last call of `worker` (indicator: `task == NULL`).

    void** wstate;
} ab;

// Shorthands
#define PSTATE      (processor->state)
#define PCOORD      (processor->coordinator)
#define PMAKER      (processor->maker)
#define PWORKER     (processor->worker)
#define PCOMPLETER  (processor->completer)
#define PSEQUENTIAL (processor->sequential)
#define PNAME       (processor->name)
#define PWSTATE     (processor->wstate)

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct wsetup {
    aktive_batch p;
    void**       wstate;
} wsetup;

static Tcl_ThreadCreateType task_maker     (aktive_batch processor);
static Tcl_ThreadCreateType task_worker    (wsetup*      ws);
static void                 task_completer (aktive_batch processor);

static void  result_enter (aktive_batch processor, void* result, aktive_uint id);
static void* result_get   (aktive_batch processor);

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_batch_inject (aktive_batch processor, void* task)
{
    TRACE_FUNC ("(processor %p = (char*) '%s', task %p)",
		processor, processor ? PNAME : "", task);

    ASSERT (!PSEQUENTIAL, "cannot inject tasks into sequential batch");

    aktive_coordinator_gen_priority (PCOORD, task);

    TRACE_RETURN_VOID;
}

extern void
aktive_batch_run ( const  char*          name
		 , aktive_batch_make     maker
		 , aktive_batch_work     worker
		 , aktive_batch_complete completer
		 , aktive_uint           sequential
		 , void*                 state)
{
    TRACE_FUNC ("((char*) '%s')", name);

    // note 1: use 2 workers less than processors, to have space for maker and completer
    // note 2: at least use one worker.
    Tcl_ThreadId id;
    aktive_uint  cores  = aktive_processors ();
    aktive_uint  wcount = (cores <= 2) ? 1 : (cores - 2);

    aktive_batch processor = ALLOC (struct aktive_batch);
    memset (processor, 0, sizeof(struct aktive_batch));

    // save configuration

    PNAME       = name;
    PSEQUENTIAL = sequential;
    PMAKER      = maker;
    PWORKER     = worker;
    PCOMPLETER  = completer;
    PSTATE      = state;

    // space for per-worker state

    PWSTATE = NALLOC (void*, wcount);
    memset (PWSTATE, 0, wcount * sizeof(void*));

    // coordinator setup, mode based

    PCOORD = sequential
	? aktive_coordinator_new_sequential (wcount)
	: aktive_coordinator_new_unordered  (wcount);

    // spawn the threads doing the work -- mostly back to front -- workers
    // start waiting for tasks -- maker then pushes tasks into the pipeline.
    //
    // The completer is not handled in a separate thread. it is handled here
    // in the main thread itself, after maker and workers are fully spawned.

    for (aktive_uint k = 0; k < wcount; k++) {
	// Worker threads get an extended setup providing identifying
	// information, i.e. their slot in the wstate array. The `ws`
	// structure allocated here is released by the `task_worker` function.

	wsetup* ws = ALLOC (wsetup);
	ws->p      = processor;
	ws->wstate = &PWSTATE [k];

	TRACE ("spawn worker %d", k);
	Tcl_CreateThread (&id, (Tcl_ThreadCreateProc*) task_worker, ws,
			  TCL_THREAD_STACK_DEFAULT, TCL_THREAD_NOFLAGS);
	TRACE ("worker %d = %p", k, id);
    }

    TRACE ("spawn maker", 0);
    Tcl_CreateThread (&id, (Tcl_ThreadCreateProc*) task_maker, processor,
		      TCL_THREAD_STACK_DEFAULT, TCL_THREAD_NOFLAGS);
    TRACE ("maker = %p", id);

    // with maker and workers now running the main thread can start handling
    // the incoming results.

    task_completer (processor);

    // with the work done clean up all the allocated structures

    aktive_coordinator_release (PCOORD);
    ckfree (PWSTATE);
    ckfree (processor);

    // and fully done

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

static void
task_maker (aktive_batch processor)
{
    TRACE_FUNC ("((batch*) %p)", processor);
    TRACE_RUN (int made = 0);

    aktive_coordinator c = PCOORD;

    do {
	TRACE ("// ............................................... MAKE %d", made);

	void* task = PMAKER (PSTATE);
	TRACE ("task = %p", task);

	if (!task) break;

	aktive_coordinator_gen_regular (c, task);
	TRACE_RUN (made ++);
    } while (1);

    TRACE ("// ...............................................", 0);
    // signal eof to workers
    aktive_coordinator_gen_complete (c);

    TRACE_THREAD_EXIT;
}

static void
task_worker (wsetup *ws) {
    TRACE_FUNC ("((batch*) %p, [%d])", ws->p, ws->wstate - ws->p->wstate);

    // Take worker-specific information into the local state, and release the
    // communication structure allocated in `aktive_batch_run`.
    aktive_uint        id        = ws->wstate - ws->p->wstate;
    aktive_batch       processor = ws->p;
    void**             wstate    = ws->wstate;
    aktive_coordinator c         = PCOORD;
    ckfree (ws);

    TRACE_RUN (int worked = 0);

    do {
	TRACE ("// ............................................... WORK %d", worked);

	void* task = aktive_coordinator_get_task (c, id);
 	TRACE ("task = %p", task);
	if (!task) break;

	void* result = PWORKER (PSTATE, task, wstate);

	aktive_coordinator_set_result (c, id, result);
	TRACE_RUN (worked ++);
    } while (1);

    // signal eof to callback
    PWORKER (PSTATE, 0, wstate);

    // forward eof to completer
    aktive_coordinator_set_result (c, id, NULL);

    TRACE ("// ...............................................", 0);
    // .. and stop
    TRACE_THREAD_EXIT;
}

static void
task_completer (aktive_batch processor)
{
    TRACE_FUNC ("((batch*) %p)", processor);
    TRACE_RUN (int completed = 0);

    aktive_coordinator c = PCOORD;

    do {
	TRACE ("// ............................................... COMPLETE %d", completed);

	void* result = aktive_coordinator_get_result (c);
	TRACE ("process result %p", result);
	if (!result) break;

	PCOMPLETER (processor, PSTATE, result);
	TRACE_RUN (completed ++);
    } while (1);

    TRACE ("// ...............................................", 0);
    TRACE ("results eof, done", 0);
    PCOMPLETER (processor, PSTATE, 0);

    // __Not__ TRACE_THREAD_EXIT - The completer is not run in a spawned thread.
    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_BATCH_H */
