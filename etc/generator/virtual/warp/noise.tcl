## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Pixels proclaim their origin location

operator warp::noise::uniform {
    section generator virtual warp

    example {width 5 height 5 seed 703011174 | -matrix}

    note Returns a warp map derived from the identity map by \
	application of uniform noise as displacement values

    note The result is designed to be usable with the \
	"<!xref aktive op warp>" operation.

    note At the technical level the result is a 2-band image \
	where each pixel declares its origin position.

    # image configuration
    uint   width   Width of the returned image
    uint   height  Height of the returned image
    int? 0 x       X location of the returned image in the 2D plane
    int? 0 y       Y location of the returned image in the 2D plane

    # jitter configuration
    uint? {[expr {int(4294967296*rand())}]} seed \
	Randomizer seed. Needed only to force fixed results.

    body {
	aktive op math add \
	    [aktive image indexed       width $width height $height] \
	    [aktive image noise uniform width $width height $height depth 2 \
		 seed $seed]
    }
}

operator warp::noise::gauss {
    section generator virtual warp

    example {width 5 height 5 seed 703011174 | -matrix}

    note Returns a warp map derived from the identity map by \
	application of gaussian noise as displacement values.

    note The result is designed to be usable with the \
	"<!xref aktive op warp>" operation.

    note At the technical level the result is a 2-band image \
	where each pixel declares its origin position.

    # image configuration
    uint   width   Width of the returned image
    uint   height  Height of the returned image
    int? 0 x       X location of the returned image in the 2D plane
    int? 0 y       Y location of the returned image in the 2D plane

    # jitter configuration
    uint? {[expr {int(4294967296*rand())}]} seed \
	Randomizer seed. Needed only to force fixed results.

    double? 0 mean    Mean of the desired gauss distribution.
    double? 1 sigma   Sigma of the desired gauss distribution.

    body {
	aktive op math add \
	    [aktive image indexed     width $width height $height] \
	    [aktive image noise gauss width $width height $height depth 2 \
		 seed $seed mean $mean sigma $sigma]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
