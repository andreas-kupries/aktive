## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Split into rows, columns, or bands
## - Rotate in 90 degree increments
## - Transpose / transverse
## - Cropping

# # ## ### ##### ######## ############# #####################

tcl-operator op::split::x {src} {
    set end [aktive query width $src]
    set r {}
    for {set k 0} {$k < $end} {incr k} {
	lappend r [aktive op select x $k $k $src]
    }
    return $r
}

tcl-operator op::split::y {src} {
    set end [aktive query height $src]
    set r {}
    for {set k 0} {$k < $end} {incr k} {
	lappend r [aktive op select y $k $k $src]
    }
    return $r
}

tcl-operator op::split::z {src} {
    set end [aktive query depth $src]
    set r {}
    for {set k 0} {$k < $end} {incr k} {
	lappend r [aktive op select z $k $k $src]
    }
    return $r
}

# # ## ### ##### ######## ############# #####################

tcl-operator op::rotate::cw   {src} { aktive op flip x [aktive op swap xy $src] }
tcl-operator op::rotate::ccw  {src} { aktive op flip y [aktive op swap xy $src] }
tcl-operator op::rotate::half {src} { aktive op flip x [aktive op flip  y $src] }

# # ## ### ##### ######## ############# #####################

tcl-operator op::transpose    {src} { swap xy $src }
tcl-operator op::transverse   {src} { flip x [flip y [swap xy $src]] }

# # ## ### ##### ######## ############# #####################

tcl-operator op::crop {left right top bottom src} {
    set g [aktive query geometry $src]
    dict with g {}
    # x y width height depth

    set bottom [expr {$height - 1 - $bottom}]
    set right  [expr {$width  - 1 - $right}]

    # TODO: optimization
    # - 1 - if the src is a select x or (or y) choose the matching orientation as the
    #       first to place around the source, take advantage of select chain reduction.
    #
    # - 2 - see if the stack is two select ops indicating a previous crop.  If so, reorder
    #       the stack to reduce both x and y selections.

    return [aktive op select y $top $bottom [aktive op select x $left $right $src]]
}

##
# # ## ### ##### ######## ############# #####################
::return
