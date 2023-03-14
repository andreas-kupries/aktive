## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# # ## ### ##### ######## ############# #####################
## From a technical point of view these are band recombinations.
## They use the same kind of blit schema.

operator op::color::Lab::to::XYZ {
    section transformer color

    note Returns image in XYZ colorspace, from input in Lab colorspace.

    note This conversion is based on the (1,1,1) reference white.

    note For a different whitepoint scale the XYZ bands by the \
	associated illuminant values after performing the conversion.

    input

    state -setup {
	aktive_geometry* g = aktive_image_get_geometry (srcs->v[0]);
	if (g->depth != 3) aktive_failf ("rejecting input with depth %d != 3", g->depth);
	aktive_geometry_copy (domain, g);
    }

    blit convert {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
    } {raw xyz-from-lab {
	// http://www.brucelindbloom.com/index.html?Eqn_Lab_to_XYZ.html

	double y = (L + 16.) / 116.;
	double x = y + A/500.;
	double z = y - B/200.;

	X = LAB_TO_XYZ (x);
	Y = LAB_TO_XYZ (y);
	Z = LAB_TO_XYZ (z);
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define L srcvalue [0]
	#define A srcvalue [1]
	#define B srcvalue [2]

	#define X dstvalue [0]
	#define Y dstvalue [1]
	#define Z dstvalue [2]

	@@convert@@

	#undef X
	#undef Y
	#undef Z
	#undef L
	#undef A
	#undef B
    }
}

operator op::color::XYZ::to::Lab {
    section transformer color

    note Returns image in Lab colorspace, from input in XYZ colorspace.

    note This conversion is based on the (1,1,1) reference white.

    note For a different whitepoint divide the XYZ bands by the \
	associated illuminant values before performing the conversion.

    input

    state -setup {
	aktive_geometry* g = aktive_image_get_geometry (srcs->v[0]);
	if (g->depth != 3) aktive_failf ("rejecting input with depth %d != 3", g->depth);
	aktive_geometry_copy (domain, g);
    }

    blit convert {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
    } {raw lab-from-xyz {
	// http://www.brucelindbloom.com/index.html?Eqn_XYZ_to_Lab.html

	L = 116 *  XYZ_TO_LAB (Y) - 16;
	A = 500 * (XYZ_TO_LAB (X) - XYZ_TO_LAB (Y));
	B = 200 * (XYZ_TO_LAB (Y) - XYZ_TO_LAB (Z));
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define L dstvalue [0]
	#define A dstvalue [1]
	#define B dstvalue [2]
	#define X srcvalue [0]
	#define Y srcvalue [1]
	#define Z srcvalue [2]

	@@convert@@

	#undef X
	#undef Y
	#undef Z
	#undef L
	#undef A
	#undef B
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
