/* -*- c -*-
 *
 * -- Direct operator support - Connected components
 */

#include <rt.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>
#include <cconn.h>
#include <batch.h>
#include <amath.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 * State structures for the CC batch processor.  The result of the processing
 * will be a single `block` covering all rows of the image and holding the CCs
 * of that image.
 */

A_STRUCTURE(aktive_cc_task) {
    // a == 0 --> row task
    // else   --> fuse task

    A_FIELD (aktive_uint,            y)    ; // Row to generate.
    A_FIELD (aktive_cc_block*,       a)    ; // Block to fuse. A.ymax+1 = B.ymin
    A_FIELD (aktive_cc_block*,       b)    ; //   ditto
} A_END (aktive_cc_task);

A_STRUCTURE(aktive_cc_batch) {
    // maker
    A_FIELD (aktive_uint,       count);  // Count of rows to generate tasks for.

    // maker/completer comms - eof is determined by completer, not maker
    A_FIELD (aktive_uint,       stop);  // eof flag
    A_FIELD (Tcl_Mutex,         lock);  // gen/complete exclusion
    A_FIELD (Tcl_Condition,     eof);   // gen/complete signaling

    // worker
    A_FIELD (aktive_image, src) ; // image to process
    A_FIELD (aktive_uint,  w)   ; // image width = row size

    // completer
    A_FIELD (aktive_cc_block**, row);    // Adjacency array, #rows elements
    A_FIELD (aktive_uint,       maxrow); // Highest row index

    // Note: O(row) memory
    //       O(1)   add/remove have to touch only first/last row of a block
} A_END (aktive_cc_batch);

/*
 * - - -- --- ----- -------- -------------
 * Supporting static functions for various manipulations of the state and
 * CC data structures (block, row, cc, run).
 */

static aktive_cc_run* cc_new_run (aktive_cc* owner, aktive_uint y, aktive_uint xmin, aktive_uint xmax)
{
    TRACE_FUNC("(aktive_cc*) %p, @%u/%u..%u", owner, y, xmin, xmax);

    aktive_cc_run* run = ALLOC (aktive_cc_run);

    run->y        = y;
    run->xmin     = xmin;
    run->xmax     = xmax;
    run->owner    = owner;
    run->row_next = 0;
    run->cc_next  = 0;

    TRACE_RETURN ("(aktive_cc_run*) %p", run);
}

static aktive_cc* cc_new (aktive_uint y, aktive_uint xmin, aktive_uint xmax)
{
    TRACE_FUNC("@%u/%u..%u", y, xmin, xmax);

    aktive_cc* cc = ALLOC (aktive_cc);
    memset (cc, 0, sizeof (aktive_cc));
    cc->ymin = y;
    cc->ymax = y;
    cc->xmin = xmin;
    cc->xmax = xmax;
    cc->area = xmax - xmin + 1;

    aktive_cc_run* run = cc_new_run (cc, y, xmin, xmax);

    cc->first = run;
    cc->last  = run;
    cc->next  = 0;
    cc->prev  = 0;

    TRACE_RETURN ("(aktive_cc*) %p", cc);
}

static aktive_cc_row* cc_new_row (aktive_uint y)
{
    TRACE_FUNC("@%u", y);

    aktive_cc_row* row = ALLOC (aktive_cc_row);
    row->y     = y;
    row->first = 0;
    row->last  = 0;
    row->next  = 0;

    TRACE_RETURN ("(aktive_cc_row*) %p", row);
}

static aktive_cc_block* cc_new_block (aktive_uint y)
{
    TRACE_FUNC("@%u", y);

    aktive_cc_block* block = ALLOC (aktive_cc_block);
    memset (block, 0, sizeof (aktive_cc_block));

    block->ymin      = y;
    block->ymax      = y;

    aktive_cc_row*   row = cc_new_row (y);
    block->row_first = row;
    block->row_last  = row;

    TRACE_RETURN ("(aktive_cc_block*) %p", block);
}

