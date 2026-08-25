
#
# row reduction. the input structure is the same as for band reduction. the
# output however is a single-column, with a many bands as the input
#
# src structure: row of pixels, pixels contain bands.
# dst structure: single-column row, same bands as input, reduction result
#
# K = W-1, N=D-1
#
# src: p0b0 ... p0bN p1b0 ... p1bN ... pKb0 pKbN
# dst: b0   ... bN
#

proc gen-row {name} {
    code-next

    global benchmarking testing
    if {$benchmarking} {
	# benchmarking uses all known implementations, except for cross-checking
	build-func row baseline $name
	return
    } elseif {$testing} {
	# testing needs all known implementations
	build-func row baseline $name
	# so that the cross-checker is able to ensure result validity.
	#build-func band crosscheck $name
	return
    }

    # in production mode choose the best implementation for each reductor

    if 0 {if {$name in {sumsquared stddev variance}} {
	# production complex - keep to special, unrolling is worse
	build-func row perdepth $name
    } else {
	# production general - unroll
	build-func row unroll4 $name
    }}

    build-func row baseline $name
    return
}
