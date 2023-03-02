## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - repeat mirrored tiles
#
## See op/embed.tcl for the supporting commands (Check, ...)

tcl-operator op::embed::mirror {
    section transform structure

    note Returns image embedding the input into a border \
	made from the replicated mirrored input.

    arguments left right top bottom src
    body {
	Check

	lassign [aktive query geometry $src] x y w h d

	incr x -$left
	incr y -$top

	# This here cannot be done by means of op::view. We have to places (mirrored) copies
	# of the source around it to get the desired effect

	lassign [Count $left   $w] lpart left
	lassign [Count $right  $w] rpart right
	lassign [Count $top    $h] tpart top
	lassign [Count $bottom $h] bpart bottom

	set wdirections [list {*}[lreverse [Directions $left]] 0 {*}[Directions $right]]
	set hdirections [list {*}[lreverse [Directions $top]]  0 {*}[Directions $bottom]]

	set src [Tiles $wdirections x $src]
	set src [Tiles $hdirections y $src]

	# Now handle the partial tiling by cropping to the actual area.

	set src [Crop $lpart $rpart $tpart $bpart $w $h $src]

	# And at last shift the result to the proper location. This may be a nop.
	return [aktive op translate to $x $y $src]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
