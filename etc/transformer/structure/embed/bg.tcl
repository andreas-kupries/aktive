## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - any colored border
#
## See op/embed.tcl for the supporting commands (Check, ...)

operator op::embed::bg {
    section transform structure

    note Returns image embedding the input into an arbitrarily colored border. \
	The color is specified through the band values.

    uint?    0 left	Number of columns to extend the left input border by
    uint?    0 right	Number of columns to extend the right input border by
    uint?    0 top	Number of rows to extend the top input border by
    uint?    0 bottom	Number of rows to extend the bottom input border by
    double()   bands	Band values

    input

    body {
	Check

	lassign [aktive query geometry $src] x y w h d
	while {[llength $bands] < $d} { lappend bands 0 }

	incr x -$left
	incr y -$top

	# This here cannot be done by means of op::view. We have to place proper constant
	# areas around the source to get the desired effect

	if {$left}  { set src [aktive op montage x [aktive image from bands width $left height $h values {*}$bands] $src] }
	if {$right} { set src [aktive op montage x $src [aktive image from bands width $right height $h values {*}$bands]] }

	# Get the horizontally expanded geometry, i.e. proper extended width
	lassign [aktive query geometry $src] _ _ w _ _

	if {$top}    { set src [aktive op montage y [aktive image from bands width $w height $top values {*}$bands] $src] }
	if {$bottom} { set src [aktive op montage y $src [aktive image from bands width $w height $bottom values {*}$bands]] }

	# And at last shift the result to the proper location. This may be a nop.
	return [aktive op location move to $src x $x y $y]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
