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

tcl-operator image::threshold::bernsen {
    section transform threshold generate

    note Returns image containing per-pixel thresholds for the input, as per Bernsen's method.

    arguments radius src
    body {
	set e   [aktive op embed mirror $radius $radius $radius $radius $src]
	set min [aktive op tile min $radius $e]
	set max [aktive op tile max $radius $e]

	return [aktive op math1 scale 0.5 [aktive op math add $min $max]]
    }
}

# # ## ### ##### ######## ############# #####################
## Niblack
#
#	t = mN + (k * stdN)

tcl-operator image::threshold::niblack {
    section transform threshold generate

    note Returns image containing per-pixel thresholds for the input, as per Niblack's method.

    arguments k radius src
    body {
	set e    [aktive op embed mirror $radius $radius $radius $radius $src]
	set mean [aktive op tile mean   $radius $e]
	set std  [aktive op tile stddev $radius $e]

	return [aktive op math add $mean [aktive op math1 scale $k $std]]
    }
}

# # ## ### ##### ######## ############# #####################
## Sauvola
#
#	t = mN * (1 + k * ((stdN/R) - 1))

tcl-operator image::threshold::sauvola {
    section transform threshold generate

    note Returns image containing per-pixel thresholds for the input, as per Sauvola's method.

    arguments k R radius src
    body {
	set e    [aktive op embed mirror $radius $radius $radius $radius $src]
	set mean [aktive op tile mean   $radius $e]
	set std  [aktive op tile stddev $radius $e]

	return [aktive op math mul $mean \
		    [aktive op math1 linear $k 1 \
			 [aktive op math1 linear [expr {1.0/$R}] -1 \
			      $std]]]
    }
}

# # ## ### ##### ######## ############# #####################
## Phansalkar
#
#	t = mN * (p * exp(-q * mN) + 1 + k * ((stdN / R) - 1))

tcl-operator image::threshold::phansalkar {
    section transform threshold generate

    note Returns image containing per-pixel thresholds for the input, as per Phansalkar's method.

    arguments k R p q radius src
    body {
	set e    [aktive op embed mirror $radius $radius $radius $radius $src]
	set mean [aktive op tile mean   $radius $e]
	set std  [aktive op tile stddev $radius $e]

	return [aktive op math mul \
		    $mean \
		    [aktive op math add \
			 [aktive op math1 scale $p \
			      [aktive op math1 exp \
				   [aktive op math1 scale [expr {- $q}] \
					$mean]]] \
			 [aktive op math1 linear $k 1 \
			      [aktive op math1 linear [expr {1.0/$R}] -1 \
				   $std]]]]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
