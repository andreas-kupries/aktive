<img src='../../../doc/assets/aktive-logo-128.png' style='float:right;'>

# Benchmark results for reading from in-memory cache

||
|---|
|[Parent ↗](../README.md)|

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

[<img src='aktive-op-cache-1.svg' style='width:46%;'>](aktive-op-cache-1.svg)
[<img src='aktive-op-cache-2.svg' style='width:46%;'>](aktive-op-cache-2.svg)

### Cache vs file, AKTIVE

[<img src='aktive-op-cache-3.svg' style='width:46%;'>](aktive-op-cache-3.svg)
[<img src='aktive-op-cache-4.svg' style='width:46%;'>](aktive-op-cache-4.svg)

### Cache vs file, NETPBM

[<img src='aktive-op-cache-5.svg' style='width:46%;'>](aktive-op-cache-5.svg)
[<img src='aktive-op-cache-6.svg' style='width:46%;'>](aktive-op-cache-6.svg)
