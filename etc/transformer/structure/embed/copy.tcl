## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - extend (copy) the nearest edge
#
## See op/embed.tcl for the supporting commands (Check, ...)

operator op::embed::copy {
    section transform structure

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 left 32 right 32 top 32 bottom 32
    }

    note Returns an image embedding the input into a border \
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
	    set ext [aktive op sample replicate x [aktive op select x $origin from 0] by $left]
	    set src [aktive op montage x-core $ext $src] }
	if {$right} {
	    set range $w ; incr range -1
	    set ext [aktive op sample replicate x [aktive op select x $origin from $range] by $right]
	    set src [aktive op montage x-core $src $ext] }

	set origin $src

	if {$top} {
	    set ext [aktive op sample replicate y [aktive op select y $origin from 0] by $top]
	    set src [aktive op montage y-core $ext $src] }
	if {$bottom} {
	    set range $h ; incr range -1
	    set ext [aktive op sample replicate y [aktive op select y $origin from $range] by $bottom]
	    set src [aktive op montage y-core $src $ext] }

	# And at last shift the result to the proper location. This may be a nop.
	return [aktive op location move to $src x $x y $y]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
