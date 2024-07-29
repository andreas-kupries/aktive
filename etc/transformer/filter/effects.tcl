## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Artistic effects

# # ## ### ##### ######## ############# #####################
##

operator effect::emboss {
    section transform effect

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1
    }

    note Returns embossed input.

    input

    body {
	set k   [aktive image kernel emboss]
	set src [aktive op convolve xy $k $src]
	set src [aktive op math1 fit min-max $src]
    }
}

operator effect::sharpen {
    section transform effect

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1
    }

    note Returns sharpened input.

    input

    body {
	aktive op convolve xy [aktive image kernel sharp X] $src
    }
}

operator effect::blur {
    section transform effect

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 radius 16
    }
    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 1]
	@1 radius 16
    }

    note Returns blurred input, per the specified blur radius.

    input

    double? 2 radius Blur kernel radius. Defaults to 2.

    body {
	aktive op convolve xy [aktive image kernel gauss discrete sigma [expr {$radius/3.0}]] $src
    }
}

operator effect::sketch {
    section transform effect

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1
    }
    example {
	aktive op sdf 2image smooth [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}]
	@1
    }

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
