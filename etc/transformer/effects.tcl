## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Artistic effects

# # ## ### ##### ######## ############# #####################
##

operator effect::sketch {
    section transform effect

    note Returns image with a general sketch of the input.

    input

    body {
	aktive op math1 invert \
	    [aktive op morph gradient all $src]
    }
}

operator effect::charcoal {
    section transform effect

    note Returns grey image with a charcoal-like sketch of the sRGB input.

    input

    bool? no light  Artistic choice between stronger and lighter sketch lines.

    body {
	# variants
	##
	# |lines   |operation order             |
	# |---     |---                         |
	# |stronger|color gradient, then to grey|
	# |lighter |to grey, then gradient      |
	#
	# Grey, being Y of XYZ is in range 0...100, thus the need to scale
	# by 1/100 to get range 0...1 for result, or input to gradient and
	# inversion.
	#
	# The inversion gives us black/grey lines on white background.

	if {$light} {
	    set src [aktive op color sRGB to Grey $src]
	    set src [aktive op math1 scale $src factor 0.01]
	    #
	    set src [aktive op morph gradient all $src]
	    set src [aktive op math1 invert $src]
	} else {
	    set src [aktive op morph gradient all $src]
	    set src [aktive op math1 invert $src]
	    #
	    set src [aktive op color sRGB to Grey $src]
	    set src [aktive op math1 scale $src factor 0.01]
	}
	return $src
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
