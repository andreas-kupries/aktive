## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Transformers -- Threshold generation - Local / Adaptive
#
# References
# - https://craftofcoding.wordpress.com/2021/10/27/thresholding-algorithms-bernsen-local/
# - https://craftofcoding.wordpress.com/2021/09/30/thresholding-algorithms-niblack-local/
# - https://craftofcoding.wordpress.com/2021/10/06/thresholding-algorithms-sauvola-local/
# - https://craftofcoding.wordpress.com/2021/09/28/thresholding-algorithms-phansalkar-local/
#
# - https://github.com/chriswolfvision/local_adaptive_binarization/blob/HASH/binarizewolfjolion.cpp#L182
#   where HASH = 2eb51465a917297910f2795fc149abafc96e657f
# - http://liris.cnrs.fr/christian.wolf/papers/icpr2002v.pdf

# # ## ### ##### ######## ############# #####################
## Mean

operator image::threshold::mean {
    section transform threshold generate

    example {
	scancrop
	@1 radius 7
    }

    example {
	butterfly
	@1 radius 7
    }

    note Returns an image containing per-pixel thresholds for the input, \
	as per the local mean.

    note The operator "<!xref: aktive image mask per mean>" \
	uses this to generate a mask of the input.

    note There are better methods. Extensions to the simple mean, in order \
	of creation (and complexity), are Sauvola, Niblack, and Phansalkar. \
	Each of these modifies the plain mean with a bias based on a mix of \
	standard deviation, parameters, and the mean itself.

    uint radius	Size of region to consider, as radius from center

    input

    body {
	# t = meanN
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#                    /       \.
	# t = (*) - meanN - e - ... - src
	#        \           \       /
	#         0.5
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	set e  [aktive op embed mirror $src left $radius right $radius top $radius bottom $radius]
	return [aktive op tile mean $e radius $radius]
    }
}

# # ## ### ##### ######## ############# #####################
## Bernsen

