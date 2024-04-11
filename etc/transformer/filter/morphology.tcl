## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Morphology

# # ## ### ##### ######## ############# #####################
##

operator {dname} {
    op::morph::erode              erosion
    op::morph::dilate             dilation
    op::morph::open               opening
    op::morph::close              closing
    op::morph::gradient::all      gradient
    op::morph::gradient::internal {inner gradient}
    op::morph::gradient::external {outer gradient}
    op::morph::tophat::white      {white tophat}
    op::morph::tophat::black      {black tophat}
    op::morph::toggle             toggle
} {
    section transform morphology

    note Returns image containing the morphological {*}$dname of the input \
	using a (2*radius+1)x(2*radius+1) square structuring element.

    # Note that the core operations, i.e. the min/max filtering used to erode/dilate are
    # implemented with the tile operators optimized for such, and not via generic rank
    # order filters.

    uint? 1     radius	Size of the structuring element to perform the operation with.
    str?  black embed	Embedding method to use before core operators to keep output from shrinking.

    input

    body [dict get {
	erosion {
	    set src [aktive op embed $embed $src left $radius right $radius top $radius bottom $radius]
	    set src [aktive op tile min $src radius $radius]
	}
	dilation {
	    set src [aktive op embed $embed $src left $radius right $radius top $radius bottom $radius]
	    set src [aktive op tile max $src radius $radius]
	}
	opening {
	    set src [erode  $src radius $radius embed $embed]
	    set src [dilate $src radius $radius embed $embed]
	}
	closing          {
	    set src [dilate $src radius $radius embed $embed]
	    set src [erode  $src radius $radius embed $embed]
	}
	gradient {
	    set d   [aktive op morph dilate $src radius $radius embed $embed]
	    set e   [aktive op morph erode  $src radius $radius embed $embed]
	    set src [aktive op math sub $d $e]
	}
	{inner gradient} {
	    set e   [aktive op morph erode $src radius $radius embed $embed]
	    set src [aktive op math sub $src $e]
	}
	{outer gradient} {
	    set d   [aktive op morph dilate $src radius $radius embed $embed]
	    set src [aktive op math sub $d $src]
	}
	{white tophat} {
	    set o   [aktive op morph open $src radius $radius embed $embed]
	    set src [aktive op math sub $src $o]
	}
	{black tophat} {
	    set c   [aktive op morph close $src radius $radius embed $embed]
	    set src [aktive op math sub $c $src]
	}
	toggle {
	    set d   [dilate $src radius $radius embed $embed]
	    set e   [erode  $src radius $radius embed $embed]
	    set src [aktive op math add $e $d]
	    set src [aktive op math1 scale $src factor 0.5]
	}
    } $dname]
}

##
# # ## ### ##### ######## ############# #####################
::return
