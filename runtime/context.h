/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Contexts
 *
 * Contexts allow for the saving and reuse of information by key.
 *
 * Region management use them to determine images used in multiple branches of
 * a DAG to both reduce the number of region structures and mark nodes where
 * caching is useful.
 *
 * With a context the context graph for an image DAG is a DAG matching the iDAG
 * structure.  Without a context the context graph devolves into a tree with
 * multiple branches for all image nodes with multiple users in the DAG.
 */
#ifndef AKTIVE_CONTEXT_H
#define AKTIVE_CONTEXT_H

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_context* aktive_context;

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_context aktive_context_new     (void);
extern void           aktive_context_destroy (aktive_context c);
extern int            aktive_context_has     (aktive_context c, void* key);
extern void*          aktive_context_get     (aktive_context c, void* key);
extern void           aktive_context_put     (aktive_context c, void* key, void* value);
extern void           aktive_context_remove  (aktive_context c, void* key);

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
#endif /* AKTIVE_CONTEXT_H */
