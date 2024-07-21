## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - any colored border
#
## See op/embed.tcl for the supporting commands (Check, ...)

operator op::embed::bg {
    section transform structure

    example \
	{aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]} \
	{@1 left 32 right 32 top 32 bottom 32 values 0.5}

    note Returns image embedding the input into an arbitrarily colored border. \
	The color is specified through the band values.

    uint?    0 left	Number of columns to extend the left input border by
    uint?    0 right	Number of columns to extend the right input border by
    uint?    0 top	Number of rows to extend the top input border by
    uint?    0 bottom	Number of rows to extend the bottom input border by
    double()   values	Band values

    input

    body {
	Check

	lassign [aktive query geometry $src] x y w h d
	while {[llength $values] < $d} { lappend values 0 }

	incr x -$left
	incr y -$top

	# This here cannot be done by means of op::view. We have to place proper constant
	# areas around the source to get the desired effect

	if {$left}  { set src [aktive op montage x [aktive image from band width $left height $h values {*}$values] $src] }
	if {$right} { set src [aktive op montage x $src [aktive image from band width $right height $h values {*}$values]] }

	# Get the horizontally expanded geometry, i.e. proper extended width
	lassign [aktive query geometry $src] _ _ w _ _

	if {$top}    { set src [aktive op montage y [aktive image from band width $w height $top values {*}$values] $src] }
	if {$bottom} { set src [aktive op montage y $src [aktive image from band width $w height $bottom values {*}$values]] }

	# And at last shift the result to the proper location. This may be a nop.
	return [aktive op location move to $src x $x y $y]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
