## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Transpose / transverse

tcl-operator op::transpose  {
    section transform structure

    note Returns image with the input mirrored along the primary diagonal.

    note This is an alias of `swap xy`.

    arguments src
    body { swap xy $src }
}

tcl-operator op::transverse {
    section transform structure

    note Returns image with the input mirrored along the secondary diagonal.

    arguments src
    body { flip x [flip y [swap xy $src]] }
}

##
# # ## ### ##### ######## ############# #####################
::return
