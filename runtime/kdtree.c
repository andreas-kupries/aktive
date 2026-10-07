/*
 * = = == === ===== ======== ============= =====================
 * Structures and methods to encapsulate 2D KD-Tree spatial indices
 *
 * Ref:
 *  - https://rosettacode.org/wiki/K-d_tree#C
 *  - https://cs.colby.edu/courses/S18/cs251/moore-KDTrees-1991.pdf
 *    "An intoductory tutorial on kd-trees",
 *     Andrew W. Moore, Carnegie Mellon University, 1991
 */

#include <kdtree.h>
#include <critcl_trace.h>
#include <critcl_assert.h>
#include <critcl_alloc.h>
#include <math.h>

TRACE_OFF;

/*
 * = = == === ===== ======== ============= =====================
 * Structures
 *
 * - Tree node with pivot and lesser/greater branches
 * - Tree itself, wrapping the root node
 * - Visitation counter for benchmarking
 */

typedef struct kdnode {
    aktive_fpoint  pivot; // 2D point used to split the plane
    struct kdnode* left;  // before the pivot
    struct kdnode* right; // after the pivot

    // Note: The dimension a node is split on is implied in the depth of the
    // node and tracked both during creation and search. Splitting starts with
    // X, flips to Y, back to X, etc.
} *kdnode;

typedef struct aktive_kdtree {
    kdnode root; // tree root
} *aktive_kdtree;

// for benchmarking, count of nodes visited by last find operation
static aktive_uint visited = 0;

#define FP(fpoint_ptr) (((double*) fpoint_ptr)[dim])

#define SPLITX 0

/*
 * = = == === ===== ======== ============= =====================
 * internal support
 */

// `swap` exchanges the contents of the referenced 2D fpoints
static inline void
swap (aktive_fpoint* a, aktive_fpoint* b)
{
    aktive_fpoint tmp = *a; *a = *b; *b = tmp;
}

// `quick_select_median` uses a recursive quick select algorithm to find the
// median of the points between `start` and `end` (assumed to be in the same
// array of fpoints) along the given `dim`ension (0 -> x, 1 -> y). This
// modifies array by swapping points as needed.
static aktive_fpoint*
quick_select_median (aktive_fpoint* start,
		     aktive_fpoint* end,
		     aktive_uint dim)
{
    TRACE_FUNC ("((node*) %p [%d] (node*) %p @%s)", start, end-start, end, dim ? "y" : "x");

    // dim :: index of dimension to compare on

    if (end <= start)     { TRACE_RETURN ("(node*) %p", NULL); }
    if (end == start + 1) { TRACE_RETURN ("(node*) %p", start); }

    aktive_fpoint* p;
    aktive_fpoint* store;
    aktive_fpoint* mid = start + (end - start) / 2;
    double         pivot;

    while (1) {
	pivot = FP (mid);
	swap (mid, end-1);
	for (store = p = start; p < end; p++) {
	    if (FP (p) < pivot) {
		if (p != store)	swap (p, store);
		store ++;
	    }
	}
	swap (store, end-1);
	// scan over duplicates of the median
	if (FP (store) == FP (mid)) { TRACE_RETURN ("(node*) %p", mid); }
	// tail-recurse deeper
	if (store > mid) { end = store; } else { start = store; }
    }

    TRACE_RETURN ("should not be reached (node*) %p", NULL);
}

// `make_node` creates a KD-tree from the array of `len` fpoints in `v`, and
// returns the root node of that tree. The returned node is split at the given
// `dim`ension (0 -> x, 1 -> y).
static kdnode
make_node (aktive_fpoint* v,
	   aktive_uint    len,
	   aktive_uint    dim)
{
    TRACE_FUNC ("([%d]fpoint %p @%s)", len, v, dim ? "y" : "x");

    // quick stop if there is nothing to process
    if (!len) { TRACE_RETURN ("none (node*) %p", NULL); }

    kdnode root = ALLOC (struct kdnode);
    root->left  = NULL;
    root->right = NULL;

    // quick stop for trivial case
    if (len == 1) {
	root->pivot = *v;
	TRACE_RETURN ("single (node*) %p", root);
    }

    aktive_fpoint* median = quick_select_median (v, v + len, dim);
    if (median) {
	root->pivot = *median;
	root->left  = make_node (v,          median - v,         1-dim);
	root->right = make_node (median + 1, (v+len)-(median+1), 1-dim);
    }

    TRACE_RETURN ("general (node*) %p", root);
}

// `release_node` releases the given node and its children, if any.
static void
release_node (kdnode n)
{
    TRACE_FUNC ("((kdnode*) %p)", n);

    if (n->left)  release_node (n->left);
    if (n->right) release_node (n->right);
    FREE (n);

    TRACE_RETURN_VOID;
}

