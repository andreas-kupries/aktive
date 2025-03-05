## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Color corrections
#
## - Grey world

# # ## ### ##### ######## ############# #####################

operator op::color::correct::greyworld::global {
    section transform color

    example {
	aktive read from netpbm file path tests/assets/watergarden.ppm
	@1
    }

    example {
	butterfly
	@1
    }

    note Corrects a color cast in the input using a global grey world assumption and returns the result.
    note Accepts inputs in the `sRGB` and `scRGB` color spaces, and returns a result in the same space.
    note The actual correction is always done in the `scRGB` space, i.e. with linear colors.

    input

    double? {{}} mean  Use as a fixed global mean, if specified. \
	Else use the actual global mean for the input.

    body {
	set cs [aktive op query colorspace $src]
	if {$cs ni {sRGB scRGB}} { aktive error "Unable to handle non-RGB colorspace `$cs`" }

	set linear [string equal $cs scRGB]
	    if {!$linear} { set src [aktive op color sRGB to scRGB $src] }
	# Ensured linear color

	# Split into bands ...
	lassign [aktive op split z $src] r g b

	# ... per band means ..
	set mr [aktive op image mean $r]	;# --- semi-materializes input
	set mg [aktive op image mean $g]	;# --/
	set mb [aktive op image mean $b]	;# -/

	# ... global mean
	if {$mean eq {}} {
	    # ... from the band means ...
	    set gmean [expr {($mr + $mg + $mb)/3.}]
	} else {
	    # .. or user's choice
	    set gmean $mean
	}

	# ... scale factors to shift the band means towards the global mean ...
	set fr [expr {$gmean/$mr}]
	set fg [expr {$gmean/$mg}]
	set fb [expr {$gmean/$mb}]

	# ... re-scale the bands ...
	set xr [aktive op math1 scale $r factor $fr]
	set xg [aktive op math1 scale $g factor $fg]
	set xb [aktive op math1 scale $b factor $fb]

	# ... and bring the bands back together
	set src [aktive op montage z $xr $xg $xb]

	# Restore non-linear color
	if {!$linear} { set src [aktive op color scRGB to sRGB $src] }
	return $src
    }
}

operator op::color::correct::greyworld::local {
    section transform color

    note Corrects a color cast in the input using a local grey world assumption and returns the result.
    note Accepts inputs in the `sRGB` and `scRGB` color spaces, and returns a result in the same space.
    note The actual correction is always done in the `scRGB` space, i.e. with linear colors.
    note The size of the window/tile used to compute local conditions is set by radius. The default is 10.

    input

    uint? 10 radius \
	Tile size as radius from center. \
	Full width and height of the tile are `2*radius+1`. \
	Default value is 10.

    double? {{}} mean  Use as a fixed xglobal mean, if specified. Else use the actual xglobal mean for the input.

    body {
	set cs [aktive op query colorspace $src]
	if {$cs ni {sRGB scRGB}} { aktive error "Unable to handle non-RGB colorspace `$cs`" }

	set linear [string equal $cs scRGB]
	if {!$linear} { set src [aktive op color sRGB to scRGB $src] }
	# Ensured linear color

	# Extend mirror-like to have space for the tile at the image borders
	set src [aktive op embed mirror $src left $radius right $radius top $radius bottom $radius]

	# Split into bands ...
	lassign [aktive op split z $src] r g b

	# ... tiled per band means ..
	set mr [aktive op tile mean $r radius $radius]
	set mg [aktive op tile mean $g radius $radius]
	set mb [aktive op tile mean $b radius $radius]

	# Some math ...
	##
	# newRed = oldRed * meanTile / meanRed, where meanTile = (meanRed + meanGreen + meanBlue) / 3
	#        |
	#        = oldRed * (1/3 * (meanRed + meanGreen + meanBlue) / meanRed)
	#        = 1/3 * oldRed * (meanRed/meanRed + (meanGreen + meanBlue)/meanRed)
	#        = 1/3 * oldRed * (1 + (meanGreen + meanBlue)/meanRed)
	#        = 1/3 * (oldRed + oldRed * (meanGreen + meanBlue)/meanRed))
	#        = 1/3 * (oldRed + oldRed/meanRed * (meanGreen + meanBlue))
	## All three
	#
	#  newRed   = 1/3 * (oldRed   + oldRed   / meanRed   * (meanGreen + meanBlue ))
	#  newGreen = 1/3 * (oldGreen + oldGreen / meanGreen * (meanRed   + meanBlue ))
	#  newBlue  = 1/3 * (oldBlue  + oldBlue  / meanBlue  * (meanRed   + meanGreen))
	#                               \- n... -----------/   \- m... --------------/
	#                               \- n... -------------------------------------/
	#                    \- n... ------------------------------------------------/
	#
	# The scaling can be done last, when everything else is done

	set nr [aktive op math div $r $mr]
	set ng [aktive op math div $g $mg]
	set nb [aktive op math div $b $mb]

	if {$mean eq {}} {
	    # .. fixed final scaling ...
	    set mean [expr {1./3.}]

	    # ... from the band-means
	    set mgb [aktive op math add $mg $mb] ; set nr [aktive op math mul $nr $mgb]
	    set mrb [aktive op math add $mr $mb] ; set ng [aktive op math mul $ng $mrb]
	    set mrg [aktive op math add $mr $mg] ; set nb [aktive op math mul $nb $mrg]

	    set nr [aktive op math add $r $nr]
	    set ng [aktive op math add $g $ng]
	    set nb [aktive op math add $b $nb]
	} ; # else ... user's choice is final scaling

	# ... bring the bands back together
	set src [aktive op montage z $nr $ng $nb]

	# .. and apply the final scaling ...
	set src [aktive op math1 scale $src factor $mean]

	# Restore non-linear color
	if {!$linear} { set src [aktive op color scRGB to sRGB $src] }
	return $src
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
