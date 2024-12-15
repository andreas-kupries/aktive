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
# --> operations for and, or, not, xor, outlining, rounding, ...
#

# # ## ### ##### ######## ############# #####################
## SDF primitives

operator [sdf-known image::sdf::] {
    section generator virtual sdf

    op -> _ mode sdf

    def element [sdf-label $sdf]

    note Returns an image with the given dimensions and location, \
	containing the signed distance field of a $element.

    ref https://iquilezles.org/articles/distfunctions2d

    import sdf/note.tcl

    note See also "<!xref: aktive op draw $sdf on>" \
	and "<!xref: aktive image draw ${sdf}>."

    sdf-common-params

    import sdf/parameter/$sdf.tcl
    import sdf/coding/$sdf.tcl
}

# # ## ### ##### ######## ############# #####################
## Supporting operators I -- boolean combiners/modifiers

operator op::sdf::not {
    section transform sdf

    # !xref-mark sdf
    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	@1 | ; sdf-fit ; sdf-smooth ; sdf-pixelated
    }
    # !xref-mark /end

    note Returns the inverted input SDF, where inside and outside changed places. \
	This is defined as `1 - SRC`.

    ref https://iquilezles.org/articles/distfunctions2d

    input

    body {
	aktive op math1 neg $src
    }
}

operator op::sdf::or {
    section transform sdf combiner

    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	aktive image sdf box    center {48 48} width 128 height 128 ewidth 40 eheight 40
	@1 @2 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }

    note Returns the union (`+`, `min`) of all input SDFs.

    ref https://iquilezles.org/articles/distfunctions2d

    input...

    body {
	aktive op math min {*}$args
    }
}

operator op::sdf::and {
    section transform sdf combiner

    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	aktive image sdf box    center {48 48} width 128 height 128 ewidth 40 eheight 40
	@1 @2 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }

    note Returns the intersection (`*`, `max`) of all input SDFs.

    ref https://iquilezles.org/articles/distfunctions2d

    input...

    body {
	aktive op math max {*}$args
    }
}

operator op::sdf::sub {
    section transform sdf combiner

    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	aktive image sdf box    center {48 48} width 128 height 128 ewidth 40 eheight 40
	@1 @2 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }

    note Returns the difference `A - B` of the two input SDFs. \
	This is defined as `A * (not B)`.

    ref https://iquilezles.org/articles/distfunctions2d

    input a	SDF A
    input b	SDF B

    body {
	# The difference `A-B is the intersection of `A` and `not B`
	and $a [not $b]
    }
}

operator op::sdf::xor {
    section transform sdf combiner

    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	aktive image sdf box    center {48 48} width 128 height 128 ewidth 40 eheight 40
	@1 @2 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }

    note Returns the symmetric difference of all input SDFs.

    ref https://iquilezles.org/articles/distfunctions2d

    input...

    body {
	aktive::aggregate {
	    aktive op sdf xor-core
	} $args
    }
}

operator op::sdf::xor-core {
    section transform sdf combiner

    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	aktive image sdf box    center {48 48} width 128 height 128 ewidth 40 eheight 40
	@1 @2 | sdf-fit ; sdf-smooth ; sdf-pixelated
    }

    note Returns the symmetric difference of the two input SDFs. \
	This is defined as `(A + B) - (A * B)`.

    ref https://iquilezles.org/articles/distfunctions2d

    input a	SDF A
    input b	SDF B

    body {
	# The symmetric difference is the union minus the intersection
	sub [or $a $b] [and $a $b]
    }
}

# # ## ### ##### ######## ############# #####################
## Supporting operators II -- appearance modulation

operator op::sdf::ring {
    section transform sdf

    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	@1 thickness 4 | ; sdf-fit ; sdf-smooth ; sdf-pixelated
    }

    note Combines outlining and rounding to replace the input SDF with \
	an SDF tracing the border at some thickness and returns the result.

    note The result is annular, i.e. has a ring/onion-like structure.

    note Note that a thickness of zero devolves this operation to a plain \
	outline.

    ref https://iquilezles.org/articles/distfunctions2d

    input

    uint thickness Desired border thickness.

    body {
	round [outline $src] radius $thickness
    }
}

operator op::sdf::outline {
    section transform sdf

    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	@1 | ; sdf-fit ; sdf-smooth ; sdf-pixelated
    }

    note Replaces the input SDF with an outlined form, and returns the result.

    note This is implemented by taking the absolute of the input.

    ref https://iquilezles.org/articles/distfunctions2d

    input

    body {
	aktive op math1 abs $src
    }
}

operator op::sdf::round {
    section transform sdf

    example {
	aktive image sdf box center {64 64} width 128 height 128 ewidth 40 eheight 40
	@1 radius 20 | ; sdf-fit ; sdf-smooth ; sdf-pixelated
    }

    note Replaces the input SDF with a more rounded form per the radius, \
	and returns the result.

    note This is implemented by shifting the input SDF down by the radius.

    note For a radius > 0 this expands the SDF, making the encoded element \
	rounder. A radius < 0 conversely shrinks the SDF.

    note To get a rounded SDF at the original size use a pre-shrunken/expanded \
	SDF as the input to compensate the changes made by this operator.

    note A radius of zero is ignored.

    ref https://iquilezles.org/articles/distfunctions2d

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

    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	aktive image sdf box    center {48 48} width 128 height 128 ewidth 40 eheight 40
	aktive op sdf and @1 @2 | sdf-fit
    }

    note Compresses the input SDF into the range 0..1 and returns the resulting grayscale image.

    ref https://iquilezles.org/articles/distfunctions2d

    input

    body {
	aktive op math1 fit min-max $src
    }
}

operator op::sdf::2image::smooth {
    section transform sdf

    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	aktive image sdf box    center {48 48} width 128 height 128 ewidth 40 eheight 40
	aktive op sdf and @1 @2 | sdf-smooth
    }

    note Converts the SDF into a grey-scale image with anti-aliased element borders.

    ref https://iquilezles.org/articles/distfunctions2d

    input

    body {
	set src [aktive op math1 clamp $src]
	set src [aktive op math1 invert $src]
    }
}

operator op::sdf::2image::pixelated {
    section transform sdf

    example {
	aktive image sdf circle center {80 80} width 128 height 128 radius 40
	aktive image sdf box    center {48 48} width 128 height 128 ewidth 40 eheight 40
	aktive op sdf and @1 @2 | sdf-pixelated
    }

    note Converts the SDF into a black/white image with pixelated element borders.

    ref https://iquilezles.org/articles/distfunctions2d

    input

    body {
	aktive op math1 lt $src threshold 0.5
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
