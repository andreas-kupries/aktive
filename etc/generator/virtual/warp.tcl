## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Affine and projevtive transformation matrices

# https://medium.com/@junfeng142857/
#                    affine-transformation-why-3d-matrix-for-a-2d-transformation-8922b08bce75

operator transform::invert {
    section generator virtual warp

    example {
	aktive transform translate x -5 y -6 | -matrix -label translate x -5 y -6
	@1                                   | -matrix
    }
    example {
	aktive transform translate x -5 y -6 | -matrix -label translate x -5 y -6
	aktive transform invert @1           | -matrix -label invert
	aktive transform compose @1 @2       | -matrix
    }

    note Takes a single 3x3 projective transformation matrix and returns the \
	matrix of the inverted transformation. This is used to turn forward \
	into backward transformations, and vice versa.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    strict 1st \
	The projective matrix is materialized and \
	immediately used to compute the inversion.

    input

    body {
	# https://www.cuemath.com/algebra/inverse-of-3x3-matrix/
	return [BOX [Invert [UNBOX input $src]]]
    }
}

operator transform::compose {
    section generator virtual warp

    # from right to left: translate, then rotate, then translate back
    # => rotation around the non-origin point (5,6)
    example {
	aktive transform translate x -5 y -6 | -matrix -label translate x -5 y -6
	aktive transform rotate by 45        | -matrix -label rotate by 45
	aktive transform translate x 5 y 6   | -matrix -label translate x 5 y 6
	@1 @2 @3                             | -matrix -label rotate 45 around (5,6)
    }

    note Takes any number of 3x3 projective transformation matrices and returns their \
	composition.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    strict all \
	All projective matrices are materialized and \
	immediately used to compute the composition.

    input...

    body {
	aktive::aggregate {aktive transform compose-core} $args
    }
}

operator transform::compose-core {
    section generator virtual warp

    # from right to left: translate, then rotate
    example {
	aktive transform rotate by 45      | -matrix -label rotate
	aktive transform translate x 5 y 6 | -matrix -label translate
	@1 @2                              | -matrix -label rotate after translate
    }

    # from right to left: rotate, then translate
    example {
	aktive transform translate x 5 y 6 | -matrix -label rotate
	aktive transform rotate by 45      | -matrix -label translate
	@1 @2                              | -matrix -label translate after rotate
    }

    note Takes two 3x3 projective transformation matrices and \
	returns their composition.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    strict both \
	The two projective matrices are materialized \
	and immediately used to compute the composition A*B.

    input
    input

    body {
	BOX \
	    [Mul \
		 [UNBOX a $src0] \
		 [UNBOX b $src1]]
    }
}

operator transform::identity {
    section generator virtual warp

    example { | -matrix}

    note Returns a single-band 3x3 image containing the identity transform.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    # | 1 0 0 |
    # | 0 1 0 |
    # | 0 0 1 |
    body {
	BOXany \
	    1 0 0 \
	    0 1 0 \
	    0 0 1
    }
}

operator transform::scale {
    section generator virtual warp

    example {x 3 y 0.5 | -matrix}
    example {
	aktive transform scale x 3 y 0.5  | -matrix -label scale x 3 y 1/2
	aktive transform invert @1        | -matrix -label invert
    	aktive transform compose @1 @2    | -matrix
    }

    note Returns a single-band 3x3 image specifying a scaling by x- and y factors.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double? 1 x Scaling factor for x-axis
    double? 1 y Scaling factor for y-axis

    # | x 0 0 |
    # | 0 y 0 |
    # | 0 0 1 |
    body {
	BOXany \
	    $x 0  0 \
	    0  $y 0 \
	    0  0  1
    }
}

