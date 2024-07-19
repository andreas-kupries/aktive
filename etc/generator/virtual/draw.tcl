## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Basic 2D geometry primitives
#
## At the core of the implementation are signed distance functions.
## See these in the sdf.tcl file, wih runtime support in op/sdf.[ch].
#
## Instead of having to explicitly set each pixel of the primitive based on some
## drawing algorithm (bresenham, variants, etc.) here each pixel computes the
## distance to the primitive (or its outline (filled yes/no)) and either lights
## up within +/- 0.5 (b/w, jaggy), or gradually lights up within +/- 1 (grey
## scale, antialiased drawing).
#
## This is also naturally parallelizable and fits directly into the multi-
## threaded setup used in AKTIVE (see [VIPS](https://www.libvips.org) for the
## inspiring system).
#
## [..] Box
## [..] Box with rounded corners
## [ok] Circle
## [..] Circle arc(s)
## [..] Circle segment(s)
## [ok] Circles (dots)
## [..] Ellipse
## [ok] Line segment
## [ok] Line segments (poly-line)
## [..] Line segments (separate, scattered)
## [..] Parallelogram
## [..] Rhombus
## [..] Rotated ellipse(s)
## [..] Triangle
## [..] ...

# # ## ### ##### ######## ############# #####################

proc draw-modifier {} {
    uplevel 1 {
	if {$sdf in {
	    line
	    polyline
	}} {
	    import sdf/parameter/strokewidth.tcl
	} else {
	    import sdf/parameter/outlined.tcl
	}
    }
}

# # ## ### ##### ######## ############# #####################
## Draw elements

operator [sdf-known image::draw::] {
    section generator virtual drawing

    op -> _ mode sdf

    def element [sdf-label $sdf]

    note Returns an image with the given dimensions and location, \
	with a $element drawn into it.

    import sdf/note.tcl

    note The returned image is always single-band. It is grey-scale \
	when anti-aliasing is active, and black/white if not.

    pass sdf-common-params

    bool? 1 antialiased		Draw with antialiasing for smoother contours (Default)

    draw-modifier

    pass import sdf/parameter/$sdf.tcl

    body {
	set sdf [aktive image sdf @@sdf@@ @@passthrough@@]

	@@modifier@@

	if {$antialiased} {
	    set sdf [aktive op sdf 2image smooth $sdf]
	} else {
	    set sdf [aktive op sdf 2image pixelated $sdf]
	}
	::return $sdf
    }
}

# # ## ### ##### ######## ############# #####################
## Draw elements over a background image

operator [sdf-known op::draw:: ::on] {
    section transform drawing

    op -> _ mode sdf _

    input	;# image to draw on. i.e. the background for the drawing

    def element [sdf-label $sdf]

    note Returns an image where a $element is drawn on the input image.

    import sdf/note.tcl

    pass bool? 1 antialiased		Draw with antialiasing for smoother contours (Default)
    pass draw-modifier

    str color	List of band values, color of the drawn $element. \
	Their number has to match the input's depth.

    pass import sdf/parameter/$sdf.tcl

    body {
	lassign [aktive query geometry $src] x y w h d
	set n [llength $color]

	if {$n != $d} { aktive error "Band mismatch, have $n, expected $d" }

	set color [aktive image from band    width $w height $h values {*}$color]
	set draw  [aktive image draw @@sdf@@ width $w height $h x $x y $y @@passthrough@@]

	if {$antialiased} {
	    #                              else then   if
	    set sdf [aktive op math linear $src $color $draw]
	} else {
	    set sdf [aktive op if-then-else $draw $color $src]
	}
	::return $sdf
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
