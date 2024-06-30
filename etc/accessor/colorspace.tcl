## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Getters -- Color space

operator op::query::colorspace {
    section accessor

    note Returns the name of color space the image is in.

    note If no colorspace is set then `sRGB` is assumed for 3-band images, \
	and `grey` for single-band images.

    note For anything else an error is thrown instead of making assumptions.

    input

    body {
	if {[aktive meta exists $src colorspace]} {
	    return [aktive meta get $src colorspace]
	}
	switch -exact -- [aktive query depth $src] {
	    1       { return "gray" }
	    3       { return "sRGB" }
	    default { aktive error "Unable to assume a colorspace" }
	}
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
