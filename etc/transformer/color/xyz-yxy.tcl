## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# https://en.wikipedia.org/wiki/CIE_1931_color_space#CIE_xy_chromaticity_diagram_and_the_CIE_xyY_color_space

# # ## ### ##### ######## ############# #####################
## From a technical point of view these are band recombinations.
## They use the same kind of blit schema.

operator op::color::Yxy::to::XYZ {
    section transformer color

    note Returns image in XYZ colorspace, from input in Yxy colorspace.

    cc-reduce Yxy XYZ

    input

    state -setup {
	aktive_geometry* g = aktive_image_get_geometry (srcs->v[0]);
	if (g->depth != 3) aktive_failf ("rejecting input with depth %d != 3", g->depth);
	aktive_geometry_copy (domain, g);
    }

    blit convert {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
    } {raw xyz-from-yxy {
	// https://www.easyrgb.com/en/math.php
	// http://www.brucelindbloom.com/index.html?Eqn_xyY_to_XYZ.html

	YD = YS;
	XD = (yS == 0) ? 0 : (xS            * YS/yS);
	ZD = (yS == 0) ? 0 : ((1 - xS - yS) * YS/yS);
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define YS srcvalue [0]
	#define xS srcvalue [1]
	#define yS srcvalue [2]

	#define XD dstvalue [0]
	#define YD dstvalue [1]
	#define ZD dstvalue [2]

	@@convert@@

	#undef XD
	#undef YD
	#undef ZD
	#undef YS
	#undef xS
	#undef yS
    }
}

operator op::color::XYZ::to::Yxy {
    section transformer color

    note Returns image in Yxy colorspace, from input in XYZ colorspace.

    cc-reduce XYZ Yxy

    input

    state -setup {
	aktive_geometry* g = aktive_image_get_geometry (srcs->v[0]);
	if (g->depth != 3) aktive_failf ("rejecting input with depth %d != 3", g->depth);
	aktive_geometry_copy (domain, g);
    }

    blit convert {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
    } {raw yxy-from-xyz {
	// https://www.easyrgb.com/en/math.php
	// http://www.brucelindbloom.com/index.html?Eqn_XYZ_to_xyY.html

	double s = XS + YS + ZS;

	YD = YS;
	xD = (s == 0) ? 1 : (XS / s);
	yD = (s == 0) ? 1 : (YS / s);
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define XS srcvalue [0]
	#define YS srcvalue [1]
	#define ZS srcvalue [2]

	#define YD dstvalue [0]
	#define xD dstvalue [1]
	#define yD dstvalue [2]

	@@convert@@

	#undef YD
	#undef xD
	#undef yD
	#undef XS
	#undef YS
	#undef ZS
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
