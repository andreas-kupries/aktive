## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- signed distance fields

#
# SDF manipulations .............................
#
# Example elements:
#
# 1. set box    [aktive image sdf box-rounded width 1000 height 1000 ewidth 400 eheight 200 center {500 500} downrightradius 100]
# 2. set circle [aktive image sdf circle width 1000 height 1000 radius 200 center {500 300}]
#
# Singular manipulations ........................
#
#  <> is the place holder for the operation converting the SDF into a regular image (not `fit`).
#
# (a) image = (1).<>                          -> filled box
# (b)       = (1).abs.<>                      -> outlined box
# (c)       = (1).ring(15).<>                 -> thick outlined box
# (d)       = (1).ring(15).abs.<>             -> double outlined box
# (e)       = (1).abs.ring(15).<>             -> See (c), abs has no effect
# (f)       = (1).ring(15).abs.ring(2).<>     -> double thick outlined box
# (g)       = (1).ring(15).abs.ring(2).abs.<> -> quadruple outlined box
#
# Combining SDFs ................................
#
#   Basic combiners:
#
#     min                   -> or, union
#     max                   -> and, intersection
#     neg                   -> not, inversion
#
#     and (a, not b)        -> sub/traction
#     sub (a or b, a and b) -> xor, symmetric difference
#
#   abs  or not before combining, per element
#   ring or not before combining, per element
#
#   abs         after combining -- See above, singular manipulations
#   ring        after combining -- See above, singular manipulations
#
#     (1) (2) combiner
# -------+---+----
# (a)         min -> union  filled   circle, filled   box
# (b) abs     min -> union  filled   circle, outlined box
# (c)     abs min -> union  outlined circle, filled   box
# (d) abs abs min -> union  outlined circle, outlined box
#
# (e)         max -> isect  filled   circle, filled   box
# (f) abs     max -> isect  filled   circle, outlined box (box outline in circle)
# (g)     abs max -> isect  outlined circle, filled   box (circle outline in box)
# (h) abs abs max -> isect  outlined circle, outlined box (points, circle/box crossings)
#
# (i)         add -> (*)
# (j) abs     add -> (*)
# (k)     abs add -> (*)
# (l) abs abs add -> See (h)
#
# (m)         sub -> (*)
# (n) abs     sub -> (*)
# (o)     abs sub -> (*)
# (p) abs abs sub -> (*)
#
# (*) Weird gradient? shapes
#
# Note that SDF make interesting images of their own when fit/compressed into the [0..1]
# range. Terrain pseudo 3D display through shading.
#

# # ## ### ##### ######## ############# #####################
## SDF primitives

operator image::sdf::box {
    section generator virtual sdf

    note Returns an image holding the signed distance field of an \
	axis-aligned box of 2*ewidth+1 and 2*eheight+1 and the \
	specified center.

    def element box ; import sdf-note.tcl

    uint     width      Width of the returned image
    uint     height     Height of the returned image
    int?  0  x          Image location, X coordinate
    int?  0  y          Image location, Y coordinate

    uint? 1  ewidth   Element width
    uint? 1  eheight  Element height
    point    center   Element center

    state -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
    }

    blit box-sdf {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	BOX (x, y)
    }}

    pixels {
	double w  = param->ewidth;
	double h  = param->eheight;
	double cx = param->center.x;
	double cy = param->center.y;

	TRACE("center     = @%d,%d", param->center.x, param->center.y);
	TRACE("box width  =  %d", param->ewidth);
	TRACE("box height =  %d", param->eheight);

	#define BOX(x,y) aktive_sdf_box (aktive_sdf_translate (x, y, cx, cy), w, h)
	#define SD         (idomain->depth)
	#define SH         (idomain->height)
	#define SW         (idomain->width)
	#define SX         (request->x)
	#define SY         (request->y)

	@@box-sdf@@

	#undef BOX
    }
}

