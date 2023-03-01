## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - white border

tcl-operator op::embed::white {left right top bottom src} {
    Check

    lassign [aktive query geometry $src] x y w h d

    incr x -$left
    incr y -$top

    # This here cannot be done by means of op::view. We have to place proper constant
    # areas around the source to get the desired effect

    if {$left}  { set src [aktive op montage x [aktive image constant $left  $h $d 1] $src] }
    if {$right} { set src [aktive op montage x $src [aktive image constant $right $h $d 1]] }

    # Get the horizontally expanded geometry, i.e. proper extended width
    lassign [aktive query geometry $src] _ _ w _ _

    if {$top}    { set src [aktive op montage y [aktive image constant $w $top    $d 1] $src] }
    if {$bottom} { set src [aktive op montage y $src [aktive image constant $w $bottom $d 1]] }

    # And at last shift the result to the proper location. This may be a nop.
    return [aktive op translate to $x $y $src]
}

##
# # ## ### ##### ######## ############# #####################
::return
