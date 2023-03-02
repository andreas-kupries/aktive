## -*- mode: tcl ; fill-column: 90 -*-
# # # ## ### ##### ######## ############# #####################
## Transformer -- Change viewport into the image plane

operator op::view {
    section transform

    note Returns image arbitrarily offset and shaped compared to the input domain. \
	In other words, an arbitrary view (port) into the input.

    note Beware, the requested area may fall __anywhere__ with respect to the \
	input's domain. Same, inside (subset), outside, partially overlapping, etc.

    input
    rect view  The specific area to view in the plane

    state -setup {
	aktive_geometry_set (domain,
			     param->view.x,
			     param->view.y,
			     param->view.width,
			     param->view.height,
			     aktive_image_get_depth (srcs->v[0]));
    }
    pixels {
	// pass-through operation ...
	// - Requested area passes unchanged to input ...
	// - Returned pixels pass unchanged to caller ...
	//
	// CONSIDER :: A reworked fetch API enabling zero copy full pass-through
	//          :: (full area, requested area, pixel memory)
	//          :: Maybe move aktive_block out of region ? Caller-owned ?
	//          :: ops not passing through => block is standard region state ?!
	//
	// assert: result.used == block.used
	// assert: result.geo  == block.geo

	aktive_blit_copy0 (block, dst, aktive_region_fetch_area (srcs->v[0], request));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
