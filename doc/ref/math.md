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

 - [aktive math polynomial eval](#math_polynomial_eval)
 - [aktive math regression points](#math_regression_points)
 - [aktive math regression series](#math_regression_series)

## Operators

---
### [↑](#top) <a name='math_polynomial_eval'></a> aktive math polynomial eval

Syntax: __aktive math polynomial eval__ x coefficients... [[→ definition](/file?ci=trunk&ln=9&name=etc/math/polynomials.tcl)]

Evaluate the polynomial given by the coefficients at the specified point

The cofficients are listed from lowest to highest order. In other words, the first coefficient is the contant, followed by the values for `x`, `x^2`, etc.

Trailing zeroes are ignored.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|x|double||The point to evaluate the polynomial at|
|coefficients|double...||The cofficients of the polynomial, from lowest to highest order|

#### <a name='math_polynomial_eval__examples'></a> Examples

<a name='math_polynomial_eval__examples__e1'></a><table>
<tr><th>aktive math polynomial eval 5  1 3
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;16.0</td></tr>
</table>

<a name='math_polynomial_eval__examples__e2'></a><table>
<tr><th>aktive math polynomial eval 2  1 3 -2
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;-1.0</td></tr>
</table>

<a name='math_polynomial_eval__examples__e3'></a><table>
<tr><th>aktive math polynomial eval 2  1 3 -2 0 0 0 0 0
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;-1.0</td></tr>
</table>


---
### [↑](#top) <a name='math_regression_points'></a> aktive math regression points

Syntax: __aktive math regression points__  (param value)... [[→ definition](/file?ci=trunk&ln=6&name=etc/math/regression.tcl)]

Perform a least squares regression of the given order on the specified 2d-points

Returns the coefficients of the best-fitting polynomial of the given order, or less.

The cofficients are listed from lowest to highest order. In other words, the first coefficient is the contant, followed by the values for `x`, `x^2`, etc. The coefficients will not contain trailing zeroes.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|order|str||Regression order. Does accept positive integers > 0, and a few keywords for specific orders. These are `linear`, `quadratic`, and `cubic`.|
|points|str||Series of 2d-points|

#### <a name='math_regression_points__examples'></a> Examples

<a name='math_regression_points__examples__e1'></a><table>
<tr><th>aktive math regression points order 1 points {{0 3} {1 4} {2 5} {3 6} {4 4} {5 2} {6 0} {7 5} {8 10} {9 15}}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;1.8545454545454554 0.7878787878787881</td></tr>
</table>

<a name='math_regression_points__examples__e2'></a><table>
<tr><th>aktive math regression points order 2 points {{0 3} {1 4} {2 5} {3 6} {4 4} {5 2} {6 0} {7 5} {8 10} {9 15}}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;5.672727272727279 -2.075757575757576 0.31818181818181723</td></tr>
</table>

<a name='math_regression_points__examples__e3'></a><table>
<tr><th>aktive math regression points order 3 points {{0 3} {1 4} {2 5} {3 6} {4 4} {5 2} {6 0} {7 5} {8 10} {9 15}}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;2.5888111888111993 3.5658508158508724 -1.333916083916078 0.12237762237762284</td></tr>
</table>


---
### [↑](#top) <a name='math_regression_series'></a> aktive math regression series

Syntax: __aktive math regression series__  (param value)... [[→ definition](/file?ci=trunk&ln=39&name=etc/math/regression.tcl)]

Perform a least squares regression of the given order on the specified x- and y-series.

Returns the coefficients of the best-fitting polynomial of the given order, or less.

The cofficients are listed from lowest to highest order. In other words, the first coefficient is the contant, followed by the values for `x`, `x^2`, etc. The coefficients will not contain trailing zeroes.

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|order|str||Regression order. Does accept positive integers > 0, and a few keywords for specific orders. These are `linear`, `quadratic`, and `cubic`.|
|xs|str||Series of x-coordinates|
|ys|str||Series of y-coordinates|

#### <a name='math_regression_series__examples'></a> Examples

<a name='math_regression_series__examples__e1'></a><table>
<tr><th>aktive math regression series order 1 xs {0 1 2 3 4 5 6 7 8 9} ys {3 4 5 6 4 2 0 5 10 15}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;1.8545454545454554 0.7878787878787881</td></tr>
</table>

<a name='math_regression_series__examples__e2'></a><table>
<tr><th>aktive math regression series order 2 xs {0 1 2 3 4 5 6 7 8 9} ys {3 4 5 6 4 2 0 5 10 15}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;5.672727272727279 -2.075757575757576 0.31818181818181723</td></tr>
</table>

<a name='math_regression_series__examples__e3'></a><table>
<tr><th>aktive math regression series order 3 xs {0 1 2 3 4 5 6 7 8 9} ys {3 4 5 6 4 2 0 5 10 15}
    <br>&nbsp;</th></tr>
<tr><td valign='top'>&nbsp;2.5888111888111993 3.5658508158508724 -1.333916083916078 0.12237762237762284</td></tr>
</table>


