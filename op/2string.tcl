# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023-2024 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################

package require debug           ;# Tcllib
package require debug::caller   ;# ditto

debug level  aktive/2string
debug prefix aktive/2string {<[pid]> | }

#debug on     aktive/2string

namespace eval aktive {}

# # ## ### ##### ######## ############# #####################
## Helper to wrap a 2chan image writer so that it writes to a file
## The helper is not made public.

proc aktive::2file {path src args} {
    debug.aktive/2string {}

    set dst [open $path w]
    uplevel 1 [linsert $args end $src into $dst]
    close $dst
    return
}

# # ## ### ##### ######## ############# #####################
return

