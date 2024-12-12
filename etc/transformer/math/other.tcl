## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Image transformer - More math (pixel wise)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core

operator op::math::linear {
    section transform math

    note Blends first and second input under control of the third.
    note As an equation: `result = A + T*(B-A) = A*(1-T)+T*B`.

    input a	Primary image A to blend
    input b	Secondary image B to blend into A
    input t	Per-pixel blending factors

    note All inputs are extended to matching depth.
    note - The images to blend are extended with black/zeros.
    note - The blend factors replicate their last band.

    note The other dimensions of the inputs, i.e. width and height, have to match. \
	An error is thrown if they don't.

    body {
	lassign [aktive query geometry $a] _ _ wa ha da
	lassign [aktive query geometry $b] _ _ wb hb db
	lassign [aktive query geometry $t] _ _ wt ht dt

	if {($wa != $wb) || ($wa != $wt) ||
	    ($ha != $hb) || ($ha != $ht)} { aktive error "Geometry mismatch" }

	set d  [expr {max($da,$db,$dt)}]
	if {$da < $d} { set a [aktive op embed band black $a down [expr {$d-$da}]] }
	if {$db < $d} { set b [aktive op embed band black $b down [expr {$d-$db}]] }
	if {$dt < $d} { set t [aktive op embed band copy  $t down [expr {$d-$dt}]] }

	#      Z = A + T*(B-A)	Accesses: 1xT, 1xB, 2xA
	# <==> Z = (1-T)*A+T*B  Accesses: 2xT, 1xB, 1xA

	return [aktive op math add $a [aktive op math mul $t [aktive op math sub $b $a]]]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
