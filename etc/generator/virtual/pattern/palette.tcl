## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Gray/Color palettes

operator image::palette::grey {
    section generator virtual

    note Returns a 128x128 image containing a gray palette.

    example

    body {
	aktive op sample replicate xy \
	    [aktive image gradient width 8 height 8 depth 1 first 0 last 1] \
	    by 16
    }
}

operator image::palette::color {
    section generator virtual

    note Returns a 128x128 image containing a color palette.

    example

    body {
	set red   [aktive image gradient width 8 height 8 depth 1 first 0 last 1]
	set green [aktive op rotate cw   $red]
	set blue  [aktive op rotate half $red]
	aktive op sample replicate xy [aktive op montage z $red $green $blue] by 16
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
