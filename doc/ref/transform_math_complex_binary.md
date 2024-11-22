<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform math complex binary

## Table Of Contents

  - [transform math complex](transform_math_complex.md) ↗


### Operators

 - [aktive op cmath add](#op_cmath_add)
 - [aktive op cmath cons](#op_cmath_cons)
 - [aktive op cmath div](#op_cmath_div)
 - [aktive op cmath mul](#op_cmath_mul)
 - [aktive op cmath pow](#op_cmath_pow)
 - [aktive op cmath sub](#op_cmath_sub)

## Operators

---
### <a name='op_cmath_add'></a> aktive op cmath add

Syntax: __aktive op cmath add__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=8&name=etc/transformer/math/complex/binary.tcl)]

Returns complex-valued image with the complex-valued binary operation 'A + B' applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.


---
### <a name='op_cmath_cons'></a> aktive op cmath cons

Syntax: __aktive op cmath cons__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=41&name=etc/transformer/math/complex/unary.tcl)]

Returns complex-valued image constructed from the 2 single-band inputs. First input becomes the real part, second the imaginary.


---
### <a name='op_cmath_div'></a> aktive op cmath div

Syntax: __aktive op cmath div__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=8&name=etc/transformer/math/complex/binary.tcl)]

Returns complex-valued image with the complex-valued binary operation 'A / B' applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.


---
### <a name='op_cmath_mul'></a> aktive op cmath mul

Syntax: __aktive op cmath mul__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=8&name=etc/transformer/math/complex/binary.tcl)]

Returns complex-valued image with the complex-valued binary operation 'A * B' applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.


---
### <a name='op_cmath_pow'></a> aktive op cmath pow

Syntax: __aktive op cmath pow__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=8&name=etc/transformer/math/complex/binary.tcl)]

Returns complex-valued image with the complex-valued binary operation 'pow(A, B)' applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.


---
### <a name='op_cmath_sub'></a> aktive op cmath sub

Syntax: __aktive op cmath sub__ src0 src1 [[→ definition](../../../../file?ci=trunk&ln=8&name=etc/transformer/math/complex/binary.tcl)]

Returns complex-valued image with the complex-valued binary operation 'A - B' applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.


