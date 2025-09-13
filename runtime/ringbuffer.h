/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Ringbuffer queue
 *
 * A ring buffer is a particular kind of fifo with a limited number of
 * entries The version here is implemented with macros,
 * i.e. header-only, for embedding into larger structures, and further
 * limited to (void*) entries, and things which can be cast into and
 * from (void*). The capacity is set from the outside, and passed to
 * operations where needed.
 *
 * Operations:
 * - init
 * - release
 * - put
 * - take
 * - isempty
 * - isfull
 */
#ifndef AKTIVE_RINGBUFFER_H
#define AKTIVE_RINGBUFFER_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <base.h>

#define ACQUIRE(var) Tcl_MutexLock     (&(var))
#define RELEASE(var) Tcl_MutexUnlock   (&(var))
#define FINISHD(var) Tcl_MutexFinalize (&(var))

typedef struct aktive_ringbuffer {
    Tcl_Mutex     serial;    // serialize access to structure
    Tcl_Condition notfull;   // publisher/consumer signaling
    Tcl_Condition notempty;  //

    aktive_uint   capacity;  // buffer capacity
    aktive_uint   put;       // index where to place the next value into
    aktive_uint   get;       // index where to take the next value from
    aktive_uint   isempty;   // flag, true when empty
    aktive_uint   isfull;    // flag, true then full
    TRACE_RUN ( aktive_uint   count );    // number of filled entries
    void**        buffer;    // array of entries

  // `put == get` describes an ambigous state. the buffer may be full,
  // or empty, depending on how the state was reached. if the
  // operation was a `put` it is full. if the last operation was a
  // `get` it is empty.
} ringbuffer;

/*
 * - - -- --- ----- -------- -------------
 */

#define ring_init(bufvar, cap) {				\
	TRACE ("ring %s (%d) setup", #bufvar, capacity);	\
	memset (&(bufvar), 0, sizeof (bufvar));			\
	bufvar.capacity = (cap);				\
	bufvar.put      = 0;					\
	bufvar.get      = 0;					\
	TRACE_RUN ( bufvar.count   = 0 );			\
	bufvar.isempty  = 1;					\
	bufvar.isfull   = 0;					\
	bufvar.buffer   = NALLOC (void*, cap);			\
    }
// serial, notfull, notempty undef

#define ring_release(bufvar) {				\
	FINISHD(bufvar.serial);				\
	Tcl_ConditionFinalize (&(bufvar.notfull));	\
	Tcl_ConditionFinalize (&(bufvar.notempty));	\
	ckfree (bufvar.buffer);				\
	TRACE ("ring %s release", #bufvar);		\
    }

#define ring_put(bufvar, value) {				\
	ACQUIRE (bufvar.serial);				\
	while (bufvar.isfull) {					\
	    TRACE ("WAIT %s NOTFULL", #bufvar);			\
	    Tcl_ConditionWait (&(bufvar.notfull),		\
			       &(bufvar.serial), NULL);		\
	    TRACE ("RECV %s NOTFULL", #bufvar);			\
	}							\
	bufvar.buffer[bufvar.put] = (void*) (value);		\
	TRACE ("ring %s (%d) put[%d] (%p) #%d", #bufvar,	\
	       bufvar.capacity,					\
	       bufvar.put, bufvar.buffer[bufvar.put],		\
	       bufvar.count+1);					\
	bufvar.put = (bufvar.put + 1) % bufvar.capacity;	\
	if (bufvar.put == bufvar.get) bufvar.isfull = 1;	\
	bufvar.isempty = 0;					\
	TRACE_RUN (bufvar.count ++);				\
	TRACE ("SEND %s NOT EMPTY", #bufvar);			\
	Tcl_ConditionNotify (&(bufvar.notempty));		\
	RELEASE (bufvar.serial);				\
    }

#define ring_take(bufvar, valvar) {				\
	ACQUIRE (bufvar.serial);				\
	while (bufvar.isempty) {				\
	    TRACE ("WAIT %s NOTEMPTY", #bufvar);		\
	    Tcl_ConditionWait (&(bufvar.notempty),		\
			       &(bufvar.serial), NULL);		\
	    TRACE ("RECV %s NOTEMPTY", #bufvar);		\
	}							\
	valvar = (typeof(valvar)) bufvar.buffer[bufvar.get];	\
	TRACE ("ring %s (%d) take[%d] (%p) #%d", #bufvar,	\
	       bufvar.capacity,					\
	       bufvar.get, bufvar.buffer[bufvar.get],		\
	       bufvar.count-1);					\
	bufvar.get = (bufvar.get + 1) % (bufvar.capacity);	\
	if (bufvar.put == bufvar.get) bufvar.isempty = 1;	\
	bufvar.isfull = 0;					\
	TRACE_RUN (bufvar.count --);				\
	TRACE ("SEND %s NOT FULL", #bufvar);			\
	Tcl_ConditionNotify (&(bufvar.notfull));		\
	RELEASE (bufvar.serial);				\
    }

#define ring_take_ifnotempty(bufvar, valvar, condvar) {			\
	ACQUIRE (bufvar.serial);					\
	if (bufvar.isempty) {						\
	    condvar = 0;						\
	} else {							\
	    condvar = 1;						\
	    valvar = (typeof(valvar)) bufvar.buffer[bufvar.get];	\
	    TRACE ("ring %s (%d) take[%d] (%p) #%d", #bufvar,		\
		   bufvar.capacity,					\
		   bufvar.get, bufvar.buffer[bufvar.get],		\
		   bufvar.count-1);					\
	    bufvar.get = (bufvar.get + 1) % (bufvar.capacity);		\
	    if (bufvar.put == bufvar.get) bufvar.isempty = 1;		\
	    bufvar.isfull = 0;						\
	    TRACE_RUN (bufvar.count --);				\
	    TRACE ("SEND %s NOT FULL", #bufvar);			\
	    Tcl_ConditionNotify (&(bufvar.notfull));			\
	}								\
	RELEASE (bufvar.serial);					\
    }

/* ****************************************************
#define ring_peek(bufvar, bufvar.capacity, valvar) {				\
    ASSERT_VA (!bufvar.isempty, "buffer is empty", "%d == 0", bufvar.count); \
    valvar = bufvar.buffer[bufvar.get];					\
    TRACE ("ring %s (%d) peek[%d] (%d)", #bufvar, bufvar.capacity, bufvar.get, valvar); \
  }

#define ring_used(bufvar)    (bufvar.count)
#define ring_isempty(bufvar) (bufvar.isempty)
#define ring_isfull(bufvar)  (bufvar.isfull)

#define ring_has_entries(bufvar) (!ring_isempty (bufvar))
#define ring_has_space(bufvar)   (!ring_isfull (bufvar))
******************************************************** */

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_RINGBUFFER_H */
