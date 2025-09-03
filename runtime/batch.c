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
 *  - tasker	Generates the tasks to process, each specifying the part to work on.
 *  - worker	Processes a task, generating a result.
 *  - retirer	Takes taask results and integrates them into a final result.
 *
 * Each batch processer runs a single tasker, several wokers and a single retirer.
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
#include <queue.h>
#include <nproc.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_batch {
    // -- read only configuration --

    const char*           name      ; // Identification
    aktive_batch_make     maker     ; // Batch task generation
    aktive_batch_work     worker    ; // Batch task processing
    aktive_batch_complete completer ; // Batch task completion
    aktive_uint           sequential ;
    void*                 state    ; // User state/configuration

    // -- maker / worker -- communication by queue -- maker writes, worker reads

    aktive_queue tasks;

    // -- worker only -- state per-worker --
    //                -- to be initialized in first call of `worker`.
    //                -- to be released in last call of `worker` (indicator: `task == NULL`).

    void** wstate;

    // -- worker / completer --
    //    two distinct modes -- sequential and not
    //
    //    sequential mode forces processing of results in the same order as
    //    their tasks were created. Whereas non-sequential mode does not
    //    impose an ordering on the completer.
    //
    //    communication in non-sequential mode is by a queue like for
    //    maker/worker. worker writes, completer reads.
    //
    //    communication in sequential mode is done by ping/pong signaling
    //    between completer and workers. The completer asks for a specific
    //    result, and only the worker who has that result will place it and
    //    then signal the result's presence back. Workers which do not have
    //    the asked for result wait until theirs is asked for.
    //
    //    a small complication is eof signaling from workers to completer.
    //    workers who end do __not__ have to wait. they simply update the
    //    count. the completer then tracks if it should end also, or not,
    //    whenever it asks for a result.

    // This queue is relevant and allocated only in non-sequential mode
    aktive_queue  results   ; // Result queue -- worker writes, completer reads

    // Ping/pong signaling for sequential mode.
    Tcl_Mutex     mresult   ; // mutex controlling worker/completer synch in sequential mode
    Tcl_Condition await     ; // signal when completer is ready for next result
    aktive_uint   awaiting  ; // id of task the completer is waiting for
    Tcl_Condition hasresult ; // signal when worker has placed the awaited result (or eof)
    void**        result    ; // result for completer to take
    aktive_uint   workers   ; // number of active workers
} ab;

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
		processor, processor ? processor->name : "", task);

    ASSERT (!processor->sequential, "cannot inject tasks into sequential batch");

    aktive_queue_enter_priority (processor->tasks, task);
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

    processor->name       = name;
    processor->maker      = maker;
    processor->worker     = worker;
    processor->completer  = completer;
    processor->state      = state;
    processor->sequential = sequential;

    // space for per-worker state

    processor->wstate = NALLOC (void*, wcount);
    memset (processor->wstate, 0, wcount*sizeof(void*));

    // maker/worker communication

    processor->tasks = aktive_queue_new (2*wcount);

    // worker/completer communication -- mutex and signals are initialized by memset

    if (!sequential) {
	processor->results = aktive_queue_new (2*wcount);
    } else {
	processor->awaiting = 0;
    }

    // spawn the threads doing the work -- mostly back to front -- workers
    // start waiting for tasks -- maker then pushes tasks into the pipeline.
    //
    // The completer is not handled in a separate thread. it is handled here
    // in the main thread itself.

    processor->workers = wcount;
    for (aktive_uint k = 0; k < wcount; k++) {
	// Worker threads get an extended setup providing identifying
	// information, i.e. their slot in the wstate array. The `ws`
	// structure allocated here is released by the `task_worker` function.

	wsetup* ws = ALLOC (wsetup);
	ws->p      = processor;
	ws->wstate = &processor->wstate [k];

	TRACE ("spawn worker %d", k);
	Tcl_CreateThread (&id, (Tcl_ThreadCreateProc*) task_worker, ws,
			  TCL_THREAD_STACK_DEFAULT, TCL_THREAD_NOFLAGS);
	TRACE ("worker %d = %p", k, id);
    }

    TRACE ("spawn maker", 0);
    Tcl_CreateThread (&id, (Tcl_ThreadCreateProc*) task_maker, processor,
		      TCL_THREAD_STACK_DEFAULT, TCL_THREAD_NOFLAGS);
    TRACE ("maker = %p", id);

    // with marker and worker running the main thread can now start handling
    // the incoming results.

    task_completer (processor);

    // with the work done clean up all the allocated structures

    if (processor->sequential) {
	Tcl_ConditionFinalize (&processor->await);
	Tcl_ConditionFinalize (&processor->hasresult);
	Tcl_MutexFinalize     (&processor->mresult);
    } else {
	aktive_queue_free (processor->results);
    }
    aktive_queue_free (processor->tasks);
    ckfree (processor->wstate);
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

    do {
	TRACE ("// ...............................................", 0);

	void* task = processor->maker (processor->state);
	if (!task) break;

	aktive_queue_enter (processor->tasks, task);
    } while (1);

    TRACE ("// ...............................................", 0);
    aktive_queue_eof (processor->tasks);

    TRACE_THREAD_EXIT;
}

