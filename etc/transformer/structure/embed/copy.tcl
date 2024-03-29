## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - extend (copy) the nearest edge
#
## See op/embed.tcl for the supporting commands (Check, ...)

operator op::embed::copy {
    section transform structure

    note Returns image embedding the input into a border \
	made from the replicated input edges.

    uint? 0 left	Number of columns to extend the left input border by
    uint? 0 right	Number of columns to extend the right input border by
    uint? 0 top		Number of rows to extend the top input border by
    uint? 0 bottom	Number of rows to extend the bottom input border by

    input

    body {
	Check

	set origin $src
	lassign [aktive query geometry $src] x y w h d

	incr x -$left
	incr y -$top

	# This here cannot be done by means of op::view. We have to place proper constant
	# areas around the source to get the desired effect

	if {$left} {
	    set ext [aktive op montage x-rep [aktive op select x $origin from 0] by $left]
	    set src [aktive op montage x-core $ext $src] }
	if {$right} {
	    set range $w ; incr range -1
	    set ext [aktive op montage x-rep [aktive op select x $origin from $range] by $right]
	    set src [aktive op montage x-core $src $ext] }

	set origin $src

	if {$top} {
	    set ext [aktive op montage y-rep [aktive op select y $origin from 0] by $top]
	    set src [aktive op montage y-core $ext $src] }
	if {$bottom} {
	    set range $h ; incr range -1
	    set ext [aktive op montage y-rep [aktive op select y $origin from $range] by $bottom]
	    set src [aktive op montage y-core $src $ext] }

	# And at last shift the result to the proper location. This may be a nop.
	return [aktive op location move to $src x $x y $y]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
