## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Transpose / transverse

tcl-operator op::transpose  {
    note Transformer. Structure. \
	Mirror the image along the main diagonal. \
	An alias of `swap xy`.

    arguments src
    body { swap xy $src }
}

tcl-operator op::transverse {
    note Transformer. Structure. \
	Mirror the image along the secondary diagonal.

    arguments src
    body { flip x [flip y [swap xy $src]] }
}

##
# # ## ### ##### ######## ############# #####################
::return
