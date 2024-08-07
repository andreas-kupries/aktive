<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform math

## Table Of Contents

  - [transform](transform.md) ↗


## Subsections


 - [transform math binary](transform_math_binary.md) ↘
 - [transform math n-ary](transform_math_nary.md) ↘
 - [transform math unary](transform_math_unary.md) ↘

### Operators

 - [aktive op math linear](#op_math_linear)

## Operators

---
### <a name='op_math_linear'></a> aktive op math linear

Syntax: __aktive op math linear__ src0 src1 src2

Blends first and second input under control of the third.

As an equation: `result = A + T*(B-A)`.

All inputs are extended to matching depth.

- The images to blend are extended with black/zeros.

- The blend factors replicate their last band.

The other dimensions of the inputs, i.e. width and height, have to match. An error is thrown if they don't.


