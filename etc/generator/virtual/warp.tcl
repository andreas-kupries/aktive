## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Affine and projevtive transformation matrices

# https://medium.com/@junfeng142857/
#                    affine-transformation-why-3d-matrix-for-a-2d-transformation-8922b08bce75

operator transform::compose {
    section generator virtual warp

    note Takes any number of 3x3 projective transformation matrices and returns their \
	composition.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    strict all \
	All projective matrices are materialized \
	and then used to compute the composition.

    # from right to left: translate, then rotate, then translate back
    # => rotation around the non-origin point (5,6)
    example {
	aktive transform translate dx -5 dy -6 | -matrix
	aktive transform rotate by 45          | -matrix
	aktive transform translate dx 5 dy 6   | -matrix
	@1 @2 @3                               | -matrix
    }

    input...

    body {
	aktive::aggregate {aktive transform compose-core} $args
    }
}

operator transform::compose-core {
    section generator virtual warp

    note Takes two 3x3 projective transformation matrices and returns their composition.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    strict both \
	The two projective matrices are materialized \
	and then used to compute the composition A*B.

    # from right to left: translate, then rotate
    example {
	aktive transform rotate by 45        | -matrix
	aktive transform translate dx 5 dy 6 | -matrix
	@1 @2                                | -matrix
    }

    # from right to left: rotate, then translate
    example {
	aktive transform translate dx 5 dy 6 | -matrix
	aktive transform rotate by 45        | -matrix
	@1 @2                                | -matrix
    }

    input
    input

    body {
	lassign [aktive query domain $src0] _ _ aw ah
	if {($aw != 3) || ($ah != 3)} { aktive error "input A is not a projective matrix" }
	lassign [aktive query domain $src1] _ _ bw bh
	if {($bw != 3) || ($bh != 3)} { aktive error "input B is not a projective matrix" }

	set a [aktive query values $src0]
	set b [aktive query values $src1]

	lassign $a aa ab ac ad ae af ag ah ai
	lassign $b ba bb bc bd be bf bg bh bi

	# | aa ab ac |   | ba bb bc |   | aa*ba+ab*bd+ac*bg aa*bb+ab*be+ac*bh aa*bc+ab*bf+ac*bi |
	# | ad ae af | * | bd be bf | = | ad*ba+ae*bd+af*bg ad*bb+ae*be+af*bh ad*bc+ae*bf+af*bi |
	# | ag ah ai |   | bg bh bi |   | ag*ba+ah*bd+ai*bg ag*bb+ah*be+ai*bh ag*bc+ah*bf+ai*bi |

	# unrolled matrix multiplication
	set a [expr { $aa*$ba + $ab*$bd + $ac*$bg }]
	set b [expr { $aa*$bb + $ab*$be + $ac*$bh }]
	set c [expr { $aa*$bc + $ab*$bf + $ac*$bi }]
	set d [expr { $ad*$ba + $ae*$bd + $af*$bg }]
	set e [expr { $ad*$bb + $ae*$be + $af*$bh }]
	set f [expr { $ad*$bc + $ae*$bf + $af*$bi }]
	set g [expr { $ag*$ba + $ah*$bd + $ai*$bg }]
	set h [expr { $ag*$bb + $ah*$be + $ai*$bh }]
	set i [expr { $ag*$bc + $ah*$bf + $ai*$bi }]

	aktive image from matrix width 3 height 3 values $a $b $c $d $e $f $g $h $i
    }
}

operator transform::scale {
    section generator virtual warp

    note Returns a single-band 3x3 image specifying a scaling by x- and y factors.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double? 1 xf Scaling factor for x-axis
    double? 1 yf Scaling factor for y-axis

    example {xf 3 yf 0.5 | -matrix}

    # | xf  0 0 |
    # | 0  yf 0 |
    # | 0   0 1 |
    body {
	affine \
	    a $xf b 0 c 0 \
	    d 0 e $yf f 0
    }
}

operator transform::translate {
    section generator virtual warp

    note Returns a single-band 3x3 image specifying a translation by x- and y offsets.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double? 0 dx Translation offset for x-axis
    double? 0 dy Translation offset for y-axis

    example {dx 3 dy 0.5 | -matrix}

    # | 1 0 dx |
    # | 0 1 dy |
    # | 0 0  1 |
    body {
	affine \
	    a 1 b 0 c $dx \
	    d 0 e 1 f $dy
    }
}

operator transform::shear::x {
    section generator virtual warp

    note Returns a single-band 3x3 image specifying a shearing along the x-axis.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double by	Shear by this many pixels along the x-axis

    example {by 10 | -matrix}

    # | 1 n 0 |
    # | 0 1 0 |
    # | 0 0 1 |
    body {
	aktive transform affine \
	    a 1 b $by c 0 \
	    d 0 e 1   f 0
    }
}

operator transform::shear::y {
    section generator virtual warp

    note Returns a single-band 3x3 image specifying a shearing along the y-axis.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double by	Shear by this many pixels along the y-axis

   example {by 10 | -matrix}

    # | 1 0 0 |
    # | n 1 0 |
    # | 0 0 1 |
    body {
	aktive transform affine \
	    a 1   b 0 c 0 \
	    d $by e 1 f 0
    }
}

operator transform::rotate {
    section generator virtual warp

    note Returns a single-band 3x3 image specifying a rotation around the coordinate \
	origin, by the given angle (in degrees).

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    double by In degrees, angle to rotate

    # | c -s 0 | where c = cos angle,
    # | s  c 0 | and   s = sin angle
    # | 0  0 1 |
    example {by 45 | -matrix}

    body {
	set rad [expr {atan(1)/45}] ;# 4*atan(1) = pi, rad = pi/180 -> atan(1)*4/180 -> atan(1)/45
	set c   [expr {cos($by*$rad)}]
	set s   [expr {sin($by*$rad)}]
	set ns  [expr {- $s}]

	affine a $c b $ns c 0 d $c e $s f 0
    }
}

operator transform::affine {
    section generator virtual warp

    note Returns a single-band 3x3 image holding the affine \
	transformation specifed by the 6 parameters a to f.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    # | a b c |
    # | d e f |
    # | 0 0 1 |

    example {a 1 b 2 c 3 d 4 e 5 f 6 | -int -matrix}

    double a Parameter a of the affine transform
    double b Parameter b of the affine transform
    double c Parameter c of the affine transform
    double d Parameter d of the affine transform
    double e Parameter e of the affine transform
    double f Parameter f of the affine transform

    body {
	aktive image from matrix width 3 height 3 values $a $b $c $d $e $f 0 0 1
    }
}

operator transform::projective {
    section generator virtual warp

    note Returns a single-band 3x3 image holding the projective \
	transformation specifed by the 8 parameters a to h.

    note The result is suitable for use with "<!xref: aktive warp matrix>"

    # | a b c |
    # | d e f |
    # | g h 1 |

    example {a 1 b 2 c 3 d 4 e 5 f 6 g 7 h 8 | -int -matrix}

    double a Parameter a of the projective transform
    double b Parameter b of the projective transform
    double c Parameter c of the projective transform
    double d Parameter d of the projective transform
    double e Parameter e of the projective transform
    double f Parameter f of the projective transform
    double g Parameter g of the projective transform
    double h Parameter h of the projective transform

    body {
	aktive image from matrix width 3 height 3 values $a $b $c $d $e $f $g $h 1
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
