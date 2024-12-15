## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Origin map of a wobble/ripple effect

operator warp::wobble {
    section generator virtual warp

    example {width 11 height 11 | -matrix}

    note Returns the origin map for a wobble effect around the \
	specified __center__, with base __amplitude__, __frequency__, \
	__chirp__, and __attenuation__ powers.

    note Inspired by <http://libvips.blogspot.com/2015/11/fancy-transforms.html>

    ref  http://libvips.blogspot.com/2015/11/fancy-transforms.html

    note The result is designed to be usable with the \
	"<!xref: aktive op warp bicubic>" operation and its relatives.

    note At the technical level the result is a 2-band image \
	where each pixel declares its origin position.

    # image configuration
    uint       width   Width of the returned image
    uint       height  Height of the returned image

    import wobble-config.tcl

    body {
	if {[llength $center]} {
	    lassign $center dx dy
	} else {
	    set dx [expr {$width /2.}]
	    set dy [expr {$height/2.}]
	}

	# identity as displacement base
	set index  [aktive image indexed width $width height $height]

	# shift origin to desired wobble center
	set cdelta [aktive image from band width $width height $height values $dx $dy]
	set center [aktive op math sub $index $cdelta]

	# switch to distance/angle representation in prep for the distance modulation
	set polar  [aktive op cmath topolar   $center]
	set dist   [aktive op cmath real      $polar]
	set angle  [aktive op cmath imaginary $polar]

	# modulate the distance according to the formula

	# attenuator -- (1+d)^attenuation
	set attenuate [aktive op math1 shift $dist offset 1]
	if {$attenuation != 1} {
	    set attenuate [aktive op math1 pow $attenuate exponent $attenuation]
	}

	# envelope -- amplitude / attenuate -- amplitude / (1+d)^attenuation
	set envelope [aktive op math1 reciproc-scale $attenuate factor $amplitude]

	# chirp factor -- dist^chirp
	if {$chirp != 1} {
	    set dist [aktive op math1 pow $dist exponent $chirp]
	}

	# wave -- sin (frequency * dist^chirp)
	set wave [aktive op math1 sin [aktive op math1 scale $dist factor $frequency]]

	# assemble the pieces -- wave                         * envelope
	#                     -- sin (frequency * dist^chirp) * amplitude / (1+d)^attenuation
	set dist [aktive op math mul $wave $envelope]

	# switch back to cartesian representation for proper displacement
	set polar  [aktive op cmath cons $dist $angle]
	set deltas [aktive op cmath tocartesian $polar]

	# and generate the origin map from the displacements
	aktive op math add $index $deltas
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
