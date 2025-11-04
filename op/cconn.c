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

    A_FIELD (aktive_uint,      y)    ; // Row to generate.
    A_FIELD (aktive_cc_block*, a)    ; // Block to fuse. A.ymax+1 = B.ymin
    A_FIELD (aktive_cc_block*, b)    ; //   ditto
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
    //       O(1)   access, as add/remove has to touch only first/last row of a block
} A_END (aktive_cc_batch);

/*
 * - - -- --- ----- -------- -------------
 * Supporting static functions for various manipulations of the state and
 * CC data structures (block, row, cc, range).
 */

/* Creates and returns a new filled range structure (proto-CC, piece of CC).
 * Used during extension of a base block, when scanning an image row.
 */
static aktive_cc_range* cc_new_range (aktive_cc* owner, aktive_uint y, aktive_uint xmin, aktive_uint xmax)
{
    TRACE_FUNC("(aktive_cc*) %p, @%u/%u..%u", owner, y, xmin, xmax);

    aktive_cc_range* range = ALLOC (aktive_cc_range);

    range->y        = y;
    range->xmin     = xmin;
    range->xmax     = xmax;
    range->owner    = owner;
    range->row_next = 0;
    range->cc_next  = 0;

    TRACE_RETURN ("(aktive_cc_range*) %p", range);
}

/* Creates and returns a new filled CC structure (with associated single range).
 * Used during extension of a base block, when scanning an image row.
 */
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

    cc->xsum = (xmax == xmin)
	? xmax
	: (xmax*(xmax+1) - xmin*(xmin-1)) >> 1;
    // -- sum(xmin,xmax) = sum(0,xmax)-sum(0,xmin-1)
    // -- sum(0,n)       = n*(n+1)/2
    // -- sum(x,x)       = (x*(x+1) - (x-1)*x)/2 = (x*x+x-x*x+x)/2 = 2x/2 = x
    cc->ysum = y * cc->area;

    aktive_cc_range* range = cc_new_range (cc, y, xmin, xmax);

    cc->first = range;
    cc->last  = range;
    cc->next  = 0;
    cc->prev  = 0;

    TRACE_RETURN ("(aktive_cc*) %p", cc);
}

/* Creates and returns a new filled row structure.
 * Used during creation of a base block, when scanning an image row, for the row to be scanned.
 */
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

/* Creates and returns a new filled block structure for a single row.
 * Used to create the base block to be filled by scanning an image row.
 */
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

/* Unlinks a CC discarded by a merge from its block.
 */
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

/* Extend a base block with a new range and its CC.
 * Used during scanning of an image row to record a newly found range/CC.
 */
static void cc_extend_block (aktive_cc_block* block, aktive_uint xmin, aktive_uint xmax)
{
    TRACE_FUNC("(aktive_cc_block*) %p += %u..%u", block, xmin, xmax);

    // This assumes the modified block covers a single row, i.e. was returned
    // by `cc_new_block` and only modified by this function.

    // We add a new CC, consisting of a single range.
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

    // link the range of the cc into the block's single row.
    aktive_cc_range* range = cc->first;
    aktive_cc_row* row = block->row_last;

    if (row->last) {
	row->last->row_next = range;
    } else {
	row->first = range;
    }
    row->last = range;

    TRACE_RETURN_VOID;
}

/* Merge two CCs.
 * The second CC, B, is freed after adding itself to A.
 * where itself = (ranges, area, bounding box)
 */
static void cc_merge (aktive_cc* a, aktive_cc* b)
{
    TRACE_FUNC("(aktive_cc*) %p, %p", a, b);

    // for all ranges in B, change owner to A

    aktive_cc_range* range;
    for (range = b->first; range; range = range->cc_next) { range->owner = a; }

    // relink the ranges of B into A (append)
    // assumes that both A and B have at least one range.

    a->last->cc_next = b->first;
    a->last          = b->last;

    // merge bounding boxes, areas, and centroid data

    a->xmin = MIN (a->xmin, b->xmin);
    a->xmax = MAX (a->xmax, b->xmax);
    a->ymin = MIN (a->ymin, b->ymin);
    a->ymax = MAX (a->ymax, b->ymax);

    a->area += b->area;

    a->xsum += b->xsum;
    a->ysum += b->ysum;

    // release superfluous structure
    FREE (b);

    TRACE_RETURN_VOID;
}

