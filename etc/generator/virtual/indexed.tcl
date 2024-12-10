## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Pixels proclaim their location

operator image::indexed {
    section generator virtual

    example {          width 5 height 5 | -int -matrix}
    example {x -5 y -5 width 8 height 8 | -int -matrix}

    note Returns a 2-band image where each pixel declares its own position.

    note __Note__ that while the result is usable as a warp map for \
	the "<!xref aktive op warp map>" operation, it will not do \
	anything, as it represents the identity warping.

    int? 0 x      X location of the returned image in the 2D plane
    int? 0 y      Y location of the returned image in the 2D plane
    uint   width  Width of the returned image
    uint   height Height of the returned image

    state -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 2);
    }

    blit indexed {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z  0 1 up} {z  0 1 up}}
    } {point {
	(z == 0) ? ((int) x) : ((int) y)
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
