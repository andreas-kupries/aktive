# Benchmark results for the NETPBM reader

## Navigation

[Parent](../README.md)

## Summary

  - For iterated, i.e. cache fill time not relevant, unordered is
    faster than sequential, regardless of format.

  - Conversely text format is faster than binary, likely because of
    the in-memory cache.

  - For shots, where cache fill time is measured as part of the
    operation binary has no difference to iterated, as expected, as
    binary is without a cache.

  - For text format however the time to fill the cache is substantial,
    up to 8 seconds. Still around 6 seconds for thread count >= actual
    core count.

## Takeaways

  - Look into ideas for a faster cache implementation than the current
    (row) vector cache, especially faster fill.

      - Veccache uses quite a lot of locking between the contending
        threads while incrementally filling individual rows
        (i.e. separate allocations)

      - Could a variant of the `cache` op be better, with a single
        thread once streaming the file into a single memory block ?

	Maybe with incremental release of filled rows to the
	requesting threads interleaved with the fill itself ?

  - Look into caching binary too.

  - Look into other means of reading from a file instead of (serial)
    through a file descriptor.

      - VIPS seems to support mapping of a file directly into process
      	memory ?!

## Plots

### Iterated binary, unordered / sequential

![](netpbm-read-1.svg)

### Iterated text, unordered / sequential

![](netpbm-read-2.svg)

### Iterated unordered, text / binary

![](netpbm-read-3.svg)

### Iterated sequential, text / binary

![](netpbm-read-4.svg)

### Iterated all

![](netpbm-read-5.svg)

### Oneshot binary, unordered / sequential

![](netpbm-read-6.svg)

### Oneshot text, unordered / sequential

![](netpbm-read-7.svg)

### Oneshot unordered, text / binary

![](netpbm-read-9.svg)

### Oneshot sequential, text / binary

![](netpbm-read-8.svg)

### Shot all

![](netpbm-read-10.svg)

### Text unordered, shot / iterated

![](netpbm-read-11a.svg)

![](netpbm-read-11b.svg)

### Text sequential, shot / iterated

![](netpbm-read-12a.svg)

![](netpbm-read-12b.svg)

### Binary unordered, shot / iterated

![](netpbm-read-13a.svg)

![](netpbm-read-13b.svg)

### Binary sequential, shot / iterated

![](netpbm-read-14a.svg)

![](netpbm-read-14b.svg)
