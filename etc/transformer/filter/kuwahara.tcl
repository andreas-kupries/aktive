## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Kuwahara filtering, Spatial
#
## References
#
# - http://www.mathworks.com/matlabcentral/fileexchange/15027-faster-kuwahara-filter
#   MatLab, done by Luca Balbi
# - https://github.com/adussault/python-kuwahara/blob/master/Kuwahara.py
#   Same, translated to NumPy.
# - https://en.wikipedia.org/wiki/Kuwahara_filter
# -

# # ## ### ##### ######## ############# #####################

operator op::kuwahara {
    section transform kuwahara

    example {
	butterfly
	@1 radius 4
    }

    input	;# input image (See `op::tile::rank` for analogous blit setup).

    uint? 2 radius	Filter radius. Actual window size is `2*radius-1`. \
	The default value of `2` is the minimum allowed value.

    note Returns the input with a \
	"\[Kuwahara\](https://en.wikipedia.org/wiki/Kuwahara_filter)" \
	filter applied to it.

    note The location of the input is ignored.

    note The result image is shrunken by `radius` relative to the input. \
	An input smaller than that are rejected.

    note If shrinkage is not desired add a border to the input use \
	the "<!xref: aktive op embed bg>" operator or one of its siblings \
	before applying this operator.

    note The source can be a multi-band image. \
	For known colorspaces the core filter is applied to the luminance \
	channel of the input. The image may be converted into and out of a \
	colorspace with such a channel if it does not have one on its own. \
	For images without a known colorspace the last band is used as the \
	luminance channel.

    body {
	if {$radius < 2} { aktive error "Invalid radius $radius, expected a value >= 2" }

	switch -exact -- [aktive query depth $src] {
	    1 {
		# Grey input. Apply filter directly.
		return [aktive op color set [aktive op kuwahara-core $src radius $radius] Grey]
	    }
	    3 {
		set bands [aktive op split z $src]
		set cs    [aktive op query colorspace $src]
		switch -exact -- $cs {
		    sRGB {
			# Transform into and out colorspace with luminance channel.
			# Use adjacent space to avoid a long conversion chain.
			set src [aktive op color sRGB to HSV $src]
			set src [aktive op kuwahara $src radius $radius]
			return  [aktive op color HSV to sRGB $src]
		    }
		    scRGB {
			# Transform into and out colorspace with luminance channel.
			# Use adjacent space to avoid a long conversion chain.
			set src [aktive op color scRGB to XYZ $src]
			set src [aktive op kuwahara $src radius $radius]
			return  [aktive op color XYZ to scRGB $src]
		    }
		    HSV -
		    HSL {
			# Luminance is in the third channel.
			lassign $bands a b c
			set c     [aktive op kuwahara-core $c radius $radius]
			set bands [list $a $b $c]
		    }
		    XYZ {
			# Luminance is in the second channel
			lassign $bands a b c
			set b     [aktive op kuwahara-core $b radius $radius]
			set bands [list $a $b $c]
		    }
		    Yxy -
		    Lab -
		    LCh {
			# Luminance is in the first channel.
			set tail  [lassign $bands first]
			set first [aktive op kuwahara-core $first radius $radius]
			set bands [list $first {*}$tail]
		    }
		    default {
			# Not a known color input. Filter through last band.
			set head  [lreverse [lassign [lreverse $bands] last]]
			set last  [aktive op kuwahara-core $last radius $radius]
			set bands [list {*}$head $last]
		    }
		}
		# Ensure that the result has the same color space as the input.
		return [aktive op color set [aktive op montage z {*}$bands] $cs]
	    }
	    default {
		# Not a known color input. Filter through last band.
		# Colorspace, if any, is dropped.
		set bands [aktive op split z $src]
		set head  [lreverse [lassign [lreverse $bands] last]]
		set last  [aktive op kuwahara-core $last radius $radius]
		return [aktive op montage z {*}$head $last]
	    }
	}
    }
}

operator op::kuwahara-core {
    section transform kuwahara

    example {
	aktive op color sRGB to gray [butterfly]
	@1 radius 4
    }

    input	;# input image (See `op::tile::rank` for analogous blit setup).

    uint? 2 radius	Filter radius. The actual window size is `2*radius-1`. \
	The default value of `2` is the minimum allowed value.

    note Returns the input with a \
	"\[Kuwahara\](https://en.wikipedia.org/wiki/Kuwahara_filter)" \
	filter applied to it.

    note The location of the input is ignored.

    note The input is expected to be single-band.

    note The result image is shrunken by `radius` relative to the input. \
	An input smaller than that are rejected.

    note If shrinkage is not desired add a border to the input use \
	the "<!xref: aktive op embed bg>" operator or one of its siblings \
	before applying this operator.

    note The prefered embedding for kuwahara is `mirror`. \
	It is chosen to have minimal to no impact on results \
	at the original input's borders.

    body {
	if {$radius < 2} { aktive error "Invalid radius $radius, expected a value >= 2" }
	if {[aktive query depth $src] > 1} { aktive error "Invalid input, expected single-band" }

	set nul [expr {$radius - 1}]

	# Create the convolution filters for the 4 quadrants of the window.
	# Example for k=2, window size 3:
	#
	# | 110 | 011 | 000 | 000 |
	# | 110 | 011 | 011 | 110 |
	# | 000 | 000 | 011 | 110 |
	#
	# The `1` in the examples is replaced with a scaling factor ensuring that the
	# result of the filter is the mean of the values in the addressed quadrant.

	set mfcore [aktive image from value width $radius height $radius depth 1 \
			value [expr {1./($radius*$radius)}]]
	foreach {bordera borderb} {
	    right bottom
	    left  bottom
	    left  top
	    right top
	} { lappend mfilters [aktive op embed black $mfcore $bordera $nul $borderb $nul] }

	# Squared input.
	set sq [aktive op math1 square $src]

	foreach mf $mfilters {
	    # Apply the filters to compute the means for regular and squared input.
	    set     mq   [aktive op embed mirror [aktive op convolve xy $mf $src] left $nul right $nul top $nul bottom $nul]
	    set     sqmq [aktive op embed mirror [aktive op convolve xy $mf $sq]  left $nul right $nul top $nul bottom $nul]
	    lappend means $mq

	    # The variance is computed by `means-of-squared - square-of-means`.
	    lappend vars [aktive op math sub $sqmq [aktive op math1 square $mq]]
	}

	# And now the filter in two steps:
	# - Compute the index of the quadrant with minimum variance, per pixel, and
	# - select the mean values from these quadrants into the result.

	set indices [aktive op band arg min    [aktive op montage z {*}$vars]]
	set src     [aktive op take z $indices [aktive op montage z {*}$means]]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
