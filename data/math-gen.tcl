# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

critcl::msg "[dsl::reader::blue {Math Vector Support}]: [dsl::reader::magenta [dict get {
  0 Production
  1 Benchmarking
} $benchmarking]]"

# # ## ### ##### ######## #############

proc direct {section name spec} {
    upvar 1 vdecl vdecl stash stash

    #      generate max-unrolled scalar loop if scalar is available and nothing was made before
    # else generate all possible scalar loop if scalar is available and benchmarking activated

    if {![dict exists $spec direct]} return

    set dsection [string trim $section 012]

    global benchmarking

    if {$benchmarking} {
	# make all possibilities available
	direct-gen $section $name direct 1 $spec
	direct-gen $section $name direct 2 $spec
	direct-gen $section $name direct 4 $spec
	set stash "#define aktive_vector_${dsection}_$name aktive_vector4_${dsection}_$name"
	lappend vdecl $stash
	return
    }

    if {$stash ne {}} return

    direct-gen $section $name direct 4 $spec
    set stash "#define aktive_vector_${dsection}_$name aktive_vector4_${dsection}_$name"
    lappend vdecl $stash
    return
}

proc direct-gen {section name key n spec} {
    upvar 2 vdecl vdecl vdefs vdefs nlmap nlmap

    critcl::msg "\tscalar (unroll $n) [dsl::reader::cyan $section] [dsl::reader::blue $name]"

    set opcode [string trim [dict get $spec $key]]
    set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]

    upvar 2 u${n}_${section}_vdecl declaration
    upvar 2 u${n}_${section}_vdef  definition

    lappend vdecl [string map $xmap $declaration]
    lappend vdefs [string map $xmap [string trim $definition]]\n
    return
}

proc highway {section name spec} {
    #      generate highway if  highway is available
    #                       and (nothing was made before or benchmarking activated)

    if {![dict exists $spec highway]} return

    global benchmarking
    upvar 1 stash stash
    if {!$benchmarking && ($stash ne {})} return

    upvar 1 hdecl hdecl hdefs hdefs hexps hexps nlmap nlmap

    upvar 1 ${section}_hdecl   declaration
    upvar 1 ${section}_hdef    definition
    upvar 1 ${section}_hexport export

    critcl::msg "\thighway _________ [dsl::reader::cyan $section] [dsl::reader::blue $name]"

    set opcode [string trim [dict get $spec highway]]
    set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]

    lappend hdecl [string map $xmap $declaration]
    lappend hdefs [string map $xmap [string trim $definition]]\n
    lappend hexps [string map $xmap $export]\n

    set stash "#define aktive_vector_${dsection}_$name aktive_highway_unary_$name"
    lappend hdecl $stash
    return
}

apply {{} {
    source tests/support/files.tcl	;# catx, touch+
    source data/mathfunc/spec.tcl

    # generate vector operations (header, implementation), direct and highway

    set vdecl {}	;# direct vector ops, declarations ...
    set vdefs {}	;# ... and definitions

    set hdecl {}	;# highway vectors ops, declarations,
    set hdefs {}	;# ... definitions, ...
    set hexps {}	;# ... and exported dispatchers

    # common substitutions for the code fragments
    lappend nlmap "\n    " "\n"
    lappend nlmap "\n\t"   "\n    "

    foreach {name spec} $unary0 {
	set stash {}
	if {[dict exists $spec highway]} {
	}
	highway unary0 $name $spec
	direct  unary0 $name $spec
    }

    foreach {name spec} $unary1 {
	set stash {}
    	if {[dict exists $spec highway]} {
	    set opcode [string trim [dict get $spec highway]]
	    set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	    lappend hdecl [string map $xmap $unary1_hdecl]
	    lappend hdefs [string map $xmap [string trim $unary1_hdef]]\n
	    lappend hexps [string map $xmap $unary1_hexport]\n
	    set stash "#define aktive_vector_unary_$name aktive_highway_unary_$name"
	    lappend hdecl $stash
	}
	direct unary1 $name $spec
    }

    foreach {name spec} $unary2 {
	set stash {}
    	if {[dict exists $spec highway]} {
	    set opcode [string trim [dict get $spec highway]]
	    set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	    lappend hdecl [string map $xmap $unary2_hdecl]
	    lappend hdefs [string map $xmap [string trim $unary2_hdef]]\n
	    lappend hexps [string map $xmap $unary2_hexport]\n
	    set stash "#define aktive_vector_unary_$name aktive_highway_unary_$name"
	    lappend hdecl $stash
	}
	direct unary2 $name $spec
    }

    foreach {name spec} $binary {
	set stash {}
    	if {[dict exists $spec highway]} {
	    set opcode [string trim [dict get $spec highway]]
	    set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	    lappend hdecl [string map $xmap $binary_hdecl]
	    lappend hdefs [string map $xmap [string trim $binary_hdef]]\n
	    lappend hexps [string map $xmap $binary_hexport]\n
	    set stash "#define aktive_vector_binary_$name aktive_highway_binary_$name"
	    lappend hdecl $stash
	}
	direct binary $name $spec
    }

    lappend zmap @vdecl@    [join $vdecl \n]
    lappend zmap @hdecl@    [join $hdecl \n]
    lappend zmap @vdefs@    [join $vdefs \n]
    lappend zmap @hdefs@    [join $hdefs \n]
    lappend zmap @hexports@ [join $hexps \n]

    touch generated/vector_direct.h  [string map $zmap [catx data/mathfunc/template-vector.h]]
    touch generated/vector_direct.c  [string map $zmap [catx data/mathfunc/template-vector.c]]
    touch generated/vector_highway.h [string map $zmap [catx data/mathfunc/template-highway.h]]
    touch generated/vector_highway.c [string map $zmap [catx data/mathfunc/template-highway.c]]
    return
}}

# # ## ### ##### ######## #############
rename direct     {}
rename direct-gen {}
rename highway    {}

# # ## ### ##### ######## #############
return
