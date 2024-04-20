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
# -
# -

# # ## ### ##### ######## ############# #####################

operator op::kuwahara {
    section transform kuwahara

    input	;# input image (See `op::tile::rank` for analogous blit setup).

    uint? 2 k	Filter radius. Actual window size is `2*k-1`. \
	The default value is 2. This is also the minimum allowed value.

    note Returns input with a Kuwahara filter applied to it.
    note The location of the input is ignored.

    note The image is allowed to be multi-band.
    note For known colorspaces the core filter is applied to the luminance channel of the input.
    note The image may be converted into and out of a colorspace with such a channel if it does not have one on its own.
    note For images without known colorspace the last band is used as the luminance channel.

    body {
	if {$k < 2} { aktive error "Invalid radius $k, expected a value >= 2" }

	switch -exact -- [aktive query depth $src] {
	    1 {
		# Grey input. Apply filter directly.
		return [aktive op color set [aktive op kuwahara-core $src k $k] Grey]
	    }
	    3 {
		set bands [aktive op split z $src]
		set cs    [aktive op query colorspace $src]
		switch -exact -- $cs {
		    sRGB {
			# Transform into and out colorspace with luminance channel.
			# Use adjacent space to avoid a long conversion chain.
			set src [aktive op color sRGB to HSV $src]
			set src [aktive op kuwahara $src k $k]
			return  [aktive op color HSV to sRGB $src]
		    }
		    scRGB {
			# Transform into and out colorspace with luminance channel.
			# Use adjacent space to avoid a long conversion chain.
			set src [aktive op color scRGB to XYZ $src]
			set src [aktive op kuwahara $src k $k]
			return  [aktive op color XYZ to scRGB $src]
		    }
		    HSV -
		    HSL {
			# Luminance is in the third channel.
			lassign $bands a b c
			set c     [aktive op kuwahara-core $c k $k]
			set bands [list $a $b $c]
		    }
		    XYZ {
			# Luminance is in the second channel
			lassign $bands a b c
			set b     [aktive op kuwahara-core $b k $k]
			set bands [list $a $b $c]
		    }
		    Yxy -
		    Lab -
		    LCh {
			# Luminance is in the first channel.
			set tail  [lassign $bands first]
			set first [aktive op kuwahara-core $first k $k]
			set bands [list $first {*}$tail]
		    }
		    default {
			# Not a known color input. Filter through last band.
			set head  [lreverse [lassign [lreverse $bands] last]]
			set last  [aktive op kuwahara-core $last k $k]
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
		set last  [aktive op kuwahara-core $last k $k]
		return [aktive op montage z {*}$head $last]
	    }
	}
    }
}

operator op::kuwahara-core {
    section transform kuwahara

    input	;# input image (See `op::tile::rank` for analogous blit setup).

    uint? 2 k	Filter radius. Actual window size is `2*k-1`. \
	The default value is 2. This is also the minimum allowed value.

    note Returns input with a Kuwahara filter applied to it.
    note The location of the input is ignored.

    note The input is expected to be single-band.

    note The result image is shrunken by `k` relative to the input. \
	Inputs smaller than that are rejected.

    note If shrinkage is not desired add a border to the input using one of \
	the `aktive op embed ...` operators before applying this operator.

    note The prefered embedding for kuwahara is `mirror`. \
	It is chosen to have minimal to no impact on results \
	at the original input's borders.

    body {
	if {$k < 2} { aktive error "Invalid radius $k, expected a value >= 2" }
	if {[aktive query depth $src] > 1} { aktive error "Invalid input, expected single-band" }

	set nul [expr {$k - 1}]

	# Create the convolution filters for the 4 quadrants of the window.
	# Example for k=2, window size 3:
	#
	# 110 011 000 000
	# 110 011 011 110
	# 000 000 011 110
	#
	# The `1` in the examples is replaced with a scaling factor ensuring that the
	# result of the filtre is the mean of the values in the addressed quadrant.

	set mfcore [aktive image from value width $k height $k depth 1 value [expr {1./($k*$k)}]]
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
