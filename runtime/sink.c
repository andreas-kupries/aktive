/* -*- c -*-
 */

#include <rt.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_sink_run (aktive_sink* sink,
		 aktive_image src)
{
    TRACE_FUNC ("((aktive_sink*) %p '%s', (aktive_image) src)",
		sink, sink->name, src);
    
    void* state = sink->setup (src, sink->state);

    // Caller is expected to have made any checks which would make the sink fail
    ASSERT (state, "sink failed to create state");
    
    // Scan image by rows      -- TODO FUTURE -- ask image for prefered method
    // Scan image sequentially -- TODO FUTURE -- spread over multiple threads

    aktive_region rg = aktive_region_new (src);
	
    aktive_rectangle_def_as (scan, aktive_image_get_domain (src));
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