/* Check if the two ranges A and B overlap enough in X to make their owning
 * CCs neighbours and thus the same.  Assumes that the ranges are in adjacent
 * rows. No check of this done.
 */
static int cc_neighbour_4 (aktive_cc_range* a, aktive_cc_range* b)
{
    TRACE_FUNC("(aktive_cc_range*) %p, %p", a, b);

    // The possible relative positions of the two ranges A and B under
    // consideration, and when they are neighbours. The two ranges are in
    // adjacent rows, where `A.row + 1 = B.row`.
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
    // N4k  | A   |---|               |   yes
    //      | B   |---|               |
    // %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%

    if (a->xmax < b->xmin) { TRACE_RETURN ("neighbour %d", 0); } // N4a
    if (a->xmin > b->xmax) { TRACE_RETURN ("neighbour %d", 0); } // N4b
    TRACE_RETURN ("neighbour %d", 1);                            // N4[c-k]
}

/* Phase 2 task: Fuse two blocks by iterating over the ranges in the adjacent
 * rows and merging all neighbouring CCs. The merged CCs of B are
 * discarded. All unmerged CCs of B are added to A. All row and ranges of B
 * are added to A.
 */
static void cc_fuse_blocks (aktive_cc_block* a, aktive_cc_block* b)
{
    TRACE_FUNC("(aktive_cc_block*) %p, %p, %% @%u..%u @%u..%u",
	       a, b, a->ymin, a->ymax, b->ymin, b->ymax);

    // a before b -- `a->row_last` adjacent to `b->row_first`.
    aktive_cc_range* ar = a->row_last->first;
    aktive_cc_range* br = b->row_first->first;

    while (ar && br) {
	if (cc_neighbour_4 (ar, br) && (ar->owner != br->owner)) {
	    cc_unlink (br->owner);
	    cc_merge  (ar->owner, br->owner);
	}

        // The possible relative positions of the two ranges A and B under
	// consideration, and how to step. Essentially neighbour 4 with a
	// different action table attached to it.
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
	// N4k  | A   |---|               | A
	//      | B   |---|               |
	// %%%%% %%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
	//
	// Step A :: A.xmax <= B.xmax
	// Step B :: else
	//
	// The step action skips over the range which has the smallest reach
	// into the future where more overlaps may be hidden with other range.
	//
	// In the case of N4k we expect that an N4b follows immediately,
	// causing us to step over B as well.

	if (ar->xmax <= br->xmax) {
	    /* N4[acegjk] Step A */ ar = ar->row_next;
	} else {
	    /* N4[bdfhi]  Step B */ br = br->row_next;
	}
    }

    // relink the remaining CCs of B, if any, into A

    if (b->cc_first) {
	// change owner of CCs to A
	aktive_cc* cc;
	for (cc = b->cc_first; cc; cc = cc->next) { cc->owner = a; }

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

/* Phase 1 task: Scan a single row of the input image and generate a basic
 * block for it, with a single, found ranges and trivial CCs.
 */
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
 * Batch processor hooks
 */

/* Issue a basic task (scanning an image row) per call. When all tasks are
 * issued wait for the eof from the completer and then issue a regular
 * shutdown to the controlling batch processor.
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

/* Execute the next task, either scanning the requested image row, or fusing
 * two blocks into a larger block.
 */
static aktive_cc_block*
cc_worker (const aktive_cc_batch* controller, aktive_cc_task* task, void** wstate)
{
    TRACE_FUNC("(aktive_cc_batch*) %p, (aktive_cc_task*) %p", controller, task);

    // EOF reached?
    if (!task) {
	TRACE ("no tasks", 0);
	// Note: Do not exclude possibility that EOF was reached without *wstate initialized.
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

    aktive_block*    p = aktive_region_fetch_area_head (*wstate, &rq);
    aktive_cc_block* a = cc_new_block (row);

    cc_scan (p, a);

    // .. and done
    TRACE_RETURN ("(aktive_cc_block*) %p", a);
}

/* Receive and act on worker results, blocks. Blocks adjacent to a previously
 * seen block trigger generation and injection of fuse requests. Standalone
 * blocks are recorded for adjacency checks against future results.
 *
 * Note that blocks put into a fuse request are removed from (or not even
 * entered into) the adjacency array. This prevents their use in other fuse
 * requests until they are properly processed.
 */
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

	// The next call of the completer will trigger the EOF branch of this
	// function, see above.
	TRACE_RETURN_VOID;
    }

    aktive_cc_task* fuse = 0;
    // Check if the incoming result is adjacent to an existing block below it.
    // If yes, then do not enter it and pull the other block out for fusion.

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

	    // and inject into the overall batch process
	    aktive_batch_inject (processor, fuse);
	    TRACE_RETURN_VOID;
	}
    }

    // Check if the incoming result is adjacent to an existing block above it.
    // If yes, then do not enter it and pull the other block out for fusion.

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

	    // and inject into the overall batch process
	    aktive_batch_inject (processor, fuse);
	    TRACE_RETURN_VOID;
	}
    }

    // The incoming result has no adjacent blocks yet. Record in the adjacency
    // array for pick up by future results

    TRACE ("save stand-alone", 0);

    controller->row [result->ymin] = result;
    controller->row [result->ymax] = result;

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 * Main API entry point, setting up and executing a batch processor for CC calculation.
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
 * Subordinate API entry points.
 */

