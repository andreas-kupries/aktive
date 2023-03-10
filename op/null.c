/* -*- c -*-
 *
 * -- Direct operator support - NULL format support, aka /dev/null
 */

#include <rt.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>
#include <null.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

typedef struct aktive_null_control {
    // Processing configuration
    aktive_sink*   sink;     // Owning/owned sink

    // Processing state
    aktive_uint    size;       // Image size
    aktive_uint    written;    // Values written == size at end    
} aktive_null_control;

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_null_control* null_header (aktive_null_control* info, aktive_image src);
static void                 null_pixels (aktive_null_control* info, aktive_block* src);
static void                 null_final  (aktive_null_control* info);

/*
 * - - -- --- ----- -------- -------------
 */

extern aktive_sink*
aktive_null_sink (aktive_uint sequential)
{
    TRACE_FUNC ("()", 0);
  
    aktive_null_control* info = ALLOC (aktive_null_control);
    aktive_sink*         sink = ALLOC (aktive_sink);

    info->sink     = sink;
    info->size     = 0;
    info->written  = 0;

    sink->name       = "null";
    sink->setup      = (aktive_sink_setup)   null_header;
    sink->final      = (aktive_sink_final)   null_final;
    sink->process    = (aktive_sink_process) null_pixels;
    sink->sequential = sequential;
    sink->state      = info;
    
    TRACE_RETURN ("(aktive_sink*) %p", sink);
}

/*
 * - - -- --- ----- -------- -------------
 */

static aktive_null_control*
null_header (aktive_null_control* info, aktive_image src)
{
    TRACE_FUNC ("((aktive_null_control*) %p '%s', (aktive_image) %p '%s')",
		info, info->sink->name, src, aktive_image_get_type (src)->name);

    aktive_geometry* g = aktive_image_get_geometry (src);

    info->size    = aktive_geometry_get_size (g);
    info->written = 0;

    TRACE_RETURN ("(aktive_null_control*) %p", info);
}

static void
null_final (aktive_null_control* info) {
    TRACE_FUNC ("((aktive_null_control*) %p '%s', written %d)",
		info, info->sink->name, info->written);

    ASSERT_VA (info->written == info->size, "write mismatch",
	       "NULL wrote %d != required %d", info->written, info->size);
    
    ckfree (info->sink);
    ckfree (info);

    TRACE_RETURN_VOID;
}

static void
null_pixels (aktive_null_control* info, aktive_block* src)
{
    TRACE_FUNC ("((aktive_null_control*) %p '%s', written %d, getting (%p): %d)",
		info, info->sink->name, info->written, src, src->used);

    info->written += src->used;

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
