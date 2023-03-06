/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Batch processing
 *
 * Batch processors handle a task by spawning a number of threads operating
 * concurrently on independent parts of the whole.
 *
 * A batch processor is specified through 3 functions
 *
 *  - A task generator. It produces the tasks to preform and places them into a queue.
 *  - A worker. Workers dequeue tasks from their queue, generate a result, and queue them.
 *  - A task completer. It dequeues results from their queue and integrates them into the
 *    final result.
 *
 * Each batch processor runs a single generator, several workers and a single
 * completer. All execute concurrently. The run ends when the completer has
 * seen and handled the last task made by the generator.
 *
 * Note: In __sequential__ mode the batch processor ensures that the completer
 *       sees worker results in the same order as the associated tasks were
 *       created in. It internally delays results created early, i.e. out of
 *       order, as needed.
 *
 *       When sequential is not asked for the completer sees the results in
 *       arbitrary order, as the workers generate them.
 *
 * A batch processor returns when all its tasks have been done and completed.
 */
#ifndef AKTIVE_BATCH_H
#define AKTIVE_BATCH_H

/*
 * - - -- --- ----- -------- -------------
 *
 * - create   :: return one task per call, until all tasks are created
 *            :: return NULL when there are no tasks anymore.
 * - work     :: Take and process task, return a result
 * - complete :: Take and process result
 *
 * All have access to the user-specified state. Create and complete can work
 * concurrently without locking if they modify different parts of that
 * state. If they access the same fields they have to lock. Work has only
 * read-only access.
 */

typedef void* (*aktive_batch_make)     (      void* state);
typedef void* (*aktive_batch_work)     (const void* state, void* task, void** wstate);
typedef void  (*aktive_batch_complete) (      void* state, void* result);

/*
 * - - -- --- ----- -------- -------------
 */

extern void aktive_batch_run ( const  char*          name
	   		     , aktive_batch_make     maker
	   		     , aktive_batch_work     worker
	   		     , aktive_batch_complete completer
			     , aktive_uint           sequential
	   		     , void*                 state);

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
#endif /* AKTIVE_BATCH_H */
