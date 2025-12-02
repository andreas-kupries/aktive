<img src='../../../doc/assets/aktive-logo-128.png' style='float:right;'>

Benchmark results comparing the 4-unrolled super-scalar loops against highway-based simd loops

||
|---|
|[Parent ↗](../README.md)|

## Summary (Dec 1, 2025)


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

__Note__: A suspicious behaviour is that for a number of
operations the speed curve becomes totally flat starting with 1000
values and higher.


### Addendum (Dec 2, 2025)


The experiment with unrolling the simd-based loops has __not__ born out.
Higher levels of unrolling make the simd-based loops __slower__.

Having watched the CPU temps during the run (up to 88 Celcius) I
strongly suspect that the normal simd loop already encounters
thermal throttling, and that unrolling simply drives the CPU
deeper into it, undoing any performance boost we may have gained
otherwise.

This throttling may also be the cause of why a number of scalar
loops loose speed for larger vectors, i.e. the CPU is still
throttled despite not using the vector units at the moment.

Checking this requires changing the order of benchmarks,
i.e. instead of having the vector length as the outer loop make
them the inner loop, thus keeping scalar and simd commands
separate instead of interleaved.


## Plots

[<img src='svg/times-simd-unary-ceil.svg' style='width:46%;'>](svg/times-simd-unary-ceil.svg)
[<img src='svg/ispeed-simd-unary-ceil.svg' style='width:46%;'>](svg/ispeed-simd-unary-ceil.svg)

[<img src='svg/times-simd-unary-clamp.svg' style='width:46%;'>](svg/times-simd-unary-clamp.svg)
[<img src='svg/ispeed-simd-unary-clamp.svg' style='width:46%;'>](svg/ispeed-simd-unary-clamp.svg)

[<img src='svg/times-simd-unary-fabs.svg' style='width:46%;'>](svg/times-simd-unary-fabs.svg)
[<img src='svg/ispeed-simd-unary-fabs.svg' style='width:46%;'>](svg/ispeed-simd-unary-fabs.svg)

[<img src='svg/times-simd-unary-floor.svg' style='width:46%;'>](svg/times-simd-unary-floor.svg)
[<img src='svg/ispeed-simd-unary-floor.svg' style='width:46%;'>](svg/ispeed-simd-unary-floor.svg)

[<img src='svg/times-simd-unary-invert.svg' style='width:46%;'>](svg/times-simd-unary-invert.svg)
[<img src='svg/ispeed-simd-unary-invert.svg' style='width:46%;'>](svg/ispeed-simd-unary-invert.svg)

[<img src='svg/times-simd-unary-neg.svg' style='width:46%;'>](svg/times-simd-unary-neg.svg)
[<img src='svg/ispeed-simd-unary-neg.svg' style='width:46%;'>](svg/ispeed-simd-unary-neg.svg)

[<img src='svg/times-simd-unary-not.svg' style='width:46%;'>](svg/times-simd-unary-not.svg)
[<img src='svg/ispeed-simd-unary-not.svg' style='width:46%;'>](svg/ispeed-simd-unary-not.svg)

[<img src='svg/times-simd-unary-reciprocal.svg' style='width:46%;'>](svg/times-simd-unary-reciprocal.svg)
[<img src='svg/ispeed-simd-unary-reciprocal.svg' style='width:46%;'>](svg/ispeed-simd-unary-reciprocal.svg)

[<img src='svg/times-simd-unary-round.svg' style='width:46%;'>](svg/times-simd-unary-round.svg)
[<img src='svg/ispeed-simd-unary-round.svg' style='width:46%;'>](svg/ispeed-simd-unary-round.svg)

[<img src='svg/times-simd-unary-sign.svg' style='width:46%;'>](svg/times-simd-unary-sign.svg)
[<img src='svg/ispeed-simd-unary-sign.svg' style='width:46%;'>](svg/ispeed-simd-unary-sign.svg)

[<img src='svg/times-simd-unary-signb.svg' style='width:46%;'>](svg/times-simd-unary-signb.svg)
[<img src='svg/ispeed-simd-unary-signb.svg' style='width:46%;'>](svg/ispeed-simd-unary-signb.svg)

[<img src='svg/times-simd-unary-sqrt.svg' style='width:46%;'>](svg/times-simd-unary-sqrt.svg)
[<img src='svg/ispeed-simd-unary-sqrt.svg' style='width:46%;'>](svg/ispeed-simd-unary-sqrt.svg)

[<img src='svg/times-simd-unary-square.svg' style='width:46%;'>](svg/times-simd-unary-square.svg)
[<img src='svg/ispeed-simd-unary-square.svg' style='width:46%;'>](svg/ispeed-simd-unary-square.svg)

[<img src='svg/times-simd-unary-eq.svg' style='width:46%;'>](svg/times-simd-unary-eq.svg)
[<img src='svg/ispeed-simd-unary-eq.svg' style='width:46%;'>](svg/ispeed-simd-unary-eq.svg)

