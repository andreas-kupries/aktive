# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

apply {{} {
    source tests/support/files.tcl	;# catx, touch+
    source data/mathfunc/spec.tcl

    # generate vector operations (header, implementation), direct and highway

    set vdecl {}	;# direct vector ops, declarations ...
    set vdefs {}	;# ... and definitions

    set hdecl {}	;# highway vectors ops, declarations,
    set hdefs {}	;# ... definitions, ...
    set hexps {}	;# ... and exported dispatchers

    lappend nlmap "\n    " "\n"
    lappend nlmap "\n\t"   "\n    "

    foreach {name spec} $unary0 {
	set opcode [string trim [dict get $spec direct]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend vdecl [string map $xmap $unary0_vdecl]
	lappend vdefs [string map $xmap [string trim $unary0_vdef]]\n

	if {![dict exists $spec highway]} continue

	set opcode [string trim [dict get $spec highway]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend hdecl [string map $xmap $unary0_hdecl]
	lappend hdefs [string map $xmap [string trim $unary0_hdef]]\n
	lappend hexps [string map $xmap $unary0_hexport]\n
    }

    foreach {name spec} $unary1 {
	set opcode [string trim [dict get $spec direct]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend vdecl [string map $xmap $unary1_vdecl]
	lappend vdefs [string map $xmap [string trim $unary1_vdef]]\n

    	if {![dict exists $spec highway]} continue

	set opcode [string trim [dict get $spec highway]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend hdecl [string map $xmap $unary1_hdecl]
	lappend hdefs [string map $xmap [string trim $unary1_hdef]]\n
	lappend hexps [string map $xmap $unary1_hexport]\n
    }

    foreach {name spec} $unary2 {
	set opcode [string trim [dict get $spec direct]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend vdecl [string map $xmap $unary2_vdecl]
	lappend vdefs [string map $xmap [string trim $unary2_vdef]]\n

    	if {![dict exists $spec highway]} continue

	set opcode [string trim [dict get $spec highway]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend hdecl [string map $xmap $unary2_hdecl]
	lappend hdefs [string map $xmap [string trim $unary2_hdef]]\n
	lappend hexps [string map $xmap $unary2_hexport]\n
    }

    foreach {name spec} $binary {
	set opcode [string trim [dict get $spec direct]]
	set xmap   [linsert $nlmap end @name@ $name @opcode@ $opcode]
	lappend vdecl [string map $xmap $binary_vdecl]
	lappend vdefs [string map $xmap [string trim $binary_vdef]]\n

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
return
