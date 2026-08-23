# -*- mode: tcl; fill-column: 90 -*-
# # ## ### ##### ######## ############# ##################### ##################################
##
# internal database for math functions (math ops, function templates, loop templates)
# loaded from the specification
##

proc def-op {kind mode name arguments body} {
    global   ops
    dict set ops $mode $kind $name $arguments $body
    return
}

proc def-func {kind arguments decl body} {
    global func
    append kind /[join $arguments ,]
    set decl [string trim $decl]
    set body "$decl \{$body\}"
    set decl "extern $decl;"
    dict set func $kind [list $decl $body]
    return
}

proc def-loop {kind unroll body} {
    global loop
    dict set loop $kind $unroll $body
}

# # ## ### ##### ######## #############

proc ops {mode} {
    global ops ;# dict mode -> kind -> name -> arguments -> body
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

proc func {kind arguments} {
    global func
    append kind /[join $arguments ,]
    dict get $func $kind
}

proc loop-body {kind unroll} {
    global loop
    dict get $loop $kind $unroll
}

# # ## ### ##### ######## ############# ##################### ##################################
return
