## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Artistic effects

# # ## ### ##### ######## ############# #####################
##

operator effect::wobble {
    section transform effect

    example {
	butterfly
	@1 center {100 50}
    }

    note Returns the input with a swirling effect applied to it.

    note This effect applies around the \
	specified __center__, with base __amplitude__, __frequency__, \
	__chirp__, and __attenuation__ powers.

    note The effect modulates the distance from the center based on the \
	formula	`sin (radius^chirp * frequency) * amplitude / (1+radius)^attenuation`, \
	where `radius` is the original distance.

    note All parameters, including the center are optional.

    note The underlying operation is "<!xref: aktive warp wobble>."

    # wobble configuration
    point?   {{}} center	Center of the wobble, relative to the image location. \
	Defaults to the image center.
    double?  500  amplitude	Base amplitude of the displacement.
    double?  2    frequency	Base wave frequency.
    double?  0.5  chirp		Chirp (power) factor modulating the frequency.
    double?  0.6  attenuation	Power factor tweaking the base 1/x attenuation.

    str? bilinear interpolate   Interpolation method to use.

    input

    body {
	lassign [aktive query domain $src] x y w h
	set map [aktive warp wobble width $w height $h \
		     center      $center     \
		     amplitude   $amplitude  \
		     frequency   $frequency  \
		     chirp       $chirp      \
		     attenuation $attenuation]
	aktive op warp $interpolate $map $src
    }
}

operator effect::swirl {
    section transform effect

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 decay 0.05 from 135
    }
    example {
	aktive read from netpbm path tests/assets/sines.ppm | -label assets/sines.ppm
	@1 decay 0.01 from 135
    }
    example {
	butterfly | -label assets/butterfly.ppm
	@1 decay 0.01 from 135
    }

    note Returns the input with a swirling effect applied to it.

    note This effect applies around the specified __center__, \
	with fixed rotation __phi__, a base rotation __from__, \
	and a __decay__ factor.

    note The rotation angle added to a pixel is given by \
	`phi + from * exp(-radius * decay)`, \
	where __radius__ is the distance of the pixel from the \
	__center__. A large decay reduces the swirl at shorter \
	radii. A decay of zero disables the decay.

    note All swirl parameters are optional.

    note The underlying operation is "<!xref: aktive warp swirl>."

    str? bilinear interpolate   Interpolation method to use.

    # swirl configuration
    point?  {{}} center  Center of the swirl, default center of the image.
    double?    0 phi     In degrees, fixed rotation to apply. Default none.
    double?   45 from    In degrees, swirl rotation at distance 0 from center.
    double?  0.1 decay   Rotation decay with distance from center.

    # see also op::warp::swirl, keep matching

    input

    body {
	lassign [aktive query domain $src] x y w h
	# validate interpolation?

	if {![llength $center]} {
	    set center [list [expr {$x + $w/2}] [expr {$y + $h/2}]]
	}

	set map [aktive warp swirl \
		     x $x y $y width $w height $h \
		     center $center phi $phi decay $decay from $from]
	aktive op warp $interpolate $map $src
    }
}

operator effect::jitter::uniform {
    section transform effect

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 min 1 max 6 seed 703011174
    }
    example {
	aktive read from netpbm path tests/assets/sines.ppm | -label assets/sines.ppm
	@1 min 1 max 6 seed 703011174
    }
    example {
	aktive read from netpbm path tests/assets/butterfly.ppm | -label assets/butterfly.ppm
	@1 min 1 max 6 seed 703011174
    }

    note Returns the input with a jitter effect based on uniform noise \
	applied to it. Visually this looks like frosted glass.

    note The underlying operation is "<!xref: aktive warp noise uniform>."

    str? bilinear interpolate   Interpolation method to use

    # jitter configuration
    uint? {[expr {int(4294967296*rand())}]} seed \
	Randomizer seed. Needed only to force fixed results.

    double? 0 min	Minimal noise value
    double? 1 max	Maximal noise value

    input

    body {
	lassign [aktive query domain $src] x y w h
	# validate interpolation?
	set map [aktive warp noise uniform \
		     x $x y $y width $w height $h \
		     seed $seed min $min max $max]
	aktive op warp $interpolate $map $src
    }
}

operator effect::jitter::gauss {
    section transform effect

    example {
	aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]
	@1 sigma 4 seed 703011174
    }
    example {
	aktive read from netpbm path tests/assets/sines.ppm | -label assets/sines.ppm
	@1 sigma 4 seed 703011174
    }
    example {
	aktive read from netpbm path tests/assets/butterfly.ppm | -label assets/butterfly.ppm
	@1 sigma 4 seed 703011174
    }

    note Returns the input with a jitter effect based on gaussian noise \
	applied to it. Visually this looks like frosted glass.

    note The underlying operation is "<!xref: aktive warp noise gauss>."

    str? bilinear interpolate   Interpolation method to use

    # jitter configuration
    uint? {[expr {int(4294967296*rand())}]} seed \
	Randomizer seed. Needed only to force fixed results.

    double? 0 mean    Mean of the desired gauss distribution.
    double? 1 sigma   Sigma of the desired gauss distribution.

    input

    body {
	lassign [aktive query domain $src] x y w h
	# validate interpolation?
	set map [aktive warp noise gauss \
		     x $x y $y width $w height $h \
		     seed $seed mean $mean sigma $sigma]
	aktive op warp $interpolate $map $src
    }
}

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

    example {
	butterfly | -label assets/butterfly.ppm
	@1
    }

    example {
	butterfly | -label assets/butterfly.ppm
	@1 light yes
    }

    note Returns a grey image with a charcoal-like sketch of the sRGB input.

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

operator {op compare desc1 desc2} {
    effect::max-rgb max ge {reaches the max}  {reaching the max}
    effect::min-rgb min le {falls to the min} {falling to the min}
} {
    section transform effect

    example {
	butterfly | -label assets/butterfly.ppm
	@1
    }

    note Returns an image suppressing at each pixel of the input the bands \
	not ${desc2} of the bands at that location.

    note For a single-band input this is a no-op.

    note Despite the use of `rgb` in the operator name this operator works \
	on all multi-band images, regardless of the exact number or their \
	semantic interpretation.

    note Idea from <https://docs.gimp.org/2.8/en/plug-in-max-rgb.html>

    input

    body {
	# for single-band this filter is a no-op
	if {[aktive query depth $src] == 1} { return $src }

        set mb [aktive op band @@op@@ $src]
	aktive op montage z {*}[lmap band [aktive op split z $src] {
	    # get mask which is 1 where the band value @@desc1@@, and 0 else
	    set mask [aktive op math @@compare@@ $band $mb]
	    # use the mask to set all values not @@desc2@@ to 0/black, and leave the rest as is.
	    aktive op math mul $band $mask
	}]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