operator transform::translate {
    section generator virtual warp

    example {x 3 y 1 | -matrix}
    example {
	aktive transform translate x 3 y 1 | -matrix -label translate x 3 y 1
	aktive transform invert @1           | -matrix -label invert
	aktive transform compose @1 @2       | -matrix
    }

    note Returns a single-band 3x3 image specifying a translation by x- and y offsets.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double? 0 x Translation offset for x-axis
    double? 0 y Translation offset for y-axis

    # | 1 0 x |
    # | 0 1 y |
    # | 0 0 1 |
    body {
	BOXany \
	    1 0 $x \
	    0 1 $y \
	    0 0 1
    }
}

operator transform::shear {
    section generator virtual warp

    example {x 10    | -matrix}
    example {y 10    | -matrix}
    example {x 5 y 3 | -matrix}
    example {
	aktive transform shear x 5 y 3 | -matrix -label shear x 5 y 3
	aktive transform invert @1     | -matrix -label invert
	aktive transform compose @1 @2 | -matrix
    }

    note Returns a single-band 3x3 image specifying a shearing along the axes.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double? 0 x	Shear by this many pixels along the x-axis
    double? 0 y	Shear by this many pixels along the y-axis

    # | XY+1 X 0 |
    # | Y    1 0 |
    # | 0    0 1 |
    body {
	set z [expr {1+$x*$y}]
	BOXany \
	    $z $x 0 \
	    $y 1  0 \
	    0  0  1
    }
}

operator transform::rotate {
    section generator virtual warp

    example {by 45 | -matrix}
    example {
	aktive transform rotate by 45  | -matrix -label rotate by 45
	aktive transform invert @1     | -matrix -label invert
    	aktive transform compose @1 @2 | -matrix
    }

    note Returns a single-band 3x3 image specifying a rotation around the coordinate \
	origin, by the given angle (in degrees).

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double by In degrees, angle to rotate

    # | c -s 0 | where c = cos angle,
    # | s  c 0 | and   s = sin angle
    # | 0  0 1 |
    body {
	# note: atan(1)/45 is pi/180, given pi = 4*atan(1)
	set rad [/ [atan 1] 45]
	set c   [cos [* $by $rad]]
	set s   [sin [* $by $rad]]
	BOXany \
	    $c [- $s] 0 \
	    $s $c     0 \
	    0  0      1
    }
}

