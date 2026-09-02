/* -*- c -*-
 *
 * -- Direct operator support - op::cache filler and context
 */

#include <tclpre9compat.h>
#include <critcl_trace.h>

#include <ocache.h>
#include <op/memory.h>

TRACE_OFF;

/*
 * - - -- --- ----- -------- -------------
 */

extern void
aktive_op_ocache (aktive_block* out, aktive_ocache* context)
{
  TRACE_FUNC("((aktive_block*) %p, (aktive_ocache*) %p)", out, context);

  aktive_blit_setup (out, aktive_geometry_as_rectangle (context->domain));
  out->initialized = 1;

  aktive_sink_run (aktive_memory_sink (out), context->src);
  // Note: The sink self-destroys in its state finalization.
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
