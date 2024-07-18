# Documentation -- Reference Pages -- transform math n-ary logical

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [transform math n-ary](transform_math_nary.md) ↗


### Operators

 - [aktive op math and](#op_math_and)
 - [aktive op math or](#op_math_or)
 - [aktive op math xor](#op_math_xor)

## Operators

---
### <a name='op_math_and'></a> aktive op math and

Syntax: __aktive op math and__ srcs...

As a logical operation the inputs are trivially thresholded at 0.5. Values <= 0.5 are seen as false, else as true.

Returns image aggregated from the application of the associative binary operation 'A && B' to all shared pixels of all the inputs.


---
### <a name='op_math_or'></a> aktive op math or

Syntax: __aktive op math or__ srcs...

As a logical operation the inputs are trivially thresholded at 0.5. Values <= 0.5 are seen as false, else as true.

Returns image aggregated from the application of the associative binary operation 'A || B' to all shared pixels of all the inputs.


---
### <a name='op_math_xor'></a> aktive op math xor

Syntax: __aktive op math xor__ srcs...

As a logical operation the inputs are trivially thresholded at 0.5. Values <= 0.5 are seen as false, else as true.

Returns image aggregated from the application of the associative binary operation 'A ^^ B' to all shared pixels of all the inputs.


