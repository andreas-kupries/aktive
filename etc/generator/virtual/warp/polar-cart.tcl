## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Generators -- Virtual Image - Origin map of polar/cartesian transforms

operator warp::2polar {
    section generator virtual warp

    example {width 11 height 11 | -matrix}

    note Returns the origin map for a transformation to polar around the image center.

    note The inverse transformation is created by "<!xref: aktive warp 2cartesian>."

    note Inspired by <http://libvips.blogspot.com/2015/11/fancy-transforms.html>

    ref  http://libvips.blogspot.com/2015/11/fancy-transforms.html

    note The result is designed to be usable with \
	"<!xref: aktive op warp bicubic>" \
	and its relatives.

    note At the technical level the result is a 2-band image \
	where each pixel declares its origin position.

    # image configuration
    uint       width   Width of the returned image
    uint       height  Height of the returned image

    body {
	# identity as displacement base
	set index  [aktive image indexed width $width height $height]
	# shift origin to the center
	set dx     [expr {$width /2.}]
	set dy     [expr {$height/2.}]
	set cdelta [aktive image from band width $width height $height values $dx $dy]
	set index  [aktive op math sub $index $cdelta]
	# rescale to fit
	set scale  [expr {min ($width, $height) / double($width)}]
	set index  [aktive op math1 scale $index factor [expr {2./$scale}]]
	# switch to distance/angle representation
	set index  [aktive op cmath topolar $index]
	# shift angles from [-pi,pi] to [0,2pi] -- offset +pi = 4*atan(1)
	set offset [expr {4*atan(1)}]
	set offset [aktive image from band width $width height $height values 0 $offset]
	set index  [aktive op math add $index $offset]
	# scale angles to [0,height-1] - 2pi = 2*4*atan(1)
	set ascale [expr {($height-1) / (8*atan(1))}]
	set ascale [aktive image from band width $width height $height values 1 $ascale]
	set index  [aktive op math mul $index $ascale]
	# done
	return $index
    }
}

operator warp::2cartesian {
    section generator virtual warp

    example {width 11 height 11 | -matrix}

    note Returns the origin map for a transformation to cartesian \
	from a polar around the image center.

    note The inverse transformation is created by "<!xref: aktive warp 2polar>."

    note Inspired by <http://libvips.blogspot.com/2015/11/fancy-transforms.html>

    ref  http://libvips.blogspot.com/2015/11/fancy-transforms.html

    note The result is designed to be usable with \
	"<!xref: aktive op warp bicubic>" \
	and its relatives.

    note At the technical level the result is a 2-band image \
	where each pixel declares its origin position.

    # image configuration
    uint       width   Width of the returned image
    uint       height  Height of the returned image

    body {
	# identity as displacement base
	set index  [aktive image indexed width $width height $height]
	# scale the angles (in [0,height-1]) to [0,2pi]
	set ascale [expr {(8*atan(1)) / ($height-1)}]
	set ascale [aktive image from band width $width height $height values 1 $ascale]
	set index  [aktive op math mul $index $ascale]
	# shift angles from [0,2pi] to [-pi,pi] -- offset -pi = 4*atan(1)
	set offset [expr {-4*atan(1)}]
	set offset [aktive image from band width $width height $height values 0 $offset]
	set index  [aktive op math add $index $offset]
	# switch to cartesian
	set index  [aktive op cmath tocartesian $index]
	# scale from fit
	set scale  [expr {min ($width, $height) / double($width)}]
	set index  [aktive op math1 scale $index factor [expr {$scale / 2.}]]
	# shift origin out of center
	set dx     [expr {$width /2.}]
	set dy     [expr {$height/2.}]
	set cdelta [aktive image from band width $width height $height values $dx $dy]
	set index  [aktive op math add $index $cdelta]
	# done
	return $index
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
