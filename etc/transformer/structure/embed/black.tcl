## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - black border
#
## See op/embed.tcl for the supporting commands (Check, ...)

operator op::embed::black {
    section transform structure

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 left 32 right 32 top 32 bottom 32
    }

    note Returns an image embedding the input into a black border.

    uint? 0 left	Number of columns to extend the left input border by
    uint? 0 right	Number of columns to extend the right input border by
    uint? 0 top		Number of rows to extend the top input border by
    uint? 0 bottom	Number of rows to extend the bottom input border by

    input

    body {
	Check

	lassign [aktive query domain $src] x y w h

	incr x -$left
	incr y -$top
	incr w  $left ; incr w $right
	incr h  $top  ; incr h $bottom

	# This works because the region core processing automatically
	# returns black when an area outside of the image's domain is
	# requested.

	return [aktive op view $src port [list $x $y $w $h]]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
