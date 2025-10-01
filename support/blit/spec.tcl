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
    variable fracs    {} ;# bool /isfractional, across all blocks
    variable axes     {} ;# dict (prefix -> list(axis...)) /custom order: y x z!
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
    variable fracs    0  ;# ok
    variable axes     {} ;# ok

    lassign [action flags $function] virtual nopos allowsrc
    set depth [llength $blit]
    if {!$depth} { E "empty" }

    set scanlenset [lsort -uniq [lmap scan $blit { llength $scan }]]
    if {[llength $scanlenset] > 1} { E "scan mismatch, in #iterators" }
    if {$scanlenset == 0}          { E "empty scan" }
    if {$scanlenset == 1}          { E "no iterators" }

    set span $scanlenset ; incr span -1	;# drop range element from span

    if {!$allowsrc && ($span > 1)} { E "action / iterator mismatch, sources not allowed" }

    set prefixes [Prefixes [lrange [lindex $blit 0] 1 end]]
    set level 0
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
	# ensure custom order y/x/z, i.e. row/column/band, for the actually used axes
	dict set axes $prefix [lmap a {y x z} {
	    if {![dict exists $spec $a]} continue
	    set a
	}]
    }
    # axes :: dict (prefix -> list(axis...))
    return
}

# # ## ### ##### ######## #############
## internal helpers

proc ::dsl::blit::spec::CheckAxis {a} {
    # TODO: axis xz
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
