## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# # ## ### ##### ######## ############# #####################
## From a technical point of view these are band recombinations.
## They use the same kind of blit schema.
#
## HSV does not fit into a simple matrix multiplication however.

# https://en.wikipedia.org/wiki/HSL_and_HSV#Color_conversion_formulae

operator op::color::sRGB::to::HSV {
    section transformer color

    note Returns image in HSV colorspace, from input in sRGB colorspace.

    input

    state -setup {
	aktive_geometry* g = aktive_image_get_geometry (srcs->v[0]);
	if (g->depth != 3) aktive_failf ("rejecting input with depth %d != 3", g->depth);
	aktive_geometry_copy (domain, g);
    }

    blit convert {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
    } {raw hsv-from-srgb {
	// https://en.wikipedia.org/wiki/HSL_and_HSV#From_RGB
	//
	// Generally ensure (clmap) that the incoming values are in the expected range.
	//
	// __ATTENTION__: The `mod` in the referenced equations seems to assume that
	// negative values still have a positive result, i.e. -1 mod 6 == 5. The C
	// language `fmod` returns -1 instead, hence the correction at (*).

	double r = R; r = MAX (0, r); r = MIN (r, 1);
	double g = G; g = MAX (0, g); g = MIN (g, 1);
	double b = B; b = MAX (0, b); b = MIN (b, 1);

	double xmax = MAX (r, MAX (g, b));
	double xmin = MIN (r, MIN (g, b));
	double c    = xmax - xmin;
	double h;

	if (c == 0) {
	    h = 0;
	} else if (xmax == r) {
	    h = fmod ((g-b)/c, 6) / 6.;
	    if (h < 0) h = 1 + h;	// (*) wrap around, fmod correction
	} else if (xmax == g) {
	    h = ((b-r)/c + 2.) / 6.;
	} else if (xmax == b) {
	    h = ((r-g)/c + 4.) / 6.;
	} else {
	    ASSERT (0, "rgb to hsv conversion internal error");
	}

	H = h;
	S = (xmax == 0) ? 0 : c/xmax;
	V = xmax;
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define H dstvalue [0]
	#define S dstvalue [1]
	#define V dstvalue [2]

	#define R srcvalue [0]
	#define G srcvalue [1]
	#define B srcvalue [2]

	@@convert@@

	#undef H
	#undef S
	#undef V
	#undef R
	#undef G
	#undef B
    }
}

operator op::color::HSV::to::sRGB {
    section transformer color

    note Returns image in sRGB colorspace, from input in HSV colorspace.

    input

    state -setup {
	aktive_geometry* g = aktive_image_get_geometry (srcs->v[0]);
	if (g->depth != 3) aktive_failf ("rejecting input with depth %d != 3", g->depth);
	aktive_geometry_copy (domain, g);
    }

    blit convert {
	{DH {y 0 1 up} {y 0 1 up}}
	{DW {x 0 1 up} {x 0 1 up}}
    } {raw srgb-from-hsv {
	// https://en.wikipedia.org/wiki/HSL_and_HSV#HSV_to_RGB_alternative
	// HSV in [0,1]^3 ...
	// WPedia code assumes H in [0,360] :: H/60 => x*360/60 = x*6
	// To avoid issues with fmod for k+h*6 < 0 ensure that H is in range 0..1
	// For S and V we clamp instead.

	double h = fmod (H, 1); if (h < 0) h = 1 + h;
	double s = S; s = MAX (0, s); s = MIN (s, 1);
	double v = V; v = MAX (0, v); v = MIN (v, 1);

	double k5 = fmod (5+h*6, 6); k5 = MIN (k5, 4-k5); k5 = MAX (0, k5); k5 = MIN (k5, 1);
	double k3 = fmod (3+h*6, 6); k3 = MIN (k3, 4-k3); k3 = MAX (0, k3); k3 = MIN (k3, 1);
	double k1 = fmod (1+h*6, 6); k1 = MIN (k1, 4-k1); k1 = MAX (0, k1); k1 = MIN (k1, 1);

	R = v * (1 - s * k5);
	G = v * (1 - s * k3);
	B = v * (1 - s * k1);
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (srcs->v[0], request);

	#define R dstvalue [0]
	#define G dstvalue [1]
	#define B dstvalue [2]

	#define H srcvalue [0]
	#define S srcvalue [1]
	#define V srcvalue [2]

	@@convert@@

	#undef H
	#undef S
	#undef V
	#undef R
	#undef G
	#undef B
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
