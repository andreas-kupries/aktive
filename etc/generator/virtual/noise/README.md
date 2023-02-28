# noise images, random fields

A problem with randomly filled images is that calling rand() will return different values each time.

This means that in a naive implementation requesting the same area twice will provide different
results.

This could be overcome by caching request and their results, and deliver from said cache all parts
of a new request already known. This is complicated and expensive (time (searching the cache
structure) and memory (the cache)).

VIPS went a different path. A key property of rand() and other RNGs is that they are actually
only pseudo-random. I.e. deterministic in the series of values returned for a given `seed`. They
are still random over the set seeds however.

Thus, VIPS computes a random seed for an image, and then extends that seed with the coordinates
(x,y, z) of the desired pixel, to then compute the pixel value. This vlaue is deterministic in the
coordinates, yet random across different images, given their different seeds.
