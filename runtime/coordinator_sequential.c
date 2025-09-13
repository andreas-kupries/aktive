/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Sequential coordinator
 */

#include <tclpre9compat.h>
#include <coordinator_int.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 * Forward declarations of the internal coordinator implementations, and types
 */

typedef struct s_coordinator {
    coordinator base;     // name and function vectors

    /*
     * Thread interaction
     * ```
     *      /<-- (idle) ---\
     * maker -- (tasks) --> worker -- (results) --> completer
     *      \                                      /
     *       \-- (order) ------------------------>/
     * ```
     *
     * EOF, i.e. the end of task generation, is handled as a wave of signals
     * through the processing nodes. It is signaled by placing `num(workers)`
     * null tasks into the task queue. This terminates the workers, which pass
     * the signal as a null result before ending. The completer collects these
     * null results until it has one per worker, and then terminates itself.
     *
     * tasks and results are ring arrays, one entry per worker
     */

    aktive_uint eof;

    // maker -> worker :: passing of tasks
    ringbuffer* task;

    // maker -> completer :: passing of ordering info
    ringbuffer  pickup;

    // worker -> maker :: passing of idle workers
    ringbuffer  worker_idle;

    // worker -> completer :: passing of results
    ringbuffer* result;

} s_coordinator;

#define CAP (c->base.capacity)

static void  release      (s_coordinator* c);
static void  gen_regular  (s_coordinator* c, void* task);
static void  gen_priority (s_coordinator* c, void* task);
static void  gen_complete (s_coordinator* c);
static void* get_task     (s_coordinator* c, aktive_uint id);
static void  set_result   (s_coordinator* c, aktive_uint id, void* result);
static void* get_result   (s_coordinator* c);

#define SM "state mismatch: "

#define CLEARA(var, capacity) memset (var, 0, capacity * sizeof (var[0]))
#define CLEARV(var)           memset (var, 0, sizeof (*var))

/*
 * - - -- --- ----- -------- -------------
 * API methods - constructors
 */

aktive_coordinator
aktive_coordinator_new_sequential (aktive_uint capacity)
{
    TRACE_FUNC ("((capacity) %d)", capacity);

    s_coordinator*     c  = ALLOC (s_coordinator);
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

    c->eof = 0;

    c->task          = NALLOC (ringbuffer, capacity);
    c->result        = NALLOC (ringbuffer, capacity);

    ring_init (c->pickup,      capacity);
    ring_init (c->worker_idle, capacity+2);

    // all result rings are empty
    { aktive_uint worker; for (worker = 0; worker < capacity; worker++) ring_init (c->result[worker], capacity); }

    // all task rings are empty, capacity 3
    { aktive_uint worker; for (worker = 0; worker < capacity; worker++) ring_init (c->task[worker], 3); }

    // all workers start out as idle
    { aktive_uint worker; for (worker = 0; worker < capacity; worker++) ring_put (c->worker_idle, worker); }

    TRACE_RETURN("((aktive_coordinator) %p)", ac);
}

/*
 * - - -- --- ----- -------- -------------
 * Method implementations
 *
 * -- The sequential coordinator ensures that the results are returned in the
 *    same order as the tasks are entered. this is done by a fifo from maker
 *    to completer, see `pickup`.
 *
 *    Various fields are arrays sized to the number of worker threads to
 *    control concurrency and backpressure.
 */

void
release (s_coordinator* c)
{
    TRACE_FUNC("((s_coordinator*) %p)", c);

    // preconditions
    ASSERT (c->pickup.isempty,      "coordinator has uncompleted tasks");
    ASSERT (c->worker_idle.isempty, "coordinator has idle workers");
    { aktive_uint worker ;						\
	for (worker = 0; worker < CAP; worker++)			\
	    ASSERT (c->task[worker].isempty,				\
		    "coordinator has leftover tasks"); }
    { aktive_uint worker ;						\
	for (worker = 0; worker < CAP; worker++)			\
	    ASSERT (c->result[worker].isempty,				\
		    "coordinator has leftover results"); }

    ring_release (c->worker_idle);
    ring_release (c->pickup);

    { aktive_uint worker ; for (worker = 0; worker < CAP; worker++) ring_release (c->task[worker]); }
    { aktive_uint worker ; for (worker = 0; worker < CAP; worker++) ring_release (c->result[worker]); }

    ckfree (c->task);
    ckfree (c->result);
    ckfree (c);

    TRACE_RETURN_VOID;
}

void
gen_regular (s_coordinator* c, void* task)
{
    TRACE_FUNC("((s_coordinator*) %p, (void*) %p)", c, task);

    ASSERT (!c->eof, "task after eof");

    aktive_uint worker;
    ring_take (c->worker_idle,   worker);
    ring_put  (c->pickup,        worker);
    ring_put  (c->task [worker], task);

    TRACE_RETURN_VOID;
}

void
gen_priority (s_coordinator* c, void* task)
{
    TRACE_FUNC("((s_coordinator*) %p, (task*) %p)", c, task);
    ASSERT (0, "sequential does not support priority tasking");
    TRACE_RETURN_VOID;
}

void
gen_complete (s_coordinator* c)
{
    TRACE_FUNC("((s_coordinator*) %p)", c);

    aktive_uint leftover = CAP;
    aktive_uint taken;

    ASSERT (!c->eof, "second eof after first");

    // send eof tasks to all idled workers. then wait for the remainder to
    // become idle and eof them as well

    TRACE ("EOF IDLE", 0);
    while (leftover > 0) {
	aktive_uint worker;

	ring_take_ifnotempty (c->worker_idle, worker, taken);
	if (!taken) break; // empty ... now can wait for busy remainder, if any

	TRACE ("EOF %d", worker);
	ring_put  (c->pickup,        worker);
	ring_put  (c->task [worker], NULL);

	leftover --;
    }

    TRACE ("EOF REMAINDER %d", leftover);
    while (leftover > 0) {
	aktive_uint worker;

	ring_take (c->worker_idle,   worker);
	TRACE ("EOF %d", worker);
	ring_put  (c->pickup,        worker);
	ring_put  (c->task [worker], NULL);

	leftover --;
    }

    TRACE_RETURN_VOID;
}

void*
get_task (s_coordinator* c, aktive_uint worker)
{
    TRACE_FUNC("((s_coordinator*) %p, (worker) %d)", c, worker);

    void* task = NULL;
    ring_take (c->task [worker], task);

    TRACE_RETURN (task ? "(task*) %p" : "(task*) %p (eof)", task);
}

void
set_result (s_coordinator* c, aktive_uint worker, void* result)
{
    TRACE_FUNC("((s_coordinator*) %p, (worker) %d, (result) %p)", c, worker, result);

    ring_put (c->result [worker], result);
    if (result) {
	ring_put (c->worker_idle, worker);
    }

    TRACE_RETURN_VOID;
}

void*
get_result (s_coordinator* c)
{
    TRACE_FUNC("((s_coordinator*) %p)", c);

    void* result;

    while (1) {
	aktive_uint worker;
	result = NULL;

	ring_take (c->pickup,          worker);
	ring_take (c->result [worker], result);

	if (result) break;

	TRACE ("CLOSED (%d)", worker);
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
