## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Morphology

# # ## ### ##### ######## ############# #####################
##

operator {dname description} {
    op::morph::erode              erosion         erosion
    op::morph::dilate             dilation        dilation
    op::morph::open               opening        {opening (erode, then dilate)}
    op::morph::close              closing        {closing (dilate, then erode)}
    op::morph::gradient::all      gradient       {gradient (subtract eroded from dilated)}
    op::morph::gradient::internal inner-gradient {inner gradient (subtract eroded from input)}
    op::morph::gradient::external outer-gradient {outer gradient (subtract input from dilated)}
    op::morph::tophat::white      white-tophat   {white tophat (subtract opening from input)}
    op::morph::tophat::black      black-tophat   {black tophat (subtract input from closing)}
    op::morph::toggle             toggle
} {
    section transform morphology

    example [string map [list VALUES [string map [list \n { } \t {} _ {0 } * {1 }] {
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
    }]] {
	aktive image from matrix width 33 height 11 values VALUES | times 8
	@1 radius 1                                               | times 8
    }]

    example [string map [list VALUES [string map [list \n { } \t {} _ {0 } * {1 }] {
	_________________________
	_****____**************__
	_****____________________
	_****__*********_________
	_****__*********_________
	_****__*********_________
	_****__***___***_________
	_****__*********_________
	_______*********_________
	_______*********_________
	__________________******_
	_____________***********_
	_____________***********_
    }]] {
	aktive image from matrix width 25 height 13 values VALUES | times 8
	@1 radius 1                                               | times 8
    }]

    note Returns image containing the morphological {*}$description of the input \
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
	inner-gradient {
	    set e   [aktive op morph erode $src radius $radius embed $embed]
	    set src [aktive op math sub $src $e]
	}
	outer-gradient {
	    set d   [aktive op morph dilate $src radius $radius embed $embed]
	    set src [aktive op math sub $d $src]
	}
	white-tophat {
	    set o   [aktive op morph open $src radius $radius embed $embed]
	    set src [aktive op math sub $src $o]
	}
	black-tophat {
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
