/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Queues, types and methods
 */

/*
 * - - -- --- ----- -------- -------------
 */

#include <tcl.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <queue.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_queue {
    Tcl_Mutex     lock;
    Tcl_Condition notfull;
    Tcl_Condition notempty;
    //
    aktive_uint   capacity; // number of entries in thing
    aktive_uint   used;     // number of used entries
    aktive_uint   write;    // index of slot to place next entry into
    aktive_uint   read;     // index of slot to get   next entry from
    aktive_uint   eof;	    // queue is EOF;
    aktive_uint   id;       // global id for next retrieved entry
    //
    void*         thing[0];
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

    TRACE ("filled %d/%d, eof %d", q->used, q->capacity, q->eof);

    void*       thing = 0;
    aktive_uint rid   = 0;

    while (!q->used && !q->eof) {
	TRACE ("queue empty, wait", 0);
	Tcl_ConditionWait (&q->notempty, &q->lock, NULL);
    }

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
