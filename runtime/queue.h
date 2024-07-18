/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Queues, types and methods
 *
 *  Queues are two-ended FIFOS. One end to place data in, the other to
 *  retrieve data from. They are used for communication between concurrent
 *  threads. All necessary synchronization and locking is done internally.
 *
 *  new . - Creates a queue of the given capacity. This many elements can be put
 *          into the queue before it becomes necessary to take elements out of it.
 *
 *  enter - Places an element into the queue Q. Returns when the element is
 *          successfully placed. __Waits__ for a place when the queue is full,
 *          i.e. waits for the internal `notfull` signal from `get`. Signals
 *          `notempty` itself.
 *
 *          The waiting for a place on a full queue Q automatically throttles
 *          the producer thread(s) filling Q.
 *
 *  get . - Takes an element from the queue. Returns when the element is
 *          successfully taken. __Waits__ for an element when the queue is
 *          empty, i.e. waits for the internal `notempty` signal from
 *          `enter`. Signals `notfull` itself.
 *
 *          The waiting for an element on an empty queue Q automatically
 *          throttles the consumer thread(s) emptying Q.
 *
 *  eof . - Tells consumers that the queue will receive no more elements when
 *          it runs empty. Consumers will see this condition only after the
 *          last actual element is taken. The condition is reported as a NULL
 *          element returned from `get`. Signals `notempty` to unlock
 *          consumers possibly already waiting on more elements.
 *
 */
#ifndef AKTIVE_QUEUE_H
#define AKTIVE_QUEUE_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <base.h>

typedef struct aktive_queue *aktive_queue;

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_queue aktive_queue_new           (aktive_uint capacity);
extern void         aktive_queue_eof           (aktive_queue q);
extern void         aktive_queue_enter         (aktive_queue q, void* thing);
extern void         aktive_queue_enter_priority (aktive_queue q, void* thing);
extern void*        aktive_queue_get           (aktive_queue q, aktive_uint* id);
extern void         aktive_queue_free          (aktive_queue q);

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
#endif /* AKTIVE_QUEUE_H */
