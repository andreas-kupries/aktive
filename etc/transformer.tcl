## -*- mode: tcl ; fill-column: 90 -*-
# # # ## ### ##### ######## ############# #####################
## Image transformer - Single input image, possibly parameters

## # # ## ### ##### ######## ############# #####################

operator op::view {
    note Look at some area of an image.
    note The requested area may fall anywhere regarding the input image's domain.
    note Same, insude (subset), outside, partially overlapping, etc.

    input keep
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

## # # ## ### ##### ######## ############# #####################

import unary-math.tcl

##
## # # ## ### ##### ######## ############# #####################
::return
