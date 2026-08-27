
# this band reducer iterates over the pixels of the row and reduces their bands
# using the existing un-optimized functionality. this provides the baseline,
# performance-wise, all other implementations will be measured against.

def-func band baseline {
    placeholder @name@ $name
} {

    aktive_uint k;
    for (k = 0; k < count; k++, dst ++, src += stride) {
	*dst = aktive_reduce_@name@ (src, stride, 1, 0 /* client data, ignored */);
    }
}
