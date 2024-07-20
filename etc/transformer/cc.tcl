## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Connected components as image

# # ## ### ##### ######## ############# #####################
##

operator op::connected-components::labeled {
    section transform morphology

    example -matrix -int {aktive image from matrix width 33 height 11 values {*}{
	0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 1 0 0 1 1 0 0 1 1 1 0 1 1 1 1 1 0 0 0 1 1 1 1 1 1 1 0 0
	1 1 1 1 1 1 0 0 1 1 0 0 1 0 1 0 1 0 0 0 1 0 0 1 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 1 1 0 0 0 1 1 1 0 1 0 0 0 1 0 1 1 1 1 1 1 1 1 1 1 1
	0 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 0 1 0 1 1 1 0 0 0 0 0 1 1 1
	0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 1 0 1 1 0 0 0 1 0 0 0 1 1
	0 1 0 1 1 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 0 0 1 1 0 0 1 0 0 1 1 0
	0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 1 0 1 1 0 0
	0 1 1 0 0 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 0 0 0 0 0
	0 1 1 0 0 1 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1
	0 0 0 0 0 1 0 0 0 0 0 0 1 1 0 0 0 0 1 1 0 0 0 0 0 0 1 1 1 0 0 0 0
    }} @1

    note Returns the input with labeled connected components.

    strict single The computed pixels are not materialized, \
	only used to compute the connected components. \
	The returned image is virtual based on the CC data.

    input

    body {
	set ccs [aktive op connected-components get $src]
	# collect ranges labeled with CC ids, kill the range in the CCS
	set ranges {}
	dict for {id spec} $ccs {
	    lappend ranges {*}[lmap range [dict get $spec parts] { linsert $range end $id }]
	    dict unset ccs $id parts
	}
	# set up virtual image from the ranges showing the labeling
	set src [aktive image from sparse ranges ranges {*}[lsort -dict $ranges]]

	# .. and add the remaining CCS data, i.e. without ranges, to the image meta data.
	set src [aktive meta set $src cc $ccs]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
