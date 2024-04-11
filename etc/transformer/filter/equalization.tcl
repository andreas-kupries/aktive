## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Histogram equalization
#
## References
#
# - https://en.wikipedia.org/wiki/Histogram_equalization
# - https://towardsdatascience.com/histogram-equalization-5d1013626e64
# - https://docs.opencv.org/4.x/d4/d1b/tutorial_histogram_equalization.html
# - https://docs.opencv.org/4.x/d5/daf/tutorial_py_histogram_equalization.html
# -
# -

# # ## ### ##### ######## ############# #####################

operator op::equalization::global {
    section transform global histogram equalization

    input	;# input image

    bool? 0 bandwise	Flag to process all bands of an image separately.

    note Returns input with equalized global histogram.
    note The location of the input is ignored, and passed to the result.

    note When bandwise is __not__ set (default) then

    note - Single-band inputs are processed as is.

    note - Three-band with a known color space images have their equivalent \
	of the luminance channel processed. RGB formats are converted into \
	and out of a space where that is possible.

    note - Anything else has just their last band processed.

    body {
	set n  [aktive query depth $src]
	set cs [aktive op query colorspace $src]

	if {$n == 1} {
	    # grey or other single-band. apply directly.
	    set ghist [aktive op image histogram $src]		 ;# global histogram
	    set csum  [aktive op row cumulative  $ghist]	 ;# global cumulative sum
	    set norm  [expr {1./[aktive op image max $csum]}]	 ;# normalization factor
	    set pdf   [aktive op math1 scale $csum factor $norm] ;# global PDF, normalized sum
	    set src   [aktive op lut indexed $pdf $src]
	    #
	    set src   [aktive op color set $src $cs]
	    return $src
	}

	if {$bandwise} {
	    # multi-band, process all bands, separately
	    set bands [aktive op split z $src]
	    set bands [lmap b $bands { global $b }]
	} elseif {$n == 3} {
	    switch -exact -- $cs {
		sRGB {
		    # Transform into and out colorspace with luminance channel.
		    # Use adjacent space to avoid a long conversion chain.
		    set src [aktive op color sRGB to HSV $src]
		    set src [global $src]
		    return  [aktive op color HSV to sRGB $src]
		}
		scRGB {
		    # Transform into and out colorspace with luminance channel.
		    # Use adjacent space to avoid a long conversion chain.
		    set src [aktive op color scRGB to XYZ $src]
		    set src [global $src]
		    return  [aktive op color XYZ to scRGB $src]
		}
		HSV -
		HSL {
		    # Luminance is in the third channel.
		    set bands [aktive op split z $src]
		    lassign $bands a b c
		    set c     [global $c]
		    set bands [list $a $b $c]
		}
		XYZ {
		    aktive error "Unable to equalize $cs image"
		    # Luminance is in the second channel -- TODO different scale.
		    set bands [aktive op split z $src]
		    lassign $bands a b c
		    set b     [global $b]
		    set bands [list $a $b $c]
		}
		Yxy -
		Lab -
		LCh {
		    aktive error "Unable to equalize $cs image"
		    # Luminance is in the first channel -- TODO different scale.
		    set bands [aktive op split z $src]
		    set tail  [lassign $bands first]
		    set first [global $first]
		    set bands [list $first {*}$tail]
		}
		default {
		    # Not a known color spaces. Filter last band
		    set bands [aktive op split z $src]
		    set head  [lreverse [lassign [lreverse $bands] last]]
		    set last  [global $last]
		    set bands [list {*}$head $last]
		}
	    }
	} else {
	    # Not any kind of color format at all. Filter last band.
	    set bands [aktive op split z $src]
	    set head  [lreverse [lassign [lreverse $bands] last]]
	    set last  [global $last]
	    set bands [list {*}$head $last]
	}

	set src [aktive op montage z {*}$bands]
	set src [aktive op color set $src $cs]
	return $src
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
