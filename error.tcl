# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Fixed command, not generated

proc aktive::error {m args} {
    return -code error -errorcode [linsert $args 0 AKTIVE ERROR] $m
}

# # ## ### ##### ######## ############# #####################
return

