## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Arbitrary resizing

operator op::resize   {
    section transform structure

    example {
	sines
	@1 width 21 height 29
    }

    note Returns image resized to the specified width and height.

    note This is a convenience operator implemented on top of "<!xref: aktive op transform by>."

    str? bilinear interpolate   \[Interpolation method](interpolation.md) to use.

    uint          width         Desired width of the result
    uint          height        Desired height of the result

    input

    body {
	lassign [aktive query domain $src] _ _ w h

	set xscale  [expr {double($width)  / $w}]
	set yscale  [expr {double($height) / $h}]
	set trafo   [aktive transform scale x $xscale y $yscale]
	set resized [aktive op transform by $trafo $src interpolate $interpolate]

	# Due to the limited precision of floating point the transform may
	# return a geometry which is not exactly the desired geometry (off by 1
	# usually).  When this happens a view port with the proper geometry is
	# stacked on to enforce the target.
	lassign [aktive query geometry $resized] x y rw rh
	if {($rw != $width) || ($h != $height)} {
	    set resized [aktive op view $resized port [list $x $y $width $height]]
	}

	return $resized
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
