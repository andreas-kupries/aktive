## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color conversions

# # ## ### ##### ######## ############# #####################

operator op::color::scRGB::to::sRGB {
    section transform color

    note Returns image in sRGB colorspace, from input in scRGB colorspace. \
	Linear light becomes (gamma) compressed light.

    # simplifications happen in the math1 gamma commands.

    input

    body {
	::aktive::op::color::CC scRGB sRGB $src aktive op math1 gamma compress $src
    }
}

operator op::color::sRGB::to::scRGB {
    section transform color

    # simplifications happen in the math1 gamma commands.

    note Returns image in scRGB colorspace, from input in sRGB colorspace. \
	(gamma) compressed light becomes linear light.

    input

    body {
	::aktive::op::color::CC sRGB scRGB $src aktive op math1 gamma expand $src
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
