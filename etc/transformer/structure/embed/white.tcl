## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - white border
#
## See op/embed.tcl for the supporting commands (Check, ...)

tcl-operator op::embed::white {
    section transform structure

    note Returns image embedding the input into a white border.

    arguments left right top bottom src
    body {
	Check

	lassign [aktive query geometry $src] x y w h d

	incr x -$left
	incr y -$top

	# This here cannot be done by means of op::view. We have to place proper constant
	# areas around the source to get the desired effect

	if {$left}  { set src [aktive op montage x [aktive image from value $left  $h $d 1] $src] }
	if {$right} { set src [aktive op montage x $src [aktive image from value $right $h $d 1]] }

	# Get the horizontally expanded geometry, i.e. proper extended width
	lassign [aktive query geometry $src] _ _ w _ _

	if {$top}    { set src [aktive op montage y [aktive image from value $w $top    $d 1] $src] }
	if {$bottom} { set src [aktive op montage y $src [aktive image from value $w $bottom $d 1]] }

	# And at last shift the result to the proper location. This may be a nop.
	return [aktive op translate to $x $y $src]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
