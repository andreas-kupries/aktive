## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Pixels proclaim their location

operator image::indexed {
    note Generator. \
	Virtual image. Returns 2-band image with pixels proclaiming their own position

    uint   width   Width of the returned image
    uint   height  Height of the returned image

    state -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 2);
    }

    blit gradient {
	{RH {y DY 1 up} {y SY 1 up}}
	{RW {x DX 1 up} {x SX 1 up}}
	{DD {z 0 1 up} {z 0  1 up}}
    } {point {(z == 0) ? x : y}}

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
