<img src='../../../doc/assets/aktive-logo-128.png' style='float:right;'>

Benchmark results comparing the 4-unrolled super-scalar loops against highway-based simd loops

||
|---|
|[Parent ↗](../README.md)|

## Summary


First, the highway-based loops generate correct results.

They are also in general performing worse than the 4-unrolled
super-scalar loop.

It is suspected that due to our use of double as base-type for
pixel values we simply do not have enough vector lanes (two, IIRC)
to reach the speed of the super-scalar ops. I.e. the simd loop may
be the equivalent of a 2-unrolled super-scalar loop, at best.

A 2-unrolled simd loop on the other hand might be equivalent to
4-unrolled super-scalar, and a 4-unrolled simd loop might be
faster. These are the next experiments to run.


## Plots

[<img src='svg/times-simd-unary-ceil.svg' style='width:46%;'>](svg/times-simd-unary-ceil.svg.svg)
[<img src='svg/ispeed-simd-unary-ceil.svg' style='width:46%;'>](svg/ispeed-simd-unary-ceil.svg.svg)

[<img src='svg/times-simd-unary-clamp.svg' style='width:46%;'>](svg/times-simd-unary-clamp.svg.svg)
[<img src='svg/ispeed-simd-unary-clamp.svg' style='width:46%;'>](svg/ispeed-simd-unary-clamp.svg.svg)

[<img src='svg/times-simd-unary-fabs.svg' style='width:46%;'>](svg/times-simd-unary-fabs.svg.svg)
[<img src='svg/ispeed-simd-unary-fabs.svg' style='width:46%;'>](svg/ispeed-simd-unary-fabs.svg.svg)

[<img src='svg/times-simd-unary-floor.svg' style='width:46%;'>](svg/times-simd-unary-floor.svg.svg)
[<img src='svg/ispeed-simd-unary-floor.svg' style='width:46%;'>](svg/ispeed-simd-unary-floor.svg.svg)

[<img src='svg/times-simd-unary-invert.svg' style='width:46%;'>](svg/times-simd-unary-invert.svg.svg)
[<img src='svg/ispeed-simd-unary-invert.svg' style='width:46%;'>](svg/ispeed-simd-unary-invert.svg.svg)

[<img src='svg/times-simd-unary-neg.svg' style='width:46%;'>](svg/times-simd-unary-neg.svg.svg)
[<img src='svg/ispeed-simd-unary-neg.svg' style='width:46%;'>](svg/ispeed-simd-unary-neg.svg.svg)

[<img src='svg/times-simd-unary-not.svg' style='width:46%;'>](svg/times-simd-unary-not.svg.svg)
[<img src='svg/ispeed-simd-unary-not.svg' style='width:46%;'>](svg/ispeed-simd-unary-not.svg.svg)

[<img src='svg/times-simd-unary-reciprocal.svg' style='width:46%;'>](svg/times-simd-unary-reciprocal.svg.svg)
[<img src='svg/ispeed-simd-unary-reciprocal.svg' style='width:46%;'>](svg/ispeed-simd-unary-reciprocal.svg.svg)

[<img src='svg/times-simd-unary-round.svg' style='width:46%;'>](svg/times-simd-unary-round.svg.svg)
[<img src='svg/ispeed-simd-unary-round.svg' style='width:46%;'>](svg/ispeed-simd-unary-round.svg.svg)

[<img src='svg/times-simd-unary-sign.svg' style='width:46%;'>](svg/times-simd-unary-sign.svg.svg)
[<img src='svg/ispeed-simd-unary-sign.svg' style='width:46%;'>](svg/ispeed-simd-unary-sign.svg.svg)

[<img src='svg/times-simd-unary-signb.svg' style='width:46%;'>](svg/times-simd-unary-signb.svg.svg)
[<img src='svg/ispeed-simd-unary-signb.svg' style='width:46%;'>](svg/ispeed-simd-unary-signb.svg.svg)

