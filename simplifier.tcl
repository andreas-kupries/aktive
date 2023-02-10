# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

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
	src/value src/attr src/pop calc \
	\
	/src /src/child /const /constv /op /unary0 /unary1 /unary2 \
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

proc aktive::simplify::iff {expr args} {
    set ok [uplevel 1 [list expr $expr]]
    if {!$ok} fail
    uplevel 1 [list aktive simplify {*}$args]
}

# # ## ### ##### ######## ############# #####################
## non-image actions

proc aktive::simplify::src/value {param vardst args} {
    upvar src src $vardst dst
    set dst [dict get [aktive query params $src] $param]
    uplevel 1 [list aktive simplify {*}$args]
}

proc aktive::simplify::src/attr {attr vardst args} {
    upvar src src $vardst dst
    set dst [aktive query $attr $src]
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

proc aktive::simplify::/constv {var} {
    upvar 1 src src $var v
    set g [lrange [aktive query geometry $src] 2 end]
    aktive image constant {*}$g $v
}

proc aktive::simplify::/op {args} {
    upvar 1 src src
    set cmd {aktive op}
    set parmode 0
    foreach w $args {
	if {$parmode} { upvar 1 $w param ; lappend cmd $param; continue }
	if {$w eq ":"} { incr parmode ; continue }
	lappend cmd $w
    }
    lappend cmd $src
    set r [{*}$cmd]
    # Restore success of this simplifier. A simplifier invoked through the cmd may have
    # failed, changing the the shared state.
    variable ok 1
    return $r
}

# Note: This may optimize further, based on op and src
proc aktive::simplify::/unary0 {op} {
    upvar 1 src src
    /op math1 $op
}

proc aktive::simplify::/unary1 {op param} {
    upvar 1 src src $param p
    /op math1 $op : p
}

proc aktive::simplify::/unary2 {op pavar pbvar} {
    upvar 1 src src $pavar pa $pbvar pb
    /op math1 $op pa pb
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
## Continued simplifier support
## Math functions for pre-application of operations to constant inputs.
#
## See `op/op.c` for the C level runtime equivalents
## See `fold/constant` for where they are applied.

proc ::aktive::simplify::def {name args expr} {
    # Skip our definition if a builtin is found
    if {[llength [info commands ::tcl::mathfunc::$name]]} return
    proc ::tcl::mathfunc::$name $args [list expr $expr]
}

aktive::simplify::def aktive_clamp      x { ($x < 0) ? 0 : (($x > 1) ? 1 : $x)}
aktive::simplify::def aktive_invert     x { 1 - $x}
aktive::simplify::def aktive_neg        x { - $x}
aktive::simplify::def aktive_reciprocal x { 1.0 / $x}
aktive::simplify::def aktive_wrap       x { ($x > 1) ? fmod($x, 1) : (($x < 0) ? (1 + fmod($x - 1, 1)) : $x)}

aktive::simplify::def exp10             x { pow (10, $x) }

# Consider creating critcl::cproc's for these, calling directly on the C library.
# See the op/op.c support

aktive::simplify::def cbrt              x { pow ($x, 1./3.) }
aktive::simplify::def exp2              x { pow ( 2, $x) }
aktive::simplify::def log2              x { log ($x) / log (2) }
aktive::simplify::def sign              x { ($x < 0) ? 0 : (($x > 0) ? 1 : 0)}
aktive::simplify::def signb             x { ($x < 0) ? -1 : 1}
# https://en.wikipedia.org/wiki/Inverse_hyperbolic_functions#Definitions_in_terms_of_logarithms
aktive::simplify::def acosh             x { log ($x + sqrt ($x*$x - 1)) }	;# [1, +inf]
aktive::simplify::def asinh             x { log ($x + sqrt ($x*$x + 1)) }	;# [-inf,inf]
aktive::simplify::def atanh             x { log ((1+$x) / (1-$x)) / 2. }	;# (-1,1)

# # ## ### ##### ######## ############# #####################
## Math functions for pre-application of operations to constant inputs.
## i == image; x == function parameter
#
## See `op/op.c` for the C level runtime equivalents

aktive::simplify::def aktive_shift  {i x} { $i + $x                }
aktive::simplify::def aktive_nshift {i x} { $x - $i                }
aktive::simplify::def aktive_scale  {i x} { $i * $x                }
aktive::simplify::def aktive_rscale {i x} { $x / $i                }
aktive::simplify::def aktive_fmod   {i x} { fmod  ($x, $i)         }
aktive::simplify::def aktive_pow    {i x} { pow   ($x, $i)         }
aktive::simplify::def aktive_atan   {i x} { atan2 ($x, $i)         }
aktive::simplify::def aktive_ge     {i x} { $i >= $x ? 1 : 0       }
aktive::simplify::def aktive_le     {i x} { $i <= $x ? 1 : 0       }
aktive::simplify::def aktive_gt     {i x} { $i >  $x ? 1 : 0       }
aktive::simplify::def aktive_lt     {i x} { $i <  $x ? 1 : 0       }
aktive::simplify::def aktive_sol    {i x} { $i <= $x ? $i : 1 - $i }

# # ## ### ##### ######## ############# #####################
## Math functions for pre-application of operations to constant inputs.
## i == image; low, high == function parameters
#
## See `op/op.c` for the C level runtime equivalents

aktive::simplify::def aktive_inside_oo  {x low high} { ($low <  $x) && ($x <  $high) ? 1 : 0 }
aktive::simplify::def aktive_inside_oc  {x low high} { ($low <  $x) && ($x <= $high) ? 1 : 0 }
aktive::simplify::def aktive_inside_co  {x low high} { ($low <= $x) && ($x <  $high) ? 1 : 0 }
aktive::simplify::def aktive_inside_cc  {x low high} { ($low <= $x) && ($x <= $high) ? 1 : 0 }
aktive::simplify::def aktive_outside_oo {x low high} { ($low <  $x) && ($x <  $high) ? 0 : 1 }
aktive::simplify::def aktive_outside_oc {x low high} { ($low <  $x) && ($x <= $high) ? 0 : 1 }
aktive::simplify::def aktive_outside_co {x low high} { ($low <= $x) && ($x <  $high) ? 0 : 1 }
aktive::simplify::def aktive_outside_cc {x low high} { ($low <= $x) && ($x <= $high) ? 0 : 1 }

# # ## ### ##### ######## ############# #####################
return

