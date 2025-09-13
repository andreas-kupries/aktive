/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Coordinators
 *
 * A coordinator manages the interaction and communication between the
 * threads of a batch processor, i.e. maker, completer, and workers.
 *
 * Two different coordinators are made available, for unordered and sequential
 * task completion.
 *
 * Beyond the constructors and destructor each coordinator provides seven
 * operations.
 *
 * - make_task		- maker API, adds a regular task
 * - make_priority_task - maker API, adds a priority task
 * - make_complete	- maker API, signals end of task set
 *
 * - work_handle	- worker API, retrieves task to perform, as a handle
 * - work_task		- worker API, query a handle for the embedded task
 * - work_result	- worker API, publish a result, through a handle
 *
 * - complete_result	- completer API, retrieve a result
 *
 * Coordinators and handles exist only as opaque types, with the internals
 * managing the actual behaviour hidden from users.
 */
#ifndef AKTIVE_COORDINATOR_H
#define AKTIVE_COORDINATOR_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <base.h>

typedef struct aktive_coordinator *aktive_coordinator; // coordinator handle
typedef struct aktive_work        *aktive_work;        //

/*
 * - - -- --- ----- -------- -------------
 * lifecycle
 */

extern aktive_coordinator aktive_coordinator_new_unordered  (aktive_uint capacity);
extern aktive_coordinator aktive_coordinator_new_sequential (aktive_uint capacity);
extern void               aktive_coordinator_release        (aktive_coordinator c);

/*
 * - - -- --- ----- -------- -------------
 * task generation
 */

extern void aktive_coordinator_gen_regular  (aktive_coordinator c, void* task);
extern void aktive_coordinator_gen_priority (aktive_coordinator c, void* task);
extern void aktive_coordinator_gen_complete (aktive_coordinator c);

/*
 * - - -- --- ----- -------- -------------
 * task access and result entry
 */

extern void* aktive_coordinator_get_task   (aktive_coordinator c, int id);
extern void  aktive_coordinator_set_result (aktive_coordinator c, int id, void* result);

/*
 * - - -- --- ----- -------- -------------
 * result access
 */

extern void* aktive_coordinator_get_result (aktive_coordinator c);

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
#endif /* AKTIVE_COORDINATOR_H */
