## -*- mode: tcl ; fill-column: 90 -*-
# # ## ### ##### ######## ############# #####################
## Getter -- Threshold generation - Global
#
#	https://craftofcoding.wordpress.com/2021/10/27/thresholding-algorithms-bernsen-local/
#	https://craftofcoding.wordpress.com/2021/09/30/thresholding-algorithms-niblack-local/
#	https://craftofcoding.wordpress.com/2021/10/06/thresholding-algorithms-sauvola-local/
#	https://craftofcoding.wordpress.com/2021/09/28/thresholding-algorithms-phansalkar-local/

# # ## ### ##### ######## ############# #####################
## Mean

operator image::threshold::global::mean {
    section accessor threshold generate

    note Returns a global threshold for the input, as the image mean.

    note There are better methods. Extensions to the simple mean, in order \
	of creation (and complexity), are Sauvola, Niblack, and Phansalkar. \
	Each of these modifies the plain mean with a bias based on a mix of \
	standard deviation, parameters, and the mean itself.

    input

    body {
	# t = meanI
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	# T = meanI - src
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	return [aktive op image mean $src]
    }
}

# # ## ### ##### ######## ############# #####################
## Bernsen

operator image::threshold::global::bernsen {
    section accessor threshold generate

    note Returns a global threshold for the input, according to Bernsen's method.

    input

    body {
	# t = (minI + maxI) / 2
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#               maxI
	#              /    \.
	# T = (*) - (+)      >- src
	#        \     \.   /
	#         0.5   maxI
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	set min [aktive op image min $src]
	set max [aktive op image max $src]

	return [expr {0.5 * ($min + $max)}]
    }
}

# # ## ### ##### ######## ############# #####################
## Niblack

operator image::threshold::global::niblack {
    section accessor threshold generate

    note Returns a global threshold for the input, according to Niblack's method.

    double? -0.2 k	niblack parameter

    input

    body {
	# t = meanI + (k * stdI)
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#          meanI ---\.
	#        /           \.
	# t = (+)            /- src
	#        \.         /
	#         (*) - stdI
	#            \.
	#             k
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	set mean [aktive op image mean   $src]
	set std  [aktive op image stddev $src]

	return [expr {$mean + $k * $std}]
    }
}

# # ## ### ##### ######## ############# #####################
## Sauvola

operator image::threshold::global::sauvola {
    section accessor threshold generate

    note Returns a global threshold for the input, according to Sauvola's method.

    double? 0.5 k	sauvola parameter
    double? 128 R	sauvola parameter

    input

    body {
	# t = meanI * (1 + k * ((stdI/R) - 1))
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#          meanI -------------------\.
	#        /                          /- src
	# t = (*)     (*) - (-) - (/) - stdI
	#        \.  /   \     \     \.
	#         (+)     k     1     R
	#            \.
	#             1
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	set mean [aktive op image mean   $src]
	set std  [aktive op image stddev $src]

	return [expr {$mean * (1. + $k * ($std / double($R) - 1.))}]
    }
}

# # ## ### ##### ######## ############# #####################
## Phansalkar

operator image::threshold::global::phansalkar {
    section accessor threshold generate

    note Returns image containing per-pixel thresholds for the input, as per Phansalkar's method.

    double? 0.25 k	phansalkar parameter
    double? 0.5  R	phansalkar parameter
    double? 3    p	phansalkar parameter
    double? 10   q	phansalkar parameter

    input

    body {
	# t = meanN * (p * exp(-q * meanN) + 1 + k * ((stdN / R) - 1))
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#
	#            /------------------- meanN
	#           /                   /      \.
	#          /         (exp) - (*)        \.
	#         /         /           \ -q     \- src
	#        /      (*) - p                  /
	# t = (*)      /                        /
	#        \- (+) - (*) - (-) - (/) - stdN
	#              \     \     \     \.
	#               1     k     -1    R
	#
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	set mean [aktive op image mean   $src]
	set std  [aktive op image stddev $src]

	return [expr {$mean * ($p * exp(- $q * $mean) + 1. + $k * ($std / double($R) - 1.))}]
    }
}

##
# # ## ### ##### ######## ############# #####################
::return