#undef I
#undef K
#define I(x) Tcl_NewIntObj    ((x)) // OK tcl9
#define D(x) Tcl_NewDoubleObj ((x))
#define K(s) Tcl_NewStringObj((s), TCL_AUTO_LENGTH) /* TODO :: Use enum */ /* OK tcl9 */

/* Convert the block structure into a Tcl dictionary recording the same information.
 */
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
	// Assemble parts list (row ranges)
	//
	// NOTE: Running over rows, and then the ranges in rows provides proper
	//       order for collecting of a row subdict with list of ranges. It
	//       also roughly takes O(image). Enumerating ranges by CC on the
	//       other hand is more complex as it will have to track which
	//       rows already have ranges, to either initialize or extend the
	//       dict structures.
	//
	// SOLUTION: Defer any kind of ordering to Tcl level.
	//           Here just collect the ranges as unordered list.

	Tcl_Obj* parts = Tcl_NewListObj (0, 0); // OK tcl9
	aktive_cc_range* range;
	for (range = cc->first; range; range = range->cc_next) {
	    Tcl_Obj* v[3];
	    v[0] = I (range->y);
	    v[1] = I (range->xmin);
	    v[2] = I (range->xmax);
	    Tcl_Obj* part = Tcl_NewListObj (3, v); // OK tcl9
	    Tcl_ListObjAppendElement (ip, parts, part);
	}

	// Assemble bounding box
	Tcl_Obj* bv[4];
	bv[0] = I (cc->xmin);
	bv[1] = I (cc->ymin);
	bv[2] = I (cc->xmax);
	bv[3] = I (cc->ymax);
	Tcl_Obj* box = Tcl_NewListObj (4, bv); // OK tcl9

	// Assemble centroid
	double cx = (double) cc->xsum / (double) cc->area;
	double cy = (double) cc->ysum / (double) cc->area;
	Tcl_Obj* cv[2];
	cv[0] = D (cx);
	cv[1] = D (cy);
	Tcl_Obj* centroid = Tcl_NewListObj (2, cv); // OK tcl9

	// Assemble sub dictionary to hold the current CC
	Tcl_Obj* cco = Tcl_NewDictObj ();
	Tcl_DictObjPut (ip, cco, K ("area"),     I (cc->area));
	Tcl_DictObjPut (ip, cco, K ("box"),      box);
	Tcl_DictObjPut (ip, cco, K ("centroid"), centroid);
	Tcl_DictObjPut (ip, cco, K ("parts"),    parts);

	// Add new CC to overall result
	Tcl_DictObjPut (ip, r, I (n), cco);
    }

    TRACE_RETURN ("(Tcl_Obj*) %p", r);
}

/* Release a block structure.
 */
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

	// Enumerate and release the ranges
	aktive_cc_range* range;
	aktive_cc_range* rangenext;
	for (range = row->first; range ; range = rangenext) {
	    rangenext = range->row_next;
	    FREE (range);
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
