# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Runtime, Tcl level, Parameter collection support - Reserved namespace `parameter`

package require debug           ;# Tcllib
package require debug::caller   ;# ditto

debug level  aktive/parameter
debug prefix aktive/parameter {<[pid]> | }

#debug on     aktive/parameter

# # ## ### ##### ######## ############# #####################
## See dsl writer `ProcArgumentSetup` for the code emitting
## calls to these commands.

namespace eval aktive {
    namespace export parameter
    namespace ensemble create
}
namespace eval aktive::parameter {
    namespace export collect validate
    namespace ensemble create
}
namespace eval aktive::parameter::collect {
    namespace export required optional
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Implementations

proc aktive::parameter::validate {args} {
    upvar 1 args params
    foreach {p a} $args { dict set isargs $p $a }
    set pos 0
    foreach {p _} $params {
	if {![dict exists $isargs $p]} { aktive error "Bogus parameter $p" PARAMETER BOGUS }
	if {![dict get    $isargs $p]} { incr pos 2 ; continue }
	# p isargs -- everything after the key are the values.
	# rewrite into a proper dictionary (aggregate the list)
	incr pos
	set params [lreplace $params $pos end [lrange $params $pos end]]
	break
    }
}

proc aktive::parameter::collect::required {args} {
    debug.aktive/parameter {}
    upvar 1 args params

    foreach p $args {
	if {![dict exists $params $p]} {
	    aktive error "Required parameter $p not found" PARAMETER MISSING
	}
	uplevel 1 [list set $p [dict get $params $p]]
    }
    return
}

proc aktive::parameter::collect::optional {args} {
    debug.aktive/parameter {}
    upvar 1 args params
    foreach p $args {
	if {![dict exists $params $p]} continue
	uplevel 1 [list set $p [dict get $params $p]]
    }
    return
}

# # ## ### ##### ######## ############# #####################
return

