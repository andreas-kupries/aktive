## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Pixels proclaim their location

operator image::indexed {
    section generator virtual

    note Returns 2-band image where each pixel declares its own position

    example {width 5 height 5 | -int -matrix}

    uint   width   Width of the returned image
    uint   height  Height of the returned image

    state -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 2);
    }

    blit indexed {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z  0 1 up} {z  0 1 up}}
    } {point {
	(z == 0) ? x : y
    }}

    pixels {
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	@@indexed@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
