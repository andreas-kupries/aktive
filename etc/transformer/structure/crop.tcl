## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Cropping

tcl-operator op::crop {
    section transform structure

    note Returns image containing a rectangular subset of input, \
	specified by the amount of rows and columns to remove \
	from the four borders.

    arguments left right top bottom src
    body {
	lassign [aktive query geometry $src] x y w h d

	if {($left   == 0) &&
	    ($right  == 0) &&
	    ($top    == 0) &&
	    ($bottom == 0)} { return $src }

	if {($left   < 0) ||
	    ($right  < 0) ||
	    ($top    < 0) ||
	    ($bottom < 0)} {
	    aktive error "Unable to extend image with crop" CROP
	}

	if {(($top  + $bottom) >= $h) ||
	    (($left + $right)  >= $w)} {
	    aktive error "Unable to crop to empty image" CROP
	}

	set bottom [expr {$h - 1 - $bottom}]
	set right  [expr {$w - 1 - $right}]

	# TODO ?? optimization
	# - 1 - if the src is a select x or (or y) choose the matching orientation as the
	#       first to place around the source, take advantage of select chain reduction.
	#
	# - 2 - see if the stack is two select ops indicating a previous crop.  If so, reorder
	#       the stack to reduce both x and y selections.

	return [aktive op select y $top $bottom [aktive op select x $left $right $src]]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
