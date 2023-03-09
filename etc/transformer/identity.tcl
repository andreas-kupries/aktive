## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Identity

# # ## ### ##### ######## ############# #####################
##

operator op::pass {
    section transform pass

    note Returns unchanged input.

    note This is useful for round-trip testing, to stop simplification \
	rules from eliminating the two complementary operations under \
	test.

    # This is also the reason why this operation has no simplification rules. Because with
    # rules it could always be eliminated from the DAG.

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
