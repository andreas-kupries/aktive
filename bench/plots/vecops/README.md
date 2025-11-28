<img src='../../../doc/assets/aktive-logo-128.png' style='float:right;'>

Benchmark results for basic vector support using scalar loop at various levels of unrolling

||
|---|
|[Parent ↗](../README.md)|

## Summary

All math functions with vector support were implemented via scalar
loops, at three levels of unrolling (1, i.e. none, 2, and 4).

  - Not unrolled was generally worst.
  - 4-unrolled was generally best, and where not, it was not worse than without unrolling.
  - 2-unrolled was generally between the two above.

It is noted that unrolling generally did not help for the more
complicated functions, like `sin`, `cos,` etc. Simple math on the
other hand showed clear differences with the advantage to the
4-unrolled loops.

It is suspected that the more complicated functions could/were not
inlined into the loop, causing the unrolled loops to not take
proper advantage of super-scalar execution, only of reduced loop
overhead. Which was not strong enough to show up in the numbers.

Chosen to keep the 4-unrolled loops across the board, in the hope
of future compiler changes allowing for inlining and optimization.

## Plots

[<img src='svg/times-vecops-unary-acos.svg' style='width:46%;'>](svg/times-vecops-unary-acos.svg.svg)
[<img src='svg/ispeed-vecops-unary-acos.svg' style='width:46%;'>](svg/ispeed-vecops-unary-acos.svg.svg)

