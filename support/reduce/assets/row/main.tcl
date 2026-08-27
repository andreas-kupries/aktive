
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
	build-func row baseline  $name
	build-func row perdepth0 $name
	build-func row perdepth1 $name
	return
    } elseif {$testing} {
	# testing needs all known implementations
	build-func row baseline $name
	build-func row perdepth0 $name
	build-func row perdepth1 $name
	# so that the cross-checker is able to ensure result validity.
	build-func row crosscheck $name
	return
    }

    # in production mode choose the best implementation for each reductor

    if {$name in {
	profile rprofile
    }} {
	build-func row baseline $name
	return
    }

    build-func row perdepth1 $name
    return
}
