## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Basic 2D geometry primitives
#
## - Single Circle
## - Many circles (dots)
## - Line segment

operator image::draw::circles {
    section generator virtual

    note Returns an image with the given dimensions and location

    note Returns an image with the given dimensions and location, showing \
	a series of circles or discs with radius and stroke width, \
	at the specified set of centers.

    note Beware, the location and size of the circles are independent of \
	the image. The operator is perfectly fine with drawing a set of \
	circles completely outside of the image domain.

    note The returned image is single-band, and normally black/white, with the \
	circle/disc in white. When aliasing is active however, partial border \
	points are fractionally blended into the background, resulting in a \
	gray-scale image.

    uint    width   Width of the returned image
    uint    height  Height of the returned image
    int?  0 x       Image location, X coordinate
    int?  0 y       Image location, Y coordinate
    bool? 0 filled  Default draws a circle. When set a filled disc is drawn instead
    bool? 0 alias   When set the circle's border is smoothed by blending with the background
    uint? 0 cwidth  Stroke width. Width of the circle's border
    uint? 1 radius  Circle radius
    point... center Circle centers

    body {
	# This is implemented as a set of circle images aggregated through `max`.
	aktive::aggregate {
	    aktive op math max
	} [lmap c $center {
	    aktive image draw circle \
		x $x y $y width $width height $height \
		radius $radius cwidth $cwidth center $c \
		filled $filled alias $alias
	}]
    }
}

operator image::draw::circle {
    section generator virtual

    note Returns an image with the given dimensions and location, showing \
	a circle or disc at the given center, radius, and stroke width.

    note Beware, the location and size of the circle/disc are independent \
	of the image. The operator is perfectly fine with drawing a circle \
	completely outside of the image domain.

    note The returned image is single-band, and normally black/white, with the \
	circle/disc in white. When aliasing is active however, partial border \
        points are fractionally blended into the background, resulting in a \
	gray-scale image.

    uint    width   Width of the returned image
    uint    height  Height of the returned image
    int?  0 x       Image location, X coordinate
    int?  0 y       Image location, Y coordinate
    bool? 0 filled  Default draws a circle. When set a filled disc is drawn instead
    bool? 0 alias   When set the circle's border is smoothed by blending with the background
    uint? 0 cwidth  Stroke width. Width of the circle's border
    uint? 1 radius  Circle radius
    point   center  Circle center

    state -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
    }

    blit circle-bw {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	CIRCLE_BW (x, y)
    }}

    blit circle-grey {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	CIRCLE_GREY (x, y)
    }}

    blit disc-bw {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	DISC_BW (x, y)
    }}

    blit disc-grey {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	DISC_GREY (x, y)
    }}

    pixels {
	double      r      = param->radius;	// early cast to the type need during blit
	double      cx     = param->center.x;	// ditto
	double      cy     = param->center.y;	// ditto
	double      w      = param->cwidth;	// ditto
	aktive_uint filled = param->filled;
	aktive_uint alias  = param->alias;

	TRACE("center = @%d,%d", cx, cy);
	TRACE("radius =  %d", r);
	TRACE("width  =  %d", w);
	TRACE("filled =  %d", filled);
	TRACE("alias  =  %d", alias);

	#define CIRCLE_BW(x,y)   aktive_circle_bw   (aktive_circle_distance (x, y, cx, cy), r, w)
	#define DISC_BW(x,y)     aktive_disc_bw     (aktive_circle_distance (x, y, cx, cy), r, w)
	#define CIRCLE_GREY(x,y) aktive_circle_grey (aktive_circle_distance (x, y, cx, cy), r, w)
	#define DISC_GREY(x,y)   aktive_disc_grey   (aktive_circle_distance (x, y, cx, cy), r, w)

	if (alias) {
	    if (filled) {
		// Needed for every case because the generated code undefs them
		#define SD (idomain->depth)
		#define SH (idomain->height)
		#define SW (idomain->width)
		#define SX (request->x)
		#define SY (request->y)
		@@disc-grey@@
	    } else {
		#define SD (idomain->depth)
		#define SH (idomain->height)
		#define SW (idomain->width)
		#define SX (request->x)
		#define SY (request->y)
		@@circle-grey@@
	    }
	} else {
	    if (filled) {
		#define SD (idomain->depth)
		#define SH (idomain->height)
		#define SW (idomain->width)
		#define SX (request->x)
		#define SY (request->y)
		@@disc-bw@@
	    } else {
		#define SD (idomain->depth)
		#define SH (idomain->height)
		#define SW (idomain->width)
		#define SX (request->x)
		#define SY (request->y)
		@@circle-bw@@
	    }
	}

	#undef CIRCLE_BW
	#undef DISC_BW
	#undef CIRCLE_GREY
	#undef DISC_GREY
    }
}

##
# # ## ### ##### ######## ############# #####################
##

operator image::draw::line {
    section generator virtual

    note Returns an image with the given dimensions and location, showing \
	a line segment between 2 points, with the specified stroke width.

    note Beware, the location and size of the line segment is independent \
	of the image. The operator is perfectly fine with drawing a segment \
	completely outside of the image domain.

    note The returned image is single-band, and normally black/white, with the \
	line segment in white. When aliasing is active however, partial border \
        points are fractionally blended into the background, resulting in a \
	gray-scale image.

    uint    width        Width of the returned image
    uint    height       Height of the returned image
    int?  0 x            Image location, X coordinate
    int?  0 y            Image location, Y coordinate
    bool? 0 alias        When set the segments's border is smoothed by blending with the background
    uint? 0 strokewidth  Width of the line segment
    point   from         Start point
    point   to           End point

    state -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
    }

    blit line-segment-bw {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	LINE_SEGMENT_BW (x, y)
    }}

    blit line-segment-grey {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	LINE_SEGMENT_GREY (x, y)
    }}

    pixels {
	aktive_point* pstart = &param->from;
	aktive_point* pend   = &param->to;
	aktive_point  here;
	double        w      = param->strokewidth;
	aktive_uint   alias  = param->alias;

	TRACE("from  = @%d,%d", pstart->x, pstart->y);
	TRACE("to    = @%d,%d", pend->x, pend->y);
	TRACE("width = %d", w);
	TRACE("alias = %d", alias);

	#define LINE_SEGMENT_BW(x,y)   aktive_line_segment_bw   (aktive_line_segment_distance (x, y, pstart, pend), w)
	#define LINE_SEGMENT_GREY(x,y) aktive_line_segment_grey (aktive_line_segment_distance (x, y, pstart, pend), w)

	if (alias) {
	    #define SD (idomain->depth)
	    #define SH (idomain->height)
	    #define SW (idomain->width)
	    #define SX (request->x)
	    #define SY (request->y)
	    @@line-segment-grey@@
	} else {
	    #define SD (idomain->depth)
	    #define SH (idomain->height)
	    #define SW (idomain->width)
	    #define SX (request->x)
	    #define SY (request->y)
	    @@line-segment-bw@@
	}

	#undef LINE_SEGMENT_BW
	#undef LINE_SEGMENT_GREY
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
