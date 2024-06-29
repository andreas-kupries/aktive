## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Image transformer - More math (pixel wise)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core

operator op::math::linear {
    section transform math

    note Blends first and second input under control of the third.
    note As an equation: `result = A + T*(B-A)`.

    input	;# A :: primary image to blend with
    input	;# B :: secondary image to blend into/over
    input	;# T :: blend factors

    note All inputs are extended to matching depth.
    note - The images to blend are extended with black/zeros.
    note - The blend factors replicate their last band.

    note The other dimensions of the inputs, i.e. width and height, have to match. \
	An error is thrown if they don't.

    body {
	lassign [aktive query geometry $src0] _ _ w0 h0 d0
	lassign [aktive query geometry $src1] _ _ w1 h1 d1
	lassign [aktive query geometry $src2] _ _ w2 h2 d2

	if {($w0 != $w1) || ($w0 != $w2) ||
	    ($h0 != $h1) || ($h0 != $h2)} { aktive error "Geometry mismatch" }

	set d  [expr {max($d0,$d1,$d2)}]
	if {$d0 < $d} { set src0 [aktive op embed band black $src0 down [expr {$d-$d0}]] }
	if {$d1 < $d} { set src1 [aktive op embed band black $src1 down [expr {$d-$d1}]] }
	if {$d2 < $d} { set src2 [aktive op embed band copy  $src2 down [expr {$d-$d2}]] }

	#      Z = A + T*(B-A)	Accesses: 1xT, 1xB, 2xA
	# <==> Z = (1-T)*A+T*B  Accesses: 2xT, 1xB, 1xA

	return [aktive op math add $src0 [aktive op math mul $src2 [aktive op math sub $src1 $src0]]]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
