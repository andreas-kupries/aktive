# Benchmark results for reading from in-memory cache

## Navigation

[Parent](../README.md)

## Summary

 - Used both AKTIVE and NETPBM as backends.

 - The results are minimally different between backends.

 - For AKTIVE the cache is definitely faster than the reader itself,
   by 2 to 5 times.

 - For NETPBM it is not as clear-cut. For most configurations the
   reader is actually somewhat faster, up to 2 times. The cache
   overtakes the reader only for the higher thread counts (>= 11).

## Plots

### AKTIVE vs NETPBM

![aktive/netpbm](aktive-op-cache-1.svg)

![aktive/netpbm/relative](aktive-op-cache-2.svg)

### Cache vs file, AKTIVE

![aktive/cache/file](aktive-op-cache-3.svg)

![aktive/cache/file/relative](aktive-op-cache-4.svg)

### Cache vs file, NETPBM

![netpbm/cache/file](aktive-op-cache-5.svg)

![netpbm/cache/file/relative](aktive-op-cache-6.svg)
