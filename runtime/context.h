/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Contexts
 *
 * Contexts allow for the saving and reuse of information by key.
 *
 * Region management uses them to locate images used in multiple branches of
 * a DAG to both reduce the number of region structures and mark nodes where
 * caching is useful.
 *
 * With a context the runtime graph for an image DAG is a DAG matching the
 * image DAG structure.  Without a context however the runtime graph devolves
 * into a tree with multiple branches for all nodes which have multiple users
 * in the image DAG.
 *
 * There are issues with such sharing of runtime regions however. For more
 * details see the comments in the `region.[ch]` header and code files.
 */
#ifndef AKTIVE_CONTEXT_H
#define AKTIVE_CONTEXT_H

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_context* aktive_context;

/*
 * - - -- --- ----- -------- -------------

 * lifecycle - used by sinks and sink-adjacent code for a sink each worker
 *             thread creates a context in its first call, which is then used
 *             in the recursive region creation. The region is the thread's
 *             state, keeping a reference to its context.
 */

extern aktive_context aktive_context_new     (void);
extern void           aktive_context_destroy (aktive_context c);

/*
 * - - -- --- ----- -------- -------------
 * accessors
 */

extern int            aktive_context_has     (aktive_context c, void* key);
extern void*          aktive_context_get     (aktive_context c, void* key);

/*
 * - - -- --- ----- -------- -------------
 * mutators
 */

extern void           aktive_context_put       (aktive_context c, void* key, void* value);
extern void           aktive_context_remove    (aktive_context c, void* key);

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
