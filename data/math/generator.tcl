# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

critcl::msg "[dsl::reader::blue {Math Vector Support}]: [dsl::reader::magenta [dict get {
  0 Production
  1 Benchmarking
} $benchmarking]]"

# # ## ### ##### ######## #############

proc scalar {section name spec} {
    upvar 1 vlink vlink

    # normally generate max-unrolled scalar loops
    # else     generate all possible scalar loops if benchmarking is active
    #
    # always make the runtime use the max-unrolled loop, regardless of mode.
    # benchmarking will create its own Tcl API to the other functions.

    set dsection [string trim $section 012]

    lappend vlink "#define aktive_vector_${dsection}_$name aktive_vector4_${dsection}_$name"

    global benchmarking
    if {$benchmarking} {
	# make all possibilities available
	scalar-gen $section $name scalar 1 $spec
	scalar-gen $section $name scalar 2 $spec
	scalar-gen $section $name scalar 4 $spec
	return
    }

    # make only max-rolled available
    scalar-gen $section $name scalar 4 $spec
    return
}

proc scalar-gen {section name key unroll spec} {
    upvar 2 vdecl vdecl vdefn vdefn ;#nlmap nlmap

    critcl::msg "\tscalar (unroll $unroll) [dsl::reader::cyan $section] [dsl::reader::blue $name]"

    set dsection [string trim $section 012]
    set opcode   [string trim [dict get $spec $key]]
    #set     xmap $nlmap

    upvar 2 scalar(${section},decl) declaration
    upvar 2 scalar(${section},impl) definition

    lappend xmap @func@ aktive_vector${unroll}_${dsection}_${name}
    lappend xmap @body@ [scalar-body $dsection $unroll $opcode]

    lappend vdecl [string map $xmap [string trim $declaration]]
    lappend vdefn [string map $xmap [string trim $definition]]\n
    return
}

proc scalar-body {section unroll opcode} {
    switch -exact -- $unroll {
	1 {
	    string trimleft [scalar-loop 1 $section $opcode]
	}
	2 {
	    join \
		[list [string trimleft [scalar-loop 2 $section $opcode]] \
		                       [scalar-loop 1 $section $opcode]] \n
	}
	4 {
	    join \
		[list [string trimleft [scalar-loop 4 $section $opcode]] \
		                       [scalar-loop 2 $section $opcode]  \
		                       [scalar-loop 1 $section $opcode]] \n
	}
    }
}

proc scalar-loop {unroll section opcode} {
    upvar 4 scalar($section,$unroll) loop
    string map [list @opcode${unroll}@ [scalar-opcode $unroll $opcode]] [string trim $loop \n]
}

proc scalar-opcode {unroll opcode} {
    switch -exact -- $unroll {
	1 {              string map {@V v @A a @B b} $opcode }
	2 {
	    lappend r   [string map {@V v0 @A a0 @B b0} $opcode]
	    lappend r \t[string map {@V v1 @A a1 @B b1} $opcode]
	    join $r \n
	}
	4 {
	    lappend r   [string map {@V v0 @A a0 @B b0} $opcode]
	    lappend r \t[string map {@V v1 @A a1 @B b1} $opcode]
	    lappend r \t[string map {@V v2 @A a2 @B b2} $opcode]
	    lappend r \t[string map {@V v3 @A a3 @B b3} $opcode]
	    join $r \n
	}
    }
}

apply {{} {
    source tests/support/files.tcl	;# catx, touch+
    source data/math/spec.tcl

    # generate scalar loops for vector operations (header, implementation)

    set vdecl {}	;# declarations ...
    set vdefn {}	;# ... and definitions
    set vlink {}	;# system integration

    # common substitutions for the code fragments
    #lappend nlmap "\n    " "\n"
    #lappend nlmap "\n\t"   "\n    "

    foreach {name spec} $unary0 { scalar unary0 $name $spec }
    foreach {name spec} $unary1 { scalar unary1 $name $spec }
    foreach {name spec} $unary2 { scalar unary2 $name $spec }
    foreach {name spec} $binary { scalar binary $name $spec }

    lappend zmap @vdecl@ [join $vdecl \n]
    lappend zmap @vdefn@ [join $vdefn \n]
    lappend zmap @vlink@ [join $vlink \n]

    touch generated/math.h [string map $zmap [catx data/math/template.h]]
    touch generated/math.c [string map $zmap [catx data/math/template.c]]
    return
}}

# # ## ### ##### ######## #############
rename scalar        {}
rename scalar-gen    {}
rename scalar-body   {}
rename scalar-loop   {}
rename scalar-opcode {}

# # ## ### ##### ######## #############
return
