## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image -

operator image::sines {
    section generator virtual

    example {width 256 height 256 hf 0.5 vf 0.6}

    note Returns image containing a sine wave in two dimensions.

    note The ratio between horizontal and vertical frequencies \
	determines the angle of the composite wave relative to \
	the X axis.

    uint   width   Width of the returned image
    uint   height  Height of the returned image
    double hf      Horizontal frequency
    double vf      Vertical frequency

    state -fields {
	double c      ; // scaling factor
	double stheta ; //
	double ctheta ; //
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 1);

	double factor = hypot (param->vf, param->hf);
	double theta = atan2 (param->vf, param->hf);

	state->c      = factor * M_PI * 2.0 / param->width;
	state->ctheta = cos (theta);
	state->stheta = sin (theta);
    }

    blit sines {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z 0 1 up} {z 0  1 up}}
    } {point {
	cos (istate->c * (x * istate->ctheta - y * istate->stheta))
    }}

    pixels {
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	@@sines@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
