
# this row reducer iterates over the pixels of the row and reduces them by band
# using the existing un-optimized functionality (blitter setup). this provides
# the baseline, performance-wise, all other implementations will be measured
# against.

def-func row baseline {
    placeholder @name@ $name
} {
    aktive_uint k, depth = stride, pixels = count;
    for (k = 0; k < depth; k++, dst ++, src ++) {
	*dst = aktive_reduce_@name@ (src, count, depth, 0 /* client data, ignored */);
    }
}
