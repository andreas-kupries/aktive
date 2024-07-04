/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Runtime API -- Contexts
 */

#include <base.h>
#include <context.h>
#include <tclpre9compat.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

A_STRUCTURE (aktive_context) {
    A_FIELD (Tcl_HashTable, val) ; // key-value context map
} A_END_PTR (aktive_context);

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_context
aktive_context_new (void)
{
    TRACE_FUNC ("", 0);

    aktive_context c = ALLOC (struct aktive_context);
    Tcl_InitHashTable (&c->val, TCL_ONE_WORD_KEYS);

    TRACE_RETURN ("(context*) %p", c);
}

extern void
aktive_context_destroy (aktive_context c)
{
    TRACE_FUNC ("((context*) %p)", c);

    Tcl_DeleteHashTable (&c->val);
    ckfree (c);

    TRACE_RETURN_VOID;
}

extern int
aktive_context_has (aktive_context c, void* key)
{
    TRACE_FUNC ("((context*) %p, (key) %p)", c, key);

    Tcl_HashEntry* he = Tcl_FindHashEntry (&c->val, key);

    TRACE_RETURN ("(found) %d", he != 0);
}

extern void*
aktive_context_get (aktive_context c, void* key)
{
    TRACE_FUNC ("((context*) %p, (key) %p)", c, key);

    Tcl_HashEntry* he = Tcl_FindHashEntry (&c->val, key);
    void* r = Tcl_GetHashValue (he);

    TRACE_RETURN ("(value) %p", r);
}

extern void
aktive_context_put (aktive_context c, void* key, void* value)
{
    TRACE_FUNC ("((context*) %p, (key) %p, (value) %p)", c, key, value);

    int new;
    Tcl_HashEntry* he = Tcl_CreateHashEntry (&c->val, key, &new);
    ASSERT (new, "unable to overwrite existing entry");
    Tcl_SetHashValue (he, value);

    TRACE_RETURN_VOID;
}

extern void
aktive_context_remove (aktive_context c, void* key)
{
    TRACE_FUNC ("((context*) %p, (key) %p)", c, key);

    Tcl_HashEntry* he = Tcl_FindHashEntry (&c->val, key);
    if (he) {
	TRACE ("removed (value) %p", Tcl_GetHashValue (he));
	Tcl_DeleteHashEntry (he);
    } else {
	TRACE ("not found", 0);
    }

    TRACE_RETURN_VOID;
}

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