operator image::sdf::box-rounded {
    section generator virtual sdf

    note Returns an image holding the signed distance field of an \
	axis-aligned box of 2*ewidth+1 and 2*eheight+1, rounded corners, \
	and the specified center.

    def element box ; import sdf-note.tcl

    uint     width      Width of the returned image
    uint     height     Height of the returned image
    int?  0  x          Image location, X coordinate
    int?  0  y          Image location, Y coordinate

    uint? 0  upleftradius    Radius of element at upper left corner
    uint? 0  uprightradius   Radius of element at upper right corner
    uint? 0  downleftradius  Radius of element at lower left corner
    uint? 0  downrightradius Radius of element at lower right corner

    uint? 1  ewidth          Element width
    uint? 1  eheight         Element height
    point    center          Element center

    state -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
    }

    blit box-rounded-sdf {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	BOX (x, y)
    }}

    pixels {
	double w  = param->ewidth;	//    [3]...[1] - r: corner radii mapping
	double h  = param->eheight;	//     .     .
	double cx = param->center.x;	//     .     .
	double cy = param->center.y;	//    [2]...[0]
	double r[4];                    // <-/

	r[0] = param->downrightradius;
	r[1] = param->uprightradius;
	r[2] = param->downleftradius;
	r[3] = param->upleftradius;

	TRACE("center            = @%d,%d", param->center.x, param->center.y);
	TRACE("box width         =  %d", param->ewidth);
	TRACE("box height        =  %d", param->eheight);
	TRACE("up   left  radius =  %d", param->upleftradius);
	TRACE("up   right radius =  %d", param->uprightradius);
	TRACE("down left  radius =  %d", param->downleftradius);
	TRACE("down right radius =  %d", param->downrightradius);

	#define BOX(x,y) aktive_sdf_box_rounded (aktive_sdf_translate (x, y, cx, cy), w, h, r)
	#define SD         (idomain->depth)
	#define SH         (idomain->height)
	#define SW         (idomain->width)
	#define SX         (request->x)
	#define SY         (request->y)

	@@box-rounded-sdf@@

	#undef BOX
    }
}

operator image::sdf::circles {
    section generator virtual sdf

    note Returns an image holding the signed distance field of the union \
	of a set of circles with radius, and the specified centers.

    def element {set of circles} ; import sdf-note.tcl

    uint     width      Width of the returned image
    uint     height     Height of the returned image
    int?  0  x          Image location, X coordinate
    int?  0  y          Image location, Y coordinate

    uint? 1  radius     Circle radius
    point... centers    Circle centers

    body {
	aktive op sdf or {*}[lmap c $centers {
	    aktive image sdf circle x $x y $y width $width height $height \
		radius $radius center $c
	}]
    }
}

operator image::sdf::circle {
    section generator virtual sdf

    note Returns an image holding the signed distance field of a \
	circle with radius, and the specified center.

    def element circle ; import sdf-note.tcl

    uint     width      Width of the returned image
    uint     height     Height of the returned image
    int?  0  x          Image location, X coordinate
    int?  0  y          Image location, Y coordinate

    uint? 1  radius     Circle radius
    point    center     Circle center

    state -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
    }

    blit circle-sdf {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	CIRCLE (x, y)
    }}

    pixels {
	double r  = param->radius;	// early cast to the type need during blit
	double cx = param->center.x;	// ditto
	double cy = param->center.y;	// ditto

	TRACE("center = @%d,%d", param->center.x, param->center.y);
	TRACE("radius = %d",     param->radius);

	#define CIRCLE(x,y) aktive_sdf_circle (aktive_sdf_translate (x, y, cx, cy), r)
	#define SD         (idomain->depth)
	#define SH         (idomain->height)
	#define SW         (idomain->width)
	#define SX         (request->x)
	#define SY         (request->y)

	@@circle-sdf@@

	#undef CIRCLE
    }
}

operator image::sdf::parallelogram {
    section generator virtual sdf

    note Returns an image holding the signed distance field of an \
	axis-aligned parallelogram of 2*ewidth+1, 2*eheight+1, skew, \
	and the specified center.

    def element parallelogram ; import sdf-note.tcl

    uint     width      Width of the returned image
    uint     height     Height of the returned image
    int?  0  x          Image location, X coordinate
    int?  0  y          Image location, Y coordinate

    uint? 1  ewidth   Element width
    uint? 1  eheight  Element height
    uint? 1  eskew    Element skew
    point    center   Element center

    state -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
    }

    blit parallelogram-sdf {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	PARALLELOGRAM (x, y)
    }}

    pixels {
	double w    = param->ewidth;
	double h    = param->eheight;
	double skew = param->eskew;
	double cx   = param->center.x;
	double cy   = param->center.y;

	TRACE("center               = @%d,%d", param->center.x, param->center.y);
	TRACE("parallelogram width  =  %d", param->ewidth);
	TRACE("parallelogram height =  %d", param->eheight);
	TRACE("parallelogram skew   =  %d", param->eskew);

	#define PARALLELOGRAM(x,y) aktive_sdf_parallelogram \
	    (aktive_sdf_translate (x, y, cx, cy), \
		 w, h, skew)
	#define SD         (idomain->depth)
	#define SH         (idomain->height)
	#define SW         (idomain->width)
	#define SX         (request->x)
	#define SY         (request->y)

	@@parallelogram-sdf@@

	#undef PARALLELOGRAM
    }
}

