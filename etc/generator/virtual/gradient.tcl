## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual image - Computed pixels - Gradient across entire volume

operator image::gradient {
    note Generator. \
	Virtual Image. Provides a linear gradient through all cells

    uint   width   Width of the returned image
    uint   height  Height of the returned image
    uint   depth   Depth of the returned image
    double first   First value
    double last    Last value

    state -fields {
	double delta;
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, param->depth);

	state->delta = (param->last - param->first)
		     / (double) (aktive_geometry_get_size (domain) - 1);
    }

    blit gradient {
	{RH {y DY 1 up} {y SY 1 up}}
	{RW {x DX 1 up} {x SX 1 up}}
	{DD {z 0 1 up} {z 0  1 up}}
    } {pos {
	param->first + @ * istate->delta
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
