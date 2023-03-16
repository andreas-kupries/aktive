## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - any colored border
#
## See op/embed.tcl for the supporting commands (Check, ...)

tcl-operator op::embed::bg {
    section transform structure

    note Returns image embedding the input into an arbitrarily colored border. \
	The color is specified through the band values.

    arguments left right top bottom bands src
    body {
	Check

	lassign [aktive query geometry $src] x y w h d
	while {[llength $bands] < $d} { lappend bands 0 }

	incr x -$left
	incr y -$top

	# This here cannot be done by means of op::view. We have to place proper constant
	# areas around the source to get the desired effect

	if {$left}  { set src [aktive op montage x [aktive image const bands $left $h  {*}$bands] $src] }
	if {$right} { set src [aktive op montage x $src [aktive image const bands $right $h {*}$bands]] }

	# Get the horizontally expanded geometry, i.e. proper extended width
	lassign [aktive query geometry $src] _ _ w _ _

	if {$top}    { set src [aktive op montage y [aktive image const bands $w $top    {*}$bands] $src] }
	if {$bottom} { set src [aktive op montage y $src [aktive image const bands $w $bottom {*}$bands]] }

	# And at last shift the result to the proper location. This may be a nop.
	return [aktive op translate to $x $y $src]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
