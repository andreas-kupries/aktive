## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Transpose / transverse

tcl-operator op::transpose    {src} { swap xy $src }
tcl-operator op::transverse   {src} { flip x [flip y [swap xy $src]] }

##
# # ## ### ##### ######## ############# #####################
::return
