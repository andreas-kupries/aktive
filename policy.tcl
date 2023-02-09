# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Fixed command, not generated

namespace eval aktive {
    namespace export version simplify
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Peep-hole optimization support - Reserved namespace `opt`
#
## See dsl writer `OperatorOverlaysForOp` for the code emitting
## calls to these commands.

namespace eval aktive::simplify {
    namespace export \
	do src/type src/const param/eq param/lt param/gt \
	\
	src/value self/value src/pop calc \
	\
	/src /src/child /const /unary0 /unary1 /unary2 \
	/fold/constant/0 /fold/constant/1 /fold/constant/2 \

    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## framework - start chain, abort chain

proc aktive::simplify::do {args} {
    variable ok 1
    set replacement [uplevel 1 [list aktive simplify {*}$args]]
    if {!$ok} return

    # Simplifier was triggered successfully
    # For coverage enable the next command, run the testsuite and compare against the
    # generated/wraplist.txt
    #puts "SIMPL [lindex [info level -1] 0] $args"
    return -code return $replacement
}

proc aktive::simplify::fail {} {
    variable ok 0
    return -code return
}

# # ## ### ##### ######## ############# #####################
## predicates

proc aktive::simplify::src/type {match args} {
    upvar 1 __type type src src

    if {![info exists type]} { set type [aktive query type $src] }
    if {$type ne $match} fail

    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::src/const {value args} {
    upvar 1 src src
    set v [dict get [aktive query params $src] value]
    if {$v != $value} fail

    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::param/eq {name value args} {
    upvar 1 $name param
    if {$param != $value} fail

    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::param/lt {name value args} {
    upvar 1 $name param
    if {$param >= $value} fail

    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::param/gt {name value args} {
    upvar 1 $name param
    if {$param <= $value} fail

    uplevel 1 [list aktive simplify {*}$args]
}

# # ## ### ##### ######## ############# #####################
## non-image actions

proc aktive::simplify::self/value {varsrc vardst args} {
    upvar $varsrc src $vardst dst
    set dst $src
    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::src/value {param vardst args} {
    upvar src src $vardst dst
    set dst [dict get [aktive query params $src] $param]
    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::calc {vardst expr args} {
    upvar 1 $vardst dst
    set dst [uplevel 1 [list expr $expr]]
    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::src/pop {args} {
    upvar 1 src src
    set src [/src/child]
    uplevel 1 [list aktive simplify {*}$args]
}

# # ## ### ##### ######## ############# #####################
## image actions, chain terminations

proc aktive::simplify::/fold/constant/0 {fun} {
    upvar 1 src src
    set v [dict get [aktive query params $src] value]
    set v [tcl::mathfunc::$fun $v]
    /const $v
}

proc aktive::simplify::/fold/constant/1 {fun a} {
    upvar 1 src src $a param
    set v [dict get [aktive query params $src] value]
    set v [tcl::mathfunc::$fun $v $param]
    /const $v
}

proc aktive::simplify::/fold/constant/2 {fun a b} {
    upvar 1 src src $a pa $b pb
    set v [dict get [aktive query params $src] value]
    set v [tcl::mathfunc::$fun $v $pa $pb]
    /const $v
}

proc aktive::simplify::/const {v} {
    upvar 1 src src
    set g [lrange [aktive query geometry $src] 2 end]
    aktive image constant {*}$g $v
}

# Note: This may optimize further, based on op and src
proc aktive::simplify::/unary0 {op} {
    upvar 1 src src
    set r [aktive op math1 $op $src]
    # Restore success of this simplifier in the face of op's simplifier failing
    variable ok 1
    return $r
}

proc aktive::simplify::/unary1 {op param} {
    upvar 1 src src $param p
    set r [aktive op math1 $op $p $src]
    # Restore success of this simplifier in the face of op's simplifier failing
    variable ok 1
    return $r
}

proc aktive::simplify::/unary2 {op pavar pbvar} {
    upvar 1 src src $pavar pa $pbvar pb
    set r [aktive op math1 $op $pa $pb $src]
    # Restore success of this simplifier in the face of op's simplifier failing
    variable ok 1
    return $r
}

proc aktive::simplify::/src {} {
    upvar 1 src src
    return $src
}

proc aktive::simplify::/src/child {} {
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

