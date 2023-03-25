## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Identity

# # ## ### ##### ######## ############# #####################
##

operator op::pass {
    section transform identity

    note Returns unchanged input.

    note This is useful for round-trip testing, to stop application \
	of simplification rules which would otherwise eliminate or \
	modify the chain of operations under test.

    # This is also the reason why this operation has no simplification rules.
    # Because with rules it would always be eliminated from the DAG.

    input

    state -setup {
	aktive_geometry_copy (domain, aktive_image_get_geometry (srcs->v[0]));
    }
    pixels {
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);
	aktive_blit_copy0 (block, dst, src);
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
