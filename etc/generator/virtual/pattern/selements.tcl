## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - structuring elements for morphology
#
## - square
## - disc
## - circle
## - horizontal bar
## - vertical bar
## - axis-aligned cross (+)
## - main diagonal
## - cross (secondary) diagonal
## - diagonal-aligned cross (x)

# # ## ### ##### ######## ############# #####################

operator image::square {
    section generator virtual

    note Returns single-band white square with radius. Default radius 1.

    uint? 1 radius	Radius of the square. Full size is 2*radius + 1.

    body {
	set size [expr {2 * $radius + 1}]
	aktive image from value width $size height $size depth 1 value 1
    }
}

# # ## ### ##### ######## ############# #####################

operator {desc w dw psetup ispixel} {
    image::cbar   {cross diagonal bar}      1 0 {}              { fabs (dx+dy) <= w }
    image::circle {circle (disc perimeter)} 1 1 { double rxy; } { rxy = hypot (dx, dy), ((r - w) <= rxy) && (rxy < r) }
    image::cross  cross                     1 0 {}              { (fabs (dx) <= w) || (fabs (dy) <= w) }
    image::dbar   {diagonal bar}            1 0 {}              { fabs (dx-dy) <= w }
    image::disc   {filled disc}             0 - {}              { hypot (dx, dy) < r }
    image::hbar   {horizontal bar}          1 0 {}              { fabs (dy) <= w }
    image::vbar   {vertical bar}            1 0 {}              { fabs (dx) <= w }
    image::xcross {diagonal cross}          1 0 {}              { (fabs (dx-dy) <= w) || (fabs (dx+dy) <= w) }
} {
    section generator virtual

    note Returns square single-band image containing a ${desc}. The image has size `2*radius + 1` squared.

    uint? 1 radius	Radius of the ${desc}.

    if {!$w} {
	def wsetup {}
	def wcheck {}
    } else {
	uint? $dw width	Width of the element. Default $dw. Has to be less or equal to the radius.

	def wsetup { aktive_uint w = param->width; }
	def wcheck {
	    if (param->radius < param->width) {
		aktive_failf ("width %u too large, not less than radius %u",
			      param->width, param->radius);
	    }
	}
    }

    state -setup  {
	@@wcheck@@
	aktive_uint size = 2 * param->radius + 1;
	aktive_geometry_set (domain, 0, 0, size, size, 1);
    }

    blit seblit {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z  0 1 up} {z  0 1 up}}
    } {point {
	ISPIXEL (x, y, z)
    }}

    pixels {
	aktive_uint r = param->radius;
	TRACE("radius = %d", r);
	double dx, dy;
	@@wsetup@@
	@@psetup@@

	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
	#define SY (request->y)
	#define MID (r)
	#define ISPIXEL(x,y,z) (dx = x, dy = y, dx -= MID, dy -= MID, (@@ispixel@@) ? 1 : 0)
	@@seblit@@
	#undef ISPIXEL
	#undef MID
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
