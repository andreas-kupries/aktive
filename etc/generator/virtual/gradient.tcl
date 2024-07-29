## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual image - Computed pixels - Gradient across entire volume

operator image::gradient {
    section generator virtual

    note Returns image containing a linear gradient through all cells.

    example {width 256 height   1 depth 1 first 0 last 1 | height-times 32}
    example {width 128 height 128 depth 1 first 0 last 1}

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
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z  0 1 up} {z  0 1 up}}
    } {pos {
	param->first + @ * istate->delta
    }}

    pixels {
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
