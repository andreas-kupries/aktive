## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Split into rows, columns, or bands
## - Rotate in 90 degree increments
## - Transpose / transverse

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

tcl-operator op::rotate::cw   {src} { aktive op flip x [aktive op swap xy $src] }
tcl-operator op::rotate::ccw  {src} { aktive op flip y [aktive op swap xy $src] }
tcl-operator op::rotate::half {src} { aktive op flip x [aktive op flip  y $src] }

tcl-operator op::transpose    {src} { swap xy $src }
tcl-operator op::transverse   {src} { flip x [flip y [swap xy $src]] }

##
# # ## ### ##### ######## ############# #####################
::return
