# Documentation -- Reference Pages -- transform math unary logical

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [transform math unary](transform_math_unary.md) ↗


### Operators

 - [aktive op math1 not](#op_math1_not)

## Operators

---
### <a name='op_math1_not'></a> aktive op math1 not

Syntax: __aktive op math1 not__ src

Returns image with the unary function '!I' applied to all pixels of the input.

The resulting image has the same geometry as the input.

As a logical operation the input image is implicitly trivially thresholded at 0.5. Values <= 0.5 are seen as false, else as true.


