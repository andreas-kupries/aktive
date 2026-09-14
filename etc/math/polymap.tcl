# -*- mode: tcl; fill-column: 90 -*-
##
# AKTIVE -- Andreas Kupries's Tcl Image/Vector Extension
#
# (c) 2026 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries

# # ## ### ##### ######## ############# #####################
## Poly map operators, with plain argument processing

proc aktive::math::polynomial::map* {coefficients args} {
    lmap x $args { at $coefficients $x }
}

proc aktive::math::polynomial::map {coefficients xs} {
    lmap x $xs { at $coefficients $x }
}

# # ## ### ##### ######## ############# #####################
return

