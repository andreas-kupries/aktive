## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Basic 2D geometrey primitives

operator image::draw::circle {
    section generator virtual

    note Returns an image at the specified location with the given \
	dimension, where a (possibly filled) circle is drawn, at \
	given center and radius.

    note Beware, the location and size of the circle are independent of the image. \
	The operator is perfectly fine with getting a circle completely outside of \
	the image domain.

    note The returned image is single-band, and normally black/white, with the \
	circle points in white. When aliasing is active however, then partial \
	border points will be fractionally blended into the background, making \
	the result gray-scale.

    uint   width   Width of the returned image
    uint   height  Height of the returned image
    int? 0 x       Image location, X coordinate
    int? 0 y       Image location, Y coordinate

    point   center Circle center
    uint? 1 radius Circle radius

    bool? 0 filled Default is an unfilled circle. Filled makes it a disc.
    bool? 0 alias  If set smooths circle border by blending with the background
    uint? 0 cwidth Width of the circle's border.

    state -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
    }

    blit circle {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point {
	ISPIXEL (x, y)
    }}

    blit circle-alias {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point {
	ISPIXEL_A (x, y)
    }}

    blit circle-filled {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point {
	ISPIXEL_F (x, y)
    }}

    blit circle-alias-filled {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point {
	ISPIXEL_FA (x, y)
    }}

    pixels {
	double      r      = param->radius;	// early cast to the type need during blit
	double      cx     = param->center.x;	// ditto
	double      cy     = param->center.y;	// ditto
	double      w      = param->cwidth;	// ditto
	aktive_uint filled = param->filled;
	aktive_uint alias  = param->alias;

	TRACE("center.x = %d", cx);
	TRACE("center.y = %d", cy);
	TRACE("radius   = %d", r);
	TRACE("width    = %d", w);
	TRACE("filled   = %d", filled);
	TRACE("alias    = %d", alias);

	double d;
	#define DIST(x,y) d = hypot ((double) (x) - cx, (double) (y) - cy)
	#define CLIP(v)   fmax(0, fmin (1, (v)))

	#define ISPIXEL(x,y)	( DIST(x,y), (abs(d-r) <= w)     ? 1 : 0 )
	#define ISPIXEL_F(x,y)  ( DIST(x,y), (d     <= (r+w))    ? 1 : 0 )
	#define ISPIXEL_A(x,y)  ( DIST(x,y), (abs(d-r) <= (w+1)) ? CLIP(1-(abs(d-r)-w)) : 0 )
	#define ISPIXEL_FA(x,y) ( DIST(x,y), (d      <= (r+w+1)) ? CLIP(1-(d-(r+w)))    : 0 )

	if (alias) {
	    if (filled) {
		// Needed for every loop because each undefs them
		#define SD (idomain->depth)
		#define SH (idomain->height)
		#define SW (idomain->width)
		#define SX (request->x)
		#define SY (request->y)
		@@circle-alias-filled@@
	    } else {
		#define SD (idomain->depth)
		#define SH (idomain->height)
		#define SW (idomain->width)
		#define SX (request->x)
		#define SY (request->y)
		@@circle-alias@@
	    }
	} else {
	    if (filled) {
		#define SD (idomain->depth)
		#define SH (idomain->height)
		#define SW (idomain->width)
		#define SX (request->x)
		#define SY (request->y)
		@@circle-filled@@
	    } else {
		#define SD (idomain->depth)
		#define SH (idomain->height)
		#define SW (idomain->width)
		#define SX (request->x)
		#define SY (request->y)
		@@circle@@
	    }
	}

	#undef ISPIXEL
	#undef ISPIXEL_A
	#undef ISPIXEL_F
	#undef ISPIXEL_FA
	#undef DIST
	#undef CLIP
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
