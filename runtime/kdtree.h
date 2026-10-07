#ifndef AKTIVE_KDTREE_H
#define AKTIVE_KDTREE_H

#include <math.h>
#include <geometry.h>	/* aktive_fpoint */

#ifndef KDTREE_TEST
#define KDTREE_TEST 0
#endif

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

/*
 * API - opaque handle for KD-trees
 */

typedef struct aktive_kdtree* aktive_kdtree;

/*
 * API - lifecycle
 */

extern aktive_kdtree aktive_kdtree_setup       (aktive_uint c, aktive_fpoint* v);
extern void          aktive_kdtree_release     (aktive_kdtree kd);

/*
 * API operations
 */

extern void aktive_kdtree_find_nearest (aktive_kdtree  kd,
					aktive_fpoint* target,
					aktive_fpoint* best,
					double*        best_distance);

extern void aktive_kdtree_find_in_range (aktive_kdtree   kd,
					 aktive_fpoint*  target,
					 double          radius,
					 aktive_uint*    c,
					 aktive_fpoint*  found);

/* benchmarking - how many nodes visited by last find operation */
extern aktive_uint aktive_kdtree_visit_count (void);

/*
 * = = == === ===== ======== ============= =====================
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
#endif /* AKTIVE_KDTREE_H */