[<img src='svg/times-simd-unary-sin.svg' style='width:46%;'>](svg/times-simd-unary-sin.svg.svg)
[<img src='svg/ispeed-simd-unary-sin.svg' style='width:46%;'>](svg/ispeed-simd-unary-sin.svg.svg)

[<img src='svg/times-simd-unary-sinh.svg' style='width:46%;'>](svg/times-simd-unary-sinh.svg.svg)
[<img src='svg/ispeed-simd-unary-sinh.svg' style='width:46%;'>](svg/ispeed-simd-unary-sinh.svg.svg)

[<img src='svg/times-simd-unary-sqrt.svg' style='width:46%;'>](svg/times-simd-unary-sqrt.svg.svg)
[<img src='svg/ispeed-simd-unary-sqrt.svg' style='width:46%;'>](svg/ispeed-simd-unary-sqrt.svg.svg)

[<img src='svg/times-simd-unary-square.svg' style='width:46%;'>](svg/times-simd-unary-square.svg.svg)
[<img src='svg/ispeed-simd-unary-square.svg' style='width:46%;'>](svg/ispeed-simd-unary-square.svg.svg)

[<img src='svg/times-simd-unary-eq.svg' style='width:46%;'>](svg/times-simd-unary-eq.svg.svg)
[<img src='svg/ispeed-simd-unary-eq.svg' style='width:46%;'>](svg/ispeed-simd-unary-eq.svg.svg)

[<img src='svg/times-simd-unary-fmax.svg' style='width:46%;'>](svg/times-simd-unary-fmax.svg.svg)
[<img src='svg/ispeed-simd-unary-fmax.svg' style='width:46%;'>](svg/ispeed-simd-unary-fmax.svg.svg)

[<img src='svg/times-simd-unary-fmin.svg' style='width:46%;'>](svg/times-simd-unary-fmin.svg.svg)
[<img src='svg/ispeed-simd-unary-fmin.svg' style='width:46%;'>](svg/ispeed-simd-unary-fmin.svg.svg)

[<img src='svg/times-simd-unary-ge.svg' style='width:46%;'>](svg/times-simd-unary-ge.svg.svg)
[<img src='svg/ispeed-simd-unary-ge.svg' style='width:46%;'>](svg/ispeed-simd-unary-ge.svg.svg)

[<img src='svg/times-simd-unary-gt.svg' style='width:46%;'>](svg/times-simd-unary-gt.svg.svg)
[<img src='svg/ispeed-simd-unary-gt.svg' style='width:46%;'>](svg/ispeed-simd-unary-gt.svg.svg)

[<img src='svg/times-simd-unary-le.svg' style='width:46%;'>](svg/times-simd-unary-le.svg.svg)
[<img src='svg/ispeed-simd-unary-le.svg' style='width:46%;'>](svg/ispeed-simd-unary-le.svg.svg)

[<img src='svg/times-simd-unary-lt.svg' style='width:46%;'>](svg/times-simd-unary-lt.svg.svg)
[<img src='svg/ispeed-simd-unary-lt.svg' style='width:46%;'>](svg/ispeed-simd-unary-lt.svg.svg)

[<img src='svg/times-simd-unary-ne.svg' style='width:46%;'>](svg/times-simd-unary-ne.svg.svg)
[<img src='svg/ispeed-simd-unary-ne.svg' style='width:46%;'>](svg/ispeed-simd-unary-ne.svg.svg)

[<img src='svg/times-simd-unary-nshift.svg' style='width:46%;'>](svg/times-simd-unary-nshift.svg.svg)
[<img src='svg/ispeed-simd-unary-nshift.svg' style='width:46%;'>](svg/ispeed-simd-unary-nshift.svg.svg)

[<img src='svg/times-simd-unary-rscale.svg' style='width:46%;'>](svg/times-simd-unary-rscale.svg.svg)
[<img src='svg/ispeed-simd-unary-rscale.svg' style='width:46%;'>](svg/ispeed-simd-unary-rscale.svg.svg)

