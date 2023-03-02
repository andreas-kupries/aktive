## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)

# # ## ### ##### ######## ############# #####################
## Highlevel operations implemented on top of the C core
#
## - Shift the pixels along one axis (wrap around)
##   IOW place the indicated row, column, band of the image at
##   the origin of that axis.
##
## - Derived: Place the origin of the axis at the image center.

tcl-operator {coordinate dimension thing} {
    op::wrap::x  x width  column
    op::wrap::y  y height row
    op::wrap::z  z depth  band
} {
    note Transformer. Structure. \
	Shift the pixels along the @@coordinate@@ axis so that \
	the N'th $thing becomes the origin on that axis.

    arguments n src
    body {
	lassign [aktive query geometry $src] x y width height depth
	set n1  [expr {$n - 1}]
	set r1  [expr {$@@dimension@@ - 1}]
	return [aktive op translate to $x $y \
		    [aktive op montage @@coordinate@@-core \
			 [aktive op select @@coordinate@@ $n $r1 $src] \
			 [aktive op select @@coordinate@@ 0  $n1 $src]]]
    }
}

tcl-operator {coordinate dimension thing} {
    op::center-origin::x  x width  column
    op::center-origin::y  y height row
    op::center-origin::z  z depth  band
} {
    note Transformer. Structure. \
	Shift the center $thing to the origin of the @@coordinate@@ axis.

    arguments src
    body {
	aktive op wrap @@coordinate@@ \
	    [expr {[aktive query @@dimension@@ $src] >> 1}] \
	    $src
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
