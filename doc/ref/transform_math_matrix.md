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

 - [aktive op math matrix multiply](#op_math_matrix_multiply)

## Operators

---
### [↑](#top) <a name='op_math_matrix_multiply'></a> aktive op math matrix multiply

Syntax: __aktive op math matrix multiply__ a b [[→ definition](/file?ci=trunk&ln=8&name=etc/transformer/math/matrix/multiply.tcl)]

Treats the images A and B as matrices and performs a matrix multiplication.

An error is thrown if the necessary condition `width(A) == `height(B)` does not hold. Likewise if the two matrices do not have the same depth.

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