static void cc_unlink (aktive_cc* cc)
{
    TRACE_FUNC("(aktive_cc*) %p", cc);

    aktive_cc_block* block = cc->owner;

    // CC is the last remaining in the block
    if (block->cc_first == cc && block->cc_last == cc) {
	block->cc_first = 0;
	block->cc_last  = 0;
	TRACE_RETURN_VOID;
    }

    // CC is at head of block's CC list
    if (block->cc_first == cc) {
	cc->next->prev = 0;
	block->cc_first = cc->next;
	TRACE_RETURN_VOID;
    }

    // CC is at end of block's CC list
    if (block->cc_last == cc) {
	cc->prev->next = 0;
	block->cc_last = cc->prev;
	TRACE_RETURN_VOID;
    }

    // CC is in the middle of the list
    cc->prev->next = cc->next;
    cc->next->prev = cc->prev;

    TRACE_RETURN_VOID;
}

static void cc_extend_block (aktive_cc_block* block, aktive_uint xmin, aktive_uint xmax)
{
    TRACE_FUNC("(aktive_cc_block*) %p += %u..%u", block, xmin, xmax);

    // This assumes the modified block covers a single row, i.e. was returned
    // by `cc_new_block` and only modified by this function.

    // We add a new CC, consisting of a single run.
    aktive_cc* cc = cc_new (block->ymin, xmin, xmax);

    // link cc into the block
    cc->owner = block;

    if (block->cc_last) {
	cc->prev = block->cc_last;
	block->cc_last->next = cc;
    } else {
	// cc prev, next = 0, already
	block->cc_first = cc;
    }
    block->cc_last = cc;

    // link the run of the cc into the block's single row.
    aktive_cc_run* run = cc->first;
    aktive_cc_row* row = block->row_last;

    if (row->last) {
	row->last->row_next = run;
    } else {
	row->first = run;
    }
    row->last = run;

    TRACE_RETURN_VOID;
}

static void cc_merge (aktive_cc* a, aktive_cc* b)
{
    TRACE_FUNC("(aktive_cc*) %p, %p", a, b);

    // for all runs in B, change owner to A

    aktive_cc_run* run = b->first;
    while (run) { run->owner = a; run = run->cc_next; }

    // relink the runs of B into A (append)
    // assumes that both A and B have at least one run.

    a->last->cc_next = b->first;
    a->last          = b->last;

    // merge bounding boxes and areas

    a->xmin = MIN (a->xmin, b->xmin);
    a->xmax = MAX (a->xmax, b->xmax);
    a->ymin = MIN (a->ymin, b->ymin);
    a->ymax = MAX (a->ymax, b->ymax);
    a->area += b->area;

    // release superfluous structure
    FREE (b);

    TRACE_RETURN_VOID;
}

static int cc_neighbour_4 (aktive_cc_run* a, aktive_cc_run* b)
{
    TRACE_FUNC("(aktive_cc_run*) %p, %p", a, b);

    // The possible relative positions of the two runs A, B under consideration,
    // and when they are neighbours. The two runs are in adjacent rows, where
    // A.row + 1 = B.row
    //
    // case |                         | neighbours
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    // N4a  | A |---|                 | no
    //      | B        |---|          |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    // N4b  | A        |---|          | no
    //      | B |---|                 |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    // N4c  | A |---|                 |   yes
    //      | B     |---|             |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    // N4d  | A     |---|             |   yes
    //      | B |---|                 |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    // N4e  | A |-------|             |   yes
    //      | B     |---|             |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    // N4f  | A |-------|             |   yes
    //      | B |---|                 |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    // N4g  | A |---|                 |   yes
    //      | B   |---|               |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    // N4h  | A   |---|               |   yes
    //      | B |---|                 |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    // N4i  | A |-------|             |   yes
    //      | B   |---|               |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    // N4j  | A   |---|               |   yes
    //      | B |-------|             |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%

    if (a->xmax < b->xmin) { TRACE_RETURN ("neighbour %d", 0); } // N4a
    if (a->xmin > b->xmax) { TRACE_RETURN ("neighbour %d", 0); } // N4b
    TRACE_RETURN ("neighbour %d", 1);                            // N4[c-j]
}

