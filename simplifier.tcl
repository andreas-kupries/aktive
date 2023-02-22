# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################

package require debug           ;# Tcllib
package require debug::caller   ;# ditto

debug level  aktive/simplifier
debug prefix aktive/simplifier {<[pid]> | }

debug level  aktive/simplifier/cover
debug prefix aktive/simplifier/cover {}

#debug on     aktive/simplifier
#debug on     aktive/simplifier/cover

# # ## ### ##### ######## ############# #####################
## Peep-hole optimization support - Reserved namespace `opt`
#
## See dsl writer `OperatorOverlaysForOp` for the code emitting
## calls to these commands.

namespace eval aktive {
    namespace export simplify
    namespace ensemble create
}
namespace eval aktive::simplify {
    namespace export \
	do src/type src/const param/eq param/lt param/gt iff \
	\
	input/count src/value src/attr src/pop calc \
	\
	/src /src/child /const /constv /op /unary0 /unary1 /unary2 \
	/fold/constant/0 /fold/constant/1 /fold/constant/2 \

    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## framework - start chain, abort chain

proc aktive::simplify::do {args} {
    debug.aktive/simplifier {}

    variable ok 1
    set replacement [uplevel 1 [list aktive simplify {*}$args]]
    if {!$ok} return

    # Simplifier was triggered successfully
    # For coverage enable the next command, run the testsuite and compare against the
    # generated/wraplist.txt

    debug.aktive/simplifier/cover {@@ [lindex [info level -1] 0] $args @@}
    return -code return $replacement
}

proc aktive::simplify::fail {} {
    debug.aktive/simplifier {[debug caller]}

    variable ok 0
    return -code return
}

# # ## ### ##### ######## ############# #####################
## predicates

proc aktive::simplify::src/type {match args} {
    debug.aktive/simplifier {src/type == $match}

    upvar 1 __type type src src

    if {![info exists type]} { set type [aktive query type $src] }
    if {$type ne $match} fail

    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::src/const {value args} {
    debug.aktive/simplifier {src/const == $value}

    upvar 1 src src
    set v [dict get [aktive query params $src] value]
    if {$v != $value} fail

    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::param/eq {name value args} {
    debug.aktive/simplifier {param $name eq $value}

    upvar 1 $name param
    if {$param != $value} fail

    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::param/lt {name value args} {
    debug.aktive/simplifier {param $name lt $value}

    upvar 1 $name param
    if {$param >= $value} fail

    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::param/gt {name value args} {
    debug.aktive/simplifier {param $name gt $value}

    upvar 1 $name param
    if {$param <= $value} fail

    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::iff {expr args} {
    debug.aktive/simplifier {if ($expr)}

    set ok [uplevel 1 [list expr $expr]]
    if {!$ok} fail
    uplevel 1 [list aktive simplify {*}$args]
}

# # ## ### ##### ######## ############# #####################
## non-image actions

proc aktive::simplify::input/count {varname args} {
    debug.aktive/simplifier {input/count -> $varname}

    upvar 1 $varname dst
    set dst [llength $args]
    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::src/value {param vardst args} {
    debug.aktive/simplifier {src/value $param -> $vardst}

    upvar 1 src src $vardst dst
    set dst [dict get [aktive query params $src] $param]

    debug.aktive/simplifier {src/value $param -> $vardst = ($dst)}
    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::src/attr {attr vardst args} {
    debug.aktive/simplifier {src/attr $param -> $vardst}

    upvar 1 src src $vardst dst
    set dst [aktive query $attr $src]

    debug.aktive/simplifier {src/attr $param -> $vardst = ($dst)}
    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::calc {vardst expr args} {
    debug.aktive/simplifier {calc ($expr) -> $vardst}

    upvar 1 $vardst dst
    set dst [uplevel 1 [list expr $expr]]

    debug.aktive/simplifier {calc ($expr) -> $vardst = ($dst)}
    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::src/pop {args} {
    debug.aktive/simplifier {src/pop}

    upvar 1 src src
    set src [/src/child]
    uplevel 1 [list aktive simplify {*}$args]
}

# # ## ### ##### ######## ############# #####################
## image actions, chain terminations

proc aktive::simplify::/fold/constant/0 {fun} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src
    set v [dict get [aktive query params $src] value]
    set v [tcl::mathfunc::$fun $v]
    /const $v
}

proc aktive::simplify::/fold/constant/1 {fun a} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src $a param
    set v [dict get [aktive query params $src] value]
    set v [tcl::mathfunc::$fun $v $param]
    /const $v
}

proc aktive::simplify::/fold/constant/2 {fun a b} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src $a pa $b pb
    set v [dict get [aktive query params $src] value]
    set v [tcl::mathfunc::$fun $v $pa $pb]
    /const $v
}

proc aktive::simplify::/const {v} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src
    set g [lrange [aktive query geometry $src] 2 end]
    aktive image constant {*}$g $v
}

proc aktive::simplify::/constv {var} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src $var v
    set g [lrange [aktive query geometry $src] 2 end]
    aktive image constant {*}$g $v
}

proc aktive::simplify::/op {args} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src
    set cmd {aktive op}
    set parmode 0
    foreach w $args {
	if {$parmode} { upvar 1 $w param ; lappend cmd $param; continue }
	if {$w eq ":"} { incr parmode ; continue }
	lappend cmd $w
    }
    lappend cmd $src

    debug.aktive/simplifier {[debug caller] -- $cmd}

    set r [{*}$cmd]
    # Restore success of this simplifier. A simplifier invoked through the cmd may have
    # failed, changing the the shared state.
    variable ok 1
    return $r
}

# Note: This may optimize further, based on op and src
proc aktive::simplify::/unary0 {op} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src
    /op math1 $op
}

proc aktive::simplify::/unary1 {op param} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src $param p
    /op math1 $op : p
}

proc aktive::simplify::/unary2 {op pavar pbvar} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src $pavar pa $pbvar pb
    /op math1 $op pa pb
}

proc aktive::simplify::/src {} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src
    return $src
}

proc aktive::simplify::/src/child {} {
    debug.aktive/simplifier {[debug caller]}

    upvar 1 src src
    return [lindex [aktive query inputs $src] 0]
}

# # ## ### ##### ######## ############# #####################
## Continued simplifier support
## Math functions for pre-application of operations to constant inputs.
#
## See `op/op.c` for the C level runtime equivalents and `op/math.tcl` for the exposure to
## Tcl. Here the decision is made which of these have to be moved into `tcl::mathfunc`.
##
## See `/fold/constant/*` above for where they are applied.

foreach fun {
    acosh             aktive_outside_co  aktive_inside_oc  aktive_sol
    aktive_atan       aktive_outside_oc  aktive_inside_oo  aktive_sol
    aktive_atan       aktive_outside_oo  aktive_invert     aktive_wrap
    aktive_clamp      aktive_pow         aktive_ge         asinh
    aktive_fmod       aktive_pow         aktive_gt         atanh
    aktive_fmod       aktive_reciprocal  aktive_le         cbrt
    aktive_ge         aktive_rscale      aktive_lt         exp10
    aktive_ge         aktive_rscale      aktive_neg        exp2
    aktive_ge         aktive_scale       aktive_nshift     log2
    aktive_ge         aktive_scale       aktive_nshift     sign
    aktive_inside_cc  aktive_shift       aktive_outside_cc signb
    aktive_inside_co  aktive_shift
} {
    if {[llength [info commands ::tcl::mathfunc::$fun]]} continue
    rename ::aktive::mathfunc::$fun ::tcl::mathfunc::$fun
}

# # ## ### ##### ######## ############# #####################
return

