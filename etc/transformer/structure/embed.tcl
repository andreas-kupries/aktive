## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Embedding in various ways
##
##   (a) black  - place a black border around the image
##   (b) white  - place a white border around the image
##   (c) copy   - extend the nearest edge (pixel)
##   (d) tile   - repeat tiles
##   (e) mirror - repeat mirrored tile
##   (f)
##

tcl-operator op::embed::black {left right top bottom src} {
    if {($left   < 0) ||
	($right  < 0) ||
	($top    < 0) ||
	($bottom < 0)} {
	aktive error "Unable to crop image with extend" CROP
    }

    lassign [aktive query geometry $src] x y w h d

    incr x -$left
    incr y -$top
    incr w  $left ; incr w  $right
    incr h  $top  ; incr h $bottom

    # This works because the region core processing automatically returns black when an
    # area outside of the image's domain is requested.

    return [aktive op view [list $x $y $w $h] $src]
}

tcl-operator op::embed::white {left right top bottom src} {
    if {($left   < 0) ||
	($right  < 0) ||
	($top    < 0) ||
	($bottom < 0)} {
	aktive error "Unable to crop image with extend" CROP
    }

    lassign [aktive query geometry $src] x y w h d

    incr x -$left
    incr y -$top

    # This here cannot be done by means of op::view. We have montage proper constant areas
    # around the source

    if {$left}  { set src [aktive op montage x [aktive image constant $left  $h $d 1] $src] }
    if {$right} { set src [aktive op montage x $src [aktive image constant $right $h $d 1]] }

    # Get the horizontally expanded geometry, i.e. proper extended width
    lassign [aktive query geometry $src] _ _ w _ _

    if {$top}    { set src [aktive op montage y [aktive image constant $w $top    $d 1] $src] }
    if {$bottom} { set src [aktive op montage y $src [aktive image constant $w $bottom $d 1]] }

    # And at last shift the result to the proper location. This may be a nop.

    return $src ;#[aktive op translate to $x $y $src]
}

##
# # ## ### ##### ######## ############# #####################
::return