[<img src='svg/times-simd-unary-scale.svg' style='width:46%;'>](svg/times-simd-unary-scale.svg.svg)
[<img src='svg/ispeed-simd-unary-scale.svg' style='width:46%;'>](svg/ispeed-simd-unary-scale.svg.svg)

[<img src='svg/times-simd-unary-shift.svg' style='width:46%;'>](svg/times-simd-unary-shift.svg.svg)
[<img src='svg/ispeed-simd-unary-shift.svg' style='width:46%;'>](svg/ispeed-simd-unary-shift.svg.svg)

[<img src='svg/times-simd-unary-sol.svg' style='width:46%;'>](svg/times-simd-unary-sol.svg.svg)
[<img src='svg/ispeed-simd-unary-sol.svg' style='width:46%;'>](svg/ispeed-simd-unary-sol.svg.svg)

[<img src='svg/times-simd-unary-inside_cc.svg' style='width:46%;'>](svg/times-simd-unary-inside_cc.svg.svg)
[<img src='svg/ispeed-simd-unary-inside_cc.svg' style='width:46%;'>](svg/ispeed-simd-unary-inside_cc.svg.svg)

[<img src='svg/times-simd-unary-inside_co.svg' style='width:46%;'>](svg/times-simd-unary-inside_co.svg.svg)
[<img src='svg/ispeed-simd-unary-inside_co.svg' style='width:46%;'>](svg/ispeed-simd-unary-inside_co.svg.svg)

[<img src='svg/times-simd-unary-inside_oc.svg' style='width:46%;'>](svg/times-simd-unary-inside_oc.svg.svg)
[<img src='svg/ispeed-simd-unary-inside_oc.svg' style='width:46%;'>](svg/ispeed-simd-unary-inside_oc.svg.svg)

[<img src='svg/times-simd-unary-inside_oo.svg' style='width:46%;'>](svg/times-simd-unary-inside_oo.svg.svg)
[<img src='svg/ispeed-simd-unary-inside_oo.svg' style='width:46%;'>](svg/ispeed-simd-unary-inside_oo.svg.svg)

[<img src='svg/times-simd-unary-outside_cc.svg' style='width:46%;'>](svg/times-simd-unary-outside_cc.svg.svg)
[<img src='svg/ispeed-simd-unary-outside_cc.svg' style='width:46%;'>](svg/ispeed-simd-unary-outside_cc.svg.svg)

[<img src='svg/times-simd-unary-outside_co.svg' style='width:46%;'>](svg/times-simd-unary-outside_co.svg.svg)
[<img src='svg/ispeed-simd-unary-outside_co.svg' style='width:46%;'>](svg/ispeed-simd-unary-outside_co.svg.svg)

[<img src='svg/times-simd-unary-outside_oc.svg' style='width:46%;'>](svg/times-simd-unary-outside_oc.svg.svg)
[<img src='svg/ispeed-simd-unary-outside_oc.svg' style='width:46%;'>](svg/ispeed-simd-unary-outside_oc.svg.svg)

[<img src='svg/times-simd-unary-outside_oo.svg' style='width:46%;'>](svg/times-simd-unary-outside_oo.svg.svg)
[<img src='svg/ispeed-simd-unary-outside_oo.svg' style='width:46%;'>](svg/ispeed-simd-unary-outside_oo.svg.svg)

[<img src='svg/times-simd-binary-and.svg' style='width:46%;'>](svg/times-simd-binary-and.svg.svg)
[<img src='svg/ispeed-simd-binary-and.svg' style='width:46%;'>](svg/ispeed-simd-binary-and.svg.svg)

[<img src='svg/times-simd-binary-nand.svg' style='width:46%;'>](svg/times-simd-binary-nand.svg.svg)
[<img src='svg/ispeed-simd-binary-nand.svg' style='width:46%;'>](svg/ispeed-simd-binary-nand.svg.svg)

[<img src='svg/times-simd-binary-nor.svg' style='width:46%;'>](svg/times-simd-binary-nor.svg.svg)
[<img src='svg/ispeed-simd-binary-nor.svg' style='width:46%;'>](svg/ispeed-simd-binary-nor.svg.svg)

