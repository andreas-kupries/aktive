## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# # ## ### ##### ######## ############# #####################
## From a technical point of view these are band recombinations.
## They use the same kind of blit schema.

operator op::color::scRGB::to::XYZ {
    section transform color

    note Returns image in XYZ colorspace, from input in scRGB colorspace.

    cc-reduce scRGB XYZ

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
    } {raw xyz-from-scrgb {
	// http://www.easyrgb.com/en/math.php
	// http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
	// http://www.brucelindbloom.com/index.html?Eqn_XYZ_to_RGB.html
	//
	// Having the SCALE in each term is OK.
	// We assume that the compiler folds it into the other constants.

	X = SCALE * 0.4124564 * R + SCALE * 0.3575761 * G + SCALE * 0.1804375 * B;
	Y = SCALE * 0.2126729 * R + SCALE * 0.7151522 * G + SCALE * 0.0721750 * B;
	Z = SCALE * 0.0193339 * R + SCALE * 0.1191920 * G + SCALE * 0.9503041 * B;
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define SCALE AKTIVE_WP_D65_Y

	#define R srcvalue [0]
	#define G srcvalue [1]
	#define B srcvalue [2]

	#define X dstvalue [0]
	#define Y dstvalue [1]
	#define Z dstvalue [2]

	@@convert@@

	#undef X
	#undef Y
	#undef Z
	#undef R
	#undef G
	#undef B
	#undef SCALE
    }
}

operator op::color::XYZ::to::scRGB {
    section transform color

    note Returns image in scRGB colorspace, from input in XYZ colorspace.

    cc-reduce XYZ scRGB

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
    } {raw scrgb-from-xyz {
	// http://www.easyrgb.com/en/math.php
	// http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
	// http://www.brucelindbloom.com/index.html?Eqn_XYZ_to_RGB.html
	//
	// Having the SCALE in each term is OK.
	// We assume that the compiler folds it into the other constants.

	R =  3.2404542 / SCALE * X + -1.5371385 / SCALE * Y + -0.4985314 / SCALE * Z;
	G = -0.9692660 / SCALE * X +  1.8760108 / SCALE * Y +  0.0415560 / SCALE * Z;
	B =  0.0556434 / SCALE * X + -0.2040259 / SCALE * Y +  1.0572252 / SCALE * Z;
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define SCALE AKTIVE_WP_D65_Y

	#define X srcvalue [0]
	#define Y srcvalue [1]
	#define Z srcvalue [2]

	#define R dstvalue [0]
	#define G dstvalue [1]
	#define B dstvalue [2]

	@@convert@@

	#undef X
	#undef Y
	#undef Z
	#undef R
	#undef G
	#undef B
	#undef SCALE
    }
}

##
# # ## ### ##### ######## ############# #####################
## Lossy conversions
## - While we can convert to Grey/Luminance, we cannot convert back to color

operator op::color::XYZ::to::Grey {
    section transform color

    note Returns input converted to grey scale, from input in XYZ colorspace.

    note The gray data is just the Y channel of the input.

    input

    body {
	::aktive::op::color::CC XYZ Grey $src aktive op select z $src from 1
    }
}

operator op::color::scRGB::to::Grey {
    section transform color

    cc-meta scRGB Grey

    note Returns input converted to grey scale, from input in scRGB colorspace.

    note The gray data is just the Y channel of a conversion to XYZ colorspace. \
	A separate operator is used to completely avoid the calculation of the \
	unwanted XZ data.

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
    } {raw grey-from-scrgb {
	// http://www.easyrgb.com/en/math.php
	// http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
	// http://www.brucelindbloom.com/index.html?Eqn_XYZ_to_RGB.html
	//
	// Having the SCALE in each term is OK.
	// We assume that the compiler folds it into the other constants.

	Y = SCALE * 0.2126729 * R + SCALE * 0.7151522 * G + SCALE * 0.0721750 * B;
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define SCALE AKTIVE_WP_D65_Y

	#define R srcvalue [0]
	#define G srcvalue [1]
	#define B srcvalue [2]

	#define Y dstvalue [0]

	@@convert@@

	#undef Y
	#undef R
	#undef G
	#undef B
	#undef SCALE
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
