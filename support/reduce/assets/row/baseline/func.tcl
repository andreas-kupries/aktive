
# this row reducer iterates over the pixels of the row and reduces them by band
# using the existing un-optimized functionality (blitter setup). this provides
# the baseline, performance-wise, all other implementations will be measured
# against.

def-func row baseline {
    lappend map @name@ $name
} {
    aktive_uint k;
    for (k = 0; k < stride; k++, dst ++, src ++) {
	*dst = aktive_reduce_@name@ (src, count, stride, 0 /* client data, ignored */);
    }
}
