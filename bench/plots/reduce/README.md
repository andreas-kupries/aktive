<img src='../../../doc/assets/aktive-logo-128.png' style='float:right;'>

Benchmark results for baseline reducer

||
|---|
|[Parent ↗](../README.md)|

## Summary

The base line implementation of the by-band reductions nicely
shows how the time per value increases with the number of bands to
process.

### Addendum (Dev 4, 2025)

The first attempt at speeding things up worked. This attempt

  1. fully unrolls the inner loop for the common depths of 1 to 4, and
  2. for bands > 4 uses a generic loop effectively inlining the function calls of the baseline.

For the fully unrolled forms the new code is pretty much always faster.

For the generic loop the overhead for the more complex operations
(sums (*)) the boost is not as strong, for some ops there is no
boost at all.

(*) Additions are actually non-trivial because of my use of
[kahan summation](https://en.wikipedia.org/wiki/Kahan_summation_algorithm).

Ideas to look at for more boosts:

  - Inline the code of the kahan summation.
  - Unroll the pixel loop as well to handle more than one pixel per iteration.

## Plots

[<img src='svg/times-reduce-pair-1-argmax.svg' style='width:46%;'>](svg/times-reduce-pair-1-argmax.svg)
[<img src='svg/ispeed-reduce-pair-1-argmax.svg' style='width:46%;'>](svg/ispeed-reduce-pair-1-argmax.svg)

[<img src='svg/times-argmax.svg' style='width:46%;'>](svg/times-argmax.svg)
[<img src='svg/ispeed-argmax.svg' style='width:46%;'>](svg/ispeed-argmax.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-3-argmax.svg' style='width:46%;'>](svg/times-reduce-pair-3-argmax.svg)
[<img src='svg/ispeed-reduce-pair-3-argmax.svg' style='width:46%;'>](svg/ispeed-reduce-pair-3-argmax.svg)

[<img src='svg/times-argmax.svg' style='width:46%;'>](svg/times-argmax.svg)
[<img src='svg/ispeed-argmax.svg' style='width:46%;'>](svg/ispeed-argmax.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-5-argmax.svg' style='width:46%;'>](svg/times-reduce-pair-5-argmax.svg)
[<img src='svg/ispeed-reduce-pair-5-argmax.svg' style='width:46%;'>](svg/ispeed-reduce-pair-5-argmax.svg)

[<img src='svg/times-argmax.svg' style='width:46%;'>](svg/times-argmax.svg)
[<img src='svg/ispeed-argmax.svg' style='width:46%;'>](svg/ispeed-argmax.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-7-argmax.svg' style='width:46%;'>](svg/times-reduce-pair-7-argmax.svg)
[<img src='svg/ispeed-reduce-pair-7-argmax.svg' style='width:46%;'>](svg/ispeed-reduce-pair-7-argmax.svg)

[<img src='svg/times-argmax.svg' style='width:46%;'>](svg/times-argmax.svg)
[<img src='svg/ispeed-argmax.svg' style='width:46%;'>](svg/ispeed-argmax.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-1-argmin.svg' style='width:46%;'>](svg/times-reduce-pair-1-argmin.svg)
[<img src='svg/ispeed-reduce-pair-1-argmin.svg' style='width:46%;'>](svg/ispeed-reduce-pair-1-argmin.svg)

[<img src='svg/times-argmin.svg' style='width:46%;'>](svg/times-argmin.svg)
[<img src='svg/ispeed-argmin.svg' style='width:46%;'>](svg/ispeed-argmin.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-3-argmin.svg' style='width:46%;'>](svg/times-reduce-pair-3-argmin.svg)
[<img src='svg/ispeed-reduce-pair-3-argmin.svg' style='width:46%;'>](svg/ispeed-reduce-pair-3-argmin.svg)

[<img src='svg/times-argmin.svg' style='width:46%;'>](svg/times-argmin.svg)
[<img src='svg/ispeed-argmin.svg' style='width:46%;'>](svg/ispeed-argmin.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-5-argmin.svg' style='width:46%;'>](svg/times-reduce-pair-5-argmin.svg)
[<img src='svg/ispeed-reduce-pair-5-argmin.svg' style='width:46%;'>](svg/ispeed-reduce-pair-5-argmin.svg)

[<img src='svg/times-argmin.svg' style='width:46%;'>](svg/times-argmin.svg)
[<img src='svg/ispeed-argmin.svg' style='width:46%;'>](svg/ispeed-argmin.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-7-argmin.svg' style='width:46%;'>](svg/times-reduce-pair-7-argmin.svg)
[<img src='svg/ispeed-reduce-pair-7-argmin.svg' style='width:46%;'>](svg/ispeed-reduce-pair-7-argmin.svg)

[<img src='svg/times-argmin.svg' style='width:46%;'>](svg/times-argmin.svg)
[<img src='svg/ispeed-argmin.svg' style='width:46%;'>](svg/ispeed-argmin.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-1-max.svg' style='width:46%;'>](svg/times-reduce-pair-1-max.svg)
[<img src='svg/ispeed-reduce-pair-1-max.svg' style='width:46%;'>](svg/ispeed-reduce-pair-1-max.svg)

[<img src='svg/times-max.svg' style='width:46%;'>](svg/times-max.svg)
[<img src='svg/ispeed-max.svg' style='width:46%;'>](svg/ispeed-max.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-3-max.svg' style='width:46%;'>](svg/times-reduce-pair-3-max.svg)
[<img src='svg/ispeed-reduce-pair-3-max.svg' style='width:46%;'>](svg/ispeed-reduce-pair-3-max.svg)

[<img src='svg/times-max.svg' style='width:46%;'>](svg/times-max.svg)
[<img src='svg/ispeed-max.svg' style='width:46%;'>](svg/ispeed-max.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-5-max.svg' style='width:46%;'>](svg/times-reduce-pair-5-max.svg)
[<img src='svg/ispeed-reduce-pair-5-max.svg' style='width:46%;'>](svg/ispeed-reduce-pair-5-max.svg)

[<img src='svg/times-max.svg' style='width:46%;'>](svg/times-max.svg)
[<img src='svg/ispeed-max.svg' style='width:46%;'>](svg/ispeed-max.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-7-max.svg' style='width:46%;'>](svg/times-reduce-pair-7-max.svg)
[<img src='svg/ispeed-reduce-pair-7-max.svg' style='width:46%;'>](svg/ispeed-reduce-pair-7-max.svg)

[<img src='svg/times-max.svg' style='width:46%;'>](svg/times-max.svg)
[<img src='svg/ispeed-max.svg' style='width:46%;'>](svg/ispeed-max.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-1-mean.svg' style='width:46%;'>](svg/times-reduce-pair-1-mean.svg)
[<img src='svg/ispeed-reduce-pair-1-mean.svg' style='width:46%;'>](svg/ispeed-reduce-pair-1-mean.svg)

[<img src='svg/times-mean.svg' style='width:46%;'>](svg/times-mean.svg)
[<img src='svg/ispeed-mean.svg' style='width:46%;'>](svg/ispeed-mean.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-3-mean.svg' style='width:46%;'>](svg/times-reduce-pair-3-mean.svg)
[<img src='svg/ispeed-reduce-pair-3-mean.svg' style='width:46%;'>](svg/ispeed-reduce-pair-3-mean.svg)

[<img src='svg/times-mean.svg' style='width:46%;'>](svg/times-mean.svg)
[<img src='svg/ispeed-mean.svg' style='width:46%;'>](svg/ispeed-mean.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-5-mean.svg' style='width:46%;'>](svg/times-reduce-pair-5-mean.svg)
[<img src='svg/ispeed-reduce-pair-5-mean.svg' style='width:46%;'>](svg/ispeed-reduce-pair-5-mean.svg)

[<img src='svg/times-mean.svg' style='width:46%;'>](svg/times-mean.svg)
[<img src='svg/ispeed-mean.svg' style='width:46%;'>](svg/ispeed-mean.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-7-mean.svg' style='width:46%;'>](svg/times-reduce-pair-7-mean.svg)
[<img src='svg/ispeed-reduce-pair-7-mean.svg' style='width:46%;'>](svg/ispeed-reduce-pair-7-mean.svg)

[<img src='svg/times-mean.svg' style='width:46%;'>](svg/times-mean.svg)
[<img src='svg/ispeed-mean.svg' style='width:46%;'>](svg/ispeed-mean.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-1-min.svg' style='width:46%;'>](svg/times-reduce-pair-1-min.svg)
[<img src='svg/ispeed-reduce-pair-1-min.svg' style='width:46%;'>](svg/ispeed-reduce-pair-1-min.svg)

[<img src='svg/times-min.svg' style='width:46%;'>](svg/times-min.svg)
[<img src='svg/ispeed-min.svg' style='width:46%;'>](svg/ispeed-min.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-3-min.svg' style='width:46%;'>](svg/times-reduce-pair-3-min.svg)
[<img src='svg/ispeed-reduce-pair-3-min.svg' style='width:46%;'>](svg/ispeed-reduce-pair-3-min.svg)

[<img src='svg/times-min.svg' style='width:46%;'>](svg/times-min.svg)
[<img src='svg/ispeed-min.svg' style='width:46%;'>](svg/ispeed-min.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-5-min.svg' style='width:46%;'>](svg/times-reduce-pair-5-min.svg)
[<img src='svg/ispeed-reduce-pair-5-min.svg' style='width:46%;'>](svg/ispeed-reduce-pair-5-min.svg)

[<img src='svg/times-min.svg' style='width:46%;'>](svg/times-min.svg)
[<img src='svg/ispeed-min.svg' style='width:46%;'>](svg/ispeed-min.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-7-min.svg' style='width:46%;'>](svg/times-reduce-pair-7-min.svg)
[<img src='svg/ispeed-reduce-pair-7-min.svg' style='width:46%;'>](svg/ispeed-reduce-pair-7-min.svg)

[<img src='svg/times-min.svg' style='width:46%;'>](svg/times-min.svg)
[<img src='svg/ispeed-min.svg' style='width:46%;'>](svg/ispeed-min.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-1-stddev.svg' style='width:46%;'>](svg/times-reduce-pair-1-stddev.svg)
[<img src='svg/ispeed-reduce-pair-1-stddev.svg' style='width:46%;'>](svg/ispeed-reduce-pair-1-stddev.svg)

[<img src='svg/times-stddev.svg' style='width:46%;'>](svg/times-stddev.svg)
[<img src='svg/ispeed-stddev.svg' style='width:46%;'>](svg/ispeed-stddev.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-3-stddev.svg' style='width:46%;'>](svg/times-reduce-pair-3-stddev.svg)
[<img src='svg/ispeed-reduce-pair-3-stddev.svg' style='width:46%;'>](svg/ispeed-reduce-pair-3-stddev.svg)

[<img src='svg/times-stddev.svg' style='width:46%;'>](svg/times-stddev.svg)
[<img src='svg/ispeed-stddev.svg' style='width:46%;'>](svg/ispeed-stddev.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-5-stddev.svg' style='width:46%;'>](svg/times-reduce-pair-5-stddev.svg)
[<img src='svg/ispeed-reduce-pair-5-stddev.svg' style='width:46%;'>](svg/ispeed-reduce-pair-5-stddev.svg)

[<img src='svg/times-stddev.svg' style='width:46%;'>](svg/times-stddev.svg)
[<img src='svg/ispeed-stddev.svg' style='width:46%;'>](svg/ispeed-stddev.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-7-stddev.svg' style='width:46%;'>](svg/times-reduce-pair-7-stddev.svg)
[<img src='svg/ispeed-reduce-pair-7-stddev.svg' style='width:46%;'>](svg/ispeed-reduce-pair-7-stddev.svg)

[<img src='svg/times-stddev.svg' style='width:46%;'>](svg/times-stddev.svg)
[<img src='svg/ispeed-stddev.svg' style='width:46%;'>](svg/ispeed-stddev.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-1-sum.svg' style='width:46%;'>](svg/times-reduce-pair-1-sum.svg)
[<img src='svg/ispeed-reduce-pair-1-sum.svg' style='width:46%;'>](svg/ispeed-reduce-pair-1-sum.svg)

[<img src='svg/times-sum.svg' style='width:46%;'>](svg/times-sum.svg)
[<img src='svg/ispeed-sum.svg' style='width:46%;'>](svg/ispeed-sum.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-3-sum.svg' style='width:46%;'>](svg/times-reduce-pair-3-sum.svg)
[<img src='svg/ispeed-reduce-pair-3-sum.svg' style='width:46%;'>](svg/ispeed-reduce-pair-3-sum.svg)

[<img src='svg/times-sum.svg' style='width:46%;'>](svg/times-sum.svg)
[<img src='svg/ispeed-sum.svg' style='width:46%;'>](svg/ispeed-sum.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-5-sum.svg' style='width:46%;'>](svg/times-reduce-pair-5-sum.svg)
[<img src='svg/ispeed-reduce-pair-5-sum.svg' style='width:46%;'>](svg/ispeed-reduce-pair-5-sum.svg)

[<img src='svg/times-sum.svg' style='width:46%;'>](svg/times-sum.svg)
[<img src='svg/ispeed-sum.svg' style='width:46%;'>](svg/ispeed-sum.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-7-sum.svg' style='width:46%;'>](svg/times-reduce-pair-7-sum.svg)
[<img src='svg/ispeed-reduce-pair-7-sum.svg' style='width:46%;'>](svg/ispeed-reduce-pair-7-sum.svg)

[<img src='svg/times-sum.svg' style='width:46%;'>](svg/times-sum.svg)
[<img src='svg/ispeed-sum.svg' style='width:46%;'>](svg/ispeed-sum.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-1-sumsquared.svg' style='width:46%;'>](svg/times-reduce-pair-1-sumsquared.svg)
[<img src='svg/ispeed-reduce-pair-1-sumsquared.svg' style='width:46%;'>](svg/ispeed-reduce-pair-1-sumsquared.svg)

[<img src='svg/times-sumsquared.svg' style='width:46%;'>](svg/times-sumsquared.svg)
[<img src='svg/ispeed-sumsquared.svg' style='width:46%;'>](svg/ispeed-sumsquared.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-3-sumsquared.svg' style='width:46%;'>](svg/times-reduce-pair-3-sumsquared.svg)
[<img src='svg/ispeed-reduce-pair-3-sumsquared.svg' style='width:46%;'>](svg/ispeed-reduce-pair-3-sumsquared.svg)

[<img src='svg/times-sumsquared.svg' style='width:46%;'>](svg/times-sumsquared.svg)
[<img src='svg/ispeed-sumsquared.svg' style='width:46%;'>](svg/ispeed-sumsquared.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-5-sumsquared.svg' style='width:46%;'>](svg/times-reduce-pair-5-sumsquared.svg)
[<img src='svg/ispeed-reduce-pair-5-sumsquared.svg' style='width:46%;'>](svg/ispeed-reduce-pair-5-sumsquared.svg)

[<img src='svg/times-sumsquared.svg' style='width:46%;'>](svg/times-sumsquared.svg)
[<img src='svg/ispeed-sumsquared.svg' style='width:46%;'>](svg/ispeed-sumsquared.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-7-sumsquared.svg' style='width:46%;'>](svg/times-reduce-pair-7-sumsquared.svg)
[<img src='svg/ispeed-reduce-pair-7-sumsquared.svg' style='width:46%;'>](svg/ispeed-reduce-pair-7-sumsquared.svg)

[<img src='svg/times-sumsquared.svg' style='width:46%;'>](svg/times-sumsquared.svg)
[<img src='svg/ispeed-sumsquared.svg' style='width:46%;'>](svg/ispeed-sumsquared.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-1-variance.svg' style='width:46%;'>](svg/times-reduce-pair-1-variance.svg)
[<img src='svg/ispeed-reduce-pair-1-variance.svg' style='width:46%;'>](svg/ispeed-reduce-pair-1-variance.svg)

[<img src='svg/times-variance.svg' style='width:46%;'>](svg/times-variance.svg)
[<img src='svg/ispeed-variance.svg' style='width:46%;'>](svg/ispeed-variance.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-3-variance.svg' style='width:46%;'>](svg/times-reduce-pair-3-variance.svg)
[<img src='svg/ispeed-reduce-pair-3-variance.svg' style='width:46%;'>](svg/ispeed-reduce-pair-3-variance.svg)

[<img src='svg/times-variance.svg' style='width:46%;'>](svg/times-variance.svg)
[<img src='svg/ispeed-variance.svg' style='width:46%;'>](svg/ispeed-variance.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-5-variance.svg' style='width:46%;'>](svg/times-reduce-pair-5-variance.svg)
[<img src='svg/ispeed-reduce-pair-5-variance.svg' style='width:46%;'>](svg/ispeed-reduce-pair-5-variance.svg)

[<img src='svg/times-variance.svg' style='width:46%;'>](svg/times-variance.svg)
[<img src='svg/ispeed-variance.svg' style='width:46%;'>](svg/ispeed-variance.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)

[<img src='svg/times-reduce-pair-7-variance.svg' style='width:46%;'>](svg/times-reduce-pair-7-variance.svg)
[<img src='svg/ispeed-reduce-pair-7-variance.svg' style='width:46%;'>](svg/ispeed-reduce-pair-7-variance.svg)

[<img src='svg/times-variance.svg' style='width:46%;'>](svg/times-variance.svg)
[<img src='svg/ispeed-variance.svg' style='width:46%;'>](svg/ispeed-variance.svg)

[<img src='svg/times-2.svg' style='width:46%;'>](svg/times-2.svg)
[<img src='svg/ispeed-2.svg' style='width:46%;'>](svg/ispeed-2.svg)