[<img src='svg/times-simd-binary-or.svg' style='width:46%;'>](svg/times-simd-binary-or.svg.svg)
[<img src='svg/ispeed-simd-binary-or.svg' style='width:46%;'>](svg/ispeed-simd-binary-or.svg.svg)

[<img src='svg/times-simd-binary-xor.svg' style='width:46%;'>](svg/times-simd-binary-xor.svg.svg)
[<img src='svg/ispeed-simd-binary-xor.svg' style='width:46%;'>](svg/ispeed-simd-binary-xor.svg.svg)

[<img src='svg/times-simd-binary-add.svg' style='width:46%;'>](svg/times-simd-binary-add.svg.svg)
[<img src='svg/ispeed-simd-binary-add.svg' style='width:46%;'>](svg/ispeed-simd-binary-add.svg.svg)

[<img src='svg/times-simd-binary-sub.svg' style='width:46%;'>](svg/times-simd-binary-sub.svg.svg)
[<img src='svg/ispeed-simd-binary-sub.svg' style='width:46%;'>](svg/ispeed-simd-binary-sub.svg.svg)

[<img src='svg/times-simd-binary-mul.svg' style='width:46%;'>](svg/times-simd-binary-mul.svg.svg)
[<img src='svg/ispeed-simd-binary-mul.svg' style='width:46%;'>](svg/ispeed-simd-binary-mul.svg.svg)

[<img src='svg/times-simd-binary-div.svg' style='width:46%;'>](svg/times-simd-binary-div.svg.svg)
[<img src='svg/ispeed-simd-binary-div.svg' style='width:46%;'>](svg/ispeed-simd-binary-div.svg.svg)

[<img src='svg/times-simd-binary-fmax.svg' style='width:46%;'>](svg/times-simd-binary-fmax.svg.svg)
[<img src='svg/ispeed-simd-binary-fmax.svg' style='width:46%;'>](svg/ispeed-simd-binary-fmax.svg.svg)

[<img src='svg/times-simd-binary-fmin.svg' style='width:46%;'>](svg/times-simd-binary-fmin.svg.svg)
[<img src='svg/ispeed-simd-binary-fmin.svg' style='width:46%;'>](svg/ispeed-simd-binary-fmin.svg.svg)

[<img src='svg/times-simd-binary-eq.svg' style='width:46%;'>](svg/times-simd-binary-eq.svg.svg)
[<img src='svg/ispeed-simd-binary-eq.svg' style='width:46%;'>](svg/ispeed-simd-binary-eq.svg.svg)

[<img src='svg/times-simd-binary-ge.svg' style='width:46%;'>](svg/times-simd-binary-ge.svg.svg)
[<img src='svg/ispeed-simd-binary-ge.svg' style='width:46%;'>](svg/ispeed-simd-binary-ge.svg.svg)

[<img src='svg/times-simd-binary-gt.svg' style='width:46%;'>](svg/times-simd-binary-gt.svg.svg)
[<img src='svg/ispeed-simd-binary-gt.svg' style='width:46%;'>](svg/ispeed-simd-binary-gt.svg.svg)

[<img src='svg/times-simd-binary-le.svg' style='width:46%;'>](svg/times-simd-binary-le.svg.svg)
[<img src='svg/ispeed-simd-binary-le.svg' style='width:46%;'>](svg/ispeed-simd-binary-le.svg.svg)

[<img src='svg/times-simd-binary-lt.svg' style='width:46%;'>](svg/times-simd-binary-lt.svg.svg)
[<img src='svg/ispeed-simd-binary-lt.svg' style='width:46%;'>](svg/ispeed-simd-binary-lt.svg.svg)

[<img src='svg/times-simd-binary-ne.svg' style='width:46%;'>](svg/times-simd-binary-ne.svg.svg)
[<img src='svg/ispeed-simd-binary-ne.svg' style='width:46%;'>](svg/ispeed-simd-binary-ne.svg.svg)
