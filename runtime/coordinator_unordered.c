/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Unordered coordinator
 */

/*
 * - - -- --- ----- -------- -------------
 */

#include <tclpre9compat.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <coordinator_int.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 * Forward declarations of the internal coordinator implementations, and types
 */

typedef struct u_coordinator {
    coordinator base;     // name and function vectors

    /*
     * Thread interaction
     * ```
     * maker -- (tasks) --> worker -- (results) --> completer
     * ```
     *
     * EOF, i.e. the end of task generation, is handled as a wave of signals
     * through the processing nodes. It is signaled by placing `num(workers)`
     * null tasks into the task queue. This terminates the workers, which pass
     * the signal as a null result before ending. The completer collects these
     * null results until it has one per worker, and then terminates itself.
     */

    // system state

    // maker -> worker :: passing of tasks, regular and priority
    ringbuffer    regular_tasks;
    ringbuffer    priority_tasks;

    // worker -> completer :: passing of results
    ringbuffer    results;

} u_coordinator;

#define CAP (c->base.capacity)

static void  release      (u_coordinator* c);
static void  gen_regular  (u_coordinator* c, void* task);
static void  gen_priority (u_coordinator* c, void* task);
static void  gen_complete (u_coordinator* c);
static void* get_task     (u_coordinator* c, aktive_uint id);
static void  set_result   (u_coordinator* c, aktive_uint id, void* result);
static void* get_result   (u_coordinator* c);

#define SM "state mismatch: "

#define CLEARA(var, capacity) memset (var, 0, capacity * sizeof (var[0]))
#define CLEARV(var)           memset (var, 0, sizeof (*var))

/*
 * - - -- --- ----- -------- -------------
 * API methods - constructor
 */

aktive_coordinator
aktive_coordinator_new_unordered (aktive_uint capacity)
{
    TRACE_FUNC ("(capacity) %d", capacity);

    u_coordinator*     c  = ALLOC (u_coordinator);
    aktive_coordinator ac = &c->base;

    CLEARV (c);

    ac->name         = "coordinator-sequential";
    ac->release      = (f_release      ) release      ;
    ac->gen_regular  = (f_gen_regular  ) gen_regular  ;
    ac->gen_priority = (f_gen_priority ) gen_priority ;
    ac->gen_complete = (f_gen_complete ) gen_complete ;
    ac->get_task     = (f_get_task     ) get_task     ;
    ac->set_result   = (f_set_result   ) set_result   ;
    ac->get_result   = (f_get_result   ) get_result   ;
    ac->capacity     = capacity;
    ac->active       = capacity;

    ring_init (c->regular_tasks,  capacity);
    ring_init (c->priority_tasks, capacity);
    ring_init (c->results,        capacity);

    TRACE_RETURN("((coordinator*) %p)", ac);
}

/*
 * - - -- --- ----- -------- -------------
 * Method implementations
 */

void
release (u_coordinator* c)
{
    TRACE_FUNC("(u_coordinator*) %p", c);

    ASSERT (c->regular_tasks.isempty,  "unordered coordinator has regular tasks in flight");
    ASSERT (c->priority_tasks.isempty, "unordered coordinator has priority tasks in flight");
    ASSERT (c->results.isempty,        "unordered coordinator has unprocessed results");

    ring_release (c->regular_tasks);
    ring_release (c->priority_tasks);
    ring_release (c->results);

    ckfree (c);

    TRACE_RETURN_VOID;
}

void
gen_regular (u_coordinator* c, void* task)
{
    TRACE_FUNC("((u_coordinator*) %p, (task*) %p)", c, task);

    ring_put (c->regular_tasks, task);

    TRACE_RETURN_VOID;
}

void
gen_priority (u_coordinator* c, void* task)
{
    TRACE_FUNC("((u_coordinator*) %p, (task*) %p)", c, task);

    ring_put (c->priority_tasks, task);

    TRACE_RETURN_VOID;
}

void
gen_complete (u_coordinator* c)
{
    TRACE_FUNC("((u_coordinator*) %p)", c);

    // inject NULL [oef] tasks into the workers.
    // these become NULL [eof] results, ending the completer.

    aktive_uint worker;
    for (worker = 0; worker < CAP; worker++) {
	TRACE ("send [eof] count %d", worker);
	ring_put (c->regular_tasks, NULL);
    }

    TRACE_RETURN_VOID;
}

void*
get_task (u_coordinator* c, aktive_uint worker)
{
    TRACE_FUNC("((u_coordinator*) %p, (worker) %d)", c, worker);

    void*       task;
    aktive_uint taken;

    while (1) {
	ring_take_ifnotempty (c->priority_tasks, task, taken);
	if (taken) goto done;

	ring_take_ifnotempty (c->regular_tasks, task, taken);
	if (taken) goto done;

	// instead of spinning - wait on either ring to be notempty ?
	// cannot - separate condition variables
    }

 done:
    TRACE_RETURN (task ? "(task*) %p" : "(task*) %p (eof)", task);
}

void
set_result (u_coordinator* c, aktive_uint worker, void* result)
{
    TRACE_FUNC("((u_coordinator*) %p, (worker) %d, (result) %p)", c, worker, result);

    ring_put (c->results, result);

    TRACE_RETURN_VOID;
}

void*
get_result (u_coordinator* c)
{
    TRACE_FUNC("((u_coordinator*) %p)", c);
    void* result;

    while (1) {
	result = NULL;

	ring_take (c->results, result);
	if (result) break;

	TRACE ("CLOSED", 0);

	if (c->base.active == 1) break;
	c->base.active --;
    }

    TRACE_RETURN (result ? "(result*) %p" : "(result*) %p (eof)", result);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
