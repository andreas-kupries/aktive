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
    namespace export \
	do istype isconst param.eq param.lt param.gt \
	is input input/child const unary0 \
	fold/constant/0 fold/constant/1 fold/constant/2 \

    namespace ensemble create
}

proc aktive::opt::do {args} {
    # Start chain and collect state
    lassign [uplevel 1 [list aktive opt {*}$args]] ok result
    if {!$ok} return
    return -code return $result
}

proc aktive::opt::is {args} {
    # success, invoke action generating replacement result
    list 1 [uplevel 1 [list aktive opt {*}$args]]
}

proc aktive::opt::isconst {args} {
    upvar 1 __type type src src
    if {![info exists type]} { set type [aktive query type $src] }
    if {$type ne "image::constant"} { return {0 {}} }
    return [uplevel 1 [list aktive opt {*}$args]]
}

proc aktive::opt::istype {match args} {
    upvar 1 __type type src src
    if {![info exists type]} { set type [aktive query type $src] }
    if {$type ne $match} { return {0 {}} }
    return [uplevel 1 [list aktive opt {*}$args]]
}

proc aktive::opt::param.eq {name value args} {
    upvar 1 $name param
    if {$param != $value} { return {0 {}} }
    return [uplevel 1 [list aktive opt {*}$args]]
}

proc aktive::opt::param.lt {name value args} {
    upvar 1 $name param
    if {$param >= $value} { return {0 {}} }
    return [uplevel 1 [list aktive opt {*}$args]]
}

proc aktive::opt::param.gt {name value args} {
    upvar 1 $name param
    if {$param <= $value} { return {0 {}} }
    return [uplevel 1 [list aktive opt {*}$args]]
}

proc aktive::opt::fold/constant/0 {fun} {
    upvar 1 src src
    set v [dict get [aktive query params $src] value]
    set v [tcl::mathfunc::$fun $v]
    const $v
}

proc aktive::opt::fold/constant/1 {fun a} {
    upvar 1 src src $a param
    set v [dict get [aktive query params $src] value]
    set v [tcl::mathfunc::$fun $v $param]
    const $v
}

proc aktive::opt::fold/constant/2 {fun a b} {
    upvar 1 src src $a pa $b pb
    set v [dict get [aktive query params $src] value]
    set v [tcl::mathfunc::$fun $v $pa $pb]
    const $v
}

proc aktive::opt::const {v} {
    upvar 1 src src
    set g [lrange [aktive query geometry $src] 2 end]
    aktive image constant {*}$g $v
}

proc aktive::opt::unary0 {op} {
    upvar 1 src src
    # Note: This may optimize further, based on op and src
    aktive math1 $op $src
}

proc aktive::opt::input {} {
    upvar 1 src src
    return $src
}

proc aktive::opt::input/child {} {
    upvar 1 src src
    return [lindex [aktive query inputs $src] 0]
}

# # ## ### ##### ######## ############# #####################
## Math functions for pre-application of operations to constant inputs.
#
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
## Math functions for pre-application of operations to constant inputs.
## i == image; x == function parameter
#
## See `op/op.c` for the C level runtime equivalents

proc ::tcl::mathfunc::aktive_shift  {i x} { expr { $i + $x                } }
proc ::tcl::mathfunc::aktive_nshift {i x} { expr { $x - $i                } }
proc ::tcl::mathfunc::aktive_scale  {i x} { expr { $i * $x                } }
proc ::tcl::mathfunc::aktive_rscale {i x} { expr { $x / $i                } }
proc ::tcl::mathfunc::aktive_fmod   {i x} { expr { fmod ($x, $i)          } }
proc ::tcl::mathfunc::aktive_pow    {i x} { expr { pow ($x, $i)           } }
proc ::tcl::mathfunc::aktive_atan   {i x} { expr { atan2 ($x, $i)         } }
proc ::tcl::mathfunc::aktive_ge     {i x} { expr { $i >= $x ? 1 : 0       } }
proc ::tcl::mathfunc::aktive_le     {i x} { expr { $i <= $x ? 1 : 0       } }
proc ::tcl::mathfunc::aktive_gt     {i x} { expr { $i >  $x ? 1 : 0       } }
proc ::tcl::mathfunc::aktive_lt     {i x} { expr { $i <  $x ? 1 : 0       } }
proc ::tcl::mathfunc::aktive_sol    {i x} { expr { $i <= $x ? $i : 1 - $i } }

# # ## ### ##### ######## ############# #####################
## Math functions for pre-application of operations to constant inputs.
## i == image; low, high == function parameters
#
## See `op/op.c` for the C level runtime equivalents

proc ::tcl::mathfunc::aktive_inside_oo  {x low high} { expr { ($low <  $x) && ($x <  $high) ? 1 : 0 } }
proc ::tcl::mathfunc::aktive_inside_oc  {x low high} { expr { ($low <  $x) && ($x <= $high) ? 1 : 0 } }
proc ::tcl::mathfunc::aktive_inside_co  {x low high} { expr { ($low <= $x) && ($x <  $high) ? 1 : 0 } }
proc ::tcl::mathfunc::aktive_inside_cc  {x low high} { expr { ($low <= $x) && ($x <= $high) ? 1 : 0 } }
proc ::tcl::mathfunc::aktive_outside_oo {x low high} { expr { ($low <  $x) && ($x <  $high) ? 0 : 1 } }
proc ::tcl::mathfunc::aktive_outside_oc {x low high} { expr { ($low <  $x) && ($x <= $high) ? 0 : 1 } }
proc ::tcl::mathfunc::aktive_outside_co {x low high} { expr { ($low <= $x) && ($x <  $high) ? 0 : 1 } }
proc ::tcl::mathfunc::aktive_outside_cc {x low high} { expr { ($low <= $x) && ($x <= $high) ? 0 : 1 } }

# # ## ### ##### ######## ############# #####################
return

