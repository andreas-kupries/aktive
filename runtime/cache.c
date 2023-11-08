/* -*- c -*-
 * - - -- --- ----- -------- -------------
 *
 * -- Cache utility functions.
 *
 *    Management of a global memory area cache, with LRU eviction policy.
 *    The cache is oblivious to the data stored in the managed areas.
 *    Access to the cache from multiple concurrent threads is safe.
 *
 * See `cache.h` for the user documentation.
 */

/*
 * - - -- --- ----- -------- -------------
 */

#include <cache.h>
#include <micros.h>
#include <stddef.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 *
 * The LRU cache is a circular double-linked list rooted at `cache` (see below).
 * To ensure circularity the `once()` function properly initializes `cache` as
 * an empty circle, with all links refering back to the root itself.
 *
 * The discard pile is a plain Tcl_HashTable. Each HashEntry's user data is a
 * circular double-linked list of the discarded/invalidated nodes.
 */

#define DEFAULT_MAX  (100*1024*1024) // 100 MB
// #define DEFAULT_MAX (1024*1024*1024) //   1 GB

#define NODE_FROM_AREA(area) \
    ((aktive_cache_node*) (((char*) (area)) - offsetof (aktive_cache_node, area)))

typedef struct aktive_cache_node *aktive_cache_node_ptr;

typedef struct aktive_cache_node {
    aktive_cache_node_ptr previous; // LRU chain
    aktive_cache_node_ptr next;     // LRU chain
    void*                 owner;
    aktive_cache_area     area;     // embedded area
} aktive_cache_node;

/*
 * - - -- --- ----- -------- -------------
 */

TCL_DECLARE_MUTEX(cache_lock);
static aktive_uint       cache_size;
static aktive_uint       cache_max = DEFAULT_MAX;
static aktive_cache_node cache = {
				  0, // LRU previous = bottom/last
				  0, // LRU next     = top/first
				  0  //
};

Tcl_HashTable cache_trim;

static void pretrim  (void);
static void take     (aktive_cache_node* node);
static void inittrim (void);

