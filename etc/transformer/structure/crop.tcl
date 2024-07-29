## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Cropping

operator op::crop {
    section transform structure

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 left 10 right 20 top 30 bottom 50
    }

    note Returns image containing a rectangular subset of input, \
	specified by the amount of rows and columns to remove \
	from the four borders.

    uint? 0 left	Number of columns to remove from the left input border
    uint? 0 right	Number of columns to remove from the right input border
    uint? 0 top		Number of rows to remove from the top input border
    uint? 0 bottom	Number of rows to remove from the bottom input border
    input

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

	return [aktive op select y [aktive op select x $src from $left to $right] from $top to $bottom]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
