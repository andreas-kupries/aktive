## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Test pattern

operator image::eye {
    section generator virtual

    note Returns image containing a test pattern with increasing spatial frequency \
	from left to right, and increasing amplitude (i.e. black to white) \
	from top to bottom.

    uint   width   Width of the returned image
    uint   height  Height of the returned image
    double factor  Maximum spatial frequency. Range 0..1.

    example {width 256 height 256 factor 0.8}

    state -fields {
	double c  ; // scaling factor
	double h  ;
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 1);

	// MAX prevents divisions by zero.
	aktive_uint maxx = MAX (param->width,  1);
	aktive_uint maxy = MAX (param->height, 1);

	state->c = param->factor * M_PI / (2. * maxx);
	state->h = maxy * maxy;
    }

    blit eye {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z 0 1 up} {z 0  1 up}}
    } {point {
	y * y * cos (x * x * istate->c) / istate->h
    }}

    pixels {
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	@@eye@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
