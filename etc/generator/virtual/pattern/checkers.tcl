## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Variations on stripe, grid, and checker board patterns

operator image::grid {
    section generator virtual

    note Returns image containing an axis-aligned black/white grid with configurable stripes

    uint   width   Width of the returned image
    uint   height  Height of the returned image

    uint? 0 offset     Pattern offset
    uint? 8 black      Width of the black stripe
    uint? 8 white      Width of the white stripe

    body {
	set sv [stripes width $width height $height black $black white $white offset $offset]
	set sh [aktive op rotate cw $sv]

	aktive op math min $sv $sh
    }
}

operator image::dgrid {
    section generator virtual

    note Returns image containing a diagonal black/white grid with configurable stripes

    uint   width   Width of the returned image
    uint   height  Height of the returned image

    uint? 0 offset     Pattern offset
    uint? 8 black      Width of the black stripe
    uint? 8 white      Width of the white stripe

    body {
	set sv [dstripes width $width height $height black $black white $white offset $offset]
	set sh [aktive op rotate cw $sv]

	aktive op math min $sv $sh
    }
}

operator image::stripes {
    section generator virtual

    note Returns image containing a series of vertical black/white stripes.

    uint   width   Width of the returned image
    uint   height  Height of the returned image

    uint? 0 offset     Pattern offset
    uint? 8 black      Width of the black stripe
    uint? 8 white      Width of the white stripe

    state -fields {
	aktive_uint total; // Total width of black and white stripes. Pattern distance.
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 1);

	// save pattern distance
	state->total = param->black + param->white;
    }

    blit stripes {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z 0  1 up} {z 0  1 up}}
    } {point {
	BW (x)
    }}

    pixels {
	#define BW(x) (((((x) + param->offset) % istate->total) >= param->black) ? 1 : 0)
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	@@stripes@@
	#undef BW
    }
}

operator image::dstripes {
    section generator virtual

    note Returns image containing a series of diagonal black/white stripes.

    uint   width   Width of the returned image
    uint   height  Height of the returned image

    uint? 0 offset     Pattern offset
    uint? 8 black      Width of the black stripe
    uint? 8 white      Width of the white stripe

    state -fields {
	aktive_uint total; // Total width of black and white area. Pattern distance.
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 1);

	// save pattern distance
	state->total = param->black + param->white;
    }

    blit dstripes {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z 0  1 up} {z 0  1 up}}
    } {point {
	BW (x-y)
    }}

    pixels {
	#define BW(x) (((((x) + param->offset) % istate->total) >= param->black) ? 1 : 0)
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	@@dstripes@@
	#undef BW
    }
}

operator image::checkers {
    section generator virtual

    note Returns image containing a black/white checker board.

    uint   width   Width of the returned image
    uint   height  Height of the returned image

    uint? 0 offset     Pattern offset
    uint? 8 black      Width of the black area
    uint? 8 white      Width of the white area

    state -fields {
	aktive_uint total; // Total width of black and white area. Pattern distance.
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 1);
	// save pattern distance
	state->total = param->black + param->white;
    }

    blit checkers {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z 0  1 up} {z 0  1 up}}
    } {point {
	BW (x) ^ BW (y)
    }}

    pixels {
	#define BW(x) (((((x) + param->offset) % istate->total) >= param->black) ? 1 : 0)
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	@@checkers@@
	#undef BW
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
