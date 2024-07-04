/* -*- c -*-
 *
 * -- Direct operator support - MEMORY format support
 *
 * In-memory materialized images.
 */

#include <rt.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>
#include <memory.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_memory_control {
    // Processing configuration
    aktive_block*  memory;   // Destination for image data -- No intercalated writer isolating sink from destination.
    aktive_sink*   sink;     // Owning/owned sink

    // Processing state
    aktive_point   loc; // origin image location
} aktive_memory_control;

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_memory_control* aktive_header (aktive_memory_control* info, aktive_image src);
static void                   aktive_pixels (aktive_memory_control* info, aktive_block* src);
static void                   aktive_final  (aktive_memory_control* info);

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_sink*
aktive_memory_sink (aktive_block* memory)
{
    TRACE_FUNC ("((aktive_block*) %p)", memory);

    aktive_memory_control* info = ALLOC (aktive_memory_control);
    aktive_sink*           sink = ALLOC (aktive_sink);

    info->memory   = memory;
    info->sink     = sink;

    sink->name       = "memory";
    sink->setup      = (aktive_sink_setup)   aktive_header;
    sink->final      = (aktive_sink_final)   aktive_final;
    sink->process    = (aktive_sink_process) aktive_pixels;
    sink->sequential = 0;
    sink->state      = info;

    TRACE_RETURN ("(aktive_sink*) %p", sink);
}

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_memory_control*
aktive_header (aktive_memory_control* info, aktive_image src)
{
    TRACE_FUNC ("((aktive_memory_control*) %p '%s', (aktive_image) %p '%s')",
		info, info->sink->name, src, aktive_image_get_type (src)->name);

    aktive_geometry_set_point (&info->loc, aktive_image_get_geometry (src));

    TRACE_RETURN ("(aktive_memory_control*) %p", info);
}

static void
aktive_final (aktive_memory_control* info) {
    TRACE_FUNC ("((aktive_memory_control*) %p '%s')", info, info->sink->name);

    ckfree (info->sink);
    ckfree (info);

    TRACE_RETURN_VOID;
}

static void
aktive_pixels (aktive_memory_control* info, aktive_block* src)
{
    TRACE_FUNC ("((aktive_memory_control*) %p '%s', getting (%p): %d)",
		info, info->sink->name, src, src->used);

    TRACE_DO (__aktive_block_dump (info->sink->name, src));

    TRACE_POINT_M   ("origin  loc", &info->loc);	// location of origin image
    TRACE_POINT_M   ("blk src loc", &src->location);	// block logical location in origin image
    TRACE_GEOMETRY_M("blk src dom", &src->domain);	// (w, h, d) of src->pixel

    // destination area has soource dimensions.
    aktive_rectangle_def_as (dst, &src->domain);

    // destination area location is 0-based, translate from logical to physical
    aktive_point_set (aktive_rectangle_as_point (&dst),
		      src->location.x - info->loc.x,
		      src->location.y - info->loc.y);

    // directly blit into the provided memory block.
    aktive_blit_copy0 (info->memory, &dst, src);

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
