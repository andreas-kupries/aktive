# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2023 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Common support for color operators

namespace eval aktive::op::color {}

proc aktive::op::color::CC {from to src args} {
    if {[aktive meta exists $src colorspace] &&
	([aktive meta get $src colorspace] ne $from)} {
	aktive error "rejecting input not in colorspace $from"
    }
    aktive meta set [{*}$args] colorspace $to
}
