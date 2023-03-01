## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - extend (copy) the nearest edge

tcl-operator op::embed::copy {left right top bottom src} {
    Check

    set origin $src
    lassign [aktive query geometry $src] x y w h d

    incr x -$left
    incr y -$top

    # This here cannot be done by means of op::view. We have to place proper constant
    # areas around the source to get the desired effect

    if {$left} {
	set ext [aktive op montage x-rep $left [aktive op select x 0 0 $origin]]
	set src [aktive op montage x $ext $src] }
    if {$right} {
	set range $w ; incr range -1
	set ext [aktive op montage x-rep $right [aktive op select x $range $range $origin]]
	set src [aktive op montage x $src $ext] }

    set origin $src

    if {$top} {
	set ext [aktive op montage y-rep $top [aktive op select y 0 0 $origin]]
	set src [aktive op montage y $ext $src] }
    if {$bottom} {
	set range $h ; incr range -1
	set ext [aktive op montage y-rep $bottom [aktive op select y $range $range $origin]]
	set src [aktive op montage y $src $ext] }

    # And at last shift the result to the proper location. This may be a nop.
    return [aktive op translate to $x $y $src]
}

##
# # ## ### ##### ######## ############# #####################
::return