[<img src='svg/times-vecops-unary-acosh.svg' style='width:46%;'>](svg/times-vecops-unary-acosh.svg.svg)
[<img src='svg/ispeed-vecops-unary-acosh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-acosh.svg.svg)

[<img src='svg/times-vecops-unary-asin.svg' style='width:46%;'>](svg/times-vecops-unary-asin.svg.svg)
[<img src='svg/ispeed-vecops-unary-asin.svg' style='width:46%;'>](svg/ispeed-vecops-unary-asin.svg.svg)

[<img src='svg/times-vecops-unary-asinh.svg' style='width:46%;'>](svg/times-vecops-unary-asinh.svg.svg)
[<img src='svg/ispeed-vecops-unary-asinh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-asinh.svg.svg)

[<img src='svg/times-vecops-unary-atan.svg' style='width:46%;'>](svg/times-vecops-unary-atan.svg.svg)
[<img src='svg/ispeed-vecops-unary-atan.svg' style='width:46%;'>](svg/ispeed-vecops-unary-atan.svg.svg)

[<img src='svg/times-vecops-unary-atanh.svg' style='width:46%;'>](svg/times-vecops-unary-atanh.svg.svg)
[<img src='svg/ispeed-vecops-unary-atanh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-atanh.svg.svg)

[<img src='svg/times-vecops-unary-cbrt.svg' style='width:46%;'>](svg/times-vecops-unary-cbrt.svg.svg)
[<img src='svg/ispeed-vecops-unary-cbrt.svg' style='width:46%;'>](svg/ispeed-vecops-unary-cbrt.svg.svg)

[<img src='svg/times-vecops-unary-ceil.svg' style='width:46%;'>](svg/times-vecops-unary-ceil.svg.svg)
[<img src='svg/ispeed-vecops-unary-ceil.svg' style='width:46%;'>](svg/ispeed-vecops-unary-ceil.svg.svg)

[<img src='svg/times-vecops-unary-clamp.svg' style='width:46%;'>](svg/times-vecops-unary-clamp.svg.svg)
[<img src='svg/ispeed-vecops-unary-clamp.svg' style='width:46%;'>](svg/ispeed-vecops-unary-clamp.svg.svg)

[<img src='svg/times-vecops-unary-cos.svg' style='width:46%;'>](svg/times-vecops-unary-cos.svg.svg)
[<img src='svg/ispeed-vecops-unary-cos.svg' style='width:46%;'>](svg/ispeed-vecops-unary-cos.svg.svg)

[<img src='svg/times-vecops-unary-cosh.svg' style='width:46%;'>](svg/times-vecops-unary-cosh.svg.svg)
[<img src='svg/ispeed-vecops-unary-cosh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-cosh.svg.svg)

[<img src='svg/times-vecops-unary-exp.svg' style='width:46%;'>](svg/times-vecops-unary-exp.svg.svg)
[<img src='svg/ispeed-vecops-unary-exp.svg' style='width:46%;'>](svg/ispeed-vecops-unary-exp.svg.svg)

[<img src='svg/times-vecops-unary-exp10.svg' style='width:46%;'>](svg/times-vecops-unary-exp10.svg.svg)
[<img src='svg/ispeed-vecops-unary-exp10.svg' style='width:46%;'>](svg/ispeed-vecops-unary-exp10.svg.svg)

[<img src='svg/times-vecops-unary-exp2.svg' style='width:46%;'>](svg/times-vecops-unary-exp2.svg.svg)
[<img src='svg/ispeed-vecops-unary-exp2.svg' style='width:46%;'>](svg/ispeed-vecops-unary-exp2.svg.svg)

[<img src='svg/times-vecops-unary-fabs.svg' style='width:46%;'>](svg/times-vecops-unary-fabs.svg.svg)
[<img src='svg/ispeed-vecops-unary-fabs.svg' style='width:46%;'>](svg/ispeed-vecops-unary-fabs.svg.svg)

[<img src='svg/times-vecops-unary-floor.svg' style='width:46%;'>](svg/times-vecops-unary-floor.svg.svg)
[<img src='svg/ispeed-vecops-unary-floor.svg' style='width:46%;'>](svg/ispeed-vecops-unary-floor.svg.svg)

[<img src='svg/times-vecops-unary-gamma_compress.svg' style='width:46%;'>](svg/times-vecops-unary-gamma_compress.svg.svg)
[<img src='svg/ispeed-vecops-unary-gamma_compress.svg' style='width:46%;'>](svg/ispeed-vecops-unary-gamma_compress.svg.svg)

[<img src='svg/times-vecops-unary-gamma_expand.svg' style='width:46%;'>](svg/times-vecops-unary-gamma_expand.svg.svg)
[<img src='svg/ispeed-vecops-unary-gamma_expand.svg' style='width:46%;'>](svg/ispeed-vecops-unary-gamma_expand.svg.svg)

[<img src='svg/times-vecops-unary-invert.svg' style='width:46%;'>](svg/times-vecops-unary-invert.svg.svg)
[<img src='svg/ispeed-vecops-unary-invert.svg' style='width:46%;'>](svg/ispeed-vecops-unary-invert.svg.svg)

[<img src='svg/times-vecops-unary-log.svg' style='width:46%;'>](svg/times-vecops-unary-log.svg.svg)
[<img src='svg/ispeed-vecops-unary-log.svg' style='width:46%;'>](svg/ispeed-vecops-unary-log.svg.svg)

[<img src='svg/times-vecops-unary-log10.svg' style='width:46%;'>](svg/times-vecops-unary-log10.svg.svg)
[<img src='svg/ispeed-vecops-unary-log10.svg' style='width:46%;'>](svg/ispeed-vecops-unary-log10.svg.svg)

[<img src='svg/times-vecops-unary-log2.svg' style='width:46%;'>](svg/times-vecops-unary-log2.svg.svg)
[<img src='svg/ispeed-vecops-unary-log2.svg' style='width:46%;'>](svg/ispeed-vecops-unary-log2.svg.svg)

[<img src='svg/times-vecops-unary-neg.svg' style='width:46%;'>](svg/times-vecops-unary-neg.svg.svg)
[<img src='svg/ispeed-vecops-unary-neg.svg' style='width:46%;'>](svg/ispeed-vecops-unary-neg.svg.svg)

[<img src='svg/times-vecops-unary-not.svg' style='width:46%;'>](svg/times-vecops-unary-not.svg.svg)
[<img src='svg/ispeed-vecops-unary-not.svg' style='width:46%;'>](svg/ispeed-vecops-unary-not.svg.svg)

[<img src='svg/times-vecops-unary-reciprocal.svg' style='width:46%;'>](svg/times-vecops-unary-reciprocal.svg.svg)
[<img src='svg/ispeed-vecops-unary-reciprocal.svg' style='width:46%;'>](svg/ispeed-vecops-unary-reciprocal.svg.svg)

[<img src='svg/times-vecops-unary-round.svg' style='width:46%;'>](svg/times-vecops-unary-round.svg.svg)
[<img src='svg/ispeed-vecops-unary-round.svg' style='width:46%;'>](svg/ispeed-vecops-unary-round.svg.svg)

[<img src='svg/times-vecops-unary-sign.svg' style='width:46%;'>](svg/times-vecops-unary-sign.svg.svg)
[<img src='svg/ispeed-vecops-unary-sign.svg' style='width:46%;'>](svg/ispeed-vecops-unary-sign.svg.svg)

[<img src='svg/times-vecops-unary-signb.svg' style='width:46%;'>](svg/times-vecops-unary-signb.svg.svg)
[<img src='svg/ispeed-vecops-unary-signb.svg' style='width:46%;'>](svg/ispeed-vecops-unary-signb.svg.svg)

[<img src='svg/times-vecops-unary-sin.svg' style='width:46%;'>](svg/times-vecops-unary-sin.svg.svg)
[<img src='svg/ispeed-vecops-unary-sin.svg' style='width:46%;'>](svg/ispeed-vecops-unary-sin.svg.svg)

[<img src='svg/times-vecops-unary-sinh.svg' style='width:46%;'>](svg/times-vecops-unary-sinh.svg.svg)
[<img src='svg/ispeed-vecops-unary-sinh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-sinh.svg.svg)

[<img src='svg/times-vecops-unary-sqrt.svg' style='width:46%;'>](svg/times-vecops-unary-sqrt.svg.svg)
[<img src='svg/ispeed-vecops-unary-sqrt.svg' style='width:46%;'>](svg/ispeed-vecops-unary-sqrt.svg.svg)

[<img src='svg/times-vecops-unary-square.svg' style='width:46%;'>](svg/times-vecops-unary-square.svg.svg)
[<img src='svg/ispeed-vecops-unary-square.svg' style='width:46%;'>](svg/ispeed-vecops-unary-square.svg.svg)

[<img src='svg/times-vecops-unary-tan.svg' style='width:46%;'>](svg/times-vecops-unary-tan.svg.svg)
[<img src='svg/ispeed-vecops-unary-tan.svg' style='width:46%;'>](svg/ispeed-vecops-unary-tan.svg.svg)

[<img src='svg/times-vecops-unary-tanh.svg' style='width:46%;'>](svg/times-vecops-unary-tanh.svg.svg)
[<img src='svg/ispeed-vecops-unary-tanh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-tanh.svg.svg)

[<img src='svg/times-vecops-unary-wrap.svg' style='width:46%;'>](svg/times-vecops-unary-wrap.svg.svg)
[<img src='svg/ispeed-vecops-unary-wrap.svg' style='width:46%;'>](svg/ispeed-vecops-unary-wrap.svg.svg)

[<img src='svg/times-vecops-unary-atan2.svg' style='width:46%;'>](svg/times-vecops-unary-atan2.svg.svg)
[<img src='svg/ispeed-vecops-unary-atan2.svg' style='width:46%;'>](svg/ispeed-vecops-unary-atan2.svg.svg)

[<img src='svg/times-vecops-unary-eq.svg' style='width:46%;'>](svg/times-vecops-unary-eq.svg.svg)
[<img src='svg/ispeed-vecops-unary-eq.svg' style='width:46%;'>](svg/ispeed-vecops-unary-eq.svg.svg)

[<img src='svg/times-vecops-unary-expx.svg' style='width:46%;'>](svg/times-vecops-unary-expx.svg.svg)
[<img src='svg/ispeed-vecops-unary-expx.svg' style='width:46%;'>](svg/ispeed-vecops-unary-expx.svg.svg)

[<img src='svg/times-vecops-unary-fmax.svg' style='width:46%;'>](svg/times-vecops-unary-fmax.svg.svg)
[<img src='svg/ispeed-vecops-unary-fmax.svg' style='width:46%;'>](svg/ispeed-vecops-unary-fmax.svg.svg)

[<img src='svg/times-vecops-unary-fmin.svg' style='width:46%;'>](svg/times-vecops-unary-fmin.svg.svg)
[<img src='svg/ispeed-vecops-unary-fmin.svg' style='width:46%;'>](svg/ispeed-vecops-unary-fmin.svg.svg)

[<img src='svg/times-vecops-unary-fmod.svg' style='width:46%;'>](svg/times-vecops-unary-fmod.svg.svg)
[<img src='svg/ispeed-vecops-unary-fmod.svg' style='width:46%;'>](svg/ispeed-vecops-unary-fmod.svg.svg)

[<img src='svg/times-vecops-unary-ge.svg' style='width:46%;'>](svg/times-vecops-unary-ge.svg.svg)
[<img src='svg/ispeed-vecops-unary-ge.svg' style='width:46%;'>](svg/ispeed-vecops-unary-ge.svg.svg)

[<img src='svg/times-vecops-unary-gt.svg' style='width:46%;'>](svg/times-vecops-unary-gt.svg.svg)
[<img src='svg/ispeed-vecops-unary-gt.svg' style='width:46%;'>](svg/ispeed-vecops-unary-gt.svg.svg)

[<img src='svg/times-vecops-unary-hypot.svg' style='width:46%;'>](svg/times-vecops-unary-hypot.svg.svg)
[<img src='svg/ispeed-vecops-unary-hypot.svg' style='width:46%;'>](svg/ispeed-vecops-unary-hypot.svg.svg)

[<img src='svg/times-vecops-unary-le.svg' style='width:46%;'>](svg/times-vecops-unary-le.svg.svg)
[<img src='svg/ispeed-vecops-unary-le.svg' style='width:46%;'>](svg/ispeed-vecops-unary-le.svg.svg)

[<img src='svg/times-vecops-unary-lt.svg' style='width:46%;'>](svg/times-vecops-unary-lt.svg.svg)
[<img src='svg/ispeed-vecops-unary-lt.svg' style='width:46%;'>](svg/ispeed-vecops-unary-lt.svg.svg)

[<img src='svg/times-vecops-unary-ne.svg' style='width:46%;'>](svg/times-vecops-unary-ne.svg.svg)
[<img src='svg/ispeed-vecops-unary-ne.svg' style='width:46%;'>](svg/ispeed-vecops-unary-ne.svg.svg)

[<img src='svg/times-vecops-unary-nshift.svg' style='width:46%;'>](svg/times-vecops-unary-nshift.svg.svg)
[<img src='svg/ispeed-vecops-unary-nshift.svg' style='width:46%;'>](svg/ispeed-vecops-unary-nshift.svg.svg)

[<img src='svg/times-vecops-unary-pow.svg' style='width:46%;'>](svg/times-vecops-unary-pow.svg.svg)
[<img src='svg/ispeed-vecops-unary-pow.svg' style='width:46%;'>](svg/ispeed-vecops-unary-pow.svg.svg)

[<img src='svg/times-vecops-unary-ratan2.svg' style='width:46%;'>](svg/times-vecops-unary-ratan2.svg.svg)
[<img src='svg/ispeed-vecops-unary-ratan2.svg' style='width:46%;'>](svg/ispeed-vecops-unary-ratan2.svg.svg)

[<img src='svg/times-vecops-unary-rfmod.svg' style='width:46%;'>](svg/times-vecops-unary-rfmod.svg.svg)
[<img src='svg/ispeed-vecops-unary-rfmod.svg' style='width:46%;'>](svg/ispeed-vecops-unary-rfmod.svg.svg)

[<img src='svg/times-vecops-unary-rscale.svg' style='width:46%;'>](svg/times-vecops-unary-rscale.svg.svg)
[<img src='svg/ispeed-vecops-unary-rscale.svg' style='width:46%;'>](svg/ispeed-vecops-unary-rscale.svg.svg)

[<img src='svg/times-vecops-unary-scale.svg' style='width:46%;'>](svg/times-vecops-unary-scale.svg.svg)
[<img src='svg/ispeed-vecops-unary-scale.svg' style='width:46%;'>](svg/ispeed-vecops-unary-scale.svg.svg)

[<img src='svg/times-vecops-unary-shift.svg' style='width:46%;'>](svg/times-vecops-unary-shift.svg.svg)
[<img src='svg/ispeed-vecops-unary-shift.svg' style='width:46%;'>](svg/ispeed-vecops-unary-shift.svg.svg)

[<img src='svg/times-vecops-unary-sol.svg' style='width:46%;'>](svg/times-vecops-unary-sol.svg.svg)
[<img src='svg/ispeed-vecops-unary-sol.svg' style='width:46%;'>](svg/ispeed-vecops-unary-sol.svg.svg)

[<img src='svg/times-vecops-unary-inside_cc.svg' style='width:46%;'>](svg/times-vecops-unary-inside_cc.svg.svg)
[<img src='svg/ispeed-vecops-unary-inside_cc.svg' style='width:46%;'>](svg/ispeed-vecops-unary-inside_cc.svg.svg)

[<img src='svg/times-vecops-unary-inside_co.svg' style='width:46%;'>](svg/times-vecops-unary-inside_co.svg.svg)
[<img src='svg/ispeed-vecops-unary-inside_co.svg' style='width:46%;'>](svg/ispeed-vecops-unary-inside_co.svg.svg)

[<img src='svg/times-vecops-unary-inside_oc.svg' style='width:46%;'>](svg/times-vecops-unary-inside_oc.svg.svg)
[<img src='svg/ispeed-vecops-unary-inside_oc.svg' style='width:46%;'>](svg/ispeed-vecops-unary-inside_oc.svg.svg)

[<img src='svg/times-vecops-unary-inside_oo.svg' style='width:46%;'>](svg/times-vecops-unary-inside_oo.svg.svg)
[<img src='svg/ispeed-vecops-unary-inside_oo.svg' style='width:46%;'>](svg/ispeed-vecops-unary-inside_oo.svg.svg)

[<img src='svg/times-vecops-unary-outside_cc.svg' style='width:46%;'>](svg/times-vecops-unary-outside_cc.svg.svg)
[<img src='svg/ispeed-vecops-unary-outside_cc.svg' style='width:46%;'>](svg/ispeed-vecops-unary-outside_cc.svg.svg)

[<img src='svg/times-vecops-unary-outside_co.svg' style='width:46%;'>](svg/times-vecops-unary-outside_co.svg.svg)
[<img src='svg/ispeed-vecops-unary-outside_co.svg' style='width:46%;'>](svg/ispeed-vecops-unary-outside_co.svg.svg)

[<img src='svg/times-vecops-unary-outside_oc.svg' style='width:46%;'>](svg/times-vecops-unary-outside_oc.svg.svg)
[<img src='svg/ispeed-vecops-unary-outside_oc.svg' style='width:46%;'>](svg/ispeed-vecops-unary-outside_oc.svg.svg)

[<img src='svg/times-vecops-unary-outside_oo.svg' style='width:46%;'>](svg/times-vecops-unary-outside_oo.svg.svg)
[<img src='svg/ispeed-vecops-unary-outside_oo.svg' style='width:46%;'>](svg/ispeed-vecops-unary-outside_oo.svg.svg)

[<img src='svg/times-vecops-binary-and.svg' style='width:46%;'>](svg/times-vecops-binary-and.svg.svg)
[<img src='svg/ispeed-vecops-binary-and.svg' style='width:46%;'>](svg/ispeed-vecops-binary-and.svg.svg)

[<img src='svg/times-vecops-binary-nand.svg' style='width:46%;'>](svg/times-vecops-binary-nand.svg.svg)
[<img src='svg/ispeed-vecops-binary-nand.svg' style='width:46%;'>](svg/ispeed-vecops-binary-nand.svg.svg)

[<img src='svg/times-vecops-binary-nor.svg' style='width:46%;'>](svg/times-vecops-binary-nor.svg.svg)
[<img src='svg/ispeed-vecops-binary-nor.svg' style='width:46%;'>](svg/ispeed-vecops-binary-nor.svg.svg)

[<img src='svg/times-vecops-binary-or.svg' style='width:46%;'>](svg/times-vecops-binary-or.svg.svg)
[<img src='svg/ispeed-vecops-binary-or.svg' style='width:46%;'>](svg/ispeed-vecops-binary-or.svg.svg)

[<img src='svg/times-vecops-binary-xor.svg' style='width:46%;'>](svg/times-vecops-binary-xor.svg.svg)
[<img src='svg/ispeed-vecops-binary-xor.svg' style='width:46%;'>](svg/ispeed-vecops-binary-xor.svg.svg)

[<img src='svg/times-vecops-binary-add.svg' style='width:46%;'>](svg/times-vecops-binary-add.svg.svg)
[<img src='svg/ispeed-vecops-binary-add.svg' style='width:46%;'>](svg/ispeed-vecops-binary-add.svg.svg)

[<img src='svg/times-vecops-binary-sub.svg' style='width:46%;'>](svg/times-vecops-binary-sub.svg.svg)
[<img src='svg/ispeed-vecops-binary-sub.svg' style='width:46%;'>](svg/ispeed-vecops-binary-sub.svg.svg)

[<img src='svg/times-vecops-binary-mul.svg' style='width:46%;'>](svg/times-vecops-binary-mul.svg.svg)
[<img src='svg/ispeed-vecops-binary-mul.svg' style='width:46%;'>](svg/ispeed-vecops-binary-mul.svg.svg)

[<img src='svg/times-vecops-binary-div.svg' style='width:46%;'>](svg/times-vecops-binary-div.svg.svg)
[<img src='svg/ispeed-vecops-binary-div.svg' style='width:46%;'>](svg/ispeed-vecops-binary-div.svg.svg)

[<img src='svg/times-vecops-binary-fmod.svg' style='width:46%;'>](svg/times-vecops-binary-fmod.svg.svg)
[<img src='svg/ispeed-vecops-binary-fmod.svg' style='width:46%;'>](svg/ispeed-vecops-binary-fmod.svg.svg)

[<img src='svg/times-vecops-binary-pow.svg' style='width:46%;'>](svg/times-vecops-binary-pow.svg.svg)
[<img src='svg/ispeed-vecops-binary-pow.svg' style='width:46%;'>](svg/ispeed-vecops-binary-pow.svg.svg)

[<img src='svg/times-vecops-binary-atan2.svg' style='width:46%;'>](svg/times-vecops-binary-atan2.svg.svg)
[<img src='svg/ispeed-vecops-binary-atan2.svg' style='width:46%;'>](svg/ispeed-vecops-binary-atan2.svg.svg)

[<img src='svg/times-vecops-binary-hypot.svg' style='width:46%;'>](svg/times-vecops-binary-hypot.svg.svg)
[<img src='svg/ispeed-vecops-binary-hypot.svg' style='width:46%;'>](svg/ispeed-vecops-binary-hypot.svg.svg)

[<img src='svg/times-vecops-binary-fmax.svg' style='width:46%;'>](svg/times-vecops-binary-fmax.svg.svg)
[<img src='svg/ispeed-vecops-binary-fmax.svg' style='width:46%;'>](svg/ispeed-vecops-binary-fmax.svg.svg)

[<img src='svg/times-vecops-binary-fmin.svg' style='width:46%;'>](svg/times-vecops-binary-fmin.svg.svg)
[<img src='svg/ispeed-vecops-binary-fmin.svg' style='width:46%;'>](svg/ispeed-vecops-binary-fmin.svg.svg)

[<img src='svg/times-vecops-binary-eq.svg' style='width:46%;'>](svg/times-vecops-binary-eq.svg.svg)
[<img src='svg/ispeed-vecops-binary-eq.svg' style='width:46%;'>](svg/ispeed-vecops-binary-eq.svg.svg)

[<img src='svg/times-vecops-binary-ge.svg' style='width:46%;'>](svg/times-vecops-binary-ge.svg.svg)
[<img src='svg/ispeed-vecops-binary-ge.svg' style='width:46%;'>](svg/ispeed-vecops-binary-ge.svg.svg)

[<img src='svg/times-vecops-binary-gt.svg' style='width:46%;'>](svg/times-vecops-binary-gt.svg.svg)
[<img src='svg/ispeed-vecops-binary-gt.svg' style='width:46%;'>](svg/ispeed-vecops-binary-gt.svg.svg)

[<img src='svg/times-vecops-binary-le.svg' style='width:46%;'>](svg/times-vecops-binary-le.svg.svg)
[<img src='svg/ispeed-vecops-binary-le.svg' style='width:46%;'>](svg/ispeed-vecops-binary-le.svg.svg)

[<img src='svg/times-vecops-binary-lt.svg' style='width:46%;'>](svg/times-vecops-binary-lt.svg.svg)
[<img src='svg/ispeed-vecops-binary-lt.svg' style='width:46%;'>](svg/ispeed-vecops-binary-lt.svg.svg)

[<img src='svg/times-vecops-binary-ne.svg' style='width:46%;'>](svg/times-vecops-binary-ne.svg.svg)
[<img src='svg/ispeed-vecops-binary-ne.svg' style='width:46%;'>](svg/ispeed-vecops-binary-ne.svg.svg)