## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Color database

operator color::css {
    section color
    external!

    note Returns the RGB values for the named color. \
	The command knows the CSS colors up to CSS level 4.

    str name Color name to look up.
}

##
# # ## ### ##### ######## ############# #####################
::return
