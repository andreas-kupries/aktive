<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- transform convolution

## <anchor='top'> Table Of Contents

  - [transform](transform.md) ↗


### Operators

 - [aktive op convolve xy](#op_convolve_xy)

## Operators

---
### [↑](#top) <a name='op_convolve_xy'></a> aktive op convolve xy

Syntax: __aktive op convolve xy__ kernel src [[→ definition](../../../../file?ci=trunk&ln=15&name=etc/transformer/filter/convolve.tcl)]

Returns the result of convolving the input with the convolution kernel.

This operator is __strict__ in the 1st input. The convolution kernel is materialized and cached.

The location of the kernel image is ignored.

A kernel with even width and/or height is extended at the right/bottom to be of odd width and height.

Beware, the result image is shrunken by kernel `width-1` and `height-1` relative to the input. Inputs smaller than that are rejected.

If shrinkage is not desired add a border to the input using one of the `aktive op embed ...` operators before applying this operator.

The prefered embedding for convolutions is `mirror`. It is chosen to have minimal to no impact on results at the original input's borders.

|Input|Description|
|:---|:---|
|kernel|The convolution kernel. Internally materialized and cached.|
|src|The image to convolve|

#### <a name='op_convolve_xy__examples'></a> Examples

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op convolve xy @2 @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00358.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td>0.0078</td><td>0.0625</td><td>0.2188</td><td>0.4375</td><td>0.5469</td><td>0.4375</td><td>0.2188</td><td>0.0625</td><td>0.0078</td></tr></table></td>
    <td valign='top'><img src='example-00360.gif' alt='aktive op convolve xy @2 @1' style='border:4px solid gold'>
    <br>geometry(4 0 120 128 1)</td></tr>
</table>

<table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>aktive op convolve xy @2 @1
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00361.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><table><tr><td>0.0078</td></tr><tr><td>0.0625</td></tr><tr><td>0.2188</td></tr><tr><td>0.4375</td></tr><tr><td>0.5469</td></tr><tr><td>0.4375</td></tr><tr><td>0.2188</td></tr><tr><td>0.0625</td></tr><tr><td>0.0078</td></tr></table></td>
    <td valign='top'><img src='example-00363.gif' alt='aktive op convolve xy @2 @1' style='border:4px solid gold'>
    <br>geometry(0 4 128 120 1)</td></tr>
</table>


