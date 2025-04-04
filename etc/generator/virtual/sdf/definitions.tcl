## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- signed distance fields
##
## SDF definitions

sdf-def box
sdf-def box-rounded box
sdf-def circle
sdf-def circles {set of circles}
sdf-def line
sdf-def lines {set of independent lines}
sdf-def parallelogram
sdf-def polyline {set of connected lines}
sdf-def rhombus
sdf-def triangle

# # ## ### ##### ######## ############# #####################

proc sdf-whc {} {
    double? 1 ewidth   Element width
    double? 1 eheight  Element height
    sdf-centered
}

proc sdf-centered {} {
    fpoint   center   Element center
    # TODO: rotation, scaling
}

proc sdf-common-params {} {
    uint     width   Image width
    uint     height  Image height
    int?  0  x       Image location, X coordinate
    int?  0  y       Image location, Y coordinate
}

##
# # ## ### ##### ######## ############# #####################
::return