operator transform::quad::unit {
    section generator virtual warp

    example { a {1 2} b {6 1} c {7 6} d {2 7} | -matrix }
    example {
	aktive transform quad unit a {1 2} b {6 1} c {7 6} d {2 7} | -matrix
	aktive transform invert @1                                 | -matrix -label invert
    	aktive transform compose @1 @2                             | -matrix
    }

    note Returns a single-band 3x3 image transforming the unit square \
	to the specified quadrilateral.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    note The quadrilateral is specified as 4 points A-B-C-D in \
	counter clockwise order. The returned transform maps the \
	origin of the unit square to A and then the other points in \
	counter clockwise order.

    note To map between two arbitrary quadrilaterals A and B a composition \
	of two transforms is necessary and sufficient, i.e. mapping A to \
	the unit square (as inversion of the map from unit square to A), \
	followed by mapping the unit square to B. This is what \
	"<!xref: aktive transform quad quad>" does.

    point a Point A of the quadrilateral
    point b Point B of the quadrilateral
    point c Point C of the quadrilateral
    point d Point D of the quadrilateral

    body {
	# Calculate the transform from the unit rectangle to the specified quad.

	# Derived from the paper:
	#	A Planar Perspective Image Matching using Point Correspondences
	#	and Rectangle-to-Quadrilateral Mapping
	# By
	#	Dong-Keun Kim, Byung-Tae Jang, Chi-Jung Hwang
	# References
	#	http://portal.acm.org/citation.cfm?id=884607
	#	http://www.informatik.uni-trier.de/~ley/db/conf/ssiai/ssiai2002.html
	#	http://www.decew.net/OSS/References/Quadrilateral%20mapping.pdf
	#
	# Errata:
	# (a) Figure 1 in the paper has p2, p3 (p2', p3') swapped.
	# (b) The transform matrix A is transposed (or written for left-multiplication).

	# Map from top-left clock-wise for our y-axis.
	# Flipped relative to regular.
	#
	# *---*   *-------* <== Figure 1
	# |d c|   |p3' p2'|
	# |   | = |       |
	# |a b|   |p0' p1'|
	# *---*   *-------*

	lassign $a ax ay ; # x0, y0
	lassign $b bx by ; # x1, y1
	lassign $c cx cy ; # x2, y2
	lassign $d dx dy ; # x3, y3

	set dxd [expr {$ax - $bx + $cx - $dx}] ; # \delta x3
	set dyd [expr {$ay - $by + $cy - $dy}] ; # \delta y3

	set dxb [expr {$bx - $cx}]             ; # \delta x1
	set dxc [expr {$dx - $cx}]             ; # \delta x2

	set dyb [expr {$by - $cy}]             ; # \delta y1
	set dyc [expr {$dy - $cy}]             ; # \delta y2

	# det | dxb dyb |
	#     | dxc dyc |
	set D [expr {($dxb*$dyc - $dyb*$dxc)}]

	set g [expr {($dxd*$dyd - $dxc*$dyd)/double($D)}] ; # a6
	set h [expr {($dxb*$dyd - $dyb*$dxd)/double($D)}] ; # a7

	# note: a-d writes over the parameters now

	set a [expr {$bx * (1+$g) - $ax}] ; # a0
	set b [expr {$dx * (1+$h) - $ax}] ; # a1
	set c $ax                         ; # a2

	set d [expr {$by * (1+$g) - $ay}] ; # a3
	set e [expr {$dy * (1+$h) - $ay}] ; # a4
	set f $ay                         ; # a5

	# | a0 a3 a6 |   | a d g | => Errata (b), transpose.
	# | a1 a4 a7 | = | b e h |
	# | a2 a5 1  |   | c f 1 |
	BOXany \
	    $a $b $c \
	    $d $e $f \
	    $g $h 1
    }
}

operator transform::quad::quad {
    section generator virtual warp

    example { a {1 2} b {6 1} c {7 6} d {2 7}   e {0 3} f {7 1} g {8 7} h {1 7} | -matrix }
    example {
	aktive transform quad quad a {1 2} b {6 1} c {7 6} d {2 7}   e {0 3} f {7 1} g {8 7} h {1 7} | -matrix
	aktive transform invert @1     | -matrix -label invert
    	aktive transform compose @1 @2 | -matrix
    }

    note Returns a single-band 3x3 image transforming the specified \
	quadrilateral A to the second quadrilateral B.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    note The quadrilaterals are specified as 4 points A-B-C-D and \
	E-F-G-H in counter clockwise order. The returned transform \
	maps A to E and then the other points in counter clockwise \
	order.

    point a Point A of the quadrilateral A
    point b Point B of the quadrilateral A
    point c Point C of the quadrilateral A
    point d Point D of the quadrilateral A

    point e Point A of the quadrilateral B
    point f Point B of the quadrilateral B
    point g Point C of the quadrilateral B
    point h Point D of the quadrilateral B

    body {
	compose [unit a $e b $f c $g d $h] [invert [unit a $a b $b c $c d $d]]
    }
}
operator transform::reflect::x {
    section generator virtual warp

    example { | -matrix}
    example {
	aktive transform reflect x     | -matrix -label reflect x
	aktive transform invert @1     | -matrix -label invert
    	aktive transform compose @1 @2 | -matrix
    }

    note Returns a single-band 3x3 image specifying a reflection along the x-axis.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    note When not used as part of a chain of transformations then this is \
	better done using "<!xref: aktive op flip x>"

    body {
	BOXany \
	   -1 0 0 \
	    0 1 0 \
	    0 0 1
    }
}

