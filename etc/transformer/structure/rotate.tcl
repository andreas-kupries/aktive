## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Rotate in 90 degree increments

tcl-operator op::rotate::cw   {src} { aktive op flip x [aktive op swap xy $src] }
tcl-operator op::rotate::ccw  {src} { aktive op flip y [aktive op swap xy $src] }
tcl-operator op::rotate::half {src} { aktive op flip x [aktive op flip  y $src] }

##
# # ## ### ##### ######## ############# #####################
::return
