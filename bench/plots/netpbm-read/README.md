<img src='../../../doc/assets/aktive-logo-128.png' style='float:right;'>

# Benchmark results for the NETPBM reader

||
|---|
|[Parent ↗](../README.md)|

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

### Iterated binary/text, unordered/sequential

[<img src='netpbm-read-1.svg' style='width:23%;'>](netpbm-read-1.svg)
[<img src='netpbm-read-2.svg' style='width:23%;'>](netpbm-read-2.svg)
[<img src='netpbm-read-3.svg' style='width:23%;'>](netpbm-read-3.svg)
[<img src='netpbm-read-4.svg' style='width:23%;'>](netpbm-read-4.svg)

### Oneshot binary/text, unordered/sequential

[<img src='netpbm-read-6.svg' style='width:23%;'>](netpbm-read-6.svg)
[<img src='netpbm-read-7.svg' style='width:23%;'>](netpbm-read-7.svg)
[<img src='netpbm-read-9.svg' style='width:23%;'>](netpbm-read-9.svg)
[<img src='netpbm-read-8.svg' style='width:23%;'>](netpbm-read-8.svg)

### Iterated/Oneshot all

[<img src='netpbm-read-5.svg' style='width:46%;'>](netpbm-read-5.svg)
[<img src='netpbm-read-10.svg' style='width:46%;'>](netpbm-read-10.svg)

### Text unordered/sequential, shot/iterated

[<img src='netpbm-read-11a.svg' style='width:23%;'>](netpbm-read-11a.svg)
[<img src='netpbm-read-11b.svg' style='width:23%;'>](netpbm-read-11b.svg)
[<img src='netpbm-read-12a.svg' style='width:23%;'>](netpbm-read-12a.svg)
[<img src='netpbm-read-12b.svg' style='width:23%;'>](netpbm-read-12b.svg)

### Binary unordered/sequential, shot/iterated

[<img src='netpbm-read-13a.svg' style='width:23%;'>](netpbm-read-13a.svg)
[<img src='netpbm-read-13b.svg' style='width:23%;'>](netpbm-read-13b.svg)
[<img src='netpbm-read-14a.svg' style='width:23%;'>](netpbm-read-14a.svg)
[<img src='netpbm-read-14b.svg' style='width:23%;'>](netpbm-read-14b.svg)
