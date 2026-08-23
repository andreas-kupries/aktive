# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

critcl::msg "[dsl::reader::blue {Math Vector Support}]: [dsl::reader::magenta [dict get {
  0 Production
  1 Benchmarking
} $benchmarking]]"

# # ## ### ##### ######## #############

proc generate {kind name arguments statements fundecl fundef} { ;# puts [info level 0]
    upvar linkage linkage

    # normally                   generate max-unrolled loops
    # if benchmarking is active  generate all possible loops
    #
    # always make the runtime use the max-unrolled loop, regardless of mode.
    # benchmarking creates its own Tcl API to the other functions.

    lappend linkage "#define aktive_vector_${kind}_$name\t\taktive_unroll4_${kind}_$name"
    set     section $kind/[llength $arguments]

    global benchmarking
    if {$benchmarking} {
	# make all possibilities available
	generate-for-unroll 1 $kind $name $arguments $statements $fundecl $fundef
	generate-for-unroll 2 $kind $name $arguments $statements $fundecl $fundef
	generate-for-unroll 4 $kind $name $arguments $statements $fundecl $fundef
	return
    }

    # make only max-rolled available
    generate-for-unroll 4 $kind $name $arguments $statements $fundecl $fundef
    return
}

proc generate-for-unroll {unroll kind name arguments statements fundecl fundef} { ;# puts [info level 0]
    upvar 2 declarations declarations definitions definitions

    critcl::msg "\tscalar (unroll $unroll) [dsl::reader::cyan $kind] [dsl::reader::blue $name] ($arguments)"

    lappend funcmap @func@ aktive_unroll${unroll}_${kind}_${name} ;# match linkage
    lappend funcmap @body@ [assemble-body $unroll $kind $statements]

    lappend declarations [string map $funcmap [string trim $fundecl]]
    lappend definitions  [string map $funcmap [string trim $fundef]]\n
    return
}

proc assemble-body {unroll kind opcode} { ;# puts [info level 0]
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

proc assemble-loop {unroll kind opcode} { ;# puts [info level 0]
    string map \
	[list @opcode${unroll}@ [assemble-op $unroll $opcode]] \
	[string trim [loop-body $kind $unroll] \n]
}

proc assemble-op {unroll opcode} { ;# puts [info level 0]
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

apply {{} {
    source tests/support/files.tcl		;# import catx, touch+
    source support/math/db.tcl			;# generator data base
    source support/math/assets/ops.tcl		;# operator specs
    source support/math/assets/functions.tcl	;# function specs
    source support/math/assets/loops.tcl	;# loop specs

    # generate scalar loops for vector operations (header, implementation)

    lassign {{} {} {}} \
	declarations \
	definitions \
	linkage

    foreach spec [ops scalar] {
	lassign $spec                   kind name arguments statements
	lassign [func $kind $arguments] fundecl fundef
	#
	generate $kind $name $arguments $statements $fundecl $fundef
    }

    lappend zmap @declarations@ [join $declarations \n]
    lappend zmap @definitions@  [join $definitions \n]
    lappend zmap @linkage@      [join $linkage \n]

    touch generated/math.h [string map $zmap [catx support/math/assets/template.h]]
    touch generated/math.c [string map $zmap [catx support/math/assets/template.c]]
    return
}}

# # ## ### ##### ######## #############

rename generate            {}
rename generate-for-unroll {}
rename assemble-body       {}
rename assemble-loop       {}
rename assemble-op         {}

rename def-op    {}
rename def-func  {}
rename def-loop  {}
rename ops       {}
rename func      {}
rename loop-body {}

# # ## ### ##### ######## #############
return