[<img src='svg/times-simd-unary-fmax.svg' style='width:46%;'>](svg/times-simd-unary-fmax.svg)
[<img src='svg/ispeed-simd-unary-fmax.svg' style='width:46%;'>](svg/ispeed-simd-unary-fmax.svg)

[<img src='svg/times-simd-unary-fmin.svg' style='width:46%;'>](svg/times-simd-unary-fmin.svg)
[<img src='svg/ispeed-simd-unary-fmin.svg' style='width:46%;'>](svg/ispeed-simd-unary-fmin.svg)

[<img src='svg/times-simd-unary-ge.svg' style='width:46%;'>](svg/times-simd-unary-ge.svg)
[<img src='svg/ispeed-simd-unary-ge.svg' style='width:46%;'>](svg/ispeed-simd-unary-ge.svg)

[<img src='svg/times-simd-unary-gt.svg' style='width:46%;'>](svg/times-simd-unary-gt.svg)
[<img src='svg/ispeed-simd-unary-gt.svg' style='width:46%;'>](svg/ispeed-simd-unary-gt.svg)

[<img src='svg/times-simd-unary-le.svg' style='width:46%;'>](svg/times-simd-unary-le.svg)
[<img src='svg/ispeed-simd-unary-le.svg' style='width:46%;'>](svg/ispeed-simd-unary-le.svg)

[<img src='svg/times-simd-unary-lt.svg' style='width:46%;'>](svg/times-simd-unary-lt.svg)
[<img src='svg/ispeed-simd-unary-lt.svg' style='width:46%;'>](svg/ispeed-simd-unary-lt.svg)

[<img src='svg/times-simd-unary-ne.svg' style='width:46%;'>](svg/times-simd-unary-ne.svg)
[<img src='svg/ispeed-simd-unary-ne.svg' style='width:46%;'>](svg/ispeed-simd-unary-ne.svg)

[<img src='svg/times-simd-unary-nshift.svg' style='width:46%;'>](svg/times-simd-unary-nshift.svg)
[<img src='svg/ispeed-simd-unary-nshift.svg' style='width:46%;'>](svg/ispeed-simd-unary-nshift.svg)

[<img src='svg/times-simd-unary-rscale.svg' style='width:46%;'>](svg/times-simd-unary-rscale.svg)
[<img src='svg/ispeed-simd-unary-rscale.svg' style='width:46%;'>](svg/ispeed-simd-unary-rscale.svg)

[<img src='svg/times-simd-unary-scale.svg' style='width:46%;'>](svg/times-simd-unary-scale.svg)
[<img src='svg/ispeed-simd-unary-scale.svg' style='width:46%;'>](svg/ispeed-simd-unary-scale.svg)

[<img src='svg/times-simd-unary-shift.svg' style='width:46%;'>](svg/times-simd-unary-shift.svg)
[<img src='svg/ispeed-simd-unary-shift.svg' style='width:46%;'>](svg/ispeed-simd-unary-shift.svg)

[<img src='svg/times-simd-unary-sol.svg' style='width:46%;'>](svg/times-simd-unary-sol.svg)
[<img src='svg/ispeed-simd-unary-sol.svg' style='width:46%;'>](svg/ispeed-simd-unary-sol.svg)

[<img src='svg/times-simd-unary-inside_cc.svg' style='width:46%;'>](svg/times-simd-unary-inside_cc.svg)
[<img src='svg/ispeed-simd-unary-inside_cc.svg' style='width:46%;'>](svg/ispeed-simd-unary-inside_cc.svg)

[<img src='svg/times-simd-unary-inside_co.svg' style='width:46%;'>](svg/times-simd-unary-inside_co.svg)
[<img src='svg/ispeed-simd-unary-inside_co.svg' style='width:46%;'>](svg/ispeed-simd-unary-inside_co.svg)

[<img src='svg/times-simd-unary-inside_oc.svg' style='width:46%;'>](svg/times-simd-unary-inside_oc.svg)
[<img src='svg/ispeed-simd-unary-inside_oc.svg' style='width:46%;'>](svg/ispeed-simd-unary-inside_oc.svg)

[<img src='svg/times-simd-unary-inside_oo.svg' style='width:46%;'>](svg/times-simd-unary-inside_oo.svg)
[<img src='svg/ispeed-simd-unary-inside_oo.svg' style='width:46%;'>](svg/ispeed-simd-unary-inside_oo.svg)

[<img src='svg/times-simd-unary-outside_cc.svg' style='width:46%;'>](svg/times-simd-unary-outside_cc.svg)
[<img src='svg/ispeed-simd-unary-outside_cc.svg' style='width:46%;'>](svg/ispeed-simd-unary-outside_cc.svg)

[<img src='svg/times-simd-unary-outside_co.svg' style='width:46%;'>](svg/times-simd-unary-outside_co.svg)
[<img src='svg/ispeed-simd-unary-outside_co.svg' style='width:46%;'>](svg/ispeed-simd-unary-outside_co.svg)

