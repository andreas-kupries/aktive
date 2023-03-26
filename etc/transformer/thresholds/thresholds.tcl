## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Threshold generation
#
#	https://craftofcoding.wordpress.com/2021/10/27/thresholding-algorithms-bernsen-local/
#	https://craftofcoding.wordpress.com/2021/09/30/thresholding-algorithms-niblack-local/
#	https://craftofcoding.wordpress.com/2021/10/06/thresholding-algorithms-sauvola-local/
#	https://craftofcoding.wordpress.com/2021/09/28/thresholding-algorithms-phansalkar-local/

# # ## ### ##### ######## ############# #####################
## Bernsen

operator image::threshold::bernsen {
    section transform threshold generate

    note Returns image containing per-pixel thresholds for the input, as per Bernsen's method.

    uint radius	Size of region to consider, as radius from center

    input

    body {
	set e   [aktive op embed mirror $src left $radius right $radius top $radius bottom $radius]
	set min [aktive op tile min $e radius $radius]
	set max [aktive op tile max $e radius $radius]

	return [aktive op math1 scale \
		    [aktive op math add $min $max] \
		    factor 0.5]
    }
}

# # ## ### ##### ######## ############# #####################
## Niblack
#
#	t = mN + (k * stdN)

operator image::threshold::niblack {
    section transform threshold generate

    note Returns image containing per-pixel thresholds for the input, as per Niblack's method.

    double? -0.2 k	niblack parameter
    uint    radius	Size of region to consider, as radius from center

    input

    body {
	set e    [aktive op embed mirror $src left $radius right $radius top $radius bottom $radius]
	set mean [aktive op tile mean   $e radius $radius]
	set std  [aktive op tile stddev $e radius $radius]

	return [aktive op math add $mean \
		    [aktive op math1 scale $std \
			 factor $k]]
    }
}

# # ## ### ##### ######## ############# #####################
## Sauvola
#
#	t = mN * (1 + k * ((stdN/R) - 1))

operator image::threshold::sauvola {
    section transform threshold generate

    note Returns image containing per-pixel thresholds for the input, as per Sauvola's method.

    double? 0.5 k	sauvola parameter
    double? 128 R	sauvola parameter
    uint        radius	Size of region to consider, as radius from center

    input

    body {
	set e    [aktive op embed mirror $src left $radius right $radius top $radius bottom $radius]
	set mean [aktive op tile mean   $e radius $radius]
	set std  [aktive op tile stddev $e radius $radius]

	return [aktive op math mul $mean \
		    [aktive op math1 linear \
			 [aktive op math1 linear $std \
			      scale [expr {1.0/$R}] gain -1] \
			 scale $k gain 1]]
    }
}

# # ## ### ##### ######## ############# #####################
## Phansalkar
#
#	t = mN * (p * exp(-q * mN) + 1 + k * ((stdN / R) - 1))

operator image::threshold::phansalkar {
    section transform threshold generate

    note Returns image containing per-pixel thresholds for the input, as per Phansalkar's method.

    double? 0.25 k	phansalkar parameter
    double? 0.5  R	phansalkar parameter
    double? 3    p	phansalkar parameter
    double? 10   q	phansalkar parameter
    uint         radius	Size of region to consider, as radius from center

    input

    body {
	set e    [aktive op embed mirror $src left $radius right $radius top $radius bottom $radius]
	set mean [aktive op tile mean   $e radius $radius]
	set std  [aktive op tile stddev $e radius $radius]

	return [aktive op math mul \
		    $mean \
		    [aktive op math add \
			 [aktive op math1 scale \
			      [aktive op math1 exp \
				   [aktive op math1 scale $mean \
					factor [expr {- $q}]]] \
			      factor $p] \
			 [aktive op math1 linear \
			      [aktive op math1 linear $std \
				   scale [expr {1.0/$R}] gain -1] \
			      scale $k gain 1]]]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
