<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform math matrix

## <anchor='top'> Table Of Contents

  - [transform math](transform_math.md) ↗


### Operators

 - [aktive op math matrix invert](#op_math_matrix_invert)
 - [aktive op math matrix invert-core](#op_math_matrix_invert_core)
 - [aktive op math matrix multiply](#op_math_matrix_multiply)

## Operators

---
### [↑](#top) <a name='op_math_matrix_invert'></a> aktive op math matrix invert

Syntax: __aktive op math matrix invert__ mat [[→ definition](/file?ci=trunk&ln=5&name=etc/transformer/math/matrix/invert.tcl)]

Treat the input image as matrix and invert it. The image is allowed to be multi-band. Each band is treated as its own matrix.

The input has to be square, i.e. `width == height`. Errors are thrown if this condition is not met.

The input has to be non-singular. If its determinant is zero, then no inverse exists, and an error is thrown.

The result has the same geometry as the input.

See [aktive op math matrix invert-core](transform_math_matrix.md#op_math_matrix_invert_core) for examples

|Input|Description|
|:---|:---|
|mat|Source image|

---
### [↑](#top) <a name='op_math_matrix_invert_core'></a> aktive op math matrix invert-core

Syntax: __aktive op math matrix invert-core__ mat [[→ definition](/file?ci=trunk&ln=33&name=etc/transformer/math/matrix/invert.tcl)]

Treat the single-band input image as matrix and invert it.

The input has to be square, i.e. `width == height`. Errors are thrown if this condition is not met.

The input has to be non-singular. If its determinant is zero, then no inverse exists, and an error is thrown.

The result has the same geometry as the input.

This operator is __strict__ in the first input.

|Input|Description|
|:---|:---|
|mat|The matrix to invert|

#### <a name='op_math_matrix_invert_core__examples'></a> Examples

<a name='op_math_matrix_invert_core__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op math matrix invert-core @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>2</td></tr></table></td>
    <td valign='top'><table><tr><td>0.5</td></tr></table></td></tr>
</table>

<a name='op_math_matrix_invert_core__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op math matrix multiply @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td></tr><tr><td>4</td><td>5</td></tr></table></td>
    <td valign='top'><table><tr><td>-1.6667</td><td>0.6667</td></tr><tr><td>1.3333</td><td>-0.3333</td></tr></table></td>
    <td valign='top'><table><tr><td>1</td><td>0</td></tr><tr><td>0</td><td>1</td></tr></table></td></tr>
</table>

<a name='op_math_matrix_invert_core__examples__e3'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op math matrix multiply @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td><td>3</td></tr><tr><td>4</td><td>5</td><td>6</td></tr><tr><td>7</td><td>8</td><td>8</td></tr></table></td>
    <td valign='top'><table><tr><td>-2.6667</td><td>2.6667</td><td>-1</td></tr><tr><td>3.3333</td><td>-4.3333</td><td>2</td></tr><tr><td>-1</td><td>2</td><td>-1</td></tr></table></td>
    <td valign='top'><table><tr><td>1</td><td>0</td><td>0</td></tr><tr><td>-0</td><td>1</td><td>0</td></tr><tr><td>0</td><td>0</td><td>1</td></tr></table></td></tr>
</table>

<a name='op_math_matrix_invert_core__examples__e4'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op math matrix multiply @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td><td>3</td><td>4</td></tr><tr><td>5</td><td>6</td><td>7</td><td>8</td></tr><tr><td>9</td><td>0</td><td>1</td><td>2</td></tr><tr><td>3</td><td>4</td><td>5</td><td>7</td></tr></table></td>
    <td valign='top'><table><tr><td>-0.15</td><td>0.05</td><td>0.1</td><td>0</td></tr><tr><td>-1.95</td><td>0.15</td><td>-0.2</td><td>1</td></tr><tr><td>2.35</td><td>0.55</td><td>0.1</td><td>-2</td></tr><tr><td>-0.5</td><td>-0.5</td><td>0</td><td>1</td></tr></table></td>
    <td valign='top'><table><tr><td>1</td><td>0</td><td>0</td><td>0</td></tr><tr><td>-0</td><td>1</td><td>-0</td><td>0</td></tr><tr><td>0</td><td>0</td><td>1</td><td>0</td></tr><tr><td>-0</td><td>0</td><td>0</td><td>1</td></tr></table></td></tr>
</table>

<a name='op_math_matrix_invert_core__examples__e5'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op math matrix multiply @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td><td>3</td><td>4</td><td>2</td></tr><tr><td>5</td><td>6</td><td>7</td><td>8</td><td>3</td></tr><tr><td>9</td><td>0</td><td>1</td><td>2</td><td>5</td></tr><tr><td>3</td><td>4</td><td>5</td><td>7</td><td>7</td></tr><tr><td>7</td><td>5</td><td>3</td><td>2</td><td>0</td></tr></table></td>
    <td valign='top'><table><tr><td>0.4545</td><td>-0.1727</td><td>0.1</td><td>-0.1273</td><td>0.1273</td></tr><tr><td>2.4545</td><td>-1.4727</td><td>-0.2</td><td>0.0727</td><td>0.9273</td></tr><tr><td>-1</td><td>5.1</td><td>0.1</td><td>0.6</td><td>-2.6</td></tr><tr><td>7.2727</td><td>-3.3636</td><td>0</td><td>-0.6364</td><td>1.6364</td></tr><tr><td>-1.7273</td><td>0.6364</td><td>0</td><td>0.3636</td><td>-0.3636</td></tr></table></td>
    <td valign='top'><table><tr><td>1</td><td>0</td><td>-0</td><td>-0</td><td>-0</td></tr><tr><td>-0</td><td>1</td><td>-0</td><td>-0</td><td>-0</td></tr><tr><td>-0</td><td>0</td><td>1</td><td>0</td><td>-0</td></tr><tr><td>0</td><td>-0</td><td>-0</td><td>1</td><td>0</td></tr><tr><td>-0</td><td>0</td><td>-0</td><td>-0</td><td>1</td></tr></table></td></tr>
</table>


---
### [↑](#top) <a name='op_math_matrix_multiply'></a> aktive op math matrix multiply

Syntax: __aktive op math matrix multiply__ a b [[→ definition](/file?ci=trunk&ln=5&name=etc/transformer/math/matrix/multiply.tcl)]

Treats the images A and B as matrices and performs a matrix multiplication.

An error is thrown if the necessary condition `width(A) == height(B)` does not hold. Likewise if the two matrices do not have the same depth.

The result geometry (WxHxD) is `width (B)` x `height (A)` x `depth (A)`.

The result image has the same location in the plane as input A. The location of input B does not matter.

The bands of the two inputs are multiplied separately.

|Input|Description|
|:---|:---|
|a|Left matrix of the multiplication|
|b|Right matrix of the multiplication|

#### <a name='op_math_matrix_multiply__examples'></a> Examples

<a name='op_math_matrix_multiply__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op math matrix multiply @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td><td>3</td></tr><tr><td>4</td><td>5</td><td>6</td></tr><tr><td>7</td><td>8</td><td>9</td></tr><tr><td>0</td><td>1</td><td>2</td></tr></table></td>
    <td valign='top'><table><tr><td>9</td><td>8</td><td>7</td><td>6</td></tr><tr><td>5</td><td>4</td><td>3</td><td>2</td></tr><tr><td>1</td><td>0</td><td>9</td><td>8</td></tr></table></td>
    <td valign='top'><table><tr><td>22</td><td>16</td><td>40</td><td>34</td></tr><tr><td>67</td><td>52</td><td>97</td><td>82</td></tr><tr><td>112</td><td>88</td><td>154</td><td>130</td></tr><tr><td>7</td><td>4</td><td>21</td><td>18</td></tr></table></td></tr>
</table>

<a name='op_math_matrix_multiply__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op math matrix multiply @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td><td>3</td></tr><tr><td>4</td><td>5</td><td>6</td></tr><tr><td>7</td><td>8</td><td>8</td></tr></table></td>
    <td valign='top'><table><tr><td>-2.6667</td><td>2.6667</td><td>-1</td></tr><tr><td>3.3333</td><td>-4.3333</td><td>2</td></tr><tr><td>-1</td><td>2</td><td>-1</td></tr></table></td>
    <td valign='top'><table><tr><td>1</td><td>0</td><td>0</td></tr><tr><td>-0</td><td>1</td><td>0</td></tr><tr><td>-0</td><td>0</td><td>1</td></tr></table></td></tr>
</table>

<a name='op_math_matrix_multiply__examples__e3'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op math matrix multiply @1 @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><table><tr><td>1</td><td>2</td></tr><tr><td>4</td><td>5</td></tr></table></td>
    <td valign='top'><table><tr><td>-1.6667</td><td>0.6667</td></tr><tr><td>1.3333</td><td>-0.3333</td></tr></table></td>
    <td valign='top'><table><tr><td>1</td><td>0</td></tr><tr><td>-0</td><td>1</td></tr></table></td></tr>
</table>


