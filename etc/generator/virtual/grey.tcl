## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Left to right gradient, black to white

operator image::grey {
    note Generator. \
	Virtual image. Left to right gradient, black to white

    uint   width   Width of the returned image
    uint   height  Height of the returned image

    state -fields {
	double w;
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 1);

	double w = param->width - 1;
	if (w == 0) w = 1;

	state->w = w;
    }

    blit gradient {
	{RH {y DY 1 up} {y SY 1 up}}
	{RW {x DX 1 up} {x SX 1 up}}
	{DD {z 0 1 up} {z 0  1 up}}
    } {point {
	((double) x) / istate->w
    }}

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
	@@gradient@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
