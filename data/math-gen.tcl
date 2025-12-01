# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## #############

critcl::msg "[dsl::reader::blue {Math Vector Support}]: [dsl::reader::magenta [dict get {
  0 Production
  1 Benchmarking
} $benchmarking]]"

# # ## ### ##### ######## #############

proc direct {section name spec} {
    upvar 1 vlink vlink stash stash

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
	lappend vlink $stash
	return
    }

    if {$stash ne {}} return

    direct-gen $section $name direct 4 $spec
    set stash "#define aktive_vector_${dsection}_$name aktive_vector4_${dsection}_$name"
    lappend vlink $stash
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

proc highway {section name spec} { ;# return -- TODO: compile time conditional
    #      generate highway if  highway is available
    #                       and (nothing was made before or benchmarking activated)

    if {![dict exists $spec highway]} {
	critcl::msg "\thighway _________ [dsl::reader::cyan $section] [dsl::reader::red $name] (not supported)"
	return
    }

    global benchmarking
    upvar 1 stash stash
    if {!$benchmarking && ($stash ne {})} return

    set dsection [string trim $section 012]

    upvar 1 hdecl hdecl hdefs hdefs hexps hexps hlink hlink nlmap nlmap

    upvar 1 ${section}_hdecl   declaration
    upvar 1 ${section}_hdef    definition
    upvar 1 ${section}_hexport export

    critcl::msg "\thighway _________ [dsl::reader::cyan $section] [dsl::reader::blue $name]"

    lassign [highway-decode $spec] opcode decls
    set xmap      [linsert $nlmap end @name@ $name @opcode@ $opcode @decls@ $decls]

    lappend hdecl "    [string map $xmap $declaration]"
    lappend hdefs [string map $xmap [string trim $definition]]\n
    lappend hexps [string trim [string map $xmap $export]]\n

    set stash "#define aktive_vector_${dsection}_$name aktive_highway_${dsection}_$name"
    lappend hlink $stash
    return
}

proc highway-decode {spec} {
    # process the code fragment according to the description at the top of
    # `mathfunc/spec.tcl`.

    set decls {}
    set opcode [lmap line [split [dict get $spec highway] \n] {
	set line [string trim $line]
	# process general custom declarations
	if {[string match {const auto *} $line] ||
	    [string match {CDEF} $line]} {
	    lappend decls "    $line"
	    continue
	}
	# process builtin helper constants - note order.
	# @0 is prefix of @0.5, has to be handled after
	foreach {key var spec} {
	    @0.5 half "Set  (f64, 0.5)"
	    @0   zero "Zero (f64)"
	    @1   one  "Set  (f64, 1)"
	    @-1  none "Set  (f64, -1)"
	} {
	    if {![string match "*${key}*" $line]} continue
	    set line [highway-decl $line $key $var $spec]
	}
	string cat "\t    " $line
    }]

    if {[llength $decls]} {
	set sep "// / / // /// ///// //////// /////////////"
	set     decls [linsert $decls 0 $sep]
	lappend decls "    $sep"
    }

    list \
	[string trim [join $opcode \n]] \
	[string trim [join $decls  \n]]
}

proc highway-decl {line key var value} {
    upvar 1 decls decls
    lappend decls "    const auto __$var = $value;"
    return [string map [list $key __$var] $line]
}

apply {{} {
    source tests/support/files.tcl	;# catx, touch+
    source data/mathfunc/spec.tcl

    # generate vector operations (header, implementation), direct and highway

    set vdecl {}	;# direct vector ops, declarations ...
    set vdefs {}	;# ... and definitions
    set vlink {}	;# integration with rest of system

    set hdecl {}	;# highway vectors ops, declarations,
    set hdefs {}	;# ... definitions, ...
    set hexps {}	;# ... and exported dispatchers
    set hlink {}	;# integration with rest of system

    # common substitutions for the code fragments
    lappend nlmap "\n    " "\n"
    lappend nlmap "\n\t"   "\n    "

    foreach {name spec} $unary0 {
	set stash {}
	highway unary0 $name $spec
	direct  unary0 $name $spec
    }

    foreach {name spec} $unary1 {
	set stash {}
	highway unary1 $name $spec
	direct  unary1 $name $spec
    }

    foreach {name spec} $unary2 {
	set stash {}
	highway unary2 $name $spec
	direct  unary2 $name $spec
    }

    foreach {name spec} $binary {
	set stash {}
	highway binary $name $spec
	direct  binary $name $spec
    }

    lappend zmap @vlink@    [join $vlink \n]
    lappend zmap @hlink@    [join $hlink \n]
    lappend zmap @vdecl@    [join $vdecl \n]
    lappend zmap @hdecl@    [join $hdecl \n]
    lappend zmap @vdefs@    [join $vdefs \n]
    lappend zmap @hdefs@    [join $hdefs \n]
    lappend zmap @hexports@ [join $hexps \n]

    touch generated/vector_direct.h   [string map $zmap [catx data/mathfunc/template-vector.h]]
    touch generated/vector_direct.c   [string map $zmap [catx data/mathfunc/template-vector.c]]
    touch generated/vector_highway.h  [string map $zmap [catx data/mathfunc/template-highway.h]]
    touch generated/vector_highway.cc [string map $zmap [catx data/mathfunc/template-highway.c]]
    return
}}

# # ## ### ##### ######## #############
rename direct         {}
rename direct-gen     {}
rename highway        {}
rename highway-decode {}

# # ## ### ##### ######## #############
return