operator transform::reflect::y {
    section generator virtual warp

    example { | -matrix}
    example {
	aktive transform reflect y        | -matrix -label reflect y
	aktive transform invert @1        | -matrix -label invert
    	aktive transform compose @1 @2    | -matrix
    }

    note Returns a single-band 3x3 image specifying a reflection along the y-axis.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    note When not used as part of a chain of transformations then this is \
	better done using "<!xref: aktive op flip y>"

    body {
	BOXany \
	    1  0 0 \
	    0 -1 0 \
	    0  0 1
    }
}

operator transform::reflect::line {
    section generator virtual warp

    example { a {5 3}           | -matrix}
    example {
	aktive transform reflect line a {5 3} | -matrix -label reflect line 0--A
	aktive transform invert @1            | -matrix -label invert
    	aktive transform compose @1 @2        | -matrix
    }

    example { a {5 3} b {-2 -2} | -matrix}
    example {
	aktive transform reflect line a {5 3} b {-2 -2} | -matrix -label reflect line A--B
	aktive transform invert @1                      | -matrix -label invert
    	aktive transform compose @1 @2                  | -matrix
    }

    note Returns a single-band 3x3 image specifying a reflection along \
	either the line through point A and the origin, \
	or the line through points A and B.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    point       a Point A of the line to reflect over
    point? {{}} b Point B of the line to reflect over. If not specified, the origin is used

    body {
	if {![llength $b]} {
	    # line through A and origin (0,0).
	    # this is handled as a chain of three transformations
	    # (1) rotate around the origin to map the line 0-A on the X-axis.
	    # (2) reflect along the Y!-axis
	    # (3) rotate revers around the origin, to get line 0-A back.
	    #
	    # note: 45/atan(1) is 180/pi, given pi = 4*atan(1)
	    lassign $a x y
	    set angle [expr {atan2($y, $x) * 45 / atan(1)}]
	    return [compose \
			[rotate by $angle] \
			[y] \
			[rotate by [- $angle]]]
	}

	# a line through two points A and B is handled by ta chain of three
	# transformations
	# (1) translating A to the origin 0.
	# (2) reflection through the line 0--(B-A)	[recursion]
	# (3) translating 0 back to A

	lassign $a ax ay
	lassign $b bx by
	set ba [list [- $bx $ax] [- $by $ay]]

	return [compose \
		    [translate x $ax y $ay] \
		    [line a $ba] \
		    [translate x [- $ax] y [- $ay]]]
    }
}

operator transform::affine {
    section generator virtual warp

    example {a 1 b 2 c 3 d 4 e 5 f 6 | -int -matrix}

    note Returns a single-band 3x3 image holding the affine \
	transformation specifed by the 6 parameters a to f.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double a Parameter a of the affine transform
    double b Parameter b of the affine transform
    double c Parameter c of the affine transform
    double d Parameter d of the affine transform
    double e Parameter e of the affine transform
    double f Parameter f of the affine transform

    # | a b c |
    # | d e f |
    # | 0 0 1 |
    body {
	BOXany \
	    $a $b $c \
	    $d $e $f \
	    0  0  1
    }
}

operator transform::projective {
    section generator virtual warp

    example {a 1 b 2 c 3 d 4 e 5 f 6 g 7 h 8 | -int -matrix}

    note Returns a single-band 3x3 image holding the projective \
	transformation specifed by the 8 parameters a to h.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double a Parameter a of the projective transform
    double b Parameter b of the projective transform
    double c Parameter c of the projective transform
    double d Parameter d of the projective transform
    double e Parameter e of the projective transform
    double f Parameter f of the projective transform
    double g Parameter g of the projective transform
    double h Parameter h of the projective transform

    # | a b c |
    # | d e f |
    # | g h 1 |
    body {
	BOXany \
	    $a $b $c \
	    $d $e $f \
	    $g $h 1
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
