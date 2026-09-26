<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- math

## <anchor='top'> Table Of Contents

  - [Roots](bysection.md) ↗


### Operators

 - [aktive math least-squares-regression points](#math_least_squares_regression_points)
 - [aktive math least-squares-regression series](#math_least_squares_regression_series)
 - [aktive math polynomial at](#math_polynomial_at)
 - [aktive math polynomial map](#math_polynomial_map)
 - [aktive math polynomial map*](#math_polynomial_map*)

## Operators

---
### [↑](#top) <a name='math_least_squares_regression_points'></a> aktive math least-squares-regression points

Syntax: __aktive math least-squares-regression points__  (param value)... [[→ definition](/file?ci=trunk&ln=10&name=etc/math/regression.tcl)]

Perform a least squares regression of the given order on the specified 2d-points

Returns the coefficients of the best-fitting polynomial of the given order, or less.

The cofficients are listed from lowest to highest order. In other words, the first coefficient is the constant, followed by the values for `x`, `x^2`, etc. The coefficients will not contain trailing zeroes.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|order|str||Regression order. Does accept positive integers > 0, and a few keywords for specific orders. These are `linear`, `quadratic`, and `cubic`.|
|points|double[]||Series of 2d-points|

#### <a name='math_least_squares_regression_points__examples'></a> Examples

<a name='math_least_squares_regression_points__examples__e1'></a><table>
<tr><th>aktive math least-squares-regression points order 1 points $points
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;1.8545454545454554 0.7878787878787881</td></tr>
</table>

<a name='math_least_squares_regression_points__examples__e2'></a><table>
<tr><th>aktive math least-squares-regression points order 2 points $points
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;5.672727272727279 -2.075757575757576 0.31818181818181723</td></tr>
</table>

<a name='math_least_squares_regression_points__examples__e3'></a><table>
<tr><th>aktive math least-squares-regression points order 3 points $points
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;2.5888111888111993 3.5658508158508724 -1.333916083916078 0.12237762237762284</td></tr>
</table>


---
### [↑](#top) <a name='math_least_squares_regression_series'></a> aktive math least-squares-regression series

Syntax: __aktive math least-squares-regression series__  (param value)... [[→ definition](/file?ci=trunk&ln=48&name=etc/math/regression.tcl)]

Perform a least squares regression of the given order on the specified x- and y-series. The two series have to have the same length.

Returns the coefficients of the best-fitting polynomial of the given order, or less.

The cofficients are listed from lowest to highest order. In other words, the first coefficient is the constant, followed by the values for `x`, `x^2`, etc. The coefficients will not contain trailing zeroes.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|order|str||Regression order. Does accept positive integers > 0, and a few keywords for specific orders. These are `linear`, `quadratic`, and `cubic`.|
|xs|double[]||Series of x-coordinates|
|ys|double[]||Series of y-coordinates|

#### <a name='math_least_squares_regression_series__examples'></a> Examples

<a name='math_least_squares_regression_series__examples__e1'></a><table>
<tr><th>aktive math least-squares-regression series order 1 xs $xs ys $ys
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;1.8545454545454554 0.7878787878787881</td></tr>
</table>

<a name='math_least_squares_regression_series__examples__e2'></a><table>
<tr><th>aktive math least-squares-regression series order 2 xs $xs ys $ys
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;5.672727272727279 -2.075757575757576 0.31818181818181723</td></tr>
</table>

<a name='math_least_squares_regression_series__examples__e3'></a><table>
<tr><th>aktive math least-squares-regression series order 3 xs $xs ys $ys
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;2.5888111888111993 3.5658508158508724 -1.333916083916078 0.12237762237762284</td></tr>
</table>


---
### [↑](#top) <a name='math_polynomial_at'></a> aktive math polynomial at

Syntax: __aktive math polynomial at__ coefficients[] x [[→ definition](/file?ci=trunk&ln=62&name=etc/math/polynomials.tcl)]

Evaluate the polynomial given by the coefficients at the specified point

The coefficients are listed from lowest to highest order. In other words, the first coefficient (index 0) is the constant, followed by the values for `x`, `x^2`, etc.

Trailing zeroes are ignored.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|coefficients|double[]||The coefficients of the polynomial. Ordered lowest (x^0) to highest.|
|x|double||The x-value to evaluate the polynomial at.|

#### <a name='math_polynomial_at__examples'></a> Examples

<a name='math_polynomial_at__examples__e1'></a><table>
<tr><th>aktive math polynomial at {1 3} 5
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;16.0</td></tr>
</table>

<a name='math_polynomial_at__examples__e2'></a><table>
<tr><th>aktive math polynomial at {1 3 -2} 2
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;-1.0</td></tr>
</table>

<a name='math_polynomial_at__examples__e3'></a><table>
<tr><th>aktive math polynomial at {1 3 -2 0 0 0 0 0} 2
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;-1.0</td></tr>
</table>


---
### [↑](#top) <a name='math_polynomial_map'></a> aktive math polynomial map

Syntax: __aktive math polynomial map__ coefficients[] xs[] [[→ definition](/file?ci=trunk&ln=8&name=etc/math/polynomials.tcl)]

Evaluate the polynomial given by the coefficients at the series of specified x-values

The cofficients are listed from lowest to highest order. In other words, the first coefficient (index 0) is the constant, followed by the values for `x`, `x^2`, etc.

Trailing zeroes are ignored.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|coefficients|double[]||The coefficients of the polynomial. Ordered lowest (x^0) to highest.|
|xs|double[]||The series of x-values to evaluate the polynomial at.|

#### <a name='math_polynomial_map__examples'></a> Examples

<a name='math_polynomial_map__examples__e1'></a><table>
<tr><th>aktive math polynomial map {1 3} {5 6 7}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;16.0 19.0 22.0</td></tr>
</table>

<a name='math_polynomial_map__examples__e2'></a><table>
<tr><th>aktive math polynomial map {1 3 -2} {2 3 4}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;-1.0 -8.0 -19.0</td></tr>
</table>


---
### [↑](#top) <a name='math_polynomial_map*'></a> aktive math polynomial map*

Syntax: __aktive math polynomial map*__ coefficients[] xs... [[→ definition](/file?ci=trunk&ln=35&name=etc/math/polynomials.tcl)]

Evaluate the polynomial given by the coefficients at the series of specified x-values

The coefficients are listed from lowest to highest order. In other words, the first coefficient (index 0) is the constant, followed by the values for `x`, `x^2`, etc.

Trailing zeroes are ignored.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|coefficients|double[]||The coefficients of the polynomial. Ordered lowest (x^0) to highest.|
|xs|double...||The series of x-values to evaluate the polynomial at.|

#### <a name='math_polynomial_map*__examples'></a> Examples

<a name='math_polynomial_map*__examples__e1'></a><table>
<tr><th>aktive math polynomial map&#42 {1 3} 5 6 7
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;16.0 19.0 22.0</td></tr>
</table>

<a name='math_polynomial_map*__examples__e2'></a><table>
<tr><th>aktive math polynomial map&#42 {1 3 -2} 2 3 4
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;-1.0 -8.0 -19.0</td></tr>
</table>


