## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# # ## ### ##### ######## ############# #####################
## From a technical point of view these are band recombinations.
## They use the same kind of blit schema.

operator op::color::Lab::to::LCh {
    section transform color

    note Returns image in LCh colorspace, from input in Lab colorspace.
    note The H coordinate is provided in degrees.

    cc-reduce Lab LCh

    input

    state -setup {
	@@check-input-colorspace@@

	aktive_geometry* g = aktive_image_get_geometry (srcs->v[0]);
	if (g->depth != 3) aktive_failf ("rejecting input with depth %d != 3", g->depth);
	aktive_geometry_copy (domain, g);

	@@set-result-colorspace@@
    }

    blit convert {
	{AH {y AY 1 up} {y 0 1 up}}
	{AW {x AX 1 up} {x 0 1 up}}
    } {raw lch-from-Lab {
	// https://www.easyrgb.com/en/math.php
	// http://www.brucelindbloom.com/index.html?Eqn_Lab_to_LCH.html

	LD = LS;
	C  = LAB_TO_LCH_C (LS, A, B);
	H  = LAB_TO_LCH_H (LS, A, B) * 180 / M_PI;	// get degrees
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define LS srcvalue [0]
	#define A  srcvalue [1]
	#define B  srcvalue [2]

	#define LD dstvalue [0]
	#define C  dstvalue [1]
	#define H  dstvalue [2]

	@@convert@@

	#undef LD
	#undef C
	#undef H
	#undef LS
	#undef A
	#undef B
    }
}

operator op::color::LCh::to::Lab {
    section transform color

    note Returns image in Lab colorspace, from input in LCH colorspace.
    note The H coordinate is expected to be in degrees.

    cc-reduce LCh Lab

    input

    state -setup {
	@@check-input-colorspace@@

	aktive_geometry* g = aktive_image_get_geometry (srcs->v[0]);
	if (g->depth != 3) aktive_failf ("rejecting input with depth %d != 3", g->depth);
	aktive_geometry_copy (domain, g);

	@@set-result-colorspace@@
    }

    blit convert {
	{AH {y AY 1 up} {y 0 1 up}}
	{AW {x AX 1 up} {x 0 1 up}}
    } {raw lab-from-lch {
	// https://www.easyrgb.com/en/math.php
	// http://www.brucelindbloom.com/index.html?Eqn_LCH_to_Lab.html

	double h = H * M_PI / 180;	// get radians

	LD = LS;
	A  = LCH_TO_LAB_A (LS, C, h);
	B  = LCH_TO_LAB_B (LS, C, h);
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define LS srcvalue [0]
	#define C  srcvalue [1]
	#define H  srcvalue [2]

	#define LD dstvalue [0]
	#define A  dstvalue [1]
	#define B  dstvalue [2]

	@@convert@@

	#undef LD
	#undef A
	#undef B
	#undef LS
	#undef C
	#undef H
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
