/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Query/modify processor count
 */
#ifndef AKTIVE_NPROC_H
#define AKTIVE_NPROC_H

/*
 * - - -- --- ----- -------- -------------
 */

#include <base.h>

/*
 * - - -- --- ----- -------- -------------
 * Effect of setting the processor count on querying the same
 *
 * |n   |query behaviour                           |
 * |---:|---                                       |
 * | 0  |return actual CPU count                   |
 * |>0  |return `n`                                |
 * |<0  |return 0, concurrent execution is disabled|
 *
 * Note: It is possible to set an `n` greather than the actual CPU core count.
 * This will overcommit the CPU.
 */

extern aktive_uint aktive_processors     (void);
extern void        aktive_set_processors (int n);

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
#endif /* AKTIVE_NPROC_H */
