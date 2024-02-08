## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - copy bands
#
## See op/embed.tcl for the supporting commands (Check, ...)

operator op::embed::band::copy {
    section transform structure

    note Returns image embedding the input into a set of copied bands.

    uint? 0 up		Number of first band copies to add before the image bands
    uint? 0 down	Number of last band copies to add after the image bands

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

	if {$d == 1} {
	    # Copying for a single-band image is just stretching it in general, without
	    # having to consider first vs last.
	    set stretch [expr {1 + $up + $down}]

	    lappend bands [aktive op sample replicate z $src by $stretch]
	    # single element list, the final `montage z` will short circuit.
	} else {
	    # Multi-band image requires separate handling of first and last bands.

	    if {$up > 0} {
		set first [aktive op select z $src from 0]
		#lappend bands [aktive op montage z-rep $first by $up]
		lappend bands [aktive op sample replicate z $first by $up]
	    }
	    lappend bands $src
	    if {$down > 0} {
		incr d -1
		set last [aktive op select z $src from $d]
		#lappend bands [aktive op montage z-rep $last by $down]
		lappend bands [aktive op sample replicate z $last by $down]
	    }
	}

	return [aktive op montage z {*}$bands]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
