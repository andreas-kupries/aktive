## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# # ## ### ##### ######## ############# #####################
## From a technical point of view these are band recombinations.
## They use the same kind of blit schema.

operator op::color::sRGB::to::gray {
    section transform color

    example {
	butterfly
	@1
    }

    note Returns image in grayscale, from input in scRGB colorspace.

    note This conversion uses the NTSC conversion formula.

    cc-reduce sRGB gray

    input

    state -setup {
	@@check-input-colorspace@@

	aktive_geometry* g = aktive_image_get_geometry (srcs->v[0]);
	if (g->depth != 3) aktive_failf ("rejecting input with depth %d != 3", g->depth);
	aktive_geometry_copy (domain, g);
	domain->depth = 1;

	@@set-result-colorspace@@
    }

    blit convert {
	{AH {y AY 1 up} {y 0 1 up}}
	{AW {x AX 1 up} {x 0 1 up}}
    } {raw xyz-from-scrgb {
	GR = 0.2989 * R + 0.5870 * G + 0.1140 * B;
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define R srcvalue [0]
	#define G srcvalue [1]
	#define B srcvalue [2]

	#define GR dstvalue [0]

	@@convert@@

	#undef GR
	#undef R
	#undef G
	#undef B
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
