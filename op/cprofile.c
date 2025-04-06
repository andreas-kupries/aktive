/* -*- c -*-
 *
 * -- Direct operator support - Column profiles
 */

#include <rt.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>
#include <cprofile.h>
#include <batch.h>
#include <amath.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 * State structures for the column profile batch processor. The result of the
 * processing will be a single `block` covering all rows of the image and
 * holding the profile of the entire image.
 */

A_STRUCTURE(aktive_cprofile_task) {
    // a == 0 --> row task (generate base profile for single row `y`)
    // else   --> fuse task

    A_FIELD (aktive_uint,      y)    ; // Row to generate.
    A_FIELD (aktive_cprofile*, a)    ; // Block to fuse. A.ymax+1 = B.ymin
    A_FIELD (aktive_cprofile*, b)    ; //   ditto
} A_END (aktive_cprofile_task);

A_STRUCTURE(aktive_cprofile_batch) {
    // maker
    A_FIELD (aktive_uint,       count);  // Count of rows to generate tasks for.

    // maker/completer comms - eof is determined by completer, not maker
    A_FIELD (aktive_uint,       stop);  // eof flag
    A_FIELD (Tcl_Mutex,         lock);  // gen/complete exclusion
    A_FIELD (Tcl_Condition,     eof);   // gen/complete signaling

    // worker
    A_FIELD (aktive_image,     src)  ; // image to process
    A_FIELD (aktive_rectangle, rq)   ; // requested area (row == '0' fixed, ignore)
    A_FIELD (aktive_uint,      wd)   ; // request width * depth  = profile size [values]
    A_FIELD (double,           mark) ; // result end marker for empty column (differs by direction)

    // completer
    A_FIELD (aktive_cprofile**, row);    // Adjacency array, #rows elements
    A_FIELD (aktive_uint,       maxrow); // Highest row index

    // Note: O(row) memory
    //       O(1)   access, as add/remove has to touch only first/last row of a block
} A_END (aktive_cprofile_batch);

/*
 * - - -- --- ----- -------- -------------
 * Supporting static functions for various manipulations of the state and
 * cprofile data structures.
 */

/* Creates and returns a new filled  cprofile structure for a single row.
 * Used to create the base cprofile to be filled by scanning an image row.
 * values = width * depth
 */
static aktive_cprofile* cprofile_new (aktive_uint y, aktive_uint values)
{
    TRACE_FUNC("@%u", y);

    aktive_cprofile* cprofile = ALLOC (aktive_cprofile);
    memset (cprofile, 0, sizeof (aktive_cprofile));

    cprofile->ymin      = y;
    cprofile->ymax      = y;
    cprofile->n         = values;
    cprofile->profile   = NALLOC (double, values);

    TRACE_RETURN ("(aktive_cprofile*) %p", cprofile);
}

/* Phase 2 task: Fuse two cprofiles
 */
