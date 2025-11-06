<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform gradient

## <anchor='top'> Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op structure lines](#op_structure_lines)
 - [aktive op structure tensor](#op_structure_tensor)

## Operators

---
### [↑](#top) <a name='op_structure_lines'></a> aktive op structure lines

Syntax: __aktive op structure lines__ src [[→ definition](/file?ci=trunk&ln=61&name=etc/transformer/structure-tensor.tcl)]

Computes and returns the line energy of the input image, based on the [aktive op structure tensor](transform_gradient.md#op_structure_tensor) of the input.

|Input|Description|
|:---|:---|
|src|Source image|

#### <a name='op_structure_lines__examples'></a> Examples

<a name='op_structure_lines__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>({linear light})</th>
    <th>aktive op structure lines @2
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00631.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00632.gif' alt='@2 ({linear light})' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00633.gif' alt='aktive op structure lines @2' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 1)</td></tr>
</table>


---
### [↑](#top) <a name='op_structure_tensor'></a> aktive op structure tensor

Syntax: __aktive op structure tensor__ src ?(param value)...? [[→ definition](/file?ci=trunk&ln=88&name=etc/transformer/structure-tensor.tcl)]

Returns the structure tensor of the input. Expects the input to be in linear light. The tensor is a list of 3 images describing the components of the tensor's matrix. It consists of only three elements because the tensor is symmetric.

The tensor elements are returned in the order top-left, bottom-right (the diagonal), and top-right/bottom-left (the single anti-diagonal element).

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|gradient|str|sobel|Filter kernel to use in the calculation of the axis-aligned dicrete gradient. The name refers into the `aktive image kernel` hierarchy. It will be called as `aktive image kernel <gradient> x` and `aktive image kernel <gradient> y`.|
|lowpass|str|gauss3|Filter kernel to smooth the raw tensor elements with. The name refers into the `aktive image kernel` hierarchy. It will be called as `aktive image kernel <lowpass> xy`.|

#### <a name='op_structure_tensor__examples'></a> Examples

<a name='op_structure_tensor__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>({linear light})</th>
    <th>lindex [aktive op structure tensor @2] 0
    <br>(XX)</th></tr>
<tr><td valign='top'><img src='example-00634.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00635.gif' alt='@2 ({linear light})' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00636.gif' alt='lindex [aktive op structure tensor @2] 0 (XX)' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 1)</td></tr>
</table>

<a name='op_structure_tensor__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>({linear light})</th>
    <th>lindex [aktive op structure tensor @2] 1
    <br>(YY)</th></tr>
<tr><td valign='top'><img src='example-00637.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00638.gif' alt='@2 ({linear light})' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00639.gif' alt='lindex [aktive op structure tensor @2] 1 (YY)' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 1)</td></tr>
</table>

<a name='op_structure_tensor__examples__e3'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>({linear light})</th>
    <th>lindex [aktive op structure tensor @2] 2
    <br>(XY)</th></tr>
<tr><td valign='top'><img src='example-00640.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00641.gif' alt='@2 ({linear light})' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 3)</td>
    <td valign='top'><img src='example-00642.gif' alt='lindex [aktive op structure tensor @2] 2 (XY)' style='border:4px solid gold'>
    <br>geometry(0 0 380 250 1)</td></tr>
</table>


#### <a name='op_structure_tensor__references'></a> References

  - <https://www.cs.cmu.edu/~sarsen/structureTensorTutorial>

  - <https://en.wikipedia.org/wiki/Structure_tensor>

