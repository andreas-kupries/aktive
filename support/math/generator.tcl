# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

global benchmarking

critcl::msg "[dsl::reader::blue {Math Vector Support}]: [dsl::reader::magenta [dict get {
  0 Production
  1 Benchmarking
} $benchmarking]]"

# # ## ### ##### ######## #############

source tests/support/files.tcl		;# import catx, touch+
source support/math/db.tcl		;# generator data base

# # ## ### ##### ######## #############

proc vectormath::generate {spec} {
    # normally                   generate max-unrolled loops
    # if benchmarking is active  generate all possible loops
    #
    # always make the runtime use the max-unrolled loop, regardless of mode.
    # benchmarking creates its own Tcl API to the other functions.

    lassign $spec kind name _ _
    code-link "#define aktive_vector_${kind}_$name\t\taktive_unroll4_${kind}_$name"

    global benchmarking
    if {$benchmarking} {
	# make all possibilities available
	for-unroll 1 $spec
	for-unroll 2 $spec
	for-unroll 4 $spec
	return
    }

    # make only max-rolled available
    for-unroll 4 $spec
    return
}

proc vectormath::for-unroll {unroll spec} { ;# puts [info level 0]
    lassign $spec                   kind name arguments statements
    lassign [func $kind $arguments] fundecl fundef

    critcl::msg "\tscalar (unroll $unroll) [dsl::reader::cyan $kind] [dsl::reader::blue $name] ($arguments)"

    lappend funcmap @func@ aktive_unroll${unroll}_${kind}_${name} ;# match linkage
    lappend funcmap @body@ [assemble-body $unroll $kind $statements]

    code-extend \
	[string map $funcmap [trim $fundecl]] \
	[string map $funcmap [trim $fundef ]]\n
    return
}

proc vectormath::assemble-body {unroll kind opcode} { ;# puts [info level 0]
    if {$unroll < 1} { return -code error "bad unroll level $unroll, has to be > 1" }
    set first 1
    while {$unroll > 0} {
	set line [assemble-loop $unroll $kind $opcode]
	if {$first} { set line [string trimleft $line] ; set first 0 }
	lappend lines $line
	set unroll [expr {$unroll >> 1}]
    }
    join $lines \n
}

proc vectormath::assemble-loop {unroll kind opcode} { ;# puts [info level 0]
    string map \
	[list @opcode${unroll}@ [assemble-op $unroll $opcode]] \
	"    [trim [loop-body $kind $unroll]]"
}

proc vectormath::assemble-op {unroll opcode} { ;# puts [info level 0]
    # rewrite > 1 as loop
    if {$unroll  < 1} { return -code error "bad unroll level $unroll, has to be > 1" }
    if {$unroll == 1} { return $opcode }
    set prefix {}
    set lines {}
    while {$unroll > 0} {
	incr unroll -1
	lappend lines ${prefix}[string map \
		[list \
		     value value$unroll \
		     arga  arga$unroll  \
		     argb  argb$unroll  ] \
		$opcode]
	set prefix \t
    }
    return [join $lines \n]
}

# # ## ### ##### ######## #############

apply {{} {
    source support/math/assets/ops.tcl		;# operator specs
    source support/math/assets/functions.tcl	;# function specs
    source support/math/assets/loops.tcl	;# loop specs

    # generate scalar loops for vector operations (header, implementation)

    code-init
    foreach spec [ops scalar] { generate $spec }
    set zmap [code-map]

    touch generated/math.h [string map $zmap [catx support/math/assets/template.h]]
    touch generated/math.c [string map $zmap [catx support/math/assets/template.c]]
} vectormath}

# # ## ### ##### ######## #############

namespace delete vectormath

# # ## ### ##### ######## #############
return
