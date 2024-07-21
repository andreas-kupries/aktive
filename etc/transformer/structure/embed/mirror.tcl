## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - repeat mirrored tiles
#
## See op/embed.tcl for the supporting commands (Check, ...)

operator op::embed::mirror {
    section transform structure

    example \
	{aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]} \
	{@1 left 32 right 32 top 32 bottom 32}

    note Returns image embedding the input into a border \
	made from the replicated mirrored input.

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

	# This here cannot be done by means of op::view. We have to place (mirrored) copies
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
	return [aktive op location move to $src x $x y $y]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
