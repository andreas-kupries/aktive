## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Origin map of a swirl effect

operator warp::swirl {
    section generator virtual warp

    example {width 11 height 11 center {5 5} decay 1 | -matrix}

    note Returns the origin map for a swirl effect around the \
	specified __center__, with fixed rotation __phi__, \
	a base rotation __from__, and a __decay__ factor.

    note The rotation angle added to a pixel is given by \
	`phi + from * exp(-radius * decay)`, \
	where __radius__ is the distance of the pixel from the \
	__center__. A large decay reduces the swirl at shorter \
	radii. A decay of zero disables the decay.

    note All parameters except for the center are optional.

    note The result is designed to be usable with the \
	"<!xref: aktive op warp bicubic>" operation and its relatives.

    note At the technical level the result is a 2-band image \
	where each pixel declares its origin position.

    ref https://juliaimages.org/previews/PR218/examples/transformations/operations/swirl/

    # image configuration
    uint       width   Width of the returned image
    uint       height  Height of the returned image
    int?     0 x       X location of the returned image in the 2D plane
    int?     0 y       Y location of the returned image in the 2D plane

    # swirl configuration
    point        center Center of the swirl
    double?   0  phi    In degrees, fixed rotation to apply.
    double?  45  from   In degrees, swirl rotation at distance 0 from center.
    double? 0.1  decay  Rotation decay with distance from center.

    # see also effect::swirl, keep matching

    state -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 2);
    }

    blit indexed {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
	{DD {z  0 1 up} {z  0 1 up}}
    } {point { MAP }}

    pixels {
	#define SD (idomain->depth)
	#define SH (idomain->height)
	#define SW (idomain->width)
	#define SX (request->x)
        #define SY (request->y)

	double phi   = param->phi   * M_PI / 180.0 ;
	double base  = param->from  * M_PI / 180.0 ;
	double decay = param->decay;
	double cx    = param->center.x;
	double cy    = param->center.y;

	// fprintf(stderr, "ZZ phi    %f\n", phi);
	// fprintf(stderr, "ZZ base   %f\n", base);
	// fprintf(stderr, "ZZ decay  %f\n", decay);
	// fprintf(stderr, "ZZ center (%f, %f)\n", cx, cy);

	#define DX    (((int) srcx) - cx)
	#define DY    (((int) srcy) - cy)
	#define THETA (atan2 (DY, DX))
	#define RAD   (hypot (DX, DY))

	#define RHO   (THETA + phi + (base * exp(-RAD * decay)))
	#define U     (cx + RAD * cos (RHO))
	#define V     (cy + RAD * sin (RHO))

	#define MAP (srcz == 0) ? (U) : (V)

	// Note: Let the compiler sort out all the common expressions
	//       in the equations for U and V.

	@@indexed@@

	#undef DX
	#undef DY
	#undef THETA
	#undef RAD
	#undef RHO
	#undef U
	#undef V
	#undef MAP
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
