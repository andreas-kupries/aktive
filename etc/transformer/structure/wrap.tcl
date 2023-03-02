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

foreach {coordinate dimension} {
    x width
    y height
    z depth
} {
    lappend map @@coordinate@@ $coordinate
    lappend map @@dimension@@  $dimension

    tcl-operator op::wrap::$coordinate {n src} [string map $map {
	lassign [aktive query geometry $src] x y width height depth
	set n1  [expr {$n - 1}]
	set r1  [expr {$@@dimension@@ - 1}]
	return [aktive op translate to $x $y \
		    [aktive op montage @@coordinate@@-core \
			 [aktive op select @@coordinate@@ $n $r1 $src] \
			 [aktive op select @@coordinate@@ 0  $n1 $src]]]
    }]

    tcl-operator op::center-origin::$coordinate {src} [string map $map {
	set center [expr {[aktive query @@dimension@@ $src] >> 1}]
	aktive op wrap @@coordinate@@ $center $src
    }]

    unset map
}

##
# # ## ### ##### ######## ############# #####################
::return
