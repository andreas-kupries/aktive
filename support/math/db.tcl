# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## ############# ##################### ##################################
##
# internal database for math functions (math ops, function templates, loop templates)
# loaded from the specification
##

namespace eval vectormath {
    variable ops  {} ;# dict (mode -> kind -> name -> arguments -> body)
    variable func {} ;# dict (kind -> list (decl def))
    variable loop {} ;# dict (kind -> unroll -> body)

    variable declarations {} ;# list (declaration...)
    variable definitions  {} ;# list (definition...)
    variable linkage      {} ;# list (link...)
}

# # ## ### ##### ######## #############

proc vectormath::code-init   {} { return }

proc vectormath::code-extend {decl def} {
    variable declarations ; lappend  declarations $decl
    variable definitions  ; lappend  definitions  $def
    return
}

proc vectormath::code-link {link} { variable linkage ; lappend linkage $link }

proc vectormath::code-map {} {
    variable declarations ; lappend map @declarations@ [join $declarations \n]
    variable definitions  ; lappend map @definitions@  [join $definitions  \n]
    variable linkage      ; lappend map @linkage@      [join $linkage      \n]
    return $map
}

# # ## ### ##### ######## #############

proc vectormath::def-op {kind mode name arguments body} {
    variable ops
    dict set ops $mode $kind $name $arguments $body
    return
}

proc vectormath::def-func {kind arguments decl body} {
    variable func
    append kind /[join $arguments ,]
    set decl [string trim $decl]
    set body "$decl \{$body\}"
    set decl "extern $decl;"
    dict set func $kind [list $decl $body]
    return
}

proc vectormath::def-loop {kind unroll body} {
    variable loop
    dict set loop $kind $unroll $body
    return
}

# # ## ### ##### ######## #############

proc vectormath::ops {mode} {
    variable ops ;# dict mode -> kind -> name -> arguments -> body
    set results {}

    #puts /mode=$mode/
    foreach kind [lsort -dict [dict keys [dict get $ops $mode]]] {
	#puts /kind=$kind/
	foreach name [lsort -dict [dict keys [dict get $ops $mode $kind]]] {
	    #puts /name=$name/
	    foreach arguments [lsort -dict [dict keys [dict get $ops $mode $kind $name]]] {
		#puts /args=$arguments/
		set body [dict get $ops $mode $kind $name $arguments]
		lappend results [list $kind $name $arguments $body]
	    }
	}
    }
    return $results
}

proc vectormath::func {kind arguments} {
    variable func
    append kind /[join $arguments ,]
    dict get $func $kind
}

proc vectormath::loop-body {kind unroll} {
    variable loop
    dict get $loop $kind $unroll
}

# # ## ### ##### ######## #############

proc vectormath::map  {s args} { string map $args $s }
proc vectormath::trim {s}      { string trim $s }

# # ## ### ##### ######## ############# ##################### ##################################
return