static void cc_fuse_blocks (aktive_cc_block* a, aktive_cc_block* b)
{
    TRACE_FUNC("(aktive_cc_block*) %p, %p, %% @%u..%u @%u..%u",
	       a, b, a->ymin, a->ymax, b->ymin, b->ymax);

    // a before b -- `a->row_last` adjacent to `b->row_first`.
    aktive_cc_run* ar = a->row_last->first;
    aktive_cc_run* br = b->row_first->first;

    while (ar && br) {
	if (cc_neighbour_4 (ar, br) && (ar->owner != br->owner)) {
	    cc_unlink (br->owner);
	    cc_merge  (ar->owner, br->owner);
	}

        // The possible relative positions of the two runs A, B under consideration,
	// and how to step. Essentially neighbour 4, with a different action table
	// attached to it.
	//
	// case |                         | step
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	// N4a  | A |---|                 | A
	//      | B        |---|          |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	// N4b  | A        |---|          |  B
	//      | B |---|                 |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	// N4c  | A |---|                 | A
	//      | B     |---|             |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	// N4d  | A     |---|             |  B
	//      | B |---|                 |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	// N4e  | A |-------|             | A
	//      | B     |---|             |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	// N4f  | A |-------|             |  B
	//      | B |---|                 |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	// N4g  | A |---|                 | A
	//      | B   |---|               |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	// N4h  | A   |---|               |  B
	//      | B |---|                 |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	// N4i  | A |-------|             |  B
	//      | B   |---|               |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	// N4j  | A   |---|               | A
	//      | B |-------|             |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	//
	// Step A :: A.xmax <= B.xmax
	// Step B :: else
	//
	// The step action skips over the run which has the smallest reach
	// into the future where more overlaps may be hidden with other run.

	if (ar->xmax <= br->xmax) {
	    /* N4[acegj] Step A */ ar = ar->row_next;
	} else {
	    /* N4[bdfhi] Step B */ br = br->row_next;
	}
    }

    // relink the remaining CCs of B, if any, into A

    if (b->cc_first) {
	aktive_cc* cc = b->cc_first;
	while (cc) { cc->owner = a; cc = cc->next; }

	if (a->cc_first) {
	    // Append B's CC to A's

	    a->cc_last->next  = b->cc_first;
	    b->cc_first->prev = a->cc_last;
	    a->cc_last        = b->cc_last;
	} else {
	    // A has no CCs, just take B.

	    a->cc_first = b->cc_first;
	    a->cc_last  = b->cc_last;
	}
    } // else: just keep A

    // relink the rows of B into A (append, keeps proper order, ascending y)
    // assumes that both A and B have at least one CC.

    a->row_last->next = b->row_first;
    a->row_last       = b->row_last;
    a->ymax           = b->ymax;

    FREE (b);

    TRACE_RETURN_VOID;
}

