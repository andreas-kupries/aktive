## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Scroll the pixels along one axis (wrap around)
##   IOW place the indicated row, column, band of the image at
##   the origin of that axis.
##
## - Derived: Place the origin of the axis at the image center.

operator {coordinate dimension thing} {
    op::scroll::x  x width  column
    op::scroll::y  y height row
    op::scroll::z  z depth  band
} {
    section transform structure

    note Returns image with the pixels of the input shifted along \
	the @@coordinate@@ axis so that the N'th $thing becomes \
	the origin on that axis.

    uint offset	$coordinate scroll offset

    input

    body {
	lassign [aktive query geometry $src] x y width height depth
	set n1  [expr {$offset - 1}]
	set r1  [expr {$@@dimension@@ - 1}]
	return  [aktive op location move to \
		     [aktive op montage @@coordinate@@-core \
			  [aktive op select @@coordinate@@ $src from $offset to $r1] \
			  [aktive op select @@coordinate@@ $src from       0 to $n1]] \
		     x $y y $y]
    }
}

operator {coordinate dimension thing} {
    op::center-origin::x  x width  column
    op::center-origin::y  y height row
    op::center-origin::z  z depth  band
} {
    section transform structure

    note Returns image where the center $thing of the input is shifted to \
	the origin of the @@coordinate@@ axis.

    input

    body {
	aktive op scroll @@coordinate@@ $src \
	    offset [expr {[aktive query @@dimension@@ $src] >> 1}]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
