## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Color database

operator color::css {
    section color
    external!

    example {
	lavenderblush | -text
    }
    example {
	# active color css-names -- auto compute WxH -- prevent usage of primes
    } {
	!!aktive image from color-matrix width 30 height 5 values {*}[aktive color css-names] | times 16
    }

    note Returns the RGB values for the named color. \
	The command knows the CSS colors up to CSS level 4.

    str name Color name to look up.
}

operator color::css-names {
    section color
    external!

    example {
	!!string cat "..." [lrange [@cmd] 50 65] "..." | -text
    }

    note Returns the names of all CSS colors known to the package, up to CSS level 4.
}

##
# # ## ### ##### ######## ############# #####################
::return
