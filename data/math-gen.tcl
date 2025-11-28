# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

proc direct {section name spec} {
    upvar 1 vdecl vdecl

    # generate the requested variant for loop unrolling, or all.
    # use a define to make the requested or highest available
    # for use by image operations.

    set dsection [string trim $section 012]

    if {[dict exists $spec direct]} {
	# make all possibilities available
	direct-gen $section $name direct 1 $spec
	direct-gen $section $name direct 2 $spec
	direct-gen $section $name direct 4 $spec

	# make the 4-unrolled available for execution
	lappend vdecl "#define aktive_vector_${dsection}_$name aktive_vector4_${dsection}_$name"
    } elseif {[dict exists $spec direct1]} {
	direct-gen $section $name direct1 1 $spec

	# make the 1-unrolled available for execution
	lappend vdecl "#define aktive_vector_${dsection}_$name aktive_vector1_${dsection}_$name"
    } elseif {[dict exists $spec direct2]} {
	direct-gen $section $name direct2 2 $spec

	# make the 2-unrolled available for execution
	lappend vdecl "#define aktive_vector_${dsection}_$name aktive_vector2_${dsection}_$name"
    } elseif {[dict exists $spec direct4]} {
	direct-gen $section $name direct4 4 $spec

	# make the 4-unrolled available for execution
	lappend vdecl "#define aktive_vector_${dsection}_$name aktive_vector4_${dsection}_$name"
    }
}

proc direct-gen {section name key n spec} {
    upvar 2 vdecl vdecl vdefs vdefs nlmap nlmap

    set opcode [string trim [dict get $spec $key]]
    set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]

    upvar 2 u${n}_${section}_vdecl declaration
    upvar 2 u${n}_${section}_vdef  definition

    lappend vdecl [string map $xmap $declaration]
    lappend vdefs [string map $xmap [string trim $definition]]\n
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
	direct unary0 $name $spec

	if {![dict exists $spec highway]} continue

	set opcode [string trim [dict get $spec highway]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend hdecl [string map $xmap $unary0_hdecl]
	lappend hdefs [string map $xmap [string trim $unary0_hdef]]\n
	lappend hexps [string map $xmap $unary0_hexport]\n
    }

    foreach {name spec} $unary1 {
	direct unary1 $name $spec

    	if {![dict exists $spec highway]} continue

	set opcode [string trim [dict get $spec highway]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend hdecl [string map $xmap $unary1_hdecl]
	lappend hdefs [string map $xmap [string trim $unary1_hdef]]\n
	lappend hexps [string map $xmap $unary1_hexport]\n
    }

    foreach {name spec} $unary2 {
	direct unary2 $name $spec

    	if {![dict exists $spec highway]} continue

	set opcode [string trim [dict get $spec highway]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend hdecl [string map $xmap $unary2_hdecl]
	lappend hdefs [string map $xmap [string trim $unary2_hdef]]\n
	lappend hexps [string map $xmap $unary2_hexport]\n
    }

    foreach {name spec} $binary {
	direct binary $name $spec

    	if {![dict exists $spec highway]} continue

	set opcode [string trim [dict get $spec highway]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend hdecl [string map $xmap $binary_hdecl]
	lappend hdefs [string map $xmap [string trim $binary_hdef]]\n
	lappend hexps [string map $xmap $binary_hexport]\n
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

# # ## ### ##### ######## #############
return
