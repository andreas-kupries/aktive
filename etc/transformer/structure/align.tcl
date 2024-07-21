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
    op -> _ _ border
    section transform structure

    example \
	{aktive op sdf 2image smooth [aktive op sdf ring [aktive image sdf triangle width 128 height 128 a {10 10} b {50 80} c {80 30}] thickness 4]} \
	{@1 size 160 border mirror}

    # opposite border is what we have to expand for alignment
    def border [dict get {
	left   right
	right  left
	top    bottom
	bottom top
    } $border]

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
