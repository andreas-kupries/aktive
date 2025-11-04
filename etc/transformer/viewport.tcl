## -*- mode: tcl ; fill-column: 90 -*-
# # # ## ### ##### ######## ############# #####################
## Transformer -- Change viewport into the image plane

operator op::view {
    section transform

    example {
	butterfly
	@1 port {190 125 380 250}
    }

    example {
	butterfly
	@1 port {-190 -125 380 250}
    }
    example {
	butterfly
	@1 port {80 80 80 80}
    }

    note Returns image arbitrarily offset and sized compared to the input domain. \
	In other words, an arbitrary rectangular view (port) into the input.

    note Beware, the requested area may fall __anywhere__ with respect to the \
	input's domain. Same, inside (subset), outside, partially overlapping, etc.

    note This is useful to add after an application of "<!xref: aktive op transform by>," \
	as a means of focusing on the desired part of the transformation's result.

    input
    rect port  The specific area to view in the plane. \
	A rectangle of the form \{x y w h\}.

    state -setup {
	aktive_geometry_set (domain,
			     param->port.x,
			     param->port.y,
			     param->port.width,
			     param->port.height,
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

	aktive_blit_copy0 (block, dst, aktive_region_fetch_area (0, request));
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
