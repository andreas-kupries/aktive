# transform math binary logical

||||||||
|---|---|---|---|---|---|---|
|[Home ↗](/)|[Main ↗](index.md)|[Sections](index.md#sectree)|[Permuted Sections](bypsections.md)|[Names](byname.md)|[Permuted Names](bypnames.md)|[Implementations](bylang.md)|

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