static void
task_worker (wsetup *ws) {
    TRACE_FUNC ("((batch*) %p, [%d])", ws->p, ws->wstate - ws->p->wstate);

    // Take worker-specific information into the local state, and release the
    // communication structure allocated in `aktive_batch_run`.
    aktive_batch processor = ws->p;
    void**       wstate    = ws->wstate;
    ckfree (ws);

    do {
	TRACE ("// ...............................................", 0);

	aktive_uint taskid;
	void*       task = aktive_queue_get (processor->tasks, &taskid);

	if (!task) {
	    // signal eof to callback and completer
	    processor->worker (processor->state, 0, wstate);
	    result_enter (processor, 0, 0);
	    break;
	}
	result_enter (processor,
		      processor->worker (processor->state, task, wstate),
		      taskid);
    } while (1);

    TRACE ("// ...............................................", 0);
    // .. and stop
    TRACE_THREAD_EXIT;
}

static void
task_completer (aktive_batch processor)
{
    TRACE_FUNC ("((batch*) %p)", processor);

    do {
	TRACE ("// ...............................................", 0);
	if (processor->sequential) {
	    TRACE ("obtain result %d", processor->awaiting);
	}

	void* result = result_get (processor);
	if (!result) break;

	TRACE ("process result %p", result);
	processor->completer (processor, processor->state, result);
    } while (1);

    TRACE ("// ...............................................", 0);
    TRACE ("results eof, done", 0);
    processor->completer (processor, processor->state, 0);

    // __Not__ TRACE_THREAD_EXIT - The completer is not run in a spawned thread.
    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

static void
result_enter (aktive_batch processor, void* result, aktive_uint id)
{
    TRACE_FUNC ("((batch*) %p, (void*) %p, task %d)", processor, result, id);

    if (processor->sequential) {
	Tcl_MutexLock (&processor->mresult);

	if (!result) {
	    TRACE ("eof", 0);
	    processor->workers --;

	    // signal as result, in case a very fast completer (null) is
	    // already waiting on the condition.
	    Tcl_ConditionNotify (&processor->hasresult);
	    TRACE ("signaled eof", 0);

	    // completer will see it on next attempt to get a result
	} else {
	    // wait for completer to ask for our result
	    TRACE ("completer %d having %d", processor->awaiting, id);

	    while (processor->awaiting < id) {
		TRACE ("await completer readiness", 0);
		Tcl_ConditionWait (&processor->await, &processor->mresult, NULL);
		TRACE ("completer ready for %d", processor->awaiting);
	    }
	    // kill process if the completer somehow moved past us.
	    ASSERT (processor->awaiting == id, "passed over");

	    // place result and signal
	    processor->result = result;
	    Tcl_ConditionNotify (&processor->hasresult);
	    TRACE ("signaled %d", id);
	}

	Tcl_MutexUnlock (&processor->mresult);
	TRACE_RETURN_VOID;
    }

    // non-sequential. pass results through a simple queue

    aktive_queue_enter (processor->results, result);
    TRACE_RETURN_VOID;
}

static void*
result_get (aktive_batch processor)
{
    TRACE_FUNC ("((batch*) %p)", processor);

    void* result = 0;

    if (processor->sequential) {
	// Sequential mode. Signal readiness to receive a result, then wait
	// for it to be placed.  Do this only if there are workers
	// left. Without workers signal EOF to caller (NULL result).
	// When the desired result appears take it and prepare for next.

	Tcl_Time    wait = { 1, 0 }; // 1 second
	aktive_uint loops;
#define MAXLOOPS 10 // * wait = 10 seconds

	Tcl_MutexLock (&processor->mresult);
    restart:
	if (processor->workers) {
	    TRACE ("signal ready for %d", processor->awaiting);
	    Tcl_ConditionNotify (&processor->await);

	    loops = 0;
	    while (!processor->result) {
		TRACE ("awaiting has result", 0);
		Tcl_ConditionWait (&processor->hasresult, &processor->mresult, &wait);
		TRACE ("seen has result", 0);

		// workers completed in full while we were waiting. restart
		// from top (to possibly capture a last result).
		if (!processor->workers) goto restart;

		loops ++;
		ASSERT_VA (loops < MAXLOOPS, "waiting over 10 seconds, likely hung",
			   " (%s)", processor->name);
	    }
	    TRACE ("received has result", 0);

	    result = processor->result;
	    processor->result = 0;

	    processor->awaiting ++;
	} else if (processor->result) {
	    TRACE ("no workers, capture last", 0);

	    // There is a last result to handle.

	    result = processor->result;
	    processor->result = 0;
	}

	Tcl_MutexUnlock (&processor->mresult);
	TRACE_RETURN ("(void*) %p", result);
    }

    // Non-sequential mode. Pull from queue. Manage worker count!

    do {
	aktive_uint __id;
	result = aktive_queue_get (processor->results, &__id);

	if (!result) {
	    TRACE ("worker completion", 0);

	    // A worker signaled its completion
	    processor->workers --;
	    if (processor->workers == 0) {
		TRACE ("full completion", 0);
		TRACE_RETURN ("eof (void*) %p", 0);
	    }
	    // Still have workers, look for next result
	    continue;
	}

	TRACE_RETURN ("(void*) %p", result);
    } while (1);

    ASSERT (0, "cannot be reached");
    TRACE_RETURN ("not reachable", 0);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_BATCH_H */