static void once (void) {
    TRACE_FUNC("", 0);
    static int once = 0; if (once) { TRACE_RETURN_VOID; } once = 1;

    cache.previous = &cache;
    cache.next     = &cache;
    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_cache_set_max (aktive_uint size)
{
    once();
    TRACE_FUNC("(size %u)", size);

    TRACE_RUN (aktive_uint start = aktive_now());
    Tcl_MutexLock (&cache_lock);
    TRACE_RUN (aktive_uint entrywait = aktive_now() - start);
    TRACE("micro wait on entry %u", entrywait);

    cache_max = size;
    pretrim();

    Tcl_MutexUnlock (&cache_lock);
    TRACE_RUN(aktive_uint section = aktive_now() - start);
    TRACE("micro in section %u", section);

    TRACE_RETURN_VOID;
}

extern aktive_uint
aktive_cache_get_max (void)
{
    once();
    TRACE_FUNC("", 0);
    TRACE_RETURN("%d", cache_max);
}

extern aktive_cache_area*
aktive_cache_new (aktive_uint size, void* owner, void* context)
{
    once();
    TRACE_FUNC("(size %u, owner %p, context %p)", size, owner, context);

    aktive_cache_node* node = ALLOC_PLUS (aktive_cache_node, size+1);

    // Initialize internal parts
    node->previous = 0;
    node->next = 0;
    node->owner = owner;

    // Initialize public parts
    node->area.context = context;
    node->area.size = size;

    TRACE_RETURN("(area) %p", &node->area);
}

extern void
aktive_cache_release (aktive_cache_area* area)
{
    TRACE_FUNC("(area %p)", area);

    aktive_cache_node* node = NODE_FROM_AREA (area);
    take (node);
    FREE (node);

    TRACE_RETURN_VOID;
}

extern void
aktive_cache_take (aktive_cache_area* area)
{
    TRACE_FUNC("(area %p)", area);

    take (NODE_FROM_AREA (area));

    TRACE_RETURN_VOID;
}

extern void
aktive_cache_enter (aktive_cache_area* area)
{
    TRACE_FUNC("(area %p)", area);

    aktive_cache_node* node = NODE_FROM_AREA (area);

    TRACE_RUN (aktive_uint start = aktive_now());
    Tcl_MutexLock (&cache_lock);
    TRACE_RUN (aktive_uint entrywait = aktive_now() - start);
    TRACE("micro wait on entry %u", entrywait);

    cache_size += area->size;

    // Insert node at the beginning of the chain
    node->next           = cache.next;
    cache.next           = node;
    node->previous       = &cache;
    node->next->previous = node;

    pretrim();

    Tcl_MutexUnlock (&cache_lock);
    TRACE_RUN(aktive_uint section = aktive_now() - start);
    TRACE("micro in section %u", section);

    TRACE_RETURN_VOID;
}

extern void
aktive_cache_trim (void* owner, aktive_cache_trimmer trimmer)
{
    TRACE_FUNC("(owner %p, trimmer %p)", owner, trimmer);

    TRACE_RUN (aktive_uint start = aktive_now());
    Tcl_MutexLock (&cache_lock);
    TRACE_RUN (aktive_uint entrywait = aktive_now() - start);
    TRACE("micro wait on entry %u", entrywait);

    inittrim();

    Tcl_HashEntry* he = Tcl_FindHashEntry (&cache_trim, owner);
    if (he) {
	aktive_cache_node *iter, *head = Tcl_GetHashValue (he);

	Tcl_DeleteHashEntry (he);

	while (head->next != head) {
	    iter = head->next;

	    iter->owner = 0;
	    iter->previous->next = iter->next;
	    iter->next->previous = iter->previous;

	    trimmer (owner, &iter->area);

	    FREE (iter);
	}
    }

    Tcl_MutexUnlock (&cache_lock);
    TRACE_RUN(aktive_uint section = aktive_now() - start);
    TRACE("micro in section %u", section);

    TRACE_RETURN_VOID;
}

/*
 * - - -- --- ----- -------- -------------
 */

static void
take (aktive_cache_node* node)
{
    TRACE_FUNC("(node %p)", node);

    TRACE_RUN (aktive_uint start = aktive_now());
    Tcl_MutexLock (&cache_lock);
    TRACE_RUN (aktive_uint entrywait = aktive_now() - start);
    TRACE("micro wait on entry %u", entrywait);

    ASSERT (node->owner, "Do not call release/take from trim.trimmer");

    cache_size -= node->area.size;

    node->previous->next = node->next;
    node->next->previous = node->previous;

    Tcl_MutexUnlock (&cache_lock);
    TRACE_RUN(aktive_uint section = aktive_now() - start);
    TRACE("micro in section %u", section);

    node->previous = 0;
    node->next = 0;

    TRACE_RETURN_VOID;
}

static void
inittrim (void)
{
    TRACE_FUNC("", 0);
    static int once = 0; if (once) { TRACE_RETURN_VOID; } once = 1;

    Tcl_InitHashTable (&cache_trim, TCL_ONE_WORD_KEYS);
    TRACE_RETURN_VOID;
}

static void
pretrim (void)
{
    TRACE_FUNC("", 0);

    inittrim();
    // Remove nodes from the end of the chain, i.e. least recently used.
    while (cache_size > cache_max) {
	aktive_cache_node* last = cache.previous;
	take (last);

	// Initialize owner-indexed table of trim lists
	Tcl_HashEntry* he = Tcl_FindHashEntry (&cache_trim, last->owner);
	if (!he) {
	    int new;
	    Tcl_HashEntry* he = Tcl_CreateHashEntry (&cache_trim, last->owner, &new);
	    aktive_cache_node* head = ALLOC (aktive_cache_node);
	    head->previous = head;
	    head->next     = head;
	    Tcl_SetHashValue (he, head);
	}

	// Add removed block into owner's trim list.
	aktive_cache_node* head = Tcl_GetHashValue (he);
	last->next = head->next;
	head->next = last;
	last->previous = head;
	last->next->previous = last;
    }

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
