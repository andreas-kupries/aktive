# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################

package require debug           ;# Tcllib
package require debug::caller   ;# ditto

package require tcl::chan::variable

debug level  aktive/2string
debug prefix aktive/2string {<[pid]> | }

#debug on     aktive/2string

# # ## ### ##### ######## ############# #####################
## Helper to wrap a 2chan image writer so that it returns a string.
## The helper is not made public.

namespace eval aktive {}

proc aktive::2string {src args} {
    debug.aktive/2string {}

    set var ::aktive_[clock microseconds]_[aktive query id $src]
    set dst [tcl::chan::variable $var]

    uplevel 1 [linsert $args end $dst $src]

    upvar #0 $var content
    set r $content

    close $dst
    unset content

    return $r
}

# # ## ### ##### ######## ############# #####################
return

