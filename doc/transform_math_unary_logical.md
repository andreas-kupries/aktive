# transform math unary logical
## transform math unary logical - Table Of Contents

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


