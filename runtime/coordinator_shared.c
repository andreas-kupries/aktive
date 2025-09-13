/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Coordinator API dispatch
 */

/*
 * - - -- --- ----- -------- -------------
 */

#include <tclpre9compat.h>
//#include <critcl_alloc.h>
//#include <critcl_assert.h>
//#include <critcl_trace.h>

#include <coordinator_int.h>

//TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 * API methods - method dispatch through the function table
 */

void  aktive_coordinator_release      (aktive_coordinator c)                       { c->release      (c);             }
void  aktive_coordinator_gen_regular  (aktive_coordinator c, void* task)           { c->gen_regular  (c, task);       }
void  aktive_coordinator_gen_priority (aktive_coordinator c, void* task)           { c->gen_priority (c, task);       }
void  aktive_coordinator_gen_complete (aktive_coordinator c)                       { c->gen_complete (c);             }
void* aktive_coordinator_get_task     (aktive_coordinator c, int id)               { c->get_task     (c, id);         }
void  aktive_coordinator_set_result   (aktive_coordinator c, int id, void* result) { c->set_result   (c, id, result); }
void* aktive_coordinator_get_result   (aktive_coordinator c)                       { c->get_result   (c);             }

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
