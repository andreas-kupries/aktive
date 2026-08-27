
#
# band reduction. the interesting thing here is that images generally do not
# have that many bands. Most common are single and three-band, i.e. greyscale
# and color (RGB, HSV, Lab, XYZ, ..). Two-band also possible, for complex
# numbers. More than 3 bands generally happen only for special algorithms, for
# example a stack of convolution/correlation results of which we take one, or a
# per-pixel tensor, etc. Reduction is rare for these.
#
# src structure: row of pixels, pixels contain bands.
# dst structure: row of pixels, single-band, reduction result
#
# K = W-1, N=D-1
#
# src: p0b0 ... p0bN p1b0 ... p1bN ... pKb0 pKbN
# dst: p0   ...      p1   ...          pK
#

proc gen-band {name} {
    code-next

    global benchmarking testing
    if {$benchmarking} {
	# benchmarking uses all known implementations, except for cross-checking
	build-func band baseline   $name
	build-func band perdepth   $name
	build-func band unroll4    $name
	return
    } elseif {$testing} {
	# testing needs all known implementations
	build-func band baseline   $name
	build-func band perdepth   $name
	build-func band unroll4    $name
	# so that the cross-checker is able to ensure result validity.
	build-func band crosscheck $name
	return
    }

    # in production mode choose the best implementation for each reductor

    if {$name in {
	sumsquared stddev variance
    }} {
	# for the complex reductors band unrolling alone is best, with pixel
	# unrolling on top making things worse
	build-func band perdepth $name
	return
    }

    # for most reductors unrolling both bands and pixels is best
    build-func band unroll4 $name
}
