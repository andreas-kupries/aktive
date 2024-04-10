# Noise images, random fields

A problem with randomly filled images is that calling `rand()` will return different values each time.

This means that in a naive implementation requesting the same area twice will provide different results.

This could be overcome by caching requests and their results, and deliver all parts of a new request already known from that cache.
This is however complicated and expensive in time (searching the cache structure) and memory (the cache).

`AKTIVE` follows [VIPS](github.com/jcupitt/libvips/) way here. A key property of `rand()` and other RNGs is that they are actually
only pseudo-random. I.e. deterministic in the series of values returned for a given `seed`. They are still random over the set seeds however.

Thus, AKTIVE computes a random seed for an image, and then extends that seed with the coordinates (x,y,z) of the desired pixel, to then compute the pixel value.
This value is deterministic in the coordinates, thus no caching is required, yet also random across different images, given their different seeds.
