## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# # ## ### ##### ######## ############# #####################
## From a technical point of view these are band recombinations.
## They use the same kind of blit schema.
#
## HSL does not fit into a simple matrix multiplication however.

# https://en.wikipedia.org/wiki/HSL_and_HSV#Color_conversion_formulae

operator op::color::sRGB::to::HSL {
    section transform color

    example {
	butterfly
	@1
    }

    note Returns image in HSL colorspace, from input in sRGB colorspace.

    cc-reduce sRGB HSL

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
    } {raw hsl-from-srgb {
	// https://en.wikipedia.org/wiki/HSL_and_HSV#From_RGB
	//
	// RGB in [0,1]^3 ...
	// Generally ensure (clamp) that the incoming values are in the expected range.

	double r = R; r = MAX (0, r); r = MIN (r, 1);
	double g = G; g = MAX (0, g); g = MIN (g, 1);
	double b = B; b = MAX (0, b); b = MIN (b, 1);

	double xmax = MAX (r, MAX (g, b));
	double xmin = MIN (r, MIN (g, b));
	double c    = xmax - xmin;
	double h, s, l;

	if (c == 0)           {	h = 0;
	} else if (xmax == r) {	h = 0 + (g-b)/c;
	} else if (xmax == g) {	h = 2 + (b-r)/c;
	} else if (xmax == b) {	h = 4 + (r-g)/c;
  	} else { ASSERT_VA (0, "rgb to hsl conversion internal error", "%f = max (%f, %f, %f)", xmax, r, g, b);
	}
	if (h < 0) h = 6 + h;	// correct wrap around
	h /= 6.0;

	l = (xmax + xmin)/2;
	s = (c == 0) ? 0 : (l < 0.5) ? (c/(xmax+xmin)) : (c/(2-xmax-xmin));

	H = h;
	S = s;
	L = l;
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (0, request);

	#define R srcvalue [0]
	#define G srcvalue [1]
	#define B srcvalue [2]

	#define H dstvalue [0]
	#define S dstvalue [1]
	#define L dstvalue [2]

	@@convert@@

	#undef H
	#undef S
	#undef L
	#undef R
	#undef G
	#undef B
    }
}

operator op::color::HSL::to::sRGB {
    section transform color

    note Returns image in sRGB colorspace, from input in HSL colorspace.

    cc-reduce HSL sRGB

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
    } {raw srgb-from-hsl {
	// Was not able to make https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB_alternative to work.
	// Ditto for the regular conversion given there.
	// http://www.easyrgb.com/en/math.php
	// HSL in [0,1]^3 ...
	// Ensure that the inputs are in this range (wrap H, clamp S, L)

	double h = fmod (H, 1); if (h < 0) h = 1 + h;
	double s = S; s = MAX (0, s); s = MIN (s, 1);
	double l = L; l = MAX (0, l); l = MIN (l, 1);

	if (s == 0) {
	    R = G = B = l;
	} else {
	    double tb = (l < 0.5) ? (l+l*s) : (l+s-l*s);
	    double ta = 2*l - tb;

	    double r = h + 1./3.; r = ((r < 0) ? (r+1) : ((r > 1) ? (r-1) : r));
	    double g = h + 0    ; // no wrapping needed
	    double b = h - 1./3.; b = ((b < 0) ? (b+1) : ((b > 1) ? (b-1) : b));

	    R = (6*r < 1) ? (ta+(tb-ta)*6*r) : ((2*r < 1) ? (tb) : ((3*r < 2) ? (ta+(tb-ta)*6*(2./3.-r)) : (ta)));
	    G = (6*g < 1) ? (ta+(tb-ta)*6*g) : ((2*g < 1) ? (tb) : ((3*g < 2) ? (ta+(tb-ta)*6*(2./3.-g)) : (ta)));
	    B = (6*b < 1) ? (ta+(tb-ta)*6*b) : ((2*b < 1) ? (tb) : ((3*b < 2) ? (ta+(tb-ta)*6*(2./3.-b)) : (ta)));
	}
    }}

    pixels {
	// request passes through as is
	aktive_block* src = aktive_region_fetch_area (0, request);

	#define H srcvalue [0]
	#define S srcvalue [1]
	#define L srcvalue [2]

	#define R dstvalue [0]
	#define G dstvalue [1]
	#define B dstvalue [2]

	@@convert@@

	#undef H
	#undef S
	#undef L
	#undef R
	#undef G
	#undef B
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
