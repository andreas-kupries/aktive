/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Queues, types and methods
 */

/*
 * - - -- --- ----- -------- -------------
 */

#include <tclpre9compat.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <queue.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_queue_prio {
    void*                     thing; // priority entry
    struct aktive_queue_prio* next;  // next entry in stack
} aktive_queue_prio;

typedef struct aktive_queue {
    Tcl_Mutex     lock;      // access exclusion
    Tcl_Condition notfull;   // publisher/consumer signaling
    Tcl_Condition notempty;  //
    //
    aktive_uint   id;        // global id for next retrieved entry
    //
    aktive_queue_prio* prio; // stack of priority entries
    aktive_uint        phas; // number of priority entries
    //
    aktive_uint   capacity;  // number of entries in the fifo
    aktive_uint   used;      // number of used entries
    aktive_uint   write;     // index of slot to write next entry into
    aktive_uint   read;      // index of slot to read  next entry from
    aktive_uint   eof;	     // flag: queue is EOF;
    //
    void*         thing[0];  // fifo ring buffer
} aq;

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_queue
aktive_queue_new (aktive_uint capacity)
{
    TRACE_FUNC ("((capacity) %d)", capacity);

    aktive_queue q = (aktive_queue) NALLOC(char,sizeof(aq)+capacity*sizeof(void*));
    memset (q, 0, sizeof(aq)+capacity*sizeof(void*));
    q->capacity = capacity;

    TRACE_RETURN ("(queue*) %p", q);
}

extern void
aktive_queue_free (aktive_queue q)
{
    TRACE_FUNC ("((queue*) %p)", q);

    Tcl_ConditionFinalize (&q->notfull);
    Tcl_ConditionFinalize (&q->notempty);
    Tcl_MutexFinalize     (&q->lock);
    ckfree (q);

    TRACE_RETURN_VOID;
}

extern void
aktive_queue_eof (aktive_queue q)
{
    TRACE_FUNC ("((queue*) %p)", q);

    Tcl_MutexLock (&q->lock);

    q->eof = 1;
    Tcl_ConditionNotify (&q->notempty);

    Tcl_MutexUnlock (&q->lock);

    TRACE_RETURN_VOID;
}

extern void
aktive_queue_enter (aktive_queue q, void* thing)
{
    TRACE_FUNC ("((queue*) %p, (void*) %p)", q, thing);

    Tcl_MutexLock (&q->lock);

    TRACE ("filled %d/%d", q->used, q->capacity);
    while (q->used == q->capacity) {
	TRACE ("queue full, wait", 0);
	Tcl_ConditionWait (&q->notfull, &q->lock, NULL);
    }
    TRACE ("queue writable", 0);

    ASSERT (q->write < q->capacity, "queue outside write");

    q->thing [q->write] = thing;
    q->write = (q->write + 1) % q->capacity;
    q->used ++;

    TRACE ("(queue*) %p = filled %d/%d eof %d prio %d",
	   q, q->used, q->capacity, q->eof, q->phas);
    TRACE ("queue signal not empty", 0);
    Tcl_ConditionNotify (&q->notempty);
    Tcl_MutexUnlock (&q->lock);

    TRACE_RETURN_VOID;
}

extern void
aktive_queue_enter_priority (aktive_queue q, void* thing)
{
    TRACE_FUNC ("((queue*) %p, (void*) %p)", q, thing);

    Tcl_MutexLock (&q->lock);

    // Priority entries have no limit.

    aktive_queue_prio* entry = ALLOC (aktive_queue_prio);

    entry->thing = thing;
    entry->next  = q->prio;

    q->prio = entry;
    q->phas ++;

    TRACE ("(queue*) %p = filled %d/%d eof %d prio %d",
	   q, q->used, q->capacity, q->eof, q->phas);
    TRACE ("queue signal not empty", 0);
    Tcl_ConditionNotify (&q->notempty);
    Tcl_MutexUnlock (&q->lock);

    TRACE_RETURN_VOID;
}

extern void*
aktive_queue_get (aktive_queue q, aktive_uint* id)
{
    TRACE_FUNC ("((queue*) %p, (int*) %p)", q, id);

    Tcl_MutexLock (&q->lock);

    void*       thing = 0;
    aktive_uint rid   = 0;

    TRACE ("(queue*) %p = filled %d/%d, eof %d prio %d",
	   q, q->used, q->capacity, q->eof, q->phas);

    // Look for and return priority entries first.
    if (q->prio) {
    prio:
	TRACE ("priority", 0);

	thing = q->prio->thing;
	rid   = q->id;
	q->id ++;

	aktive_queue_prio* next  = q->prio->next;
	FREE (q->prio);
	q->prio = next;
	q->phas --;

	// We cannot signal notfull here, as the signal has only bearing for
	// regular queue entries in the ring buffer.

	goto done;
    }

    while (!q->used && !q->eof && !q->prio) {
	TRACE ("queue empty, wait", 0);
	Tcl_ConditionWait (&q->notempty, &q->lock, NULL);
    }

    if (q->prio) goto prio; // check priority again first

    if (!q->used && q->eof) goto done;

    TRACE ("queue readable", 0);

    ASSERT (q->read < q->capacity, "queue outside read");

    thing = q->thing [q->read];
    rid   = q->id;

    q->thing [q->read] = 0;
    q->read = (q->read + 1) % q->capacity;
    q->used --;
    q->id ++;

    TRACE ("queue signal not full", 0);
    Tcl_ConditionNotify (&q->notfull);

 done:
    Tcl_MutexUnlock (&q->lock);

    TRACE ("id = %d", rid);
    *id = rid;
    TRACE_RETURN ("(void*) %p", thing);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
