<img src='../../../doc/assets/aktive-logo-128.png' style='float:right;'>

Benchmark results for baseline reducer

||
|---|
|[Parent ↗](../README.md)|

## Summary

The base line implementation of the by-band reductions nicely
shows how the time per value increases with the number of bands to
process.

### Addendum (Dec 4, 2025)

The first attempt at speeding things up worked. This attempt

  1. fully unrolls the inner loop for the common depths of 1 to 4, and
  2. for bands > 4 uses a generic loop effectively inlining the function calls of the baseline.

For the fully unrolled forms the new code is pretty much always faster.

For the generic loop the overhead for the more complex operations
(sums (*)) the boost is not as strong, for some ops there is no
boost at all.

This change is accepted.

(*) Additions are actually non-trivial because of my use of
[kahan summation](https://en.wikipedia.org/wiki/Kahan_summation_algorithm).

Ideas to look at for more boosts:

  - Inline the code of the kahan summation.
  - Unroll the pixel loop as well to handle more than one pixel per iteration.

### Addendum 2 (Dec 4, 2025)

After fixing an issue in the kahan summation benchmarking inlining
of this functionality (via macros) provides a measurable boost to
all the reductions using it, i.e. `sum`, `sumsquared`, `mean`,
`stddev`, and `variance`, for both baseline and special variants.

The special variants look to get a slightly larger boost however,
as the inlining allows optimization over the entire loop body,
instead of just inside of the pixel-function used by the baseline.
Remember, these loop bodies have the band loop unrolled.

This change is accepted.

Now look at unrolling the pixel loop itself too.

### Addendum 3 (Feb 7 2026)

The pixel loop unrolled 4 times looks to be best for most of the
operations and depths. The simpler operations look to have it better.

That said, for the high-complexity ops (`stddev` and `variance`) the
unrolled form is mostly worse, except for depth 1. For higher depths the
`special` is better.

The `sumsquared` is in a bit of a transition area, where `special` is better
for depths 2 and 3, else unrolled, i.e. depths 1 and 4+. With 4+ having more
variation based on vector length.

### Addendum 4 (Feb 7 2026)

The curves had quite a bit of differences, even if the general
shape looked somewhat the same.

Reworked the benchmarks for a hopeful better estimation of general
performance. The previous code initialized the work arrays once,
with random data, and then ran all combinations of methods, depths
and vector length over that fixed set. As such each full run of
the benchmarks sampled only a single point in the input space.

The new code has each iteration for a combination re-initialize
the work array. This causes the set of iterations for a
combination to take many more samples of the input space,
averaging them at the end.

The implementation of the selector, reusing the existing special
and unrol function, and switching between them is not really
working out very well. In quite a bit of where special is called
the selector is slower. That said, in the new set of result these
are all also closer than before.

And there is that for the operations in question the 4-unrolled
loops look to be only better for `depth == 1`. Which is something
which will not occur in production, only in benchmarking. Because
for that depth all the reducers reduce to constant results, and
are handled by the simplification rules at construction time.

Scrapping the selector as-is. Simply use `special` for the complex
operations.

|Op |1| |2|3| |4|5+   |
|---|---: |---: |---: |---: |---: |---: |---: |
|argmax |u4   | |u4   |u4   | |u4   |u4   |
|argmin |u4   | |u4   |u4   | |u4   |u4   |
|max|u4   | |u4   |u4   | |u4   |u4   |
|min|u4   | |u4   |u4   | |u4   |u4   |
|mean   |u4   | |u4   |u4   | |u4   |u4   |
|sum|u4   | |u4   |u4   | |u4   |u4   |
|   | | | | | | | |
|sumsquared |u4   | |__spec__ |__spec__ | |__spec__ |__spec__ | 
|stddev |u4   | |__spec__ |__spec__ | |__spec__ |__spec__ |
|variance   |u4   | |__spec__ |__spec__ | |__spec__ |__spec__ |

## Plots

### argmax

[<img src='svg/ispeed-reduce-panel-1-argmax.svg' style='width:12%;'>](svg/ispeed-reduce-panel-1-argmax.svg)
[<img src='svg/ispeed-reduce-panel-2-argmax.svg' style='width:12%;'>](svg/ispeed-reduce-panel-2-argmax.svg)
[<img src='svg/ispeed-reduce-panel-3-argmax.svg' style='width:12%;'>](svg/ispeed-reduce-panel-3-argmax.svg)
[<img src='svg/ispeed-reduce-panel-4-argmax.svg' style='width:12%;'>](svg/ispeed-reduce-panel-4-argmax.svg)
[<img src='svg/ispeed-reduce-panel-5-argmax.svg' style='width:12%;'>](svg/ispeed-reduce-panel-5-argmax.svg)
[<img src='svg/ispeed-reduce-panel-6-argmax.svg' style='width:12%;'>](svg/ispeed-reduce-panel-6-argmax.svg)
[<img src='svg/ispeed-reduce-panel-7-argmax.svg' style='width:12%;'>](svg/ispeed-reduce-panel-7-argmax.svg)
[<img src='svg/ispeed-reduce-panel-8-argmax.svg' style='width:12%;'>](svg/ispeed-reduce-panel-8-argmax.svg)

### argmin

[<img src='svg/ispeed-reduce-panel-1-argmin.svg' style='width:12%;'>](svg/ispeed-reduce-panel-1-argmin.svg)
[<img src='svg/ispeed-reduce-panel-2-argmin.svg' style='width:12%;'>](svg/ispeed-reduce-panel-2-argmin.svg)
[<img src='svg/ispeed-reduce-panel-3-argmin.svg' style='width:12%;'>](svg/ispeed-reduce-panel-3-argmin.svg)
[<img src='svg/ispeed-reduce-panel-4-argmin.svg' style='width:12%;'>](svg/ispeed-reduce-panel-4-argmin.svg)
[<img src='svg/ispeed-reduce-panel-5-argmin.svg' style='width:12%;'>](svg/ispeed-reduce-panel-5-argmin.svg)
[<img src='svg/ispeed-reduce-panel-6-argmin.svg' style='width:12%;'>](svg/ispeed-reduce-panel-6-argmin.svg)
[<img src='svg/ispeed-reduce-panel-7-argmin.svg' style='width:12%;'>](svg/ispeed-reduce-panel-7-argmin.svg)
[<img src='svg/ispeed-reduce-panel-8-argmin.svg' style='width:12%;'>](svg/ispeed-reduce-panel-8-argmin.svg)

### max

[<img src='svg/ispeed-reduce-panel-1-max.svg' style='width:12%;'>](svg/ispeed-reduce-panel-1-max.svg)
[<img src='svg/ispeed-reduce-panel-2-max.svg' style='width:12%;'>](svg/ispeed-reduce-panel-2-max.svg)
[<img src='svg/ispeed-reduce-panel-3-max.svg' style='width:12%;'>](svg/ispeed-reduce-panel-3-max.svg)
[<img src='svg/ispeed-reduce-panel-4-max.svg' style='width:12%;'>](svg/ispeed-reduce-panel-4-max.svg)
[<img src='svg/ispeed-reduce-panel-5-max.svg' style='width:12%;'>](svg/ispeed-reduce-panel-5-max.svg)
[<img src='svg/ispeed-reduce-panel-6-max.svg' style='width:12%;'>](svg/ispeed-reduce-panel-6-max.svg)
[<img src='svg/ispeed-reduce-panel-7-max.svg' style='width:12%;'>](svg/ispeed-reduce-panel-7-max.svg)
[<img src='svg/ispeed-reduce-panel-8-max.svg' style='width:12%;'>](svg/ispeed-reduce-panel-8-max.svg)

### mean

[<img src='svg/ispeed-reduce-panel-1-mean.svg' style='width:12%;'>](svg/ispeed-reduce-panel-1-mean.svg)
[<img src='svg/ispeed-reduce-panel-2-mean.svg' style='width:12%;'>](svg/ispeed-reduce-panel-2-mean.svg)
[<img src='svg/ispeed-reduce-panel-3-mean.svg' style='width:12%;'>](svg/ispeed-reduce-panel-3-mean.svg)
[<img src='svg/ispeed-reduce-panel-4-mean.svg' style='width:12%;'>](svg/ispeed-reduce-panel-4-mean.svg)
[<img src='svg/ispeed-reduce-panel-5-mean.svg' style='width:12%;'>](svg/ispeed-reduce-panel-5-mean.svg)
[<img src='svg/ispeed-reduce-panel-6-mean.svg' style='width:12%;'>](svg/ispeed-reduce-panel-6-mean.svg)
[<img src='svg/ispeed-reduce-panel-7-mean.svg' style='width:12%;'>](svg/ispeed-reduce-panel-7-mean.svg)
[<img src='svg/ispeed-reduce-panel-8-mean.svg' style='width:12%;'>](svg/ispeed-reduce-panel-8-mean.svg)

### min

[<img src='svg/ispeed-reduce-panel-1-min.svg' style='width:12%;'>](svg/ispeed-reduce-panel-1-min.svg)
[<img src='svg/ispeed-reduce-panel-2-min.svg' style='width:12%;'>](svg/ispeed-reduce-panel-2-min.svg)
[<img src='svg/ispeed-reduce-panel-3-min.svg' style='width:12%;'>](svg/ispeed-reduce-panel-3-min.svg)
[<img src='svg/ispeed-reduce-panel-4-min.svg' style='width:12%;'>](svg/ispeed-reduce-panel-4-min.svg)
[<img src='svg/ispeed-reduce-panel-5-min.svg' style='width:12%;'>](svg/ispeed-reduce-panel-5-min.svg)
[<img src='svg/ispeed-reduce-panel-6-min.svg' style='width:12%;'>](svg/ispeed-reduce-panel-6-min.svg)
[<img src='svg/ispeed-reduce-panel-7-min.svg' style='width:12%;'>](svg/ispeed-reduce-panel-7-min.svg)
[<img src='svg/ispeed-reduce-panel-8-min.svg' style='width:12%;'>](svg/ispeed-reduce-panel-8-min.svg)

### stddev

[<img src='svg/ispeed-reduce-panel-1-stddev.svg' style='width:12%;'>](svg/ispeed-reduce-panel-1-stddev.svg)
[<img src='svg/ispeed-reduce-panel-2-stddev.svg' style='width:12%;'>](svg/ispeed-reduce-panel-2-stddev.svg)
[<img src='svg/ispeed-reduce-panel-3-stddev.svg' style='width:12%;'>](svg/ispeed-reduce-panel-3-stddev.svg)
[<img src='svg/ispeed-reduce-panel-4-stddev.svg' style='width:12%;'>](svg/ispeed-reduce-panel-4-stddev.svg)
[<img src='svg/ispeed-reduce-panel-5-stddev.svg' style='width:12%;'>](svg/ispeed-reduce-panel-5-stddev.svg)
[<img src='svg/ispeed-reduce-panel-6-stddev.svg' style='width:12%;'>](svg/ispeed-reduce-panel-6-stddev.svg)
[<img src='svg/ispeed-reduce-panel-7-stddev.svg' style='width:12%;'>](svg/ispeed-reduce-panel-7-stddev.svg)
[<img src='svg/ispeed-reduce-panel-8-stddev.svg' style='width:12%;'>](svg/ispeed-reduce-panel-8-stddev.svg)

### sum

[<img src='svg/ispeed-reduce-panel-1-sum.svg' style='width:12%;'>](svg/ispeed-reduce-panel-1-sum.svg)
[<img src='svg/ispeed-reduce-panel-2-sum.svg' style='width:12%;'>](svg/ispeed-reduce-panel-2-sum.svg)
[<img src='svg/ispeed-reduce-panel-3-sum.svg' style='width:12%;'>](svg/ispeed-reduce-panel-3-sum.svg)
[<img src='svg/ispeed-reduce-panel-4-sum.svg' style='width:12%;'>](svg/ispeed-reduce-panel-4-sum.svg)
[<img src='svg/ispeed-reduce-panel-5-sum.svg' style='width:12%;'>](svg/ispeed-reduce-panel-5-sum.svg)
[<img src='svg/ispeed-reduce-panel-6-sum.svg' style='width:12%;'>](svg/ispeed-reduce-panel-6-sum.svg)
[<img src='svg/ispeed-reduce-panel-7-sum.svg' style='width:12%;'>](svg/ispeed-reduce-panel-7-sum.svg)
[<img src='svg/ispeed-reduce-panel-8-sum.svg' style='width:12%;'>](svg/ispeed-reduce-panel-8-sum.svg)

### sumsquared

[<img src='svg/ispeed-reduce-panel-1-sumsquared.svg' style='width:12%;'>](svg/ispeed-reduce-panel-1-sumsquared.svg)
[<img src='svg/ispeed-reduce-panel-2-sumsquared.svg' style='width:12%;'>](svg/ispeed-reduce-panel-2-sumsquared.svg)
[<img src='svg/ispeed-reduce-panel-3-sumsquared.svg' style='width:12%;'>](svg/ispeed-reduce-panel-3-sumsquared.svg)
[<img src='svg/ispeed-reduce-panel-4-sumsquared.svg' style='width:12%;'>](svg/ispeed-reduce-panel-4-sumsquared.svg)
[<img src='svg/ispeed-reduce-panel-5-sumsquared.svg' style='width:12%;'>](svg/ispeed-reduce-panel-5-sumsquared.svg)
[<img src='svg/ispeed-reduce-panel-6-sumsquared.svg' style='width:12%;'>](svg/ispeed-reduce-panel-6-sumsquared.svg)
[<img src='svg/ispeed-reduce-panel-7-sumsquared.svg' style='width:12%;'>](svg/ispeed-reduce-panel-7-sumsquared.svg)
[<img src='svg/ispeed-reduce-panel-8-sumsquared.svg' style='width:12%;'>](svg/ispeed-reduce-panel-8-sumsquared.svg)

### variance

[<img src='svg/ispeed-reduce-panel-1-variance.svg' style='width:12%;'>](svg/ispeed-reduce-panel-1-variance.svg)
[<img src='svg/ispeed-reduce-panel-2-variance.svg' style='width:12%;'>](svg/ispeed-reduce-panel-2-variance.svg)
[<img src='svg/ispeed-reduce-panel-3-variance.svg' style='width:12%;'>](svg/ispeed-reduce-panel-3-variance.svg)
[<img src='svg/ispeed-reduce-panel-4-variance.svg' style='width:12%;'>](svg/ispeed-reduce-panel-4-variance.svg)
[<img src='svg/ispeed-reduce-panel-5-variance.svg' style='width:12%;'>](svg/ispeed-reduce-panel-5-variance.svg)
[<img src='svg/ispeed-reduce-panel-6-variance.svg' style='width:12%;'>](svg/ispeed-reduce-panel-6-variance.svg)
[<img src='svg/ispeed-reduce-panel-7-variance.svg' style='width:12%;'>](svg/ispeed-reduce-panel-7-variance.svg)
[<img src='svg/ispeed-reduce-panel-8-variance.svg' style='width:12%;'>](svg/ispeed-reduce-panel-8-variance.svg)