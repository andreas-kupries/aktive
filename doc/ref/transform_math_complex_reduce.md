# Documentation -- Reference Pages -- transform math complex reduce

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

||||||||
|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](index.md#sectree)|[Permuted Sections ↘](bypsections.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypnames.md)|[Implementations ↘](bylang.md)|

## Table Of Contents

  - [transform math complex](transform_math_complex.md) ↗


### Operators

 - [aktive op cmath abs](#op_cmath_abs)
 - [aktive op cmath arg](#op_cmath_arg)
 - [aktive op cmath imaginary](#op_cmath_imaginary)
 - [aktive op cmath real](#op_cmath_real)
 - [aktive op cmath sqabs](#op_cmath_sqabs)

## Operators

---
### <a name='op_cmath_abs'></a> aktive op cmath abs

Syntax: __aktive op cmath abs__ src

Returns single-band image with the complex unary reduction function 'abs(I)' applied to all pixels of the complex-valued input.

The result geometry is the same as the input, except for depth, which becomes 1.


---
### <a name='op_cmath_arg'></a> aktive op cmath arg

Syntax: __aktive op cmath arg__ src

Returns single-band image with the complex unary reduction function 'phase-angle(I)' applied to all pixels of the complex-valued input.

The result geometry is the same as the input, except for depth, which becomes 1.


---
### <a name='op_cmath_imaginary'></a> aktive op cmath imaginary

Syntax: __aktive op cmath imaginary__ src

Returns single-band image containing the imaginary part of the complex-valued input.


---
### <a name='op_cmath_real'></a> aktive op cmath real

Syntax: __aktive op cmath real__ src

Returns single-band image containing the real part of the complex-valued input.


---
### <a name='op_cmath_sqabs'></a> aktive op cmath sqabs

Syntax: __aktive op cmath sqabs__ src

Returns single-band image with the complex unary reduction function 'abs^2(I)' applied to all pixels of the complex-valued input.

The result geometry is the same as the input, except for depth, which becomes 1.


