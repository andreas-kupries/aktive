## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image -

operator image::sines {
    note Generator. \
	Virtual image. Sine wave in two dimensions.

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
	{RH {y DY 1 up} {y SY 1 up}}
	{RW {x DX 1 up} {x SX 1 up}}
	{DD {z 0 1 up} {z 0  1 up}}
    } {point { cos (istate->c * (x * istate->ctheta - y * istate->stheta))}}

    pixels {
	#define DX (dst->x)
	#define DY (dst->y)
	#define RH (request->height)
	#define RW (request->width)
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
