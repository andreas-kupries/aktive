/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Internal coordinator declarations and definitions
 */

/*
 * - - -- --- ----- -------- -------------
 */

#include <tclpre9compat.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

#include <coordinator.h>
#include <ringbuffer.h>
#include <micros.h>

/*
 * - - -- --- ----- -------- -------------
 * API and internal types
 */

typedef void  (*f_release)      (aktive_coordinator c);
typedef void  (*f_gen_regular)  (aktive_coordinator c, void* task);
typedef void  (*f_gen_priority) (aktive_coordinator c, void* task);
typedef void  (*f_gen_complete) (aktive_coordinator c);
typedef void* (*f_get_task)     (aktive_coordinator c, aktive_uint id);
typedef void  (*f_set_result)   (aktive_coordinator c, aktive_uint id, void* result);
typedef void* (*f_get_result)   (aktive_coordinator c);

typedef struct aktive_coordinator {
    // type information, name and function vectors
    const char*     name;         // coordinator kind
    f_release       release;      // vector: destructor
    f_gen_regular   gen_regular;  // vector: add regular task
    f_gen_priority  gen_priority; // vector: add priority task
    f_gen_complete  gen_complete; // vector: signal end of generation
    f_get_task      get_task;     // vector: get task for worker
    f_set_result    set_result;   // vector: set worker result
    f_get_result    get_result;   // vector: get result for completion
    // common state
    aktive_uint     capacity;     // number of workers to manage
    //                            // --> size of various state arrays
    aktive_uint     active;       // number of workers still active
} coordinator;

#define HOLD(c) Tcl_MutexLock     (&((aktive_coordinator) c)->serial)
#define DONE(c) Tcl_MutexUnlock   (&((aktive_coordinator) c)->serial)
#define FINI(c) Tcl_MutexFinalize (&((aktive_coordinator) c)->serial)

/*
 * - - -- --- ----- -------- -------------
 * Concurrency patterns
 *
 * A number of the interactions between two sides A and below can be captured by
 * a common pattern I am calling `ensure`/`ensured`, `EE` in short.
 *
 *   1. State variables
 *
 *        a. any `data`, possible multiple,
 *        b. boolean `flag`,
 *        c. condition `signal`
 *
 *   2. Behaviour
 *
 *        a. `while bad-state-of(data) do set flag; await signal ; end; ... data ...`
 *
 *           In words, `A` continues without waiting when it sees the `data` in a
 *           good state. Otherwise it uses the `flag` to indicate that it is
 *           waiting, and then waits on the `signal` before continuing. The loop is
 *           needed because simply receiving the `signal` does not prevent other
 *           threads from interfering and setting the `data` back into a bad state
 *           before `A` got cpu again.
 *
 *        b. `... data ... ; if flag then reset flag ; send signal ; end`
 *
 *           In words, `B` does something with the `data` ensuring a good state,
 *           and then sends the `signal`, if `A` indicated through `flag` to be
 *           waiting for it.  If `A` is not waiting then the `signal` is not needed
 *           and not sent.
 */

/*
 * - - -- --- ----- -------- -------------
 */

#define SEND(signal) { TRACE ("SEND %s", #signal); Tcl_ConditionNotify (&(c->signal)); }
#define WAIT(signal) { TRACE ("WAIT %s", #signal); Tcl_ConditionWait   (&(c->signal), &c->base.serial, NULL); TRACE ("RECV %s", #signal); }
#define DELE(signal) Tcl_ConditionFinalize (&(c->signal))
#define DELV(signal) { aktive_uint i; for (i = 0; i < CAP; i++) { DELE (signal[i]); } }

#define ENSURE(good, flag, signal)  while (!(good)) { c->flag = 1 ; WAIT (signal); }
#define ENSURED(flag, signal)       if (c->flag)    { c->flag = 0 ; SEND (signal); }

#define SENDI(signal, i) { TRACE ("SEND %s[%d]", #signal, i); Tcl_ConditionNotify (&(c->signal[i])); }
#define WAITI(signal, i) { TRACE ("WAIT %s[%d]", #signal, i); Tcl_ConditionWait   (&(c->signal[i]), &c->base.serial, NULL); TRACE ("RECV %s[%d]", #signal, i); }

#define ENSUREI(good, flag, signal, i)  while (!(good)) { c->flag = 1 ; WAITI (signal, i); }
#define ENSUREDI(flag, signal, i)       if (c->flag)    { c->flag = 0 ; SENDI (signal, i); }

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
