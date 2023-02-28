/* -*- c -*-
 */

#include <rt.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

#define ALL  1
#define ROWS 2
#define MODE ROWS

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_sink_run (aktive_sink* sink,
		 aktive_image src)
{
    TRACE_FUNC ("((aktive_sink*) %p '%s', (aktive_image) src)",
		sink, sink->name, src);
    
    void* state = sink->setup (sink->state, src);

    // Some errors may appear only very late.
    if (!state) { TRACE_RETURN_VOID; }
    
    // Scan image by rows      -- TODO FUTURE -- ask image for prefered method
    // Scan image sequentially -- TODO FUTURE -- spread over multiple threads

    aktive_region rg = aktive_region_new (src);

    if (!rg) { TRACE_RETURN_VOID; }
    
    aktive_rectangle_def_as (scan, aktive_image_get_domain (src));
#if MODE == ROWS
    scan.height = 1;
    aktive_uint height = aktive_image_get_height (src);
    aktive_uint row;

    for (row = 0; row < height; row ++) {
	TRACE ("fetching row %d", row);
	TRACE_RECTANGLE(&scan);

	aktive_block* pixels = aktive_region_fetch_area (rg, &scan);

	TRACE ("processing row %d pixels", row);
	sink->process (state, pixels);

	aktive_rectangle_move (&scan, 0, 1);
    }
#elif MODE == ALL
    TRACE ("fetching all pixels", 0);
    
    aktive_block* pixels = aktive_region_fetch_area (rg, &scan);

    TRACE ("processing all pixels", 0);
    sink->process (state, pixels);    
#endif

    sink->final (state);

    aktive_region_destroy (rg); // Note that this invalidates `pixels` too.

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