static void cprofile_fuse (aktive_cprofile* a, aktive_cprofile* b, double mark)
{
    TRACE_FUNC("(aktive_cprofile*) %p, %p, %% @%u..%u @%u..%u %% %f",
	       a, b, a->ymin, a->ymax, b->ymin, b->ymax, mark);

    TRACE_HEADER(1); TRACE_ADD ("[%d,%d] partA profile = {", a->ymin, a->ymax);
    for (int j = 0; j <= a->n; j++) { TRACE_ADD (" %d", (int) a->profile[j]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    TRACE_HEADER(1); TRACE_ADD ("[%d,%d] partB profile = {", b->ymin, b->ymax);
    for (int j = 0; j <= b->n; j++) { TRACE_ADD (" %d", (int) b->profile[j]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    if (mark < 0) {
	// bottom profile, max it
	for (aktive_uint k = 0; k < a->n; k++) {
	    a->profile[k] = MAX (a->profile[k], b->profile[k]);
	}
    } else {
	// top profile, min it
	for (aktive_uint k = 0; k < a->n; k++) {
	    a->profile[k] = MIN (a->profile[k], b->profile[k]);
	}
    }

    a->ymax = b->ymax;

    TRACE_HEADER(1); TRACE_ADD ("[%d,%d] partF profile = {", a->ymin, a->ymax);
    for (int j = 0; j <= a->n; j++) { TRACE_ADD (" %d", (int) a->profile[j]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    aktive_cprofile_release (b);

    TRACE_RETURN_VOID;
}

/* Phase 1 task: Scan a single row of the input image and generate a basic
 * cprofile for it.
 */
static void cprofile_scan (aktive_block* p, aktive_cprofile* a, double mark)
{
    TRACE_FUNC("(aktive_block*) %p [%d], (aktive_cprofile*) %p [%d]", p, p->used, a, a->n);

    // block is a single row
    double* values = p->pixel;
    aktive_uint nv = p->used;

    ASSERT (a->n == nv, "profile/values width mismatch");

    TRACE_HEADER(1); TRACE_ADD ("[%d] pixels = {", a->ymin);
    for (int j = 0; j <= nv; j++) { TRACE_ADD (" %f", values[j]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    for (aktive_uint i = 0; i < nv; i++) {
	a->profile[i] = (values[i] != 0) ? a->ymin : mark;
    }

    TRACE_HEADER(1); TRACE_ADD ("[%d] partX profile = {", a->ymin);
    for (int j = 0; j <= a->n; j++) { TRACE_ADD (" %d", (int) a->profile[j]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;


    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 * Batch processor hooks
 */

/* Issue a basic task (scanning an image row) per call. When all tasks are
 * issued wait for the eof from the completer and then issue a regular
 * shutdown to the controlling batch processor.
 */
static aktive_cprofile_task*
cprofile_maker (aktive_cprofile_batch* controller)
{
    TRACE_FUNC("(aktive_cprofile_batch*) %p", controller);

    /* Two sources of tasks.
     * - Self generated, one per image row.
     * - Profile fuse requests - Directly injected by completer.
     */

    // No base tasks to generate anymore?
    if (!controller->count) {
	TRACE ("waiting for eof from completer", 0);

	// wait for completer to signal eof
	Tcl_MutexLock (&controller->lock);
	while (!controller->stop) {
	    Tcl_ConditionWait (&controller->eof, &controller->lock, NULL);
	}
	Tcl_MutexUnlock (&controller->lock);
	TRACE_RETURN ("(eof) (aktive_cprofile_task*) %p", 0);
    }

    // generate and return the next base task
    aktive_cprofile_task* task = ALLOC (aktive_cprofile_task);

    controller->count --;
    task->y    = controller->count;
    task->a    = 0;
    task->b    = 0;

    TRACE_RETURN ("(aktive_cprofile_task*) %p", task);
}

/* Execute the next task, either scanning the requested image row, or fusing
 * two blocks into a larger block.
 */
static aktive_cprofile*
cprofile_worker (const aktive_cprofile_batch* controller, aktive_cprofile_task* task, void** wstate)
{
    TRACE_FUNC("(aktive_cprofile_batch*) %p, (aktive_cprofile_task*) %p", controller, task);

    // EOF reached?
    if (!task) {
	TRACE ("no tasks", 0);
	// Note: Do not exclude possibility that EOF was reached without *wstate initialized.
	if (*wstate) {
	    aktive_context c = aktive_region_context (*wstate);
	    aktive_region_destroy (*wstate);
	    aktive_context_destroy (c);
	}
	TRACE_RETURN ("(eof) (aktive_cprofile*) %p", 0);
    }

    // Fuse request ?
    if (task->a && task->b) {
	TRACE ("fuse task (%s)", (controller->mark < 0) ? "bottom" : "top");

	// import task parameters and release memory
	aktive_cprofile* a = task->a;
	aktive_cprofile* b = task->b;
	FREE (task);

	cprofile_fuse (a, b, controller->mark);
	// b is released
	TRACE_RETURN ("(aktive_cprofile*) %p", a);
    }

    // Row generator request -- Base data creation

    // import task parameters and release memory
    aktive_uint row = task->y;
    FREE (task);

    // fetch (partial) row to scan for profile, then scan
    if (! *wstate) {
	aktive_context c = aktive_context_new ();
	*wstate = aktive_region_new (controller->src, c);
    }

    aktive_rectangle_def_as (rq, &controller->rq);
    rq.y = row;

    TRACE ("scan task (%s)", (controller->mark < 0) ? "bottom" : "top");

    aktive_block*    p = aktive_region_fetch_area (*wstate, &rq);
    aktive_cprofile* a = cprofile_new (row, controller->wd);

    cprofile_scan (p, a, controller->mark);

    // .. and done
    TRACE_RETURN ("(aktive_cprofile*) %p", a);
}

/* Receive and act on worker results, cprofiles. Cprofiles adjacent to a previously
 * seen cprofile trigger generation and injection of fuse requests. Standalone
 * cprofiles are recorded for adjacency checks against future results.
 *
 * Note that cprofiles put into a fuse request are removed from (or not even
 * entered into) the adjacency array. This prevents their use in other fuse
 * requests until they are properly processed.
 */
static void
cprofile_completer (aktive_batch processor, aktive_cprofile_batch* controller, aktive_cprofile* result)
{
    TRACE_FUNC("(aktive_batch*) %p, (aktive_cprofile_batch*) %p, (aktive_cprofile*) %p",
	       processor, controller, result);

    // EOF - nothing to do
    if (!result) {
	TRACE_RETURN_VOID;
    }

    aktive_uint ymin = result->ymin;
    aktive_uint ymax = result->ymax;

    TRACE ("cprofile covering %u...%u", ymin, ymax);

    // Received a cprofile covering the entire image ?
    // If yes, we are essentially done, except for a clean shutdown.
    if (ymin == 0 && ymax == controller->maxrow) {
	// remember for caller
	controller->row [0] = result;
	TRACE ("signaling eof to maker", 0);
	// signal EOF to maker
	Tcl_MutexLock (&controller->lock);
	controller->stop = 1;
	Tcl_MutexUnlock (&controller->lock);
	Tcl_ConditionNotify (&controller->eof);

	// The next call of the completer will trigger the EOF branch of this
	// function, see above.
	TRACE_RETURN_VOID;
    }

    aktive_cprofile_task* fuse = 0;
    // Check if the incoming result is adjacent to an existing cprofile below it.
    // If yes, then do not enter it and pull the other cprofile out for fusion.

    if (result->ymin > 0) {
	aktive_uint down = result->ymin - 1;
	if (controller->row[down]) {
	    // fetch und unlink neighbouring cprofile

	    aktive_cprofile* neighbor = controller->row[down];
	    controller->row [neighbor->ymin] = 0;
	    controller->row [neighbor->ymax] = 0; // ASSERT: ymax == down

	    TRACE ("fuse (P) %u..%u (C) %u..%u", neighbor->ymin, neighbor->ymax, ymin, ymax);

	    // create fusion request

	    fuse = ALLOC (aktive_cprofile_task);
	    fuse->y = 0;
	    fuse->a = neighbor;
	    fuse->b = result; // result after neighbor

	    // and inject into the overall batch process
	    aktive_batch_inject (processor, fuse);
	    TRACE_RETURN_VOID;
	}
    }

    // Check if the incoming result is adjacent to an existing cprofile above it.
    // If yes, then do not enter it and pull the other cprofile out for fusion.

    if (result->ymax < controller->maxrow) {
	aktive_uint up = result->ymax + 1;
	if (controller->row[up]) {
	    // fetch und unlink neighbouring cprofile

	    aktive_cprofile* neighbor = controller->row[up];
	    controller->row [neighbor->ymin] = 0; // ASSERT: ymin == up
	    controller->row [neighbor->ymax] = 0;

	    TRACE ("fuse (C) %u..%u (N) %u..%u", ymin, ymax, neighbor->ymin, neighbor->ymax);

	    // create fusion request

	    fuse = ALLOC (aktive_cprofile_task);
	    fuse->y = 0;
	    fuse->a = result; // result before neighbor
	    fuse->b = neighbor;

	    // and inject into the overall batch process
	    aktive_batch_inject (processor, fuse);
	    TRACE_RETURN_VOID;
	}
    }

    // The incoming result has no adjacent cprofiles yet. Record in the adjacency
    // array for pick up by future results

    TRACE ("save stand-alone", 0);

    controller->row [result->ymin] = result;
    controller->row [result->ymax] = result;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 * Main API entry point, setting up and executing a batch processor for column
 * profile calculation.
 */

extern aktive_cprofile*
aktive_cprofile_find (aktive_image src, aktive_uint bottom, aktive_rectangle* rq)
{
    TRACE_FUNC("(aktive_image) %p", src);

    aktive_cprofile_batch* controller = ALLOC (aktive_cprofile_batch);
    memset (controller, 0, sizeof(aktive_cprofile_batch));

    controller->count  = aktive_image_get_height (src);
    controller->stop   = 0;
    controller->src    = src;
    controller->rq     = *rq;
    controller->wd     = rq->width * aktive_image_get_depth  (src);
    controller->mark   = bottom ? -1.0 : aktive_image_get_height (src);
    controller->row    = NALLOC        (aktive_cprofile*, controller->count);
    memset (controller->row, 0, sizeof (aktive_cprofile*)* controller->count);
    controller->maxrow = controller->count - 1;

    aktive_batch_run ("column profile",
		      (aktive_batch_make)     cprofile_maker,
		      (aktive_batch_work)     cprofile_worker,
		      (aktive_batch_complete) cprofile_completer,
		      0, controller);

    aktive_cprofile* result = controller->row[0];

    Tcl_ConditionFinalize (&controller->eof);
    Tcl_MutexFinalize     (&controller->lock);
    FREE (controller->row);
    FREE (controller);

    TRACE_HEADER(1); TRACE_ADD ("profile = {", 0);
    for (int j = 0; j <= result->n; j++) { TRACE_ADD (" %d", (int) result->profile[j]); }
    TRACE_ADD(" }", 0); TRACE_CLOSER;

    TRACE_RETURN ("(aktive_cprofile*) %p", result);
}

/*
 * - - -- --- ----- -------- -------------
 * Subordinate API entry points.
 */

/* Release a cprofile structure.
 */
extern void
aktive_cprofile_release (aktive_cprofile* cprofile)
{
    TRACE_FUNC("(aktive_cprofile*) %p", cprofile);

    FREE (cprofile->profile);
    FREE (cprofile);

    TRACE_RETURN_VOID;
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
