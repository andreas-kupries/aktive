# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2024 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################

package require debug           ;# Tcllib
package require debug::caller   ;# ditto

debug level  aktive/aggregate
debug prefix aktive/aggregate {<[pid]> | }

#debug on     aktive/aggregate

namespace eval aktive {}

# # ## ### ##### ######## ############# #####################
## Helpers to combine a series of images with an associative binary
## command. Because of the expected associativity the aggregation
## constructs a binary tree.

proc aktive::aggregate-or-pass {cmdprefix parts} {
    if {[llength $parts]  < 1} { aktive error "not enough inputs, expected 1 or more" }
    if {[llength $parts] == 1} { return [lindex $parts 0] }
    aggregate $cmdprefix $parts
}

proc aktive::aggregate {cmdprefix parts} {
    debug.aktive/aggregate {}
    if {[llength $parts] < 2} { aktive error "not enough inputs, expected 2 or more" }

    # combine the images through a binary tree reduction
    while {[llength $parts] >= 2} {
	if {[llength $parts] % 2 == 1} {
	    # odd-length list - reduce only even part, with a passthrough
	    set last [lindex $parts end]
	    set parts [lmap {a b} [lrange $parts 0 end-1] {
		{*}$cmdprefix $a $b
	    }]
	    lappend parts $last
	} else {
	    # even-length list - reduce as is
	    set parts [lmap {a b} $parts {
		{*}$cmdprefix $a $b
	    }]
	}
    }
    # done
    return [lindex $parts 0]
}

# # ## ### ##### ######## ############# #####################
return

