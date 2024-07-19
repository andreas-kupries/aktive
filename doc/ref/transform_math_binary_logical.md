<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform math binary logical

## Table Of Contents

  - [transform math binary](transform_math_binary.md) ↗


### Operators

 - [aktive op math nand](#op_math_nand)
 - [aktive op math nor](#op_math_nor)

## Operators

---
### <a name='op_math_nand'></a> aktive op math nand

Syntax: __aktive op math nand__ src0 src1

Returns image with the binary operation '!(A && B)' applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

As a logical operation the inputs are trivially thresholded at 0.5. Values <= 0.5 are seen as false, else as true.


---
### <a name='op_math_nor'></a> aktive op math nor

Syntax: __aktive op math nor__ src0 src1

Returns image with the binary operation '!(A || B)' applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

As a logical operation the inputs are trivially thresholded at 0.5. Values <= 0.5 are seen as false, else as true.


