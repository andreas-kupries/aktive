<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform math binary

## <anchor='top'> Table Of Contents

  - [transform math](transform_math.md) ↗


## Subsections


 - [transform math binary logical](transform_math_binary_logical.md) ↘

### Operators

 - [aktive op math atan2](#op_math_atan2)
 - [aktive op math difference](#op_math_difference)
 - [aktive op math div](#op_math_div)
 - [aktive op math eq](#op_math_eq)
 - [aktive op math ge](#op_math_ge)
 - [aktive op math gt](#op_math_gt)
 - [aktive op math hypot](#op_math_hypot)
 - [aktive op math le](#op_math_le)
 - [aktive op math lt](#op_math_lt)
 - [aktive op math mod](#op_math_mod)
 - [aktive op math ne](#op_math_ne)
 - [aktive op math pow](#op_math_pow)
 - [aktive op math screen](#op_math_screen)
 - [aktive op math sub](#op_math_sub)

## Operators

---
### [↑](#top) <a name='op_math_atan2'></a> aktive op math atan2

Syntax: __aktive op math atan2__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `atan2(A, B)` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_difference'></a> aktive op math difference

Syntax: __aktive op math difference__ a b [[→ definition](/file?ci=trunk&ln=8&name=etc/transformer/math/binary.tcl)]

Returns image holding the absolute difference `abs(A-B)` of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_div'></a> aktive op math div

Syntax: __aktive op math div__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `A / B` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_eq'></a> aktive op math eq

Syntax: __aktive op math eq__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `A == B` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_ge'></a> aktive op math ge

Syntax: __aktive op math ge__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `A >= B` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_gt'></a> aktive op math gt

Syntax: __aktive op math gt__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `A > B` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_hypot'></a> aktive op math hypot

Syntax: __aktive op math hypot__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `hypot (A, B)` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_le'></a> aktive op math le

Syntax: __aktive op math le__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `A <= B` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_lt'></a> aktive op math lt

Syntax: __aktive op math lt__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `A < B` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_mod'></a> aktive op math mod

Syntax: __aktive op math mod__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `A % B` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_ne'></a> aktive op math ne

Syntax: __aktive op math ne__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `A != B` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_pow'></a> aktive op math pow

Syntax: __aktive op math pow__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `pow (A, B)` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_screen'></a> aktive op math screen

Syntax: __aktive op math screen__ a b [[→ definition](/file?ci=trunk&ln=21&name=etc/transformer/math/binary.tcl)]

Returns image holding the `screen(A,B) = A+B-A*B = A*(1-B)+B` of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

---
### [↑](#top) <a name='op_math_sub'></a> aktive op math sub

Syntax: __aktive op math sub__ a b [[→ definition](/file?ci=trunk&ln=46&name=etc/transformer/math/binary.tcl)]

Returns image with the binary operation `A - B` applied to all shared pixels of the two inputs.

The result geometry is the intersection of the inputs.

|Input|Description|
|:---|:---|
|a|Image A|
|b|Image B|

