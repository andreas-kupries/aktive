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

[<img src='svg/times-vecops-unary-acos.svg' style='width:46%;'>](svg/times-vecops-unary-acos.svg)
[<img src='svg/ispeed-vecops-unary-acos.svg' style='width:46%;'>](svg/ispeed-vecops-unary-acos.svg)

[<img src='svg/times-vecops-unary-acosh.svg' style='width:46%;'>](svg/times-vecops-unary-acosh.svg)
[<img src='svg/ispeed-vecops-unary-acosh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-acosh.svg)

[<img src='svg/times-vecops-unary-asin.svg' style='width:46%;'>](svg/times-vecops-unary-asin.svg)
[<img src='svg/ispeed-vecops-unary-asin.svg' style='width:46%;'>](svg/ispeed-vecops-unary-asin.svg)

[<img src='svg/times-vecops-unary-asinh.svg' style='width:46%;'>](svg/times-vecops-unary-asinh.svg)
[<img src='svg/ispeed-vecops-unary-asinh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-asinh.svg)

[<img src='svg/times-vecops-unary-atan.svg' style='width:46%;'>](svg/times-vecops-unary-atan.svg)
[<img src='svg/ispeed-vecops-unary-atan.svg' style='width:46%;'>](svg/ispeed-vecops-unary-atan.svg)

[<img src='svg/times-vecops-unary-atanh.svg' style='width:46%;'>](svg/times-vecops-unary-atanh.svg)
[<img src='svg/ispeed-vecops-unary-atanh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-atanh.svg)

[<img src='svg/times-vecops-unary-cbrt.svg' style='width:46%;'>](svg/times-vecops-unary-cbrt.svg)
[<img src='svg/ispeed-vecops-unary-cbrt.svg' style='width:46%;'>](svg/ispeed-vecops-unary-cbrt.svg)

[<img src='svg/times-vecops-unary-ceil.svg' style='width:46%;'>](svg/times-vecops-unary-ceil.svg)
[<img src='svg/ispeed-vecops-unary-ceil.svg' style='width:46%;'>](svg/ispeed-vecops-unary-ceil.svg)

[<img src='svg/times-vecops-unary-clamp.svg' style='width:46%;'>](svg/times-vecops-unary-clamp.svg)
[<img src='svg/ispeed-vecops-unary-clamp.svg' style='width:46%;'>](svg/ispeed-vecops-unary-clamp.svg)

[<img src='svg/times-vecops-unary-cos.svg' style='width:46%;'>](svg/times-vecops-unary-cos.svg)
[<img src='svg/ispeed-vecops-unary-cos.svg' style='width:46%;'>](svg/ispeed-vecops-unary-cos.svg)

[<img src='svg/times-vecops-unary-cosh.svg' style='width:46%;'>](svg/times-vecops-unary-cosh.svg)
[<img src='svg/ispeed-vecops-unary-cosh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-cosh.svg)

[<img src='svg/times-vecops-unary-exp.svg' style='width:46%;'>](svg/times-vecops-unary-exp.svg)
[<img src='svg/ispeed-vecops-unary-exp.svg' style='width:46%;'>](svg/ispeed-vecops-unary-exp.svg)

[<img src='svg/times-vecops-unary-exp10.svg' style='width:46%;'>](svg/times-vecops-unary-exp10.svg)
[<img src='svg/ispeed-vecops-unary-exp10.svg' style='width:46%;'>](svg/ispeed-vecops-unary-exp10.svg)

[<img src='svg/times-vecops-unary-exp2.svg' style='width:46%;'>](svg/times-vecops-unary-exp2.svg)
[<img src='svg/ispeed-vecops-unary-exp2.svg' style='width:46%;'>](svg/ispeed-vecops-unary-exp2.svg)

[<img src='svg/times-vecops-unary-fabs.svg' style='width:46%;'>](svg/times-vecops-unary-fabs.svg)
[<img src='svg/ispeed-vecops-unary-fabs.svg' style='width:46%;'>](svg/ispeed-vecops-unary-fabs.svg)

[<img src='svg/times-vecops-unary-floor.svg' style='width:46%;'>](svg/times-vecops-unary-floor.svg)
[<img src='svg/ispeed-vecops-unary-floor.svg' style='width:46%;'>](svg/ispeed-vecops-unary-floor.svg)

[<img src='svg/times-vecops-unary-gamma_compress.svg' style='width:46%;'>](svg/times-vecops-unary-gamma_compress.svg)
[<img src='svg/ispeed-vecops-unary-gamma_compress.svg' style='width:46%;'>](svg/ispeed-vecops-unary-gamma_compress.svg)

[<img src='svg/times-vecops-unary-gamma_expand.svg' style='width:46%;'>](svg/times-vecops-unary-gamma_expand.svg)
[<img src='svg/ispeed-vecops-unary-gamma_expand.svg' style='width:46%;'>](svg/ispeed-vecops-unary-gamma_expand.svg)

[<img src='svg/times-vecops-unary-invert.svg' style='width:46%;'>](svg/times-vecops-unary-invert.svg)
[<img src='svg/ispeed-vecops-unary-invert.svg' style='width:46%;'>](svg/ispeed-vecops-unary-invert.svg)

[<img src='svg/times-vecops-unary-log.svg' style='width:46%;'>](svg/times-vecops-unary-log.svg)
[<img src='svg/ispeed-vecops-unary-log.svg' style='width:46%;'>](svg/ispeed-vecops-unary-log.svg)

[<img src='svg/times-vecops-unary-log10.svg' style='width:46%;'>](svg/times-vecops-unary-log10.svg)
[<img src='svg/ispeed-vecops-unary-log10.svg' style='width:46%;'>](svg/ispeed-vecops-unary-log10.svg)

[<img src='svg/times-vecops-unary-log2.svg' style='width:46%;'>](svg/times-vecops-unary-log2.svg)
[<img src='svg/ispeed-vecops-unary-log2.svg' style='width:46%;'>](svg/ispeed-vecops-unary-log2.svg)

[<img src='svg/times-vecops-unary-neg.svg' style='width:46%;'>](svg/times-vecops-unary-neg.svg)
[<img src='svg/ispeed-vecops-unary-neg.svg' style='width:46%;'>](svg/ispeed-vecops-unary-neg.svg)

[<img src='svg/times-vecops-unary-not.svg' style='width:46%;'>](svg/times-vecops-unary-not.svg)
[<img src='svg/ispeed-vecops-unary-not.svg' style='width:46%;'>](svg/ispeed-vecops-unary-not.svg)

[<img src='svg/times-vecops-unary-reciprocal.svg' style='width:46%;'>](svg/times-vecops-unary-reciprocal.svg)
[<img src='svg/ispeed-vecops-unary-reciprocal.svg' style='width:46%;'>](svg/ispeed-vecops-unary-reciprocal.svg)

[<img src='svg/times-vecops-unary-round.svg' style='width:46%;'>](svg/times-vecops-unary-round.svg)
[<img src='svg/ispeed-vecops-unary-round.svg' style='width:46%;'>](svg/ispeed-vecops-unary-round.svg)

[<img src='svg/times-vecops-unary-sign.svg' style='width:46%;'>](svg/times-vecops-unary-sign.svg)
[<img src='svg/ispeed-vecops-unary-sign.svg' style='width:46%;'>](svg/ispeed-vecops-unary-sign.svg)

[<img src='svg/times-vecops-unary-signb.svg' style='width:46%;'>](svg/times-vecops-unary-signb.svg)
[<img src='svg/ispeed-vecops-unary-signb.svg' style='width:46%;'>](svg/ispeed-vecops-unary-signb.svg)

[<img src='svg/times-vecops-unary-sin.svg' style='width:46%;'>](svg/times-vecops-unary-sin.svg)
[<img src='svg/ispeed-vecops-unary-sin.svg' style='width:46%;'>](svg/ispeed-vecops-unary-sin.svg)

[<img src='svg/times-vecops-unary-sinh.svg' style='width:46%;'>](svg/times-vecops-unary-sinh.svg)
[<img src='svg/ispeed-vecops-unary-sinh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-sinh.svg)

[<img src='svg/times-vecops-unary-sqrt.svg' style='width:46%;'>](svg/times-vecops-unary-sqrt.svg)
[<img src='svg/ispeed-vecops-unary-sqrt.svg' style='width:46%;'>](svg/ispeed-vecops-unary-sqrt.svg)

[<img src='svg/times-vecops-unary-square.svg' style='width:46%;'>](svg/times-vecops-unary-square.svg)
[<img src='svg/ispeed-vecops-unary-square.svg' style='width:46%;'>](svg/ispeed-vecops-unary-square.svg)

[<img src='svg/times-vecops-unary-tan.svg' style='width:46%;'>](svg/times-vecops-unary-tan.svg)
[<img src='svg/ispeed-vecops-unary-tan.svg' style='width:46%;'>](svg/ispeed-vecops-unary-tan.svg)

[<img src='svg/times-vecops-unary-tanh.svg' style='width:46%;'>](svg/times-vecops-unary-tanh.svg)
[<img src='svg/ispeed-vecops-unary-tanh.svg' style='width:46%;'>](svg/ispeed-vecops-unary-tanh.svg)

[<img src='svg/times-vecops-unary-wrap.svg' style='width:46%;'>](svg/times-vecops-unary-wrap.svg)
[<img src='svg/ispeed-vecops-unary-wrap.svg' style='width:46%;'>](svg/ispeed-vecops-unary-wrap.svg)

[<img src='svg/times-vecops-unary-atan2.svg' style='width:46%;'>](svg/times-vecops-unary-atan2.svg)
[<img src='svg/ispeed-vecops-unary-atan2.svg' style='width:46%;'>](svg/ispeed-vecops-unary-atan2.svg)

[<img src='svg/times-vecops-unary-eq.svg' style='width:46%;'>](svg/times-vecops-unary-eq.svg)
[<img src='svg/ispeed-vecops-unary-eq.svg' style='width:46%;'>](svg/ispeed-vecops-unary-eq.svg)

[<img src='svg/times-vecops-unary-expx.svg' style='width:46%;'>](svg/times-vecops-unary-expx.svg)
[<img src='svg/ispeed-vecops-unary-expx.svg' style='width:46%;'>](svg/ispeed-vecops-unary-expx.svg)

[<img src='svg/times-vecops-unary-fmax.svg' style='width:46%;'>](svg/times-vecops-unary-fmax.svg)
[<img src='svg/ispeed-vecops-unary-fmax.svg' style='width:46%;'>](svg/ispeed-vecops-unary-fmax.svg)

[<img src='svg/times-vecops-unary-fmin.svg' style='width:46%;'>](svg/times-vecops-unary-fmin.svg)
[<img src='svg/ispeed-vecops-unary-fmin.svg' style='width:46%;'>](svg/ispeed-vecops-unary-fmin.svg)

[<img src='svg/times-vecops-unary-fmod.svg' style='width:46%;'>](svg/times-vecops-unary-fmod.svg)
[<img src='svg/ispeed-vecops-unary-fmod.svg' style='width:46%;'>](svg/ispeed-vecops-unary-fmod.svg)

[<img src='svg/times-vecops-unary-ge.svg' style='width:46%;'>](svg/times-vecops-unary-ge.svg)
[<img src='svg/ispeed-vecops-unary-ge.svg' style='width:46%;'>](svg/ispeed-vecops-unary-ge.svg)

[<img src='svg/times-vecops-unary-gt.svg' style='width:46%;'>](svg/times-vecops-unary-gt.svg)
[<img src='svg/ispeed-vecops-unary-gt.svg' style='width:46%;'>](svg/ispeed-vecops-unary-gt.svg)

[<img src='svg/times-vecops-unary-hypot.svg' style='width:46%;'>](svg/times-vecops-unary-hypot.svg)
[<img src='svg/ispeed-vecops-unary-hypot.svg' style='width:46%;'>](svg/ispeed-vecops-unary-hypot.svg)

[<img src='svg/times-vecops-unary-le.svg' style='width:46%;'>](svg/times-vecops-unary-le.svg)
[<img src='svg/ispeed-vecops-unary-le.svg' style='width:46%;'>](svg/ispeed-vecops-unary-le.svg)

[<img src='svg/times-vecops-unary-lt.svg' style='width:46%;'>](svg/times-vecops-unary-lt.svg)
[<img src='svg/ispeed-vecops-unary-lt.svg' style='width:46%;'>](svg/ispeed-vecops-unary-lt.svg)

[<img src='svg/times-vecops-unary-ne.svg' style='width:46%;'>](svg/times-vecops-unary-ne.svg)
[<img src='svg/ispeed-vecops-unary-ne.svg' style='width:46%;'>](svg/ispeed-vecops-unary-ne.svg)

[<img src='svg/times-vecops-unary-nshift.svg' style='width:46%;'>](svg/times-vecops-unary-nshift.svg)
[<img src='svg/ispeed-vecops-unary-nshift.svg' style='width:46%;'>](svg/ispeed-vecops-unary-nshift.svg)

[<img src='svg/times-vecops-unary-pow.svg' style='width:46%;'>](svg/times-vecops-unary-pow.svg)
[<img src='svg/ispeed-vecops-unary-pow.svg' style='width:46%;'>](svg/ispeed-vecops-unary-pow.svg)

[<img src='svg/times-vecops-unary-ratan2.svg' style='width:46%;'>](svg/times-vecops-unary-ratan2.svg)
[<img src='svg/ispeed-vecops-unary-ratan2.svg' style='width:46%;'>](svg/ispeed-vecops-unary-ratan2.svg)

[<img src='svg/times-vecops-unary-rfmod.svg' style='width:46%;'>](svg/times-vecops-unary-rfmod.svg)
[<img src='svg/ispeed-vecops-unary-rfmod.svg' style='width:46%;'>](svg/ispeed-vecops-unary-rfmod.svg)

[<img src='svg/times-vecops-unary-rscale.svg' style='width:46%;'>](svg/times-vecops-unary-rscale.svg)
[<img src='svg/ispeed-vecops-unary-rscale.svg' style='width:46%;'>](svg/ispeed-vecops-unary-rscale.svg)

[<img src='svg/times-vecops-unary-scale.svg' style='width:46%;'>](svg/times-vecops-unary-scale.svg)
[<img src='svg/ispeed-vecops-unary-scale.svg' style='width:46%;'>](svg/ispeed-vecops-unary-scale.svg)

[<img src='svg/times-vecops-unary-shift.svg' style='width:46%;'>](svg/times-vecops-unary-shift.svg)
[<img src='svg/ispeed-vecops-unary-shift.svg' style='width:46%;'>](svg/ispeed-vecops-unary-shift.svg)

[<img src='svg/times-vecops-unary-sol.svg' style='width:46%;'>](svg/times-vecops-unary-sol.svg)
[<img src='svg/ispeed-vecops-unary-sol.svg' style='width:46%;'>](svg/ispeed-vecops-unary-sol.svg)

[<img src='svg/times-vecops-unary-inside_cc.svg' style='width:46%;'>](svg/times-vecops-unary-inside_cc.svg)
[<img src='svg/ispeed-vecops-unary-inside_cc.svg' style='width:46%;'>](svg/ispeed-vecops-unary-inside_cc.svg)

[<img src='svg/times-vecops-unary-inside_co.svg' style='width:46%;'>](svg/times-vecops-unary-inside_co.svg)
[<img src='svg/ispeed-vecops-unary-inside_co.svg' style='width:46%;'>](svg/ispeed-vecops-unary-inside_co.svg)

[<img src='svg/times-vecops-unary-inside_oc.svg' style='width:46%;'>](svg/times-vecops-unary-inside_oc.svg)
[<img src='svg/ispeed-vecops-unary-inside_oc.svg' style='width:46%;'>](svg/ispeed-vecops-unary-inside_oc.svg)

[<img src='svg/times-vecops-unary-inside_oo.svg' style='width:46%;'>](svg/times-vecops-unary-inside_oo.svg)
[<img src='svg/ispeed-vecops-unary-inside_oo.svg' style='width:46%;'>](svg/ispeed-vecops-unary-inside_oo.svg)

[<img src='svg/times-vecops-unary-outside_cc.svg' style='width:46%;'>](svg/times-vecops-unary-outside_cc.svg)
[<img src='svg/ispeed-vecops-unary-outside_cc.svg' style='width:46%;'>](svg/ispeed-vecops-unary-outside_cc.svg)

[<img src='svg/times-vecops-unary-outside_co.svg' style='width:46%;'>](svg/times-vecops-unary-outside_co.svg)
[<img src='svg/ispeed-vecops-unary-outside_co.svg' style='width:46%;'>](svg/ispeed-vecops-unary-outside_co.svg)

[<img src='svg/times-vecops-unary-outside_oc.svg' style='width:46%;'>](svg/times-vecops-unary-outside_oc.svg)
[<img src='svg/ispeed-vecops-unary-outside_oc.svg' style='width:46%;'>](svg/ispeed-vecops-unary-outside_oc.svg)

[<img src='svg/times-vecops-unary-outside_oo.svg' style='width:46%;'>](svg/times-vecops-unary-outside_oo.svg)
[<img src='svg/ispeed-vecops-unary-outside_oo.svg' style='width:46%;'>](svg/ispeed-vecops-unary-outside_oo.svg)

[<img src='svg/times-vecops-binary-and.svg' style='width:46%;'>](svg/times-vecops-binary-and.svg)
[<img src='svg/ispeed-vecops-binary-and.svg' style='width:46%;'>](svg/ispeed-vecops-binary-and.svg)

[<img src='svg/times-vecops-binary-nand.svg' style='width:46%;'>](svg/times-vecops-binary-nand.svg)
[<img src='svg/ispeed-vecops-binary-nand.svg' style='width:46%;'>](svg/ispeed-vecops-binary-nand.svg)

[<img src='svg/times-vecops-binary-nor.svg' style='width:46%;'>](svg/times-vecops-binary-nor.svg)
[<img src='svg/ispeed-vecops-binary-nor.svg' style='width:46%;'>](svg/ispeed-vecops-binary-nor.svg)

[<img src='svg/times-vecops-binary-or.svg' style='width:46%;'>](svg/times-vecops-binary-or.svg)
[<img src='svg/ispeed-vecops-binary-or.svg' style='width:46%;'>](svg/ispeed-vecops-binary-or.svg)

[<img src='svg/times-vecops-binary-xor.svg' style='width:46%;'>](svg/times-vecops-binary-xor.svg)
[<img src='svg/ispeed-vecops-binary-xor.svg' style='width:46%;'>](svg/ispeed-vecops-binary-xor.svg)

[<img src='svg/times-vecops-binary-add.svg' style='width:46%;'>](svg/times-vecops-binary-add.svg)
[<img src='svg/ispeed-vecops-binary-add.svg' style='width:46%;'>](svg/ispeed-vecops-binary-add.svg)

[<img src='svg/times-vecops-binary-sub.svg' style='width:46%;'>](svg/times-vecops-binary-sub.svg)
[<img src='svg/ispeed-vecops-binary-sub.svg' style='width:46%;'>](svg/ispeed-vecops-binary-sub.svg)

[<img src='svg/times-vecops-binary-mul.svg' style='width:46%;'>](svg/times-vecops-binary-mul.svg)
[<img src='svg/ispeed-vecops-binary-mul.svg' style='width:46%;'>](svg/ispeed-vecops-binary-mul.svg)

[<img src='svg/times-vecops-binary-div.svg' style='width:46%;'>](svg/times-vecops-binary-div.svg)
[<img src='svg/ispeed-vecops-binary-div.svg' style='width:46%;'>](svg/ispeed-vecops-binary-div.svg)

[<img src='svg/times-vecops-binary-fmod.svg' style='width:46%;'>](svg/times-vecops-binary-fmod.svg)
[<img src='svg/ispeed-vecops-binary-fmod.svg' style='width:46%;'>](svg/ispeed-vecops-binary-fmod.svg)

[<img src='svg/times-vecops-binary-pow.svg' style='width:46%;'>](svg/times-vecops-binary-pow.svg)
[<img src='svg/ispeed-vecops-binary-pow.svg' style='width:46%;'>](svg/ispeed-vecops-binary-pow.svg)

[<img src='svg/times-vecops-binary-atan2.svg' style='width:46%;'>](svg/times-vecops-binary-atan2.svg)
[<img src='svg/ispeed-vecops-binary-atan2.svg' style='width:46%;'>](svg/ispeed-vecops-binary-atan2.svg)

[<img src='svg/times-vecops-binary-hypot.svg' style='width:46%;'>](svg/times-vecops-binary-hypot.svg)
[<img src='svg/ispeed-vecops-binary-hypot.svg' style='width:46%;'>](svg/ispeed-vecops-binary-hypot.svg)

[<img src='svg/times-vecops-binary-fmax.svg' style='width:46%;'>](svg/times-vecops-binary-fmax.svg)
[<img src='svg/ispeed-vecops-binary-fmax.svg' style='width:46%;'>](svg/ispeed-vecops-binary-fmax.svg)

[<img src='svg/times-vecops-binary-fmin.svg' style='width:46%;'>](svg/times-vecops-binary-fmin.svg)
[<img src='svg/ispeed-vecops-binary-fmin.svg' style='width:46%;'>](svg/ispeed-vecops-binary-fmin.svg)

[<img src='svg/times-vecops-binary-eq.svg' style='width:46%;'>](svg/times-vecops-binary-eq.svg)
[<img src='svg/ispeed-vecops-binary-eq.svg' style='width:46%;'>](svg/ispeed-vecops-binary-eq.svg)

[<img src='svg/times-vecops-binary-ge.svg' style='width:46%;'>](svg/times-vecops-binary-ge.svg)
[<img src='svg/ispeed-vecops-binary-ge.svg' style='width:46%;'>](svg/ispeed-vecops-binary-ge.svg)

[<img src='svg/times-vecops-binary-gt.svg' style='width:46%;'>](svg/times-vecops-binary-gt.svg)
[<img src='svg/ispeed-vecops-binary-gt.svg' style='width:46%;'>](svg/ispeed-vecops-binary-gt.svg)

[<img src='svg/times-vecops-binary-le.svg' style='width:46%;'>](svg/times-vecops-binary-le.svg)
[<img src='svg/ispeed-vecops-binary-le.svg' style='width:46%;'>](svg/ispeed-vecops-binary-le.svg)

[<img src='svg/times-vecops-binary-lt.svg' style='width:46%;'>](svg/times-vecops-binary-lt.svg)
[<img src='svg/ispeed-vecops-binary-lt.svg' style='width:46%;'>](svg/ispeed-vecops-binary-lt.svg)

[<img src='svg/times-vecops-binary-ne.svg' style='width:46%;'>](svg/times-vecops-binary-ne.svg)
[<img src='svg/ispeed-vecops-binary-ne.svg' style='width:46%;'>](svg/ispeed-vecops-binary-ne.svg)