[<img src='svg/times-simd-unary-outside_oc.svg' style='width:46%;'>](svg/times-simd-unary-outside_oc.svg)
[<img src='svg/ispeed-simd-unary-outside_oc.svg' style='width:46%;'>](svg/ispeed-simd-unary-outside_oc.svg)

[<img src='svg/times-simd-unary-outside_oo.svg' style='width:46%;'>](svg/times-simd-unary-outside_oo.svg)
[<img src='svg/ispeed-simd-unary-outside_oo.svg' style='width:46%;'>](svg/ispeed-simd-unary-outside_oo.svg)

[<img src='svg/times-simd-binary-and.svg' style='width:46%;'>](svg/times-simd-binary-and.svg)
[<img src='svg/ispeed-simd-binary-and.svg' style='width:46%;'>](svg/ispeed-simd-binary-and.svg)

[<img src='svg/times-simd-binary-nand.svg' style='width:46%;'>](svg/times-simd-binary-nand.svg)
[<img src='svg/ispeed-simd-binary-nand.svg' style='width:46%;'>](svg/ispeed-simd-binary-nand.svg)

[<img src='svg/times-simd-binary-nor.svg' style='width:46%;'>](svg/times-simd-binary-nor.svg)
[<img src='svg/ispeed-simd-binary-nor.svg' style='width:46%;'>](svg/ispeed-simd-binary-nor.svg)

[<img src='svg/times-simd-binary-or.svg' style='width:46%;'>](svg/times-simd-binary-or.svg)
[<img src='svg/ispeed-simd-binary-or.svg' style='width:46%;'>](svg/ispeed-simd-binary-or.svg)

[<img src='svg/times-simd-binary-xor.svg' style='width:46%;'>](svg/times-simd-binary-xor.svg)
[<img src='svg/ispeed-simd-binary-xor.svg' style='width:46%;'>](svg/ispeed-simd-binary-xor.svg)

[<img src='svg/times-simd-binary-add.svg' style='width:46%;'>](svg/times-simd-binary-add.svg)
[<img src='svg/ispeed-simd-binary-add.svg' style='width:46%;'>](svg/ispeed-simd-binary-add.svg)

[<img src='svg/times-simd-binary-sub.svg' style='width:46%;'>](svg/times-simd-binary-sub.svg)
[<img src='svg/ispeed-simd-binary-sub.svg' style='width:46%;'>](svg/ispeed-simd-binary-sub.svg)

[<img src='svg/times-simd-binary-mul.svg' style='width:46%;'>](svg/times-simd-binary-mul.svg)
[<img src='svg/ispeed-simd-binary-mul.svg' style='width:46%;'>](svg/ispeed-simd-binary-mul.svg)

[<img src='svg/times-simd-binary-div.svg' style='width:46%;'>](svg/times-simd-binary-div.svg)
[<img src='svg/ispeed-simd-binary-div.svg' style='width:46%;'>](svg/ispeed-simd-binary-div.svg)

[<img src='svg/times-simd-binary-fmax.svg' style='width:46%;'>](svg/times-simd-binary-fmax.svg)
[<img src='svg/ispeed-simd-binary-fmax.svg' style='width:46%;'>](svg/ispeed-simd-binary-fmax.svg)

[<img src='svg/times-simd-binary-fmin.svg' style='width:46%;'>](svg/times-simd-binary-fmin.svg)
[<img src='svg/ispeed-simd-binary-fmin.svg' style='width:46%;'>](svg/ispeed-simd-binary-fmin.svg)

[<img src='svg/times-simd-binary-eq.svg' style='width:46%;'>](svg/times-simd-binary-eq.svg)
[<img src='svg/ispeed-simd-binary-eq.svg' style='width:46%;'>](svg/ispeed-simd-binary-eq.svg)

[<img src='svg/times-simd-binary-ge.svg' style='width:46%;'>](svg/times-simd-binary-ge.svg)
[<img src='svg/ispeed-simd-binary-ge.svg' style='width:46%;'>](svg/ispeed-simd-binary-ge.svg)

[<img src='svg/times-simd-binary-gt.svg' style='width:46%;'>](svg/times-simd-binary-gt.svg)
[<img src='svg/ispeed-simd-binary-gt.svg' style='width:46%;'>](svg/ispeed-simd-binary-gt.svg)

[<img src='svg/times-simd-binary-le.svg' style='width:46%;'>](svg/times-simd-binary-le.svg)
[<img src='svg/ispeed-simd-binary-le.svg' style='width:46%;'>](svg/ispeed-simd-binary-le.svg)

[<img src='svg/times-simd-binary-lt.svg' style='width:46%;'>](svg/times-simd-binary-lt.svg)
[<img src='svg/ispeed-simd-binary-lt.svg' style='width:46%;'>](svg/ispeed-simd-binary-lt.svg)

[<img src='svg/times-simd-binary-ne.svg' style='width:46%;'>](svg/times-simd-binary-ne.svg)
[<img src='svg/ispeed-simd-binary-ne.svg' style='width:46%;'>](svg/ispeed-simd-binary-ne.svg)