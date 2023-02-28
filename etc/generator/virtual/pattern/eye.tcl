## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Test pattern

operator image::eye {
    note Generator. \
	Virtual image. Test pattern with increasing spatial frequency \
	from left to right, and increasing amplitude (i.e. black to white) \
	from top to bottom.

    uint   width   Width of the returned image
    uint   height  Height of the returned image
    double factor  Maximum spatial frequency. Range 0..1.

    state -fields {
	double c  ; // scaling factor
	double h  ;
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 1);

	#define MAX(a,b) ((a) > (b) ? (a) : (b))
	// MAX to prevent divisions by zero.

	aktive_uint maxx = MAX (param->width, 1);
	aktive_uint maxy = MAX (param->height, 1);

	state->c = param->factor * M_PI / (2. * maxx);
	state->h = maxy * maxy;

	#undef MAX
    }

    blit eye {
	{RH {y DY 1 up} {y SY 1 up}}
	{RW {x DX 1 up} {x SX 1 up}}
	{DD {z 0 1 up} {z 0  1 up}}
    } {point {
	y * y * cos (x * x * istate->c) / istate->h
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
	@@eye@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
