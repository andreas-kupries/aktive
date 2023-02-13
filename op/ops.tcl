# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Operators implemented in Tcl, on top of the C-based builtins

# # ## ### ##### ######## ############# #####################
## Extended math

namespace eval aktive::math {
    namespace export difference screen
    namespace ensemble create
}

proc aktive::math::difference {a b} { return [aktive math1 abs [sub $a $b]] }
proc aktive::math::screen     {a b} { return [sub [add $a $b] [mul $a $b]] }

# # ## ### ##### ######## ############# #####################
## Split into rows, columns, or bands

namespace eval aktive::op {
    namespace export split
    namespace ensemble create
}
namespace eval aktive::op::split {
    namespace export x y z
    namespace ensemble create
}

proc aktive::op::split::x {src} {
    set end [aktive query width $src]
    set r {}
    for {set k 0} {$k < $end} {incr k} {
	lappend r [aktive op select x $k $k $src]
    }
    return $r
}

proc aktive::op::split::y {src} {
    set end [aktive query height $src]
    set r {}
    for {set k 0} {$k < $end} {incr k} {
	lappend r [aktive op select y $k $k $src]
    }
    return $r
}

proc aktive::op::split::z {src} {
    set end [aktive query depth $src]
    set r {}
    for {set k 0} {$k < $end} {incr k} {
	lappend r [aktive op select z $k $k $src]
    }
    return $r
}

# # ## ### ##### ######## ############# #####################
## rotate in 90 degree increments

namespace eval aktive::op {
    namespace export rotate
    namespace ensemble create
}
namespace eval aktive::op::rotate {
    namespace export cw ccw half
    namespace ensemble create
}

proc aktive::op::rotate::cw   {src} { aktive op flip x [aktive op swap xy $src] }
proc aktive::op::rotate::ccw  {src} { aktive op flip y [aktive op swap xy $src] }
proc aktive::op::rotate::half {src} { aktive op flip x [aktive op flip  y $src] }

# # ## ### ##### ######## ############# #####################
## transpose / transverse

namespace eval aktive::op {
    namespace export transpose transverse
    namespace ensemble create
}

proc aktive::op::transpose  {src} { swap xy $src }
proc aktive::op::transverse {src} { flip x [flip y [swap xy $src]] }

# # ## ### ##### ######## ############# #####################
return

