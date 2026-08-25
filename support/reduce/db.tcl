# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## ############# ##################### ##################################
##
# internal database for reduction operations, reducer templates. loaded from the specifications
##

# # ## ### ##### ######## #############

namespace eval reduce {
    variable reduce    {} ;# dict (name -> spec), spec: dict (key -> value)
    variable reducers  {} ;# list
    variable func      {} ;# dict (axis -> name -> (decl def))
    variable functions {} ;# dict (axis -> list (name))

    variable declarations {} ;# list (declaration...)
    variable definitions  {} ;# list (definition...)
    variable linkage      {} ;# list (link...)

    variable gendir [file dirname [file normalize [info script]]]
}

# # ## ### ##### ######## #############

proc reduce::code-init {} { return }

proc reduce::code-extend {decl def link} {
    variable declarations ; lappend  declarations $decl
    variable definitions  ; lappend  definitions  $def
    variable linkage      ; set      linkage      [lreplace $linkage end end $link]
}

proc reduce::code-next {} {
    variable linkage ; lappend linkage {/* placeholder */}
}

proc reduce::code-sep {} {
    variable declarations ; lappend declarations {}
}

proc reduce::code-map {} {
    variable declarations ; lappend map @declarations@ [join $declarations \n]
    variable definitions  ; lappend map @definitions@  [join $definitions  \n]
    variable linkage      ; lappend map @linkage@      [join $linkage      \n]
    return $map
}

# # ## ### ##### ######## #############

proc reduce::def-reduce {name spec} {
    variable reducers
    if {$name in $reducers} { return -code error "duplicate reducer $name" }
    variable reduce

    foreach {key _} $spec {
	if {$key ni {
	    once setup reduce merge finalize single
	}} { return -code error "reducer $name, bad key $key" }
    }

    #puts /$name\t>>$spec<<

    foreach {key process} {
	once      asline
	setup     asline
	reduce    asline
	merge     asline
	finalize  trim
	single    asline
    } {
	if {![dict exists $spec $key]} {
	    if {$key ne "once"} {
		return -code error "reducer $name, required key $key missing"
	    }
	    dict set spec once {}
	    continue
	}

	set value [dict get $spec $key]
	# resolve references (no recursion)
	if {[string match @* $value]} {
	    #puts	($name)=<$key>=($value)
	    set ref   [string range $value 1 end]
	    set value [dict get $reduce $ref $key]
	    #puts	($name)=<$key>=($value)
	}
	dict set spec $key [$process $value]
    }

    #puts /$name\t>>$spec<<----------

    dict set reduce  $name $spec

    lappend reducers $name
    set     reducers [lsort -dict $reducers]
    return
}

proc reduce::names {}     { variable reducers ; return $reducers }
proc reduce::get   {name} { variable reduce ; dict get $reduce $name }

# # ## ### ##### ######## #############

proc reduce::def-func {axis name placeholders body} {
    variable func
    if {[dict exists $func $axis $name]} { return -code error "duplicate ${axis} function: $name" }
    variable functions
    dict lappend functions $axis $name

    ## match the configured placeholders against the placeholders actually found in the body
    set configured [lsort -dict -uniq [lmap line [split $placeholders \n] {
	#puts CHECK($line)
	if {![string match {*lappend map *} $line]} continue ;# { puts \tSKIP ; continue }
	lindex [split [string trim $line] { }] 2 ;# key name
    }]]
    set expected [lsort -dict -uniq [regexp -all -inline {@[^@]*@} $body]]

    # debug - placeholders in placeholders and body
    #puts //$axis\t$name\t______________________________________________________________
    #puts \t>>$placeholders<<
    #puts \tconfigured:\n\t([join $configured ")\n\t("])
    #puts \t>>$body<<
    #puts \texpected:\n\t([join $expected ")\n\t("])

    if 0 {foreach c $configured { if {$c in $expected} continue
	puts "$axis/$name - configured `$c` is not used in body"
    }}
    set missing [lmap e $expected { if {$e in $configured} continue ; set e }]
    if {[llength $missing]} {
	return -code error "$axis/$name - placeholders\n\t- [join $missing "\n\t- "]) in body are not configured"
    }

    ## construct the C function to template
    variable gendir
    set header      [catx $gendir/assets/$axis/func.h]
    set funcname    "aktive_reduce_${axis}s_${name}_@name@"
    set signature   "(double *dst, double* src, aktive_uint count, aktive_uint stride)"
    set declaration "extern void $funcname ${signature};"
    set tracing     "\n    TRACE_FUNC(\"(dst %p\[%d], src %p\[%dx%d])\", dst, count, src, count, stride)"
    set body        "void $funcname $signature \{${tracing};${header}${body}    TRACE_RETURN_VOID;\n\}\n"

    ## and the lambda to generate the mapping from a reductor spec
    set placeholders "dict with spec {}\n#--> once setup reduce merge finalize\n$placeholders\nreturn \$map"

    dict set func $axis $name [list [string trim $declaration] $body $placeholders]
    return
}

proc reduce::for-axis {axis} { variable functions ; dict get $functions $axis }

proc reduce::without-base {names} {
    lmap n $names {
	if {$n eq "baseline"} continue
	set n
    }
}

proc reduce::without-xcheck {names} {
    lmap n $names {
	if {$n eq "crosscheck"} continue
	set n
    }
}

proc reduce::without-sys {names} {
    lmap n $names {
	if {$n eq "baseline"} continue
	if {$n eq "crosscheck"} continue
	set n
    }
}


proc reduce::build-func {axis funcname opname} {
    variable func
    lassign [dict get $func $axis $funcname] funcdecl funcdef placeholders

    set placeholders [apply [list {name spec} $placeholders reduce] $opname [get $opname]]

    code-extend \
	[string map $placeholders $funcdecl] \
	[string map $placeholders $funcdef] \
	"#define aktive_reduce_${axis}s_$opname aktive_reduce_${axis}s_${funcname}_$opname"
    return
}

# # ## ### ##### ######## #############

proc reduce::map    {s args} { string map $args $s }
proc reduce::trim   {s}      { string trim $s }
proc reduce::asline {s}      { trim [map $s "\n" ""] }
proc reduce::dedent {s} { map $s \
		      "\t\t    " "\t\t"   \
		      "\t\t"     "\t    " \
		      "\t    "   "\t"     \
		      "\t"       "    "   \
		      "    "     ""       }

proc reduce::single {mode size} {
    map [dict get {
	pass   {*src}
	zero   {0}
	square {(*src) * (*src)}
	forn   {(*src) != 0 ? 0 : @N}
	lorn   {(*src) != 0 ? 0 : -1}
    } $mode] @N $size
}

# # ## ### ##### ######## ############# ##################### ##################################
return
