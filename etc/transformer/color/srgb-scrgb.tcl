## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# # ## ### ##### ######## ############# #####################

tcl-operator op::color::scRGB::to::sRGB {
    section transform color

    note Returns image in sRGB colorspace, from input in scRGB colorspace. \
	Linear light becomes (gamma) compressed light.

    # simplifications happen in the math1 gamma commands.

    arguments src
    body { aktive op math1 gamma compress $src }
}

tcl-operator op::color::sRGB::to::scRGB {
    section transform color

    # simplifications happen in the math1 gamma commands.

    note Returns image in scRGB colorspace, from input in sRGB colorspace. \
	(gamma) compressed light becomes linear light.

    arguments src
    body { aktive op math1 gamma expand $src }
}

##
# # ## ### ##### ######## ############# #####################
::return