// `nearest` searches the KD-tree starting at `root` for the point which has
// the minimal distance to the `target`, and stores it in `best`. The
// associated squared minimal distance is stored in `bestd`. It assumes that
// `root` is split at the given `dim`ension (0 -> x, 1 -> y). As part of its
// operation it increments the counter for the number of tree nodes visited.
static void
nearest (kdnode          root,
	 aktive_fpoint*  target,
	 aktive_uint     dim,
	 //*********************************
	 aktive_fpoint*  best,
	 double*         bestd)
{
    TRACE_FUNC ("((node*) %p, (fpoint*) %p, %s, (fpoint**) %p, (double*) %p)",
		root, target, dim ? "y" : "x", best, bestd);

    if (!root) TRACE_RETURN_VOID;

    double dx      = root->pivot.x - target->x;
    double dy      = root->pivot.y - target->y;
    double d       = dx*dx + dy*dy;
    double delta   = FP (&root->pivot) - FP (target);
    double dsquare = delta * delta;

    visited ++;

    // chose current if better than anything else so far
    if (d < *bestd) {
        *best  = root->pivot;
        *bestd = d;
    }

    // we can stop immediately if an exact match is found
    if (d == 0) TRACE_RETURN_VOID;

    // also stop immediately if there are no children to traverse at all
    if (!root->left && !root->right) TRACE_RETURN_VOID;

    // recurse into near branch of the structure
    nearest (delta > 0
	    ? root->left
	    : root->right,
	    //*********************************
	    target, 1-dim, best, bestd);

    // do not check far branch if it cannot be better
    if (dsquare > *bestd) TRACE_RETURN_VOID;

    // check far branch of the structure as well, still possible to find a
    // better match
    nearest (delta > 0
	    ? root->right
	    : root->left,
	    //*********************************
	    target, 1-dim, best, bestd);

    TRACE_RETURN_VOID;
}

// `range` searches the KD-tree starting at `root` for all points within
// distance `radius` of the target and collects them in the result array
// `found`.  It assumes that `root` is split at the given `dim`ension (0 -> x,
// 1 -> y). As part of its operation it increments the counter for the number
// of tree nodes visited.
//
// BEWARE: The array `found` has to be large enough to contain all possible
// results, i.e. capable of holding all nodes in the tree, or more.
static void
range (kdnode          root,
       aktive_fpoint*  target,
       double          radius,
       aktive_uint     dim,
       //*********************************
       aktive_uint*    c,
       aktive_fpoint*  found)
{
    TRACE_FUNC ("((node*) %p, (fpoint*) %p, %s, (uint*) %p, (fpoint*) %p)",
		root, target, dim ? "y" : "x", c, found);

    if (!root) TRACE_RETURN_VOID;

    // This is implemented by a modified nearest neighbour search. The
    // modifications are that (i) the initial distance is not reduced as
    // closer points are discovered and (ii) all discovered points within the
    // distance are returned, not just the nearest.

    double dx      = root->pivot.x - target->x;
    double dy      = root->pivot.y - target->y;
    double d       = dx*dx + dy*dy;
    double delta   = FP (&root->pivot) - FP (target);
    double dsquare = delta * delta;

    visited ++;

    if (d < radius*radius) {
	found [*c] = root->pivot;
	(*c)++;
    }

    // recurse into near branch of the structure
    range (delta > 0
	   ? root->left
	   : root->right,
	   target, radius, 1-dim,
	   //*********************************
	   c, found);

    // do not check the far branch if it cannot be in the queried circle
    if (dsquare >= radius) TRACE_RETURN_VOID;

    // check far branch of the structure as well, still possible to find
    // matches
    range (delta > 0
	   ? root->right
	   : root->left,
	   target, radius, 1-dim,
	   //*********************************
	   c, found);

    TRACE_RETURN_VOID;
}

/*
 * = = == === ===== ======== ============= =====================
 * API
 *
 * - Create a KD-tree from an array of fpoints.
 * - Destroy a KD-tree
 * - Find the points nearest to target in a KD-tree
 * - Find the points within a specific distance of the target in tree
 * - Return the current value of the visitation counter
 */

extern aktive_kdtree
aktive_kdtree_setup (aktive_uint c, aktive_fpoint* v)
{
    TRACE_FUNC ("()", 0);

    aktive_kdtree kd = ALLOC (struct aktive_kdtree);
    kd->root = make_node (v, c, SPLITX);

    TRACE_RETURN ("(kdtree) %p", kd);
}

extern void
aktive_kdtree_release (aktive_kdtree kd)
{
    TRACE_FUNC ("((kdtree) %p)", kd);

    if (kd->root) release_node (kd->root);
    FREE (kd);

    TRACE_RETURN_VOID;
}

extern void
aktive_kdtree_find_nearest (aktive_kdtree  kd,
			    aktive_fpoint* target,
			    aktive_fpoint* best,
			    double*        distance)
{
    TRACE_FUNC ("((kdtree) %p)", kd);

    visited   = 0;
    *distance = INFINITY;
    best->x   = 0;
    best->y   = 0;

    nearest (kd->root, target, SPLITX, /* -> */ best, distance);

    TRACE_RETURN_VOID;
}

extern void
aktive_kdtree_find_in_range (aktive_kdtree  kd,
			     aktive_fpoint* target,
			     double         radius,
			     aktive_uint*   c,
			     aktive_fpoint* found)
{
    TRACE_FUNC ("((kdtree) %p)", kd);

    visited = 0;
    *c      = 0;

    range (kd->root, target, radius, SPLITX, /* -> */ c, found);

    TRACE_RETURN_VOID;
}

/*
 * benchmarking support - how many nodes were visited by the last find operation
 */
extern aktive_uint
aktive_kdtree_visit_count (void)
{
    TRACE_FUNC ("", 0);
    TRACE_RETURN ("%d", visited);
}

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
