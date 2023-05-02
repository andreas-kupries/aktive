## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Structural changes (data re-arrangements)
##
## Image embedding - Align to a border. Based on `embed`.

operator {axis dim} {
    op::align::left   x width
    op::align::right  x width
    op::align::top    y height
    op::align::bottom y height
} {
    section transform structure

    def border [dict get {
	left   right
	right  left
	top    bottom
	bottom top
    } [lindex [split $__op :] 4]]

    note Returns image aligned to a border in a larger image.

    uint       size	Desired size of the image along the ${axis}-axis.
    str? black border	Method of embedding to use.

    input

    body {
	set csize [aktive query @@dim@@ $src]
	if {$csize == $size} { return $src }
	if {$csize > $size}  { aktive error "Align cannot shrink image" ALIGN }
	return [aktive op embed $border $src \
		    @@border@@ [expr {$size - $csize}]]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
