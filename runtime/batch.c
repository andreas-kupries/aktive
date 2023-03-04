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

#include <tcl.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <stdlib.h>
#include <batch.h>
#include <queue.h>

TRACE_OFF;

#define TRACE_THREAD_EXIT \
    TRACE_HEADER (1); TRACE_ADD ("THREAD EXIT %s", "(void)") ; \
    TRACE_CLOSER ; TRACE_POP ; TCL_THREAD_CREATE_RETURN

/*
 * - - -- --- ----- -------- -------------
 */

#define AKTIVE_THREADS (6)	// TODO - query cpu, or app configurable

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct {
    int   id;
    void* value;
} rentry;

typedef struct aktive_batch* aktive_batch;
typedef struct aktive_batch {
    // -- read only configuration --
    const char*           name     ; // Identification
    aktive_batch_make     maker    ; // Batch task generation
    aktive_batch_work     worker   ; // Batch task processing
    aktive_batch_complete completer; // Batch task completion
    void*                 state    ; // User state/configuration

    void**                wstate   ; // Per worker state. Initialized on first call, destroyed on last.
    
    aktive_queue tasks             ; // Task queue   -- task_maker, task_worker
    aktive_queue results           ; // Result queue -- task_worker, task_completer

    // reorder buffer and worker completion control -- task_completer, result_get
    
    rentry*      rob          ; // Result reorder buffer
    aktive_uint  rob_capacity ; // number of entries the rob has space for
    aktive_uint  rob_used     ; // number of entries used in rob
    aktive_uint  awaiting     ; // id of task the completer is waiting for
    aktive_uint  workers      ; // number of active workers

    // completion control -- task_completer to main thread
    Tcl_Mutex     mdone    ;
    aktive_uint   done     ;
    Tcl_Condition isdone   ;
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
static Tcl_ThreadCreateType task_completer (aktive_batch processor);

const aktive_uint wcount = AKTIVE_THREADS;

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_batch_run ( const  char*          name
		 , aktive_batch_make     maker
		 , aktive_batch_work     worker
		 , aktive_batch_complete completer
		 , void*                 state)
{
    TRACE_FUNC ("((char*) '%s')", name);
    
    Tcl_ThreadId id;
    
    aktive_batch processor = ALLOC (struct aktive_batch);
    memset (processor, 0, sizeof(struct aktive_batch));
    
    processor->name      = name;
    processor->maker     = maker;
    processor->worker    = worker;
    processor->completer = completer;
    processor->state     = state;

    processor->wstate    = NALLOC (void*, wcount);
    memset (processor->wstate, 0, wcount*sizeof(void*));
    
    processor->tasks        = aktive_queue_new (2*wcount);
    processor->results      = aktive_queue_new (2*wcount);
    processor->rob_used     = 0;
    processor->rob_capacity = 4*wcount;
    processor->rob          = NALLOC (rentry, processor->rob_capacity);
    processor->awaiting     = 0;

    processor->done      = 0;
    processor->isdone    = 0;

    // pipeline is created from back to front - completer starts waiting for
    // results, workers start waiting for tasks, maker pushes tasks into the
    // pipeline.

    TRACE ("spawn completer", 0);
    
    Tcl_CreateThread (&id, (Tcl_ThreadCreateProc*) task_completer, processor,
		      TCL_THREAD_STACK_DEFAULT, TCL_THREAD_NOFLAGS);
    TRACE ("completer = %p", id);

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

    TRACE ("wait for completion", 0);
    Tcl_MutexLock (&processor->mdone);
    TRACE ("wait locked in", 0);
    while (!processor->done) {
	TRACE ("condition wait ...", 0);
	Tcl_ConditionWait (&processor->isdone, &processor->mdone, NULL);
	TRACE ("condition signaled", 0);
    }
    TRACE ("condition received", 0);
    Tcl_MutexUnlock (&processor->mdone);
    TRACE ("completion achieved", 0);

    Tcl_ConditionFinalize (&processor->isdone);
    Tcl_MutexFinalize     (&processor->mdone);

    aktive_queue_free  (processor->results);
    aktive_queue_free  (processor->tasks);
    ckfree (processor->rob);
    ckfree (processor);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

static void  result_enter (aktive_batch processor, void* result, aktive_uint id);
static void* result_get   (aktive_batch processor);

/*
 * - - -- --- ----- -------- -------------
 */

static void
task_maker (aktive_batch processor)
{
    TRACE_FUNC ("((batch*) %p)", processor);
    
    void* task = 0;

    // fprintf (stdout,"maker start\n");fflush(stdout);
    
    do {
	TRACE ("// ...............................................", 0);
	
	task = processor->maker (processor->state);
	aktive_queue_enter (processor->tasks, task);
    } while (task);

    TRACE ("// ...............................................", 0);
    aktive_queue_eof (processor->tasks);
    
    // fprintf (stdout,"maker done\n");fflush(stdout);
    TRACE_THREAD_EXIT;
}

static void
task_worker (wsetup *ws) {
    TRACE_FUNC ("((batch*) %p, [%d])", ws->p, ws->wstate - ws->p->wstate);
    
    void* task = 0;

    // Take worker-specific information into the local state, and release the
    // communication structure allocated in `aktive_batch_run`.
    aktive_batch processor = ws->p;
    void**       wstate    = ws->wstate;
    ckfree (ws);

    do {
	TRACE ("// ...............................................", 0);

	aktive_uint taskid;
	task = aktive_queue_get (processor->tasks, &taskid);
	if (task) {
	    result_enter (processor,
			  processor->worker (processor->state, task, wstate),
			  taskid);
	    continue;
	}

	// !task - no tasks anymore - signal our completion all around

	processor->worker (processor->state, 0, wstate);
	result_enter (processor, 0, 0);
    } while (task);

    TRACE ("// ...............................................", 0);
    // .. and stop
    TRACE_THREAD_EXIT;
}

static void
task_completer (aktive_batch processor)
{
    TRACE_FUNC ("((batch*) %p)", processor);

    void* result = 0;

    // fprintf (stdout,"completer start\n");fflush(stdout);

    do {
	TRACE ("// ...............................................", 0);
	TRACE ("obtain result %d", processor->awaiting);
	
	result = result_get (processor);
	if (!result) break;

	TRACE ("process result", 0);
	processor->completer (processor->state, result);
    } while (result);

    TRACE ("// ...............................................", 0);
    TRACE ("result eof, signal done", 0);

    TRACE ("done flagged", 0);
    processor->done = 1;
    TRACE ("done signaling", 0);
    Tcl_ConditionNotify (&processor->isdone);
    TRACE ("done signaled", 0);

    // fprintf (stdout,"completer done\n");fflush(stdout);
    TRACE_THREAD_EXIT;
}

/*
 * - - -- --- ----- -------- -------------
 */

static void
result_enter (aktive_batch processor, void* result, aktive_uint id)
{
    TRACE_FUNC ("((batch*) %p, (void*) %p, task %d)", processor, result, id);
    
    rentry* r = 0;
    if (result) {
	// actual result - queue wrapped to transfer both it and its task id
    	r = ALLOC (rentry);
	r->id    = id;
	r->value = result;
    } // else: completion signal, pass through
    
    aktive_queue_enter (processor->results, r);
    TRACE_RETURN_VOID;
}

static int
rentry_compare (const void *a, const void *b)
{
    // a->id < b->id --> a < b --> < 0
    return ((const rentry *) a)->id - ((const rentry *) b)->id; // < 0
}

static void*
result_get (aktive_batch processor)
{
    TRACE_FUNC ("((batch*) %p)", processor);
    
    void* result = 0;

    // Fill requests from the rob as long as ROB is not empty and the desired
    // thing is present at the front.

    do {
	TRACE ("rob check [%d]", processor->rob_used);
	
	if (processor->rob_used && (processor->rob[0].id == processor->awaiting)) {
	    TRACE ("ROB retire task %d", processor->awaiting);
	
	    // Extract result, prepare for next wait
	    result = processor->rob[0].value;
	    processor->awaiting ++;

	    // update rob - reduze size, and restore order (smallest == oldest first)
	    processor->rob_used --;
	    processor->rob[0] = processor->rob[processor->rob_used];
	    qsort (processor->rob, processor->rob_used, sizeof(rentry), rentry_compare);
	
	    TRACE_RETURN ("(void*) %p", result);
	}

	// Note: reaching here with no workers should have cleared the
	// remaining ROB entries. If not something has messed with the task
	// ordering and waiting.
	if (!processor->workers) {
	    ASSERT (!processor->rob_used, "ROB not empty");
	    // ROB empty
	    TRACE_RETURN ("eof (void*) %p", 0);
	}
	
	// Desired request is not present in ROB. Wait for additional result.
    
	rentry* r;

	TRACE ("await queue result", 0);
	
	aktive_uint __id;
	r = aktive_queue_get (processor->results, &__id);

	if (!r) {
	    TRACE ("worker completion", 0);
	    
	    // A worker signaled its completion
	    processor->workers --;
	    if (processor->workers == 0) {
		TRACE ("full completion", 0);
		if (processor->rob_used) continue;
		// all workers completed, ROB empty, signal our completion
		TRACE_RETURN ("eof (void*) %p", 0);
	    }
	    // Still have workers, look for next result
	    continue;
	}

	// got a result ...
	TRACE ("received (void*) %p, task %d", r->value, r->id);
	
	if (r->id == processor->awaiting) {
	    TRACE ("immediate retire task %d", processor->awaiting);
		
	    // It is what we were waiting for. Bypass the ROB.

	    processor->awaiting ++;
	    result = r->value;
	    ckfree (r);

	    TRACE_RETURN ("(void*) %p", result);
	}

	TRACE ("ROB extend (void*) %p [%d/%d] task %d",
	       r->value, processor->rob_used, 2*wcount, r->id);
	// result is not what we are looking for. extend the rob and wait more.

	if (processor->rob_used == processor->rob_capacity) {
	    // Very fast worker threads. Extend the ROB to hold more ahead results.
	    processor->rob_capacity *= 2;
	    processor->rob = REALLOC (processor->rob, rentry, processor->rob_capacity);
	}
	
	ASSERT (processor->rob_used < processor->rob_capacity, "ROB overflow");
	
	processor->rob[processor->rob_used] = *r;
	processor->rob_used ++;
	qsort (processor->rob, processor->rob_used, sizeof(rentry), rentry_compare);

	ckfree (r);

	TRACE ("wait more", 0);
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
