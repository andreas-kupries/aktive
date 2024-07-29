## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Connected components as image

# # ## ### ##### ######## ############# #####################
##

operator op::connected-components::labeled {
    section transform morphology

    set values [string map [list \n { } \t {}] {
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
    }]

    example [string map [list VALUES $values] {
	aktive image from matrix width 33 height 11 values VALUES | times 8
	@1                                                        | -matrix -int
    }]

    example [string map [list VALUES $values] {
	aktive image from matrix width 33 height 11 values VALUES | times 8
	@1 transform cc.max                                       | times 8
    }]

    example [string map [list VALUES $values] {
	aktive image from matrix width 33 height 11 values VALUES | times 8
	@1 transform cc.max bbox 1                                | times 8
    }]

    unset values

    note Returns the input with labeled connected components.

    note See \"<!xref: aktive op connected-components get>\" for the CC core.

    strict single The computed pixels are not materialized, \
	only used to compute the connected components. \
	The returned image is virtual based on the CC data.

    input

    str? {{}} transform	\
	Command prefix to transform the CCs before creating an image from \
	them. Executed in the global scope.

    bool? 0 bbox	\
	Flag controlling the result geometry. \
	When false (default) the result has the same geometry as the input. \
	Else the result's geometry is the bounding box containing all CCs \
	(After transformation, if any).

    body {
	set geo [expr {$bbox ? "" : "geometry {[aktive query domain $src]}"}]
	set ccs [aktive op connected-components get $src]

	# rewrite CC data, if desired
	if {$transform ne {}} {
	    set ccs [uplevel #0 [list {*}$transform $ccs]]
	}

	# collect ranges labeled with CC ids, kill the range in the CCS
	set ranges {}
	dict for {id spec} $ccs {
	    lappend ranges {*}[lmap range [dict get $spec parts] { linsert $range end $id }]
	    dict unset ccs $id parts
	}

	# set up virtual image from the ranges showing the labeling
	set result [aktive image from sparse ranges {*}$geo ranges {*}[lsort -dict $ranges]]

	# .. add the remaining CCS data, i.e. without ranges, to the image meta data.
	set result [aktive meta set $result cc $ccs]

	return $result
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
