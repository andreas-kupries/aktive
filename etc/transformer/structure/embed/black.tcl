## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - black border
#
## See op/embed.tcl for the supporting commands (Check, ...)

tcl-operator op::embed::black {
    note Transformer. Structure. \
	Embed input into a larger image using a black border.

    arguments left right top bottom src
    body {
	Check

	lassign [aktive query geometry $src] x y w h d

	incr x -$left
	incr y -$top
	incr w  $left ; incr w  $right
	incr h  $top  ; incr h $bottom

	# This works because the region core processing automatically
	# returns black when an area outside of the image's domain is
	# requested.

	return [aktive op view [list $x $y $w $h] $src]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
