## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - white border
#
## See op/embed.tcl for the supporting commands (Check, ...)

operator op::embed::white {
    section transform structure

    note Returns image embedding the input into a white border.

    uint? 0 left	Number of columns to extend the left input border by
    uint? 0 right	Number of columns to extend the right input border by
    uint? 0 top		Number of rows to extend the top input border by
    uint? 0 bottom	Number of rows to extend the bottom input border by

    input

    body {
	Check

	lassign [aktive query geometry $src] x y w h d

	incr x -$left
	incr y -$top

	# This here cannot be done by means of op::view. We have to place proper constant
	# areas around the source to get the desired effect

	if {$left}  { set src [aktive op montage x [aktive image from value width $left height $h depth $d value 1] $src] }
	if {$right} { set src [aktive op montage x $src [aktive image from value width $right height $h depth $d value 1]] }

	# Get the horizontally expanded geometry, i.e. proper extended width
	lassign [aktive query geometry $src] _ _ w _ _

	if {$top}    { set src [aktive op montage y [aktive image from value width $w height $top depth $d value 1] $src] }
	if {$bottom} { set src [aktive op montage y $src [aktive image from value width $w height $bottom depth $d value 1]] }

	# And at last shift the result to the proper location. This may be a nop.
	return [aktive op location move to $src x $x y $y]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
