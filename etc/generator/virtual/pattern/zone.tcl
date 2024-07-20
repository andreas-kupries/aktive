## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Zone plate

operator image::zone {
    section generator virtual

    example {width 256 height 256}

    note Returns image containing a zone plate test pattern.

    uint   width   Width of the returned image
    uint   height  Height of the returned image

    state -fields {
	double c  ; // scaling factor
	double hw ; //
	double hh ; //
    } -setup {
	aktive_geometry_set (domain, 0, 0, param->width, param->height, 1);

	state->c  = M_PI / (double) param->width;
	state->hw = ((double) param->width)  / 2.0;
	state->hh = ((double) param->height) / 2.0;
    }

    blit zone {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z 0 1 up} {z 0  1 up}}
    } {point {
	cos (istate->c * (((x - istate->hw)*(x - istate->hw))+((y - istate->hh)*(y - istate->hh))))
    }}

    pixels {
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	@@zone@@
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