static void cc_scan (aktive_block* p, aktive_cc_block* a)
{
    TRACE_FUNC("(aktive_block*) %p, (aktive_cc_block*) %p", p, a);

    // block is a single row
    double* values = p->pixel;
    aktive_uint nv = p->used;

    // scan state
    aktive_uint incomponent = 0; // mode flag
    aktive_uint start;           // range of current component
    aktive_uint end;
    aktive_uint i;

    for (i = 0; i < nv; i++) {
	if (values [i] > 0) {
	    // foreground, collect component
	    if (!incomponent) { incomponent = 1; start = i; }
	    // still in current component
	    end = i;
	} else {
	    // background, end collected component, if any.
	    if (incomponent) { incomponent = 0; cc_extend_block (a, start, end); }
	}
    }

    // handle last component, it reached the end of the row
    if (incomponent) { cc_extend_block (a, start, end); }

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_cc_task*
cc_maker (aktive_cc_batch* controller)
{
    TRACE_FUNC("(aktive_cc_batch*) %p", controller);

    /* Two sources of tasks.
     * - Self generated, one per image row.
     * - Block fuse requests - Directly injected by completer.
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
	TRACE_RETURN ("(eof) (aktive_cc_task*) %p", 0);
    }

    // generate and return the next base task
    aktive_cc_task* task = ALLOC (aktive_cc_task);

    controller->count --;
    task->y    = controller->count;
    task->a    = 0;
    task->b    = 0;

    TRACE_RETURN ("(aktive_cc_task*) %p", task);
}

static aktive_cc_block*
cc_worker (const aktive_cc_batch* controller, aktive_cc_task* task, void** wstate)
{
    TRACE_FUNC("(aktive_cc_batch*) %p, (aktive_cc_task*) %p", controller, task);

    // EOF
    if (!task) {
	TRACE ("no tasks", 0);
	// Do not exclude possibility that EOF is reached without *wstate initialized
	if (*wstate) {
	    aktive_context c = aktive_region_context (*wstate);
	    aktive_region_destroy (*wstate);
	    aktive_context_destroy (c);
	}
	TRACE_RETURN ("(eof) (aktive_cc_block*) %p", 0);
    }

    // Fuse request ?
    if (task->a && task->b) {
	TRACE ("fuse task", 0);

	// import task parameters and release memory
	aktive_cc_block* a = task->a;
	aktive_cc_block* b = task->b;
	FREE (task);

	cc_fuse_blocks (a, b);
	TRACE_RETURN ("(aktive_cc_block*) %p", a);
    }

    // Row generator request -- Base data creation

    // import task parameters and release memory
    aktive_uint row = task->y;
    FREE (task);

    // fetch row to scan for components, then scan
    if (! *wstate) {
	aktive_context c = aktive_context_new ();
	*wstate = aktive_region_new (controller->src, c);
    }
    aktive_rectangle_def (rq, 0, row, controller->w, 1);

    aktive_block*    p = aktive_region_fetch_area (*wstate, &rq);
    aktive_cc_block* a = cc_new_block (row);

    cc_scan (p, a);

    // .. and done
    TRACE_RETURN ("(aktive_cc_block*) %p", a);
}

static void
cc_completer (aktive_batch processor, aktive_cc_batch* controller, aktive_cc_block* result)
{
    TRACE_FUNC("(aktive_batch*) %p, (aktive_cc_batch*) %p, (aktive_cc_block*) %p",
	       processor, controller, result);

    // EOF - nothing to do
    if (!result) {
	TRACE_RETURN_VOID;
    }

    aktive_uint ymin = result->ymin;
    aktive_uint ymax = result->ymax;

    TRACE ("block covering %u...%u", ymin, ymax);

    // Received a block covering the entire image ?
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

	TRACE_RETURN_VOID;
    }

    aktive_cc_task* fuse = 0;
    // Check if the incoming result is adjacent to an existing block below it.
    // Do not enter it, pull the other block out for fusion.

    if (result->ymin > 0) {
	aktive_uint down = result->ymin - 1;
	if (controller->row[down]) {
	    // fetch und unlink neighbouring block

	    aktive_cc_block* x = controller->row[down];
	    controller->row [x->ymin] = 0;
	    controller->row [x->ymax] = 0; // ASSERT: ymax == down

	    TRACE ("fuse (P) %u..%u (C) %u..%u", x->ymin, x->ymax, ymin, ymax);

	    // create fusion request

	    fuse = ALLOC (aktive_cc_task);
	    fuse->y = 0;
	    fuse->a = x;
	    fuse->b = result; // result after x

	    // and pass to maker for injection into the overall batch process
	    aktive_batch_inject (processor, fuse);
	    TRACE_RETURN_VOID;
	}
    }

    // Check if the incoming result is adjacent to an existing block above it.
    // Do not enter it, pull the other block out for fusion.

    if (result->ymax < controller->maxrow) {
	aktive_uint up = result->ymax + 1;
	if (controller->row[up]) {
	    // fetch und unlink neighbouring block

	    aktive_cc_block* x = controller->row[up];
	    controller->row [x->ymin] = 0; // ASSERT: ymin == up
	    controller->row [x->ymax] = 0;

	    TRACE ("fuse (C) %u..%u (N) %u..%u", ymin, ymax, x->ymin, x->ymax);

	    // create fusion request

	    fuse = ALLOC (aktive_cc_task);
	    fuse->y = 0;
	    fuse->a = result; // result before x
	    fuse->b = x;

	    // and pass to maker for injection into the overall batch process
	    aktive_batch_inject (processor, fuse);
	    TRACE_RETURN_VOID;
	}
    }

    // The incoming result has no adjacent blocks (yet)
    // Enter into the adjacency array for pick up by future results

    TRACE ("save stand-alone", 0);

    controller->row [result->ymin] = result;
    controller->row [result->ymax] = result;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_cc_block*
aktive_cc_find (aktive_image src)
{
    TRACE_FUNC("(aktive_image) %p", src);

    aktive_cc_batch* controller = ALLOC (aktive_cc_batch);
    memset (controller, 0, sizeof(aktive_cc_batch));

    controller->count  = aktive_image_get_height (src);
    controller->stop   = 0;
    controller->src    = src;
    controller->w      = aktive_image_get_width (src);
    controller->row    = NALLOC        (aktive_cc_block*, controller->count);
    memset (controller->row, 0, sizeof (aktive_cc_block*)* controller->count);
    controller->maxrow = controller->count - 1;

    aktive_batch_run ("connected-components",
		      (aktive_batch_make)     cc_maker,
		      (aktive_batch_work)     cc_worker,
		      (aktive_batch_complete) cc_completer,
		      0, controller);

    aktive_cc_block* result = controller->row[0];

    Tcl_ConditionFinalize (&controller->eof);
    Tcl_MutexFinalize     (&controller->lock);
    FREE (controller->row);
    FREE (controller);

    TRACE_RETURN ("(aktive_cc_block*) %p", result);
}

/*
 * - - -- --- ----- -------- -------------
 */

#undef I
#undef K
#define I(x) Tcl_NewIntObj ((x)) // OK tcl9
#define K(s) Tcl_NewStringObj((s), TCL_AUTO_LENGTH) /* TODO :: Use enum */ /* OK tcl9 */

extern Tcl_Obj*
aktive_cc_as_tcl_dict (Tcl_Interp* ip, aktive_cc_block* block)
{
    TRACE_FUNC("(aktive_cc_block*) %p", block);

    Tcl_Obj* r = Tcl_NewDictObj ();

    // r = dict (<int> -> "xmin"  -> int
    //                 -> "xmax"  -> int
    //                 -> "ymin"  -> int
    //                 -> "ymax"  -> int
    //                 -> "area"  -> int
    //                 -> "parts" -> list (list(y xmin xmax)...)
    //          )

    // Enumerate the CCs
    aktive_cc* cc;
    aktive_uint n; // Start at 1, 0 is reserved for non-component background
    for (n = 1, cc = block->cc_first; cc ; n++, cc = cc->next) {
	// Sub dict to hold the current CC
	Tcl_Obj* cco = Tcl_NewDictObj ();
	Tcl_DictObjPut (ip, r, I (n), cco);

	// Fill the CC dict (bounding box and area)
	Tcl_DictObjPut (ip, cco, K ("xmin"), I (cc->xmin));
	Tcl_DictObjPut (ip, cco, K ("xmax"), I (cc->xmax));
	Tcl_DictObjPut (ip, cco, K ("ymin"), I (cc->ymin));
	Tcl_DictObjPut (ip, cco, K ("ymax"), I (cc->ymax));
	Tcl_DictObjPut (ip, cco, K ("area"), I (cc->area));

	// Fill CC dict (rows and runs)
	//
	// Notes: Running over rows, and then the runs in rows provides proper
	// order for collecting of a row subdict with list of runs. It also
	// roughly takes O(image). Enumerating runs by CC on the other hand is
	// more complex as it will have to track which rows already have runs,
	// to either initialize or extend the dict structures.
	//
	// Chosen: defer any kind of row ordering to Tcl level. Here just
	// collect the runs as unordered list.

	Tcl_Obj* parts = Tcl_NewListObj (0, 0); // OK tcl9
	Tcl_DictObjPut (ip, cco, K ("parts"), parts);

	aktive_cc_run* run;
	for (run = cc->first; run; run = run->cc_next) {
	    Tcl_Obj* v[3];
	    v[0] = I (run->y);
	    v[1] = I (run->xmin);
	    v[2] = I (run->xmax);
	    Tcl_Obj* part = Tcl_NewListObj (3, v); // OK tcl9
	    Tcl_ListObjAppendElement (ip, parts, part);
	}
    }

    TRACE_RETURN ("(Tcl_Obj*) %p", r);
}

extern void
aktive_cc_release_block (aktive_cc_block* block)
{
    TRACE_FUNC("(aktive_cc_block*) %p", block);

    // Enumerate and release the CCs
    aktive_cc* cc;
    aktive_cc* ccnext;
    for (cc = block->cc_first; cc ; cc = ccnext) {
	ccnext = cc->next;
	FREE (cc);
    }

    // Enumerate and release the rows.
    aktive_cc_row* row;
    aktive_cc_row* rownext;
    for (row = block->row_first; row ; row = rownext) {
	rownext = row->next;

	// Enumerate and release the runs
	aktive_cc_run* run;
	aktive_cc_run* runnext;
	for (run = row->first; run ; run = runnext) {
	    runnext = run->row_next;
	    FREE (run);
	}
	FREE (row);
    }

    FREE (block);

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
