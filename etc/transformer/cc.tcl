## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Connected components as image

# # ## ### ##### ######## ############# #####################
##

operator op::connected-components::labeled {
    section transform morphology

    esupport {
	set map [list \n { } \t {} {    } {} _ {0 } * {1 }]
	set values [string map $map {
	    _____*___________________________
	    _____*__**__***_*****___*******__
	    ******__**__*_*_*___*__*********_
	    _______**___***_*___*_***********
	    _*******_*______*___*_***_____***
	    _*_______*______*___*_**___*___**
	    _*_*******______*****__**__*__**_
	    __**____________________**_*_**__
	    _**__******_********_______*_____
	    _**__*______********__***********
	    _____*______**____**______***____
	}]
    }

    example {
	aktive image from matrix width 33 height 11 values {*}$values | times 8
	@1                                                            | -matrix -int
    }

    example {
	aktive image from matrix width 33 height 11 values {*}$values | times 8
	@1 transform cc.max                                           | times 8
    }

    example {
	aktive image from matrix width 33 height 11 values {*}$values | times 8
	@1 transform cc.max bbox 1                                    | times 8
    }

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
