## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - repeat tiles

tcl-operator op::embed::tile {left right top bottom src} {
    Check

    lassign [aktive query geometry $src] x y w h d

    incr x -$left
    incr y -$top

    # This here cannot be done by means of op::view. We have to places copies of the
    # source around it to get the desired effect

    lassign [Count $left   $w] lpart left
    lassign [Count $right  $w] rpart right
    lassign [Count $top    $h] tpart top
    lassign [Count $bottom $h] bpart bottom

    incr left $right	;# total horizontal tiles around src
    incr top  $bottom	;# total vertical tiles around src

    if {$left} { incr left ; set src [aktive op montage x-rep $left $src] }
    if {$top}  { incr top  ; set src [aktive op montage y-rep $top  $src] }

    # Now handle any partial tiling by cropping to the actual area.

    set src [Crop $lpart $rpart $tpart $bpart $w $h $src]

    # And at last shift the result to the proper location. This may be a nop.
    return [aktive op translate to $x $y $src]
}

##
# # ## ### ##### ######## ############# #####################
::return
