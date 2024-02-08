## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - black bands
#
## See op/embed.tcl for the supporting commands (Check, ...)

operator op::embed::band::black {
    section transform structure

    note Returns image embedding the input into a set of black bands.

    uint? 0 up		Number of bands to add before the image bands
    uint? 0 down	Number of bands to add after the image bands

    input

    body {
	# fast no-operation
	if {($up == 0) && ($down == 0)} {
	    return $src
	}

	# bad arguments
	if {($up   < 0) ||
	    ($down < 0)} {
	    aktive error "Unable to crop image-bands with embed band" EMBED
	}

	lassign [aktive query geometry $src] x y w h d

	if {$up   > 0} { lappend bands [aktive image from value width $w height $h depth $up value 0] }
	lappend bands $src
	if {$down > 0} { lappend bands [aktive image from value width $w height $h depth $down value 0] }

	return [aktive op montage z {*}$bands]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
