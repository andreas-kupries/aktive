## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Rotate in 90 degree increments
## - Arbitrary rotation by affine transform.

operator op::rotate::cw   {
    section transform structure

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1
    }

    note Returns image rotating the input 90 degrees clockwise.

    input

    body {
	aktive op flip x [aktive op swap xy $src]
    }
}

operator op::rotate::ccw  {
    section transform structure

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1
    }

    note Returns image rotating the input 90 degrees counter clockwise

    input

    body {
	aktive op flip y [aktive op swap xy $src]
    }
}

operator op::rotate::half {
    section transform structure

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1
    }

    note Returns image rotating the input 180 degrees (counter) clockwise.

    input

    body {
	aktive op flip x [aktive op flip y $src]
    }
}

operator op::rotate::any   {
    section transform structure

    example {
	dot green {32 32} [sines]
	@1 by 33 around {32 32} | sframe
    }

    note Returns image rotating the input at an arbitrary angle around an arbitrary center. The default center is the image center.

    note This is a convenience operator implemented on top of "<!xref: aktive op transform by>."

    double      by     In degrees, angle to rotate
    point? {{}} around Rotation center. Default is the origin

    str? bilinear interpolate   \[Interpolation method](interpolation.md) to use.

    input

    body {
	aktive op transform by \
	    [aktive transform rotate around $around by $by] \
	    $src \
	    interpolate $interpolate
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
