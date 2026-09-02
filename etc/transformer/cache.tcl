## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Functionally identity, in-memory cache, materialization

# # ## ### ##### ######## ############# #####################
##

operator op::cache {
    section cache

    note Returns the unchanged input.

    note However, this operator materializes and caches the input \
	in memory, for fast random access. Yet it is __not strict__, as \
	the materialization is deferred until the first access.

    note This is useful to put in front of a computationally expensive \
	pipeline, to avoid recomputing parts as upstream demands them. \
	The trade-off here is, of course, memory for time.

    input

    state -fields {
	aktive_gicache gic;	// in-memory image cache for global operator
    } -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
	aktive_gicache_init  (&state->gic);
	aktive_geometry_copy (&state->gic.cache.domain, domain);
    } -cleanup {
	aktive_gicache_drop(&state->gic);
    }

    pixels -state {
	aktive_image    src;	// input image
	aktive_gicache* gic;	// in-memory image cache
	aktive_block*   pixel;	// pixel block in the image cache
    } -setup {
	state->src   = aktive_region_owner (srcs->v[0]);
	state->gic   = &istate->gic;
	state->pixel = istate->gic.cache.pixel;
    } {
	aktive_ocache context = {
	    .domain = idomain,
	    .src    = state->src,
	};
	aktive_gicache_fill (state->gic,
			     (aktive_gicache_filler) aktive_op_ocache,
			     &context);

	TRACE("read cache", 0);
	aktive_blit_copy (block, dst, state->pixel, aktive_rectangle_as_point(request));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
