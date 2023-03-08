## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Rotate in 90 degree increments

tcl-operator op::rotate::cw   {
    section transform structure

    note Returns image rotating the input 90 degrees clockwise.

    arguments src
    body { aktive op flip x [aktive op swap xy $src] }
}

tcl-operator op::rotate::ccw  {
    section transform structure

    note Returns image rotating the input 90 degrees counter clockwise

    arguments src
    body { aktive op flip y [aktive op swap xy $src] }
}

tcl-operator op::rotate::half {
    section transform structure

    note Returns image rotating the input 180 degrees (counter) clockwise.

    arguments src
    body { aktive op flip x [aktive op flip y $src] }
}

##
# # ## ### ##### ######## ############# #####################
::return
