## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Warping by means of a general projective transform

operator op::transform::by {
    section transform structure warp

    example {
	bframe [dot red {10 50} [butterfly]]         |
	aktive transform rotate by 30 around {10 50} | -matrix -label rotate by 30 around {10 50}
	@2 @1 | bframe
    }
    example {
	butterfly                          |
	aktive transform scale x 0.5 y 1.5 | -matrix -label scale x 0.5 y 1.5
	@2 @1
    }
    example {
	butterfly                        |
	aktive transform shear x 20 y 10 | -matrix -label shear x 20 y 10
	@2 @1
    }
    example {
	butterfly                  |
	aktive transform reflect x | -matrix -label reflect x
	@2 @1
    }
    example {
	butterfly                  |
	aktive transform reflect y | -matrix -label reflect y
	@2 @1
    }
    example {
	bframe [line red {50 260} {150 -10} [butterfly]]     |
	aktive transform reflect line a {50 260} b {150 -10} | -matrix -label reflect line {50 260} b {150 -10}
	@2 @1 | bframe
    }
    # !xref-mark affine location marker
    # !xref-mark affine
    example {
	dot green {190 10} [dot blue {210 80} [dot red {47 62} [poly red {{47 62} {190 10} {210 80} {100 125} {47 62}} [butterfly]]]] |
	aktive transform quad 2quad   a {47 62} b {190 10} c {210 80} d {100 125}   e {0 0} f {100 0} g {100 100} h {0 100}           | -matrix -label quadrilateral
	aktive op transform by @2 @1
	aktive op view @3 port {0 0 100 100}
    }
    # !xref-mark /end

    note Applies the projective __forward__ `transform` to the source image, \
	using some kind of pixel interpolation, and returns the result. \
	The default interpolation is `bilinear`.

    note The necessary backward transformation is computed internally.

    note The result's domain is set to the domain of the \
	forward transform applied to the input domain. \
	Fractions are rounded to integers such that the actual \
	bounding box is kept enclosed.

    note The result has depth of the image.

    note See "<!xref: aktive transform affine>" and its relatives \
	for a set of operations creating transformations acceptable \
	here.

    note The "<!xref: aktive op view>" operator is a useful means of focusing \
	on the desired part of a transformation result.

    strict 1st \
	The projective matrix is materialized for the calculation of \
	the backward transform.

    str? bilinear interpolate   Interpolation method to use

    input transform	Affine forward transformation.
    input src		The image to transform.

    body {
	lassign      [aktive transform domain $transform $src] x y w h
	set backward [aktive transform invert $transform]
	set origin   [aktive warp matrix $backward x $x y $y width $w height $h]

	aktive op warp $interpolate $origin $src
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
