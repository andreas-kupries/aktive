<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform math n-ary

## <anchor='top'> Table Of Contents

  - [transform math](transform_math.md) ↗


## Subsections


 - [transform math n-ary logical](transform_math_nary_logical.md) ↘

### Operators

 - [aktive op math add](#op_math_add)
 - [aktive op math max](#op_math_max)
 - [aktive op math min](#op_math_min)
 - [aktive op math mul](#op_math_mul)

## Operators

---
### [↑](#top) <a name='op_math_add'></a> aktive op math add

Syntax: __aktive op math add__ srcs... [[→ definition](/file?ci=trunk&ln=106&name=etc/transformer/math/binary.tcl)]

Returns image aggregated from the application of the associative binary operation `A + B` to all shared pixels of all the inputs.

|Input|Description|
|:---|:---|
|args...|Source images|

---
### [↑](#top) <a name='op_math_max'></a> aktive op math max

Syntax: __aktive op math max__ srcs... [[→ definition](/file?ci=trunk&ln=106&name=etc/transformer/math/binary.tcl)]

Returns image aggregated from the application of the associative binary operation `max(A, B)` to all shared pixels of all the inputs.

|Input|Description|
|:---|:---|
|args...|Source images|

---
### [↑](#top) <a name='op_math_min'></a> aktive op math min

Syntax: __aktive op math min__ srcs... [[→ definition](/file?ci=trunk&ln=106&name=etc/transformer/math/binary.tcl)]

Returns image aggregated from the application of the associative binary operation `min(A, B)` to all shared pixels of all the inputs.

|Input|Description|
|:---|:---|
|args...|Source images|

---
### [↑](#top) <a name='op_math_mul'></a> aktive op math mul

Syntax: __aktive op math mul__ srcs... [[→ definition](/file?ci=trunk&ln=106&name=etc/transformer/math/binary.tcl)]

Returns image aggregated from the application of the associative binary operation `A * B` to all shared pixels of all the inputs.

|Input|Description|
|:---|:---|
|args...|Source images|

