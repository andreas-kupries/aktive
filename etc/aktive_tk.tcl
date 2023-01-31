# -*- mode: tcl ; fill-column: 90 -*-
## # # ## ### ##### ######## ############# #####################

type photo aktive_photo Tk_PhotoHandle

## # # ## ### ##### ######## ############# #####################
# Image sinks ... Writing an image to somewhere else

operator image::tk::set {
    input ignore

    photo photo  Tk photo to write the image to
}

## # # ## ### ##### ######## ############# #####################
# Image generators ... The returned image is constructed from the parameters.

operator image::tk::photo {
    photo photo   Tk photo image the image is read from
}