operator image::sdf::rhombus {
    section generator virtual sdf

    note Returns an image holding the signed distance field of an \
	axis-aligned rhombus of 2*ewidth+1, 2*eheight+1, and the \
	specified center.

    def element rhombus ; import sdf-note.tcl

    uint     width      Width of the returned image
    uint     height     Height of the returned image
    int?  0  x          Image location, X coordinate
    int?  0  y          Image location, Y coordinate

    uint? 1  ewidth   Element width
    uint? 1  eheight  Element height
    point    center   Element center

    state -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);
    }

    blit rhombus-sdf {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	RHOMBUS (x, y)
    }}

    pixels {
	double w  = param->ewidth;
	double h  = param->eheight;
	double cx = param->center.x;
	double cy = param->center.y;

	TRACE("center         = @%d,%d", param->center.x, param->center.y);
	TRACE("rhombus width  =  %d", param->ewidth);
	TRACE("rhombus height =  %d", param->eheight);

	#define RHOMBUS(x,y) aktive_sdf_rhombus (aktive_sdf_translate (x, y, cx, cy), w, h)
	#define SD         (idomain->depth)
	#define SH         (idomain->height)
	#define SW         (idomain->width)
	#define SX         (request->x)
	#define SY         (request->y)

	@@rhombus-sdf@@

	#undef RHOMBUS
    }
}

operator image::sdf::segments {
    section generator virtual sdf

    note Returns an image holding the signed distance field of the union of \
	a set of line segments connecting the specified locations.

    note In other words, a poly-line.

    def element poly-line ; import sdf-note.tcl

    uint     width      Width of the returned image
    uint     height     Height of the returned image
    int?  0  x          Image location, X coordinate
    int?  0  y          Image location, Y coordinate

    point... points     Points the poly-line goes through.

    body {
	aktive op sdf or {*}[lmap a [lrange $points 0 end-1] b [lrange $points 1 end] {
	    aktive image sdf segment x $x y $y width $width height $height \
		from $a to $b
	}]
    }
}

operator image::sdf::segment {
    section generator virtual sdf

    note Returns an image holding the signed distance field of a \
	line segment between the specified locations.

    def element {line segment} ; import sdf-note.tcl

    uint     width      Width of the returned image
    uint     height     Height of the returned image
    int?  0  x          Image location, X coordinate
    int?  0  y          Image location, Y coordinate

    point    from       Segment start
    point    to         Segment end

    state -fields {
	aktive_segment_spec spec;
    } -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);

	// Precompute common values for the SDF calculation

	double dx   = param->to.x - param->from.x;
	double dy   = param->to.y - param->from.y;
	double ddot = dx*dx + dy* dy;

	state->spec.from.x  = (double) param->from.x;
	state->spec.from.y  = (double) param->from.y;
	state->spec.delta.x = dx;
	state->spec.delta.y = dy;
	state->spec.ddot    = ddot;
    }

    blit segment-sdf {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	SEGMENT (x, y)
    }}

    pixels {
	TRACE("from      = @%d,%d", param->from.x, param->from.y);
	TRACE("to        = @%d,%d", param->to.x,   param->to.y);
	TRACE("delta     = %f, %f", istate->spec.delta.x, istate->spec.delta.y);
	TRACE("dot.delta = %f",     istate->spec.ddot);

	#define SEGMENT(x,y) aktive_sdf_segment_precoded (x, y, &istate->spec)
	#define SD         (idomain->depth)
	#define SH         (idomain->height)
	#define SW         (idomain->width)
	#define SX         (request->x)
	#define SY         (request->y)

	@@segment-sdf@@

	#undef SEGMENT
    }
}

operator image::sdf::triangle {
    section generator virtual sdf

    note Returns an image holding the signed distance field of a \
	triangle between the locations A, B, and C, in this order.

    def element triangle ; import sdf-note.tcl

    uint     width      Width of the returned image
    uint     height     Height of the returned image
    int?  0  x          Image location, X coordinate
    int?  0  y          Image location, Y coordinate

    point    a          Triangle point A
    point    b          Triangle point B
    point    c          Triangle point C

    state -fields {
	aktive_triangle_spec spec;
    } -setup {
	aktive_geometry_set (domain, param->x, param->y, param->width, param->height, 1);

	#define DOTSELF(x,y) ((x)*(x) + (y)*(y))

	// Precompute common values for the SDF calculation
	state->spec.a.x     = param->a.x;
	state->spec.a.y     = param->a.y;
	state->spec.b.x     = param->b.x;
	state->spec.b.y     = param->b.y;
	state->spec.c.x     = param->c.x;
	state->spec.c.y     = param->c.y;
	state->spec.ba.x    = param->b.x - param->a.x;
	state->spec.ba.y    = param->b.y - param->a.y;
	state->spec.cb.x    = param->c.x - param->b.x;
	state->spec.cb.y    = param->c.y - param->b.y;
	state->spec.ac.x    = param->a.x - param->c.x;
	state->spec.ac.y    = param->a.y - param->c.y;
	state->spec.badot   = DOTSELF (state->spec.ba.x, state->spec.ba.y);
	state->spec.cbdot   = DOTSELF (state->spec.cb.x, state->spec.cb.y);
	state->spec.acdot   = DOTSELF (state->spec.ac.x, state->spec.ac.y);
	state->spec.bacsign = aktive_sign (  state->spec.ba.x * state->spec.ac.y
					   - state->spec.ba.y * state->spec.ac.x);
	#undef DOTSELF
    }

    blit triangle-sdf {
	{AH {y AY 1 up} {y SY 1 up}}
	{AW {x AX 1 up} {x SX 1 up}}
    } {point/2d {
	TRIANGLE (x, y)
    }}

    pixels {
	TRACE("point A = @%d,%d", param->a.x, param->a.y);
	TRACE("point B = @%d,%d", param->b.x, param->b.y);
	TRACE("point C = @%d,%d", param->c.x, param->c.y);

	#define TRIANGLE(x,y) aktive_sdf_triangle_precoded (x, y, &istate->spec)
	#define SD         (idomain->depth)
	#define SH         (idomain->height)
	#define SW         (idomain->width)
	#define SX         (request->x)
	#define SY         (request->y)

	@@triangle-sdf@@

	#undef TRIANGLE
    }
}

