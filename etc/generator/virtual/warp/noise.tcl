## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Origin maps based on noise - jitter

operator warp::noise::uniform {
    section generator virtual warp

    example {width 5 height 5 seed 703011174 | -matrix}

    note Returns a origin map derived from the identity map \
	by application of uniform noise as displacement values

    note The result is designed to be usable with the \
	"<!xref: aktive op warp bicubic>" operation and its relatives.

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

    double? 0 min	Minimal noise value
    double? 1 max	Maximal noise value

    body {
	set scale [expr {$max - $min}]
	set noise [aktive image noise uniform seed $seed depth 2 width $width height $height]
	set noise [aktive op location move to $noise x $x y $y]
	set base  [aktive image indexed              x $x y $y   width $width height $height]
	set noise [aktive op math1 linear $noise scale $scale gain $min]
	aktive op math add $base $noise
    }
}

operator warp::noise::gauss {
    section generator virtual warp

    example {width 5 height 5 seed 703011174 | -matrix}

    note Returns a origin map derived from the identity map \
	by application of gaussian noise as displacement values.

    note The result is designed to be usable with the \
	"<!xref: aktive op warp bicubic>" operation and its relatives.

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
	set noise [aktive image noise gauss seed $seed depth 2 width $width height $height \
		       mean $mean sigma $sigma]
	set noise [aktive op location move to $noise x $x y $y]
	set base  [aktive image indexed              x $x y $y width $width height $height]
	aktive op math add $base $noise
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
