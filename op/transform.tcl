# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2024 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Common support for affine and projective transforms.
## - Basic argument validation and unboxing
## - Boxing
## - Determinants of 2x2 and 3x3 matrices
## - Mat mul, inversion, cofactors, adjoint

namespace eval ::aktive::transform {
    # for simple expressions direct access to ops and funcs
    namespace import ::tcl::mathfunc::*
    namespace import ::tcl::mathop::*
}

proc aktive::transform::PRINT {label m} {
    lassign $m a b c d e f g h i
    join [list ----$label "$a\t$b\t$c" "$d\t$e\t$f" "$g\t$h\t$i"] \n
}

proc aktive::transform::BOXany {args} {
    BOX $args
}

proc aktive::transform::BOX {m} {
    aktive image from matrix width 3 height 3 values {*}$m
}

proc aktive::transform::UNBOX {label src} {
    lassign [aktive query domain $src] _ _ w h
    if {($w == 3) && ($h == 3)} {
	return [aktive query values $src]
    }
    aktive error "$label is not a projective transform"
    return
}

proc aktive::transform::MulVec {m v} {
    lassign $m a b c d e f g h i
    lassign $v x y

    # unrolled matrix vector multiplication
    set u [expr { $a*$x + $b*$y + $c*1 }]
    set v [expr { $d*$x + $e*$y + $f*1 }]
    set w [expr { $g*$x + $h*$y + $i*1 }]

    list [/ $u $w] [/ $v $w]
}

proc aktive::transform::Mul {a b} {
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

    list $a $b $c $d $e $f $g $h $i
}

proc aktive::transform::Invert {m} {
    ScaleDown [Adjoint $m] [DET3 $m]
}

proc aktive::transform::ScaleDown {m v} {
    lassign $m a b c d e f g h i
    set a [/ $a $v]
    set b [/ $b $v]
    set c [/ $c $v]
    set d [/ $d $v]
    set e [/ $e $v]
    set f [/ $f $v]
    set g [/ $g $v]
    set h [/ $h $v]
    set i [/ $i $v]
    list $a $b $c $d $e $f $g $h $i
}

proc aktive::transform::Adjoint {m} {
    # https://www.cuemath.com/algebra/inverse-of-3x3-matrix/
    # adjoint is the transposed cofactor
    # | a d g |
    # | b e h |
    # | c f i |
    lassign [Cofactors $m] a b c   d e f   g h i
    # transpose
    list $a $d $g   $b $e $h   $c $f $i
}

proc aktive::transform::Cofactors {m} {
    # https://www.cuemath.com/algebra/cofactor-matrix/
    # https://www.cuemath.com/algebra/inverse-of-3x3-matrix/
    lassign $m a b c d e f g h i
    # | a b c |
    # | d e f |
    # | g h i |
    set ca [DET2 $e $f $h $i]	;# cofactor matrix
    set cb [DET2 $d $f $g $i]	;# | +ca -cb +cc | 0
    set cc [DET2 $d $e $g $h]	;# | -cd +ce -cf | 1
    set cd [DET2 $b $c $h $i]	;# | +cg -ch +ci | 2
    set ce [DET2 $a $c $g $i]	;#   0   1   2
    set cf [DET2 $a $b $g $h]	;#
    set cg [DET2 $b $c $e $f]	;# note the alternating signs
    set ch [DET2 $a $c $d $f]	;# sign = (-1)^(i+j)
    set ci [DET2 $a $b $d $e]

    list $ca [- $cb] $cc   [- $cd] $ce [- $cf]   $cg [- $ch] $ci
}

proc aktive::transform::DET2 {a b c d} {
    # determinant of the 2x2 matrix
    ##
    # det | a b | = ad-bc / difference of the
    #     | c d |           products of the
    #                       diagonals
    expr {$a * $d - $b * $c}
}

proc aktive::transform::DET3 {m} {
    # determinant of the 3x3 matrix
    # https://www.cuemath.com/algebra/inverse-of-3x3-matrix/
    #
    # | a b c | => | a b c a b c | aei + bfg + cdh - afh - bdi - ceg
    # | d e f |	   |  \ \ x / /  |
    # | g h i |	   | d e f d e f |
    #		   |    x x x    |
    #		   | g h i g h i |
    #
    lassign $m a b c d e f g h i
    expr {$a*$e*$i + $b*$f*$g + $c*$d*$h - $a*$f*$h - $b*$d*$i - $c*$e*$g}
}

# # ## ### ##### ######## ############# #####################
## enable the deeper nested transform commands (reflect, quad) to use the base commands

namespace eval ::aktive::transform::quad {
    namespace import ::aktive::transform::compose
    namespace import ::aktive::transform::invert
    # for simple expressions direct access to ops and funcs
    namespace import ::tcl::mathfunc::*
    namespace import ::tcl::mathop::*
}

namespace eval ::aktive::transform::reflect {
    namespace import ::aktive::transform::compose
    namespace import ::aktive::transform::rotate
    namespace import ::aktive::transform::translate
    # for simple expressions direct access to ops and funcs
    namespace import ::tcl::mathfunc::*
    namespace import ::tcl::mathop::*
}

# import non-exported internal commands.
interp alias {} ::aktive::transform::quad::BOXany    {} ::aktive::transform::BOXany
interp alias {} ::aktive::transform::reflect::BOXany {} ::aktive::transform::BOXany

# # ## ### ##### ######## ############# #####################
return