operator image::threshold::bernsen {
    section transform threshold generate

    example {
	scancrop
	@1 radius 7
    }

    example {
	butterfly
	@1 radius 7
    }

    note Returns an image containing per-pixel thresholds for the input, \
	as per Bernsen's method.

    note The operator "<!xref: aktive image mask per bernsen>" \
	uses this to generate a mask of the input.

    uint radius	Size of region to consider, as radius from center

    input

    body {
	# t = (minN + maxN) / 2
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#               maxN
	#              /    \    /       \.
	# t = (*) - (+)      >- e - ... - src
	#        \     \.   /    \       /
	#         0.5   maxN
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

operator image::threshold::niblack {
    section transform threshold generate

    example {
	scancrop
	@1 radius 7
    }

    example {
	butterfly
	@1 radius 7
    }

    note Returns an image containing per-pixel thresholds for the input, \
	as per Niblack's method.

    note The operator "<!xref: aktive image mask per niblack>" \
	uses this to generate a mask of the input.

    double? -0.2 k	niblack parameter
    uint    radius	Size of region to consider, as radius from center

    input

    body {
	# t = mN + (k * stdN)
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#          meanN ---\.
	#        /           \   /       \.
	# t = (+)            /- e - ... - src
	#        \.         /    \       /
	#         (*) - stdN
	#            \.
	#             k
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

operator image::threshold::sauvola {
    section transform threshold generate

    example {
	scancrop
	@1 radius 7
    }

    example {
	butterfly
	@1 radius 7
    }

    note Returns an image containing per-pixel thresholds for the input, \
	as per Sauvola's method.

    note The operator "<!xref: aktive image mask per sauvola>" \
	uses this to generate a mask of the input.

    double? 0.5 k	sauvola parameter
    double? 128 R	sauvola parameter
    uint        radius	Size of region to consider, as radius from center

    input

    body {
	# t = mN * (1 + k * ((stdN/R) - 1))
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#          meanN -------------------\   /       \.
	#        /                          /- e - ... - src
	# t = (*)     (*) - (-) - (/) - stdN    \       /
	#        \.  /   \     \     \.
	#         (+)     k     1     R
	#            \.
	#             1
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

operator image::threshold::phansalkar {
    section transform threshold generate

    example {
	scancrop
	@1 radius 7
    }

    example {
	butterfly
	@1 radius 7
    }

    note Returns an image containing per-pixel thresholds for the input, \
	as per Phansalkar's method.

    note The operator "<!xref: aktive image mask per phansalkar>" \
	uses this to generate a mask of the input.

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

	# t = mN * (p * exp(-q * mN) + 1 + k * ((stdN / R) - 1))
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#            /------------------- meanN
	#           /                   /      \.
	#          /         (exp) - (*)        \    /       \.
	#         /         /           \ -q     \- e - ... - src
	#        /      (*) - p                  /   \       /
	# t = (*)      /                        /
	#        \- (+) - (*) - (-) - (/) - stdN
	#              \     \     \     \.
	#               1     k     -1    R
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

# # ## ### ##### ######## ############# #####################
## Otsu

operator image::threshold::otsu {
    section transform threshold generate

    example {
	scancrop
	@1 radius 7
    }

    note Returns an image containing per-pixel thresholds for the input, \
	as per Otsu's method.

    note The operator "<!xref: aktive image mask per otsu>" \
	uses this to generate a mask of the input.

    uint radius	Size of region to consider, as radius from center

    int? 256 bins \
	The number of bins used by the internal histograms. \
	The pixel values are quantized to fit. \
	Only values in the range of \[0..1\] are considered valid. \
	Values outside of that range are placed into the smallest/largest bin. \
	\
	The default quantizes the image values to 8-bit.

    input

    body {
	# t = scaled (band otsu (tile histogram (embedded I)))
	#     the threshold is scaled by the number of bins, to be in [0..1]

	set e [aktive op embed mirror $src left $radius right $radius top $radius bottom $radius]
	set e [aktive op tile histogram $e radius $radius bins $bins]
	set e [aktive op band otsu $e]
	set e [aktive op math1 scale $e factor [expr {1./$bins}]]
	return $e
    }
}

# # ## ### ##### ######## ############# #####################
## Wolfjolion - Christian Wolf + J. M. Jolion - At core a variant of Sauvola

operator image::threshold::wolfjolion {
    section transform threshold generate

    example {
	scancrop
	@1 radius 7
    }

    example {
	butterfly
	@1 radius 7
    }

    note Returns an image containing per-pixel thresholds for the input, \
	as per Wolf+Jolion's method.

    note The operator "<!xref: aktive image mask per wolfjolion>" \
	uses this to generate a mask of the input.

    double? 0.5 k	wolfjolion parameter
    uint    radius	Size of region to consider, as radius from center

    input

    body {
	# R = max(stdN)
	# M = min(src)
	# t = mN + k * (stdN/R-1) * (mN-M))
	#   = mN + k*(mN-M)*(stdN/R-1)				reorder
	#   = mN + k*(mN-M)*stdN/R - k*(mN-M)			split stdN/R-1
	#   = mN + k*stdN/R*(mN-M) - k*(mN-M)			reorder
	#   = mN + k*stdN/R*(mN-M) - k*m + k*M			split 2nd mN-M
	#   = mN - k*mN + k*stdN/R*(mN-M) + k*M			reorder
	#   = (1-k)*mN + k*stdN/R*(mN-M) + k*M			factor m
	#   = (1-k)*mN + k*M + k*stdN/R*(mN-M)			reorder
	#   = (1-k)*mN + k*M + k*stdN/R*mN - k*stdN/R*M		split mN-M
	#   = (1-k)*mN + k*M + stdN*mN*(k/R) - stdN*(M*k/R)	reorder
	#   = stdN*mN*(k/R) + (1-k)*mN - stdN*(M*k/R) + k*M	reorder
	##
	#   = A*stdN*mN + B*mN + C*stdN + D
	#   for	A = k/R
	#   	B = 1-k
	#	C = -M*k/R = -M*A = -D/R
	#	D = k*M
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	set e [aktive op embed mirror $src left $radius right $radius top $radius bottom $radius]
	set m [aktive op tile mean   $e radius $radius]
	set s [aktive op tile stddev $e radius $radius]

	set R [aktive op image max $s]
	set M [aktive op image min $src]

	set a [expr {$k / double($R)}]
	set b [expr {1 - $k}]
	set c [expr {- $M * $a}]
	set d [expr {$k * $M}]

	set sm [aktive op math mul $s $m]
	set sm [aktive op math1 scale $sm factor $a]
	set m  [aktive op math1 scale $m  factor $b]
	set s  [aktive op math1 scale $s  factor $c]
	set sm [aktive op math add $sm $m $s]

	set src [aktive op math1 shift $sm offset $d]
	return $src
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
