# -*- mode: tcl ; fill-column: 90 -*-
## blitter - spec management

# # ## ### ##### ######## #############

namespace eval ::dsl::blit::spec {
    variable depth    {} ;# int  number of nested loops
    variable span     {} ;# int  number of parallel iterators per loop
    variable frac     {} ;# dict (level -> bool/isfractional)
    variable prefixes {} ;# list (varprefix...)	/block order
    variable virtual  {} ;# bool /action is virtual
    variable nopos    {} ;# bool /action does not require linear pos
    variable allowsrc {} ;# bool /action may have source iterators
    variable vector   {} ;# bool /action is vector op for xz
    variable fracs    {} ;# bool /isfractional, across all blocks
    variable axes     {} ;# dict (prefix -> list(axis...)) /custom order: y x z!
    variable hasxz    {} ;# bool /xz special axis is present (ensured to be innermost)
    #
    # API
    #
    namespace export setup
    namespace ensemble create
    namespace import ::dsl::blit::system::abort
    namespace import ::dsl::blit::action
}

# # ## ### ##### ######## #############
## API implementation

proc ::dsl::blit::spec::setup {blit function} {
    variable depth    {} ;# ok
    variable span     {} ;# ok
    variable frac     {} ;# ok
    variable prefixes {} ;# ok
    variable virtual  0  ;# ok
    variable nopos    0  ;# ok
    variable allowsrc 1  ;# ok
    variable vector   0  ;# ok
    variable fracs    0  ;# ok
    variable axes     {} ;# ok
    variable hasxz    0  ;# ok

    set function [action optimize $function]
    lassign [action flags $function] virtual nopos allowsrc vector
    set depth [llength $blit]
    if {!$depth} { E "empty" }

    set scanlenset [lsort -uniq [lmap scan $blit { llength $scan }]]
    if {[llength $scanlenset] > 1} { E "scan mismatch, in #iterators" }
    if {$scanlenset == 0}          { E "empty scan" }
    if {$scanlenset == 1}          { E "no iterators" }

    set span $scanlenset ; incr span -1	;# drop range element from span

    if {!$allowsrc && ($span > 1)} { E "action / iterator mismatch, sources not allowed" }

    set prefixes [Prefixes [lrange [lindex $blit 0] 1 end]]
    set level  0
    set hasxz 0 ;# flag that xz was used
    foreach scan $blit {
	set iterators [lassign $scan range]
	foreach iter $iterators prefix $prefixes {
	    lassign $iter axis min delta direction
	    CheckAxis $axis
	    CheckDir $direction
	    dict set axes $prefix $axis .
	    dict set frac $level [string match 1/* $delta]
	    set fracs [expr {$fracs || [dict get $frac $level]}]
	}
	incr level
    }
    # axes :: dict (prefix -> axis -> ".")
    dict for {prefix spec} $axes {
	# ensure custom order y/x/z/xz, i.e. row/column/band/col+band, for the actually used axes
	dict set axes $prefix [lmap a {y x z xz} {
	    if {![dict exists $spec $a]} continue
	    set a
	}]
    }
    # axes :: dict (prefix -> list(axis...))

    # ensure that `xz` is only used in the innermost scan, and there not mixed with other axes.
    # also ensure that the other scans only use `y`.
    # actually, it has to be exactly two scans because of the above.
    if {$hasxz} {
	if {$depth != 2} { E "blit using `xz` axis has to consist of two scans" }
	lassign $blit outer inner
	if {![HasXZ $inner]} { E "`xz` axis is not on innermost scan" }
	if {![HasY  $outer]} { E "`y` axis is not on outer scan for nest using `xz` axis" }
    }

    if {$vector && !$hasxz} { E "vector action requires use of `xz` axis" }
    return
}

# # ## ### ##### ######## #############
## internal helpers

proc ::dsl::blit::spec::HasXZ {scan} {
    set axes [lsort -uniq [lmap iterator [lassign $scan _] { lindex $iterator 0 }]]
    set has [expr {"xz" in $axes}]
    if {$has && ([llength $axes] > 1)} { E "bad scan, mixing `[join $axes {`, `}]` axes" }
    return $has
}

proc ::dsl::blit::spec::HasY {scan} {
    set axes [lsort -uniq [lmap iterator [lassign $scan _] { lindex $iterator 0 }]]
    set has [expr {"y" in $axes}]
    if {$has && ([llength $axes] > 1)} { E "bad scan, mixing `[join $axes {`, `}]` axes in nest using `xz`" }
    return $has
}

proc ::dsl::blit::spec::CheckAxis {a} {
    if {$a eq "xz"} { upvar 1 hasxz hasxz ; set hasxz 1 }
    if {$a in {x y z xz}} return
    E "bad axis `$a`, expected 'x', 'y', 'z', or 'xz'"
}

proc ::dsl::blit::spec::CheckDir {d} {
    if {$d in {up down}} return
    E "bad direction `$d`, expected 'up' or 'down'"
}

proc ::dsl::blit::spec::E {message} { abort "blit spec error: $message" }

# Prefixes - determine dst, src, src0, src1 ... for the iterators of a scan
proc ::dsl::blit::spec::Prefixes {iterators} {
    switch -exact -- [llength $iterators] {
	1 {
	    # no sources
	    return dst
	}
	2 {
	    # single source
	    return {dst src}
	}
	default {
	    # multiple sources
	    set p dst
	    set counter 0
	    return [lmap __ $iterators {
		set r $p
		set p src$counter
		incr counter
		set r
	    }]
	    # dst, src0, src1, ...
	}
    }
}

# # ## ### ##### ######## #############
return
