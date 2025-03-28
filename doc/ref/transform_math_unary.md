<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform math unary

## <anchor='top'> Table Of Contents

  - [transform math](transform_math.md) ↗


## Subsections


 - [transform math unary logical](transform_math_unary_logical.md) ↘

### Operators

 - [aktive op math1 abs](#op_math1_abs)
 - [aktive op math1 acos](#op_math1_acos)
 - [aktive op math1 acosh](#op_math1_acosh)
 - [aktive op math1 asin](#op_math1_asin)
 - [aktive op math1 asinh](#op_math1_asinh)
 - [aktive op math1 atan](#op_math1_atan)
 - [aktive op math1 atan2](#op_math1_atan2)
 - [aktive op math1 atan2b](#op_math1_atan2b)
 - [aktive op math1 atanh](#op_math1_atanh)
 - [aktive op math1 cbrt](#op_math1_cbrt)
 - [aktive op math1 ceil](#op_math1_ceil)
 - [aktive op math1 clamp](#op_math1_clamp)
 - [aktive op math1 cos](#op_math1_cos)
 - [aktive op math1 cosh](#op_math1_cosh)
 - [aktive op math1 eq](#op_math1_eq)
 - [aktive op math1 exp](#op_math1_exp)
 - [aktive op math1 exp2](#op_math1_exp2)
 - [aktive op math1 exp10](#op_math1_exp10)
 - [aktive op math1 expx](#op_math1_expx)
 - [aktive op math1 fit mean-stddev](#op_math1_fit_mean_stddev)
 - [aktive op math1 fit min-max](#op_math1_fit_min_max)
 - [aktive op math1 fit stretch](#op_math1_fit_stretch)
 - [aktive op math1 floor](#op_math1_floor)
 - [aktive op math1 gamma compress](#op_math1_gamma_compress)
 - [aktive op math1 gamma expand](#op_math1_gamma_expand)
 - [aktive op math1 ge](#op_math1_ge)
 - [aktive op math1 gt](#op_math1_gt)
 - [aktive op math1 hypot](#op_math1_hypot)
 - [aktive op math1 inside-cc](#op_math1_inside_cc)
 - [aktive op math1 inside-co](#op_math1_inside_co)
 - [aktive op math1 inside-oc](#op_math1_inside_oc)
 - [aktive op math1 inside-oo](#op_math1_inside_oo)
 - [aktive op math1 invert](#op_math1_invert)
 - [aktive op math1 le](#op_math1_le)
 - [aktive op math1 linear](#op_math1_linear)
 - [aktive op math1 log](#op_math1_log)
 - [aktive op math1 log2](#op_math1_log2)
 - [aktive op math1 log10](#op_math1_log10)
 - [aktive op math1 lt](#op_math1_lt)
 - [aktive op math1 max](#op_math1_max)
 - [aktive op math1 min](#op_math1_min)
 - [aktive op math1 mod](#op_math1_mod)
 - [aktive op math1 modb](#op_math1_modb)
 - [aktive op math1 ne](#op_math1_ne)
 - [aktive op math1 neg](#op_math1_neg)
 - [aktive op math1 neg-shift](#op_math1_neg_shift)
 - [aktive op math1 outside-cc](#op_math1_outside_cc)
 - [aktive op math1 outside-co](#op_math1_outside_co)
 - [aktive op math1 outside-oc](#op_math1_outside_oc)
 - [aktive op math1 outside-oo](#op_math1_outside_oo)
 - [aktive op math1 pow](#op_math1_pow)
 - [aktive op math1 reciproc](#op_math1_reciproc)
 - [aktive op math1 reciproc-scale](#op_math1_reciproc_scale)
 - [aktive op math1 round](#op_math1_round)
 - [aktive op math1 scale](#op_math1_scale)
 - [aktive op math1 shift](#op_math1_shift)
 - [aktive op math1 sign](#op_math1_sign)
 - [aktive op math1 sign*](#op_math1_sign*)
 - [aktive op math1 sin](#op_math1_sin)
 - [aktive op math1 sinh](#op_math1_sinh)
 - [aktive op math1 solarize](#op_math1_solarize)
 - [aktive op math1 sqrt](#op_math1_sqrt)
 - [aktive op math1 square](#op_math1_square)
 - [aktive op math1 tan](#op_math1_tan)
 - [aktive op math1 tanh](#op_math1_tanh)
 - [aktive op math1 wrap](#op_math1_wrap)

## Operators

---
### [↑](#top) <a name='op_math1_abs'></a> aktive op math1 abs

Syntax: __aktive op math1 abs__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `abs(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_acos'></a> aktive op math1 acos

Syntax: __aktive op math1 acos__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `acos(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_acosh'></a> aktive op math1 acosh

Syntax: __aktive op math1 acosh__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `acosh(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_asin'></a> aktive op math1 asin

Syntax: __aktive op math1 asin__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `asin(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_asinh'></a> aktive op math1 asinh

Syntax: __aktive op math1 asinh__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `asinh(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_atan'></a> aktive op math1 atan

Syntax: __aktive op math1 atan__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `atan(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_atan2'></a> aktive op math1 atan2

Syntax: __aktive op math1 atan2__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `atan2(I,x)` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|double||Atan by scalar x|

---
### [↑](#top) <a name='op_math1_atan2b'></a> aktive op math1 atan2b

Syntax: __aktive op math1 atan2b__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `atan2(y,I)` applied to all pixels of the input.

The image is the first argument of the command, even if not of the function

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|y|double||Atan by scalar y|

---
### [↑](#top) <a name='op_math1_atanh'></a> aktive op math1 atanh

Syntax: __aktive op math1 atanh__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `atanh(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_cbrt'></a> aktive op math1 cbrt

Syntax: __aktive op math1 cbrt__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `cbrt(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_ceil'></a> aktive op math1 ceil

Syntax: __aktive op math1 ceil__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `ceil(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_clamp'></a> aktive op math1 clamp

Syntax: __aktive op math1 clamp__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `clamp(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_cos'></a> aktive op math1 cos

Syntax: __aktive op math1 cos__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `cos(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_cosh'></a> aktive op math1 cosh

Syntax: __aktive op math1 cosh__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `cosh(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_eq'></a> aktive op math1 eq

Syntax: __aktive op math1 eq__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `I == threshold` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|threshold|double||Indicate pixels equal to the scalar threshold|

---
### [↑](#top) <a name='op_math1_exp'></a> aktive op math1 exp

Syntax: __aktive op math1 exp__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `exp(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_exp2'></a> aktive op math1 exp2

Syntax: __aktive op math1 exp2__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `exp2(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_exp10'></a> aktive op math1 exp10

Syntax: __aktive op math1 exp10__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `exp10(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_expx'></a> aktive op math1 expx

Syntax: __aktive op math1 expx__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `pow(base,I)` applied to all pixels of the input.

The image is the first argument of the command, even if not of the function

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|base|double||Power by scalar base|

---
### [↑](#top) <a name='op_math1_fit_mean_stddev'></a> aktive op math1 fit mean-stddev

Syntax: __aktive op math1 fit mean-stddev__ src ?(param value)...? [[→ definition](/file?ci=trunk&ln=338&name=etc/transformer/math/unary.tcl)]

Returns image fitted into the given range. Default range is 0..1.

Each band of the image is fitted separately.

The actual mean and standard deviation of the image bands are used to compute the necessary fit.

BEWARE, this means that construction incurs a computation cost on the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|min|double|0|Minimum value to fit the image to.|
|max|double|1|Maximum value to fit the image to.|
|sigma|double|1.2|Interval around the input mean to fit into the min/max range.|

---
### [↑](#top) <a name='op_math1_fit_min_max'></a> aktive op math1 fit min-max

Syntax: __aktive op math1 fit min-max__ src ?(param value)...? [[→ definition](/file?ci=trunk&ln=310&name=etc/transformer/math/unary.tcl)]

Returns image fitted into the given range. Default range is 0..1.

Each band of the image is fitted separately.

The actual min and max values of the image bands are used to compute the necessary fit. They may be modified by the upper and lower percentiles.

BEWARE, this means that construction incurs a computation cost on the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|min|double|0|Minimum value to fit the image to|
|max|double|1|Maximum value to fit the image to|
|upper|double|1|Upper percentile to apply to input max. Default is 100%|
|lower|double|0|Lower percentile to apply to input min. Default is 0%|

---
### [↑](#top) <a name='op_math1_fit_stretch'></a> aktive op math1 fit stretch

Syntax: __aktive op math1 fit stretch__ src ?(param value)...? [[→ definition](/file?ci=trunk&ln=233&name=etc/transformer/math/unary.tcl)]

Returns image fitted into the given range. Default range is 0..1.

Each band of the image is fitted separately.

The (image statistics) method `<by>` is used to determine the range of the image band values to fit into the destination range. The method is expected to return a list of two values, the min and the max to fit, in this order.

__Beware__, this means that construction incurs a computation cost on the input.

This cost somewhat offset by providing these `min` and `max` values to the caller. It is done by storing the values in the sub-dictionary `stretch` of the meta data dictionary. `stretch` also contains the calculated `scale` and `gain` parameters of the linear mapping. This enables the mapping of fitted values back to the original domain.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|min|double|0|Destination minimum value to fit the image into|
|max|double|1|Destination maximum value to fit the image into|
|by|str||Method computing the input min and max values to fit into the destination.|
|clamp|bool|1|Force clamping into result range.|

---
### [↑](#top) <a name='op_math1_floor'></a> aktive op math1 floor

Syntax: __aktive op math1 floor__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `floor(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_gamma_compress'></a> aktive op math1 gamma compress

Syntax: __aktive op math1 gamma compress__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `compress(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_gamma_expand'></a> aktive op math1 gamma expand

Syntax: __aktive op math1 gamma expand__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `expand(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_ge'></a> aktive op math1 ge

Syntax: __aktive op math1 ge__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `I >= threshold` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|threshold|double||Indicate pixels greater or equal to the scalar threshold|

---
### [↑](#top) <a name='op_math1_gt'></a> aktive op math1 gt

Syntax: __aktive op math1 gt__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `I > threshold` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|threshold|double||Indicate pixels greater than the scalar threshold|

---
### [↑](#top) <a name='op_math1_hypot'></a> aktive op math1 hypot

Syntax: __aktive op math1 hypot__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `hypot(I,y)` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|y|double||Hypot to scalar y|

---
### [↑](#top) <a name='op_math1_inside_cc'></a> aktive op math1 inside-cc

Syntax: __aktive op math1 inside-cc__ src (param value)... [[→ definition](/file?ci=trunk&ln=179&name=etc/transformer/math/unary.tcl)]

Returns image with the double sided thresholding against the closed/closed interval given by the two boundaries applied to all pixels of the input.

Values inside the interval are indicated as `1` in the result.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|low|double||Lower closed boundary|
|high|double||Upper closed boundary|

---
### [↑](#top) <a name='op_math1_inside_co'></a> aktive op math1 inside-co

Syntax: __aktive op math1 inside-co__ src (param value)... [[→ definition](/file?ci=trunk&ln=179&name=etc/transformer/math/unary.tcl)]

Returns image with the double sided thresholding against the closed/open interval given by the two boundaries applied to all pixels of the input.

Values inside the interval are indicated as `1` in the result.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|low|double||Lower closed boundary|
|high|double||Upper open boundary|

---
### [↑](#top) <a name='op_math1_inside_oc'></a> aktive op math1 inside-oc

Syntax: __aktive op math1 inside-oc__ src (param value)... [[→ definition](/file?ci=trunk&ln=179&name=etc/transformer/math/unary.tcl)]

Returns image with the double sided thresholding against the open/closed interval given by the two boundaries applied to all pixels of the input.

Values inside the interval are indicated as `1` in the result.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|low|double||Lower open boundary|
|high|double||Upper closed boundary|

---
### [↑](#top) <a name='op_math1_inside_oo'></a> aktive op math1 inside-oo

Syntax: __aktive op math1 inside-oo__ src (param value)... [[→ definition](/file?ci=trunk&ln=179&name=etc/transformer/math/unary.tcl)]

Returns image with the double sided thresholding against the open/open interval given by the two boundaries applied to all pixels of the input.

Values inside the interval are indicated as `1` in the result.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|low|double||Lower open boundary|
|high|double||Upper open boundary|

---
### [↑](#top) <a name='op_math1_invert'></a> aktive op math1 invert

Syntax: __aktive op math1 invert__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `1-I` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_le'></a> aktive op math1 le

Syntax: __aktive op math1 le__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `I <= threshold` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|threshold|double||Indicate pixels less or equal to the scalar threshold|

---
### [↑](#top) <a name='op_math1_linear'></a> aktive op math1 linear

Syntax: __aktive op math1 linear__ src (param value)... [[→ definition](/file?ci=trunk&ln=218&name=etc/transformer/math/unary.tcl)]

Returns image with the linear transform `(I*scale)+gain` applied to it.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|scale|double||Input scaling factor|
|gain|double||Post-scaling offset|

---
### [↑](#top) <a name='op_math1_log'></a> aktive op math1 log

Syntax: __aktive op math1 log__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `log(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_log2'></a> aktive op math1 log2

Syntax: __aktive op math1 log2__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `log2(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_log10'></a> aktive op math1 log10

Syntax: __aktive op math1 log10__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `log10(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_lt'></a> aktive op math1 lt

Syntax: __aktive op math1 lt__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `I < threshold` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|threshold|double||Indicate pixels less than the scalar threshold|

---
### [↑](#top) <a name='op_math1_max'></a> aktive op math1 max

Syntax: __aktive op math1 max__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `max(I,min)` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|min|double||Limit to greater or equal a scalar min|

---
### [↑](#top) <a name='op_math1_min'></a> aktive op math1 min

Syntax: __aktive op math1 min__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `min(I,max)` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|max|double||Limit to less or equal a scalar max|

---
### [↑](#top) <a name='op_math1_mod'></a> aktive op math1 mod

Syntax: __aktive op math1 mod__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `I % modulus` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|modulus|double||Remainder by scalar modulus|

---
### [↑](#top) <a name='op_math1_modb'></a> aktive op math1 modb

Syntax: __aktive op math1 modb__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `numerator % I` applied to all pixels of the input.

The image is the first argument of the command, even if not of the function

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|numerator|double||Remainder by scalar numerator|

---
### [↑](#top) <a name='op_math1_ne'></a> aktive op math1 ne

Syntax: __aktive op math1 ne__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `I != threshold` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|threshold|double||Indicate pixels different from the scalar threshold|

---
### [↑](#top) <a name='op_math1_neg'></a> aktive op math1 neg

Syntax: __aktive op math1 neg__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `-I` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_neg_shift'></a> aktive op math1 neg-shift

Syntax: __aktive op math1 neg-shift__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `offset-I` applied to all pixels of the input.

The image is the first argument of the command, even if not of the function

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|offset|double||Subtract from scalar offset|

---
### [↑](#top) <a name='op_math1_outside_cc'></a> aktive op math1 outside-cc

Syntax: __aktive op math1 outside-cc__ src (param value)... [[→ definition](/file?ci=trunk&ln=179&name=etc/transformer/math/unary.tcl)]

Returns image with the double sided thresholding against the closed/closed interval given by the two boundaries applied to all pixels of the input.

Values outside the interval are indicated as `1` in the result.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|low|double||Lower closed boundary|
|high|double||Upper closed boundary|

---
### [↑](#top) <a name='op_math1_outside_co'></a> aktive op math1 outside-co

Syntax: __aktive op math1 outside-co__ src (param value)... [[→ definition](/file?ci=trunk&ln=179&name=etc/transformer/math/unary.tcl)]

Returns image with the double sided thresholding against the closed/open interval given by the two boundaries applied to all pixels of the input.

Values outside the interval are indicated as `1` in the result.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|low|double||Lower closed boundary|
|high|double||Upper open boundary|

---
### [↑](#top) <a name='op_math1_outside_oc'></a> aktive op math1 outside-oc

Syntax: __aktive op math1 outside-oc__ src (param value)... [[→ definition](/file?ci=trunk&ln=179&name=etc/transformer/math/unary.tcl)]

Returns image with the double sided thresholding against the open/closed interval given by the two boundaries applied to all pixels of the input.

Values outside the interval are indicated as `1` in the result.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|low|double||Lower open boundary|
|high|double||Upper closed boundary|

---
### [↑](#top) <a name='op_math1_outside_oo'></a> aktive op math1 outside-oo

Syntax: __aktive op math1 outside-oo__ src (param value)... [[→ definition](/file?ci=trunk&ln=179&name=etc/transformer/math/unary.tcl)]

Returns image with the double sided thresholding against the open/open interval given by the two boundaries applied to all pixels of the input.

Values outside the interval are indicated as `1` in the result.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|low|double||Lower open boundary|
|high|double||Upper open boundary|

---
### [↑](#top) <a name='op_math1_pow'></a> aktive op math1 pow

Syntax: __aktive op math1 pow__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `pow(I,exponent)` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|exponent|double||Power by scalar exponent|

---
### [↑](#top) <a name='op_math1_reciproc'></a> aktive op math1 reciproc

Syntax: __aktive op math1 reciproc__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `1/I` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_reciproc_scale'></a> aktive op math1 reciproc-scale

Syntax: __aktive op math1 reciproc-scale__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `factor/I` applied to all pixels of the input.

The image is the first argument of the command, even if not of the function

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|factor|double||Divide from scalar factor|

---
### [↑](#top) <a name='op_math1_round'></a> aktive op math1 round

Syntax: __aktive op math1 round__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `round(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_scale'></a> aktive op math1 scale

Syntax: __aktive op math1 scale__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `I*factor` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|factor|double||Multiply by scalar factor|

---
### [↑](#top) <a name='op_math1_shift'></a> aktive op math1 shift

Syntax: __aktive op math1 shift__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `I+offset` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|offset|double||Add scalar offset|

---
### [↑](#top) <a name='op_math1_sign'></a> aktive op math1 sign

Syntax: __aktive op math1 sign__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `sign(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_sign*'></a> aktive op math1 sign*

Syntax: __aktive op math1 sign*__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `sign*(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_sin'></a> aktive op math1 sin

Syntax: __aktive op math1 sin__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `sin(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_sinh'></a> aktive op math1 sinh

Syntax: __aktive op math1 sinh__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `sinh(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_solarize'></a> aktive op math1 solarize

Syntax: __aktive op math1 solarize__ src (param value)... [[→ definition](/file?ci=trunk&ln=102&name=etc/transformer/math/unary.tcl)]

Returns image with the parameterized unary function `solarize(I,threshold)` applied to all pixels of the input.

The image is the first argument of the command

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|threshold|double||Solarize pixels per the threshold|

---
### [↑](#top) <a name='op_math1_sqrt'></a> aktive op math1 sqrt

Syntax: __aktive op math1 sqrt__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `sqrt(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_square'></a> aktive op math1 square

Syntax: __aktive op math1 square__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `I**2` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_tan'></a> aktive op math1 tan

Syntax: __aktive op math1 tan__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `tan(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_tanh'></a> aktive op math1 tanh

Syntax: __aktive op math1 tanh__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `tanh(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

---
### [↑](#top) <a name='op_math1_wrap'></a> aktive op math1 wrap

Syntax: __aktive op math1 wrap__ src [[→ definition](/file?ci=trunk&ln=16&name=etc/transformer/math/unary.tcl)]

Returns image with the unary function `wrap(I)` applied to all pixels of the input.

The resulting image has the same geometry as the input.

|Input|Description|
|:---|:---|
|src|Source image|

