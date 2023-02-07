# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Fixed command, not generated

namespace eval aktive {
    namespace export version opt ;# latter for optimizer support below
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Peep-hole optimization support - Reserved namespace `opt`
#
## See dsl writer `OperatorOverlaysForOp` for the code emitting
## calls to these commands.

namespace eval aktive::opt {
    namespace export type fold/constant pass pass/child
    namespace ensemble create
}

proc aktive::opt::type {} {
    upvar 1 __type type src src
    set type [aktive query type $src]
    return
}

proc aktive::opt::fold/constant {fun} {
    upvar 1 __type type src src
    if {$type ne "image::constant"} return
    set v [tcl::mathfunc::$fun [dict get [aktive query params $src] value]]

    set g [lrange [aktive query geometry $src] 2 end]
    return -code return [aktive image constant {*}$g $v]
}

proc aktive::opt::pass {match} {
    upvar 1 __type type src src
    if {$type ne $match} return
    return -code return $src
}

proc aktive::opt::pass/child {match} {
    upvar 1 __type type src src
    if {$type ne $match} return
    set child [lindex [aktive query inputs] 0]
    return -code return $child
}

# # ## ### ##### ######## ############# #####################
## Math functions for pre-application of operations to constant inputs.
## See `op/op.c` for the C level runtime equivalents
## See `fold/constant` for where they are applied.

proc ::tcl::mathfunc::aktive_clamp      x { expr {$x < 0 ? 0 : ($x > 1 ? 1 : $x)} }
proc ::tcl::mathfunc::aktive_wrap       x { expr {$x > 1 ? fmod($x, 1) : ($x < 0 ? (1 + fmod($x - 1, 1)) : $x)} }
proc ::tcl::mathfunc::aktive_invert     x { expr {1 - $x} }
proc ::tcl::mathfunc::aktive_neg        x { expr {- $x} }
proc ::tcl::mathfunc::aktive_sign       x { expr {$x < 0 ? 0 : ($x > 0 ? 1 : 0)} }
proc ::tcl::mathfunc::aktive_signb      x { expr {$x < 0 ? -1 : 1} }
proc ::tcl::mathfunc::aktive_reciprocal x { expr {1.0 / $x} }
proc ::tcl::mathfunc::aktive_cbrt       x { expr { pow ($x, 1./3.) } }
proc ::tcl::mathfunc::aktive_exp2       x { expr { pow ( 2, $x) } }
proc ::tcl::mathfunc::aktive_exp10      x { expr { pow (10, $x) } }
proc ::tcl::mathfunc::aktive_log2       x { expr { log($x) / log(2) } }

# # ## ### ##### ######## ############# #####################
return