# # ## ### ##### ######## ############# #####################
## Supporting operators I -- boolean combiners/modifiers

operator op::sdf::not {
    section transform sdf

    note Returns the inverted input SDF, where inside and outside changed places.

    input

    body {
	aktive op math1 neg $src
    }
}

operator op::sdf::or {
    section transform sdf combiner

    note Returns the union A or B or ... of the input SDFs

    input...

    body {
	aktive op math min {*}$args
    }
}

operator op::sdf::and {
    section transform sdf combiner

    note Returns the intersection A and B and ... of the input SDFs

    input...

    body {
	aktive op math max {*}$args
    }
}

operator op::sdf::sub {
    section transform sdf combiner

    note Returns the difference A - B of the two input SDFs

    input	;# A
    input	;# B

    body {
	# The difference A-B is the intersection of A and (not B)
	and $src0 [not $src1]
    }
}

operator op::sdf::xor {
    section transform sdf combiner

    note Returns the symmetric difference of the input SDFs

    input...

    body {
	aktive::aggregate {
	    aktive op sdf xor-core
	} $args
    }
}

operator op::sdf::xor-core {
    section transform sdf combiner

    note Returns the symmetric difference of the two input SDFs

    input
    input

    body {
	# The symmetric difference is the union minus the intersection
	sub [or $src0 $src1] [and $src0 $src1]
    }
}

# # ## ### ##### ######## ############# #####################
## Supporting operators II -- appearance modulation

operator op::sdf::ring {
    section transform sdf

    note Combines outlining and rounding to replace the input SDF with \
	an SDF tracing the border at some thickness and returns the result.

    note The result is annular, i.e. has a ring/onion-like structure.

    note Note that a thickness of zero devolves this operation to a plain \
	outline.

    input
    uint thickness Desired border thickness.

    body {
	round [outline $src] radius $thickness
    }
}

operator op::sdf::outline {
    section transform sdf

    note Replaces the input SDF with an outlined form, and returns the result.

    note This is implemented by taking the absolute of the input.

    input

    body {
	aktive op math1 abs $src
    }
}

operator op::sdf::round {
    section transform sdf

    note Replaces the input SDF with a more rounded form per the radius, \
	and returns the result.

    note This is implemented by shifting the input SDF down by the radius.

    note For a radius > 0 this expands the SDF, making the encoded element \
	rounder. A radius < 0 conversely shrinks the SDF.

    note To get a rounded SDF at the original size use a pre-shrunken/expanded \
	SDF as the input to compensate the changes made by this operator.

    note A radius of zero is ignored.

    input
    uint radius Expansion/Shrinkage radius for the SDF.

    body {
	if {$radius == 0} { return $src }
	aktive op math1 shift $src offset [expr {- $radius}]
    }
}

# # ## ### ##### ######## ############# #####################
## Supporting operators III -- Conversions into image

operator op::sdf::2image::fit {
    section transform sdf

    note Compresses the input SDF into the range 0..1 and returns the resulting grayscale image.

    input

    body {
	aktive op math1 fit min-max $src
    }
}

operator op::sdf::2image::smooth {
    section transform sdf

    note Converts the SDF into a grey-scale image with anti-aliased element borders.

    input

    body {
	set src [aktive op math1 clamp $src]
	set src [aktive op math1 invert $src]
    }
}

operator op::sdf::2image::pixelated {
    section transform sdf

    note Converts the SDF into a b/w-scale image with pixelated element borders.

    input

    body {
	aktive op math1 lt $src threshold 0.5
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
