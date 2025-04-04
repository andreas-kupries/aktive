<img src='../assets/aktive-logo-128.png' style='float:right;'>

||||||||
|---|---|---|---|---|---|---|
|[Project ↗](../../README.md)|[Documentation ↗](../index.md)|&mdash;|[Tutorials ↗](../tutorials.md)|[How To's ↗](../howtos.md)|[Explanations ↗](../explanations.md)|References|

|||||||||
|---|---|---|---|---|---|---|---|
|[Entry ↗](index.md)|&mdash;|[Sections ↘](bysection.md)|[Permuted Sections ↘](bypsection.md)|[Names ↘](byname.md)|[Permuted Names ↘](bypname.md)|[Strict ↘](strict.md)|[Implementations ↘](bylang.md)|

# Documentation -- Reference Pages -- composer

## <anchor='top'> Table Of Contents

  - [Roots](bysection.md) ↗


### Operators

 - [aktive op montage x](#op_montage_x)
 - [aktive op montage x-core](#op_montage_x_core)
 - [aktive op montage x-rep](#op_montage_x_rep)
 - [aktive op montage y](#op_montage_y)
 - [aktive op montage y-core](#op_montage_y_core)
 - [aktive op montage y-rep](#op_montage_y_rep)
 - [aktive op montage z](#op_montage_z)
 - [aktive op montage z-core](#op_montage_z_core)
 - [aktive op montage z-rep](#op_montage_z_rep)

## Operators

---
### [↑](#top) <a name='op_montage_x'></a> aktive op montage x

Syntax: __aktive op montage x__ srcs... [[→ definition](/file?ci=trunk&ln=40&name=etc/composer/montage.tcl)]

Returns image with all inputs joined left to right along the x-axis.

A single input is passed through unchanged.

|Input|Description|
|:---|:---|
|args...|Source images|

#### <a name='op_montage_x__examples'></a> Examples

<a name='op_montage_x__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage x @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00424.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00425.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00426.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00427.gif' alt='aktive op montage x @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 224 128 1)</td></tr>
</table>

<a name='op_montage_x__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage x @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00428.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00429.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00430.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00431.gif' alt='aktive op montage x @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 192 64 1)</td></tr>
</table>


---
### [↑](#top) <a name='op_montage_x_core'></a> aktive op montage x-core

Syntax: __aktive op montage x-core__ src0 src1 [[→ definition](/file?ci=trunk&ln=74&name=etc/composer/montage.tcl)]

Returns image with the 2 inputs joined left to right along the x-axis.

The location of the first image becomes the location of the result.

The other location is ignored.

The width of the result is the sum of the widths of the inputs.

The other dimensions use the maximum of the same over the inputs.

In the result the uncovered parts are zero (black)-filled.

|Input|Description|
|:---|:---|
|src0||
|src1||

---
### [↑](#top) <a name='op_montage_x_rep'></a> aktive op montage x-rep

Syntax: __aktive op montage x-rep__ src (param value)... [[→ definition](/file?ci=trunk&ln=12&name=etc/composer/montage.tcl)]

Returns image with input joined left to right with itself N times along the x-axis.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Replication factor|

#### <a name='op_montage_x_rep__examples'></a> Examples

<a name='op_montage_x_rep__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op montage x-rep @1 by 3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00432.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00433.gif' alt='aktive op montage x-rep @1 by 3' style='border:4px solid gold'>
    <br>geometry(0 0 96 32 1)</td></tr>
</table>


---
### [↑](#top) <a name='op_montage_y'></a> aktive op montage y

Syntax: __aktive op montage y__ srcs... [[→ definition](/file?ci=trunk&ln=40&name=etc/composer/montage.tcl)]

Returns image with all inputs joined top to bottom along the y-axis.

A single input is passed through unchanged.

|Input|Description|
|:---|:---|
|args...|Source images|

#### <a name='op_montage_y__examples'></a> Examples

<a name='op_montage_y__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage y @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00434.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00435.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00436.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00437.gif' alt='aktive op montage y @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 128 224 1)</td></tr>
</table>

<a name='op_montage_y__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage y @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00438.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00439.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00440.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00441.gif' alt='aktive op montage y @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 64 192 1)</td></tr>
</table>


---
### [↑](#top) <a name='op_montage_y_core'></a> aktive op montage y-core

Syntax: __aktive op montage y-core__ src0 src1 [[→ definition](/file?ci=trunk&ln=74&name=etc/composer/montage.tcl)]

Returns image with the 2 inputs joined top to bottom along the y-axis.

The location of the first image becomes the location of the result.

The other location is ignored.

The height of the result is the sum of the heights of the inputs.

The other dimensions use the maximum of the same over the inputs.

In the result the uncovered parts are zero (black)-filled.

|Input|Description|
|:---|:---|
|src0||
|src1||

---
### [↑](#top) <a name='op_montage_y_rep'></a> aktive op montage y-rep

Syntax: __aktive op montage y-rep__ src (param value)... [[→ definition](/file?ci=trunk&ln=12&name=etc/composer/montage.tcl)]

Returns image with input joined top to bottom with itself N times along the y-axis.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Replication factor|

#### <a name='op_montage_y_rep__examples'></a> Examples

<a name='op_montage_y_rep__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op montage y-rep @1 by 3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00442.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00443.gif' alt='aktive op montage y-rep @1 by 3' style='border:4px solid gold'>
    <br>geometry(0 0 32 96 1)</td></tr>
</table>


---
### [↑](#top) <a name='op_montage_z'></a> aktive op montage z

Syntax: __aktive op montage z__ srcs... [[→ definition](/file?ci=trunk&ln=40&name=etc/composer/montage.tcl)]

Returns image with all inputs joined front to back along the z-axis.

A single input is passed through unchanged.

|Input|Description|
|:---|:---|
|args...|Source images|

#### <a name='op_montage_z__examples'></a> Examples

<a name='op_montage_z__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage z @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00444.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00445.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00446.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 1)</td>
    <td valign='top'><img src='example-00447.gif' alt='aktive op montage z @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 128 128 3)</td></tr>
</table>

<a name='op_montage_z__examples__e2'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>@2
    <br>&nbsp;</th>
    <th>@3
    <br>&nbsp;</th>
    <th>aktive op montage z @1 @2 @3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00448.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00449.gif' alt='@2' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00450.gif' alt='@3' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 1)</td>
    <td valign='top'><img src='example-00451.gif' alt='aktive op montage z @1 @2 @3' style='border:4px solid gold'>
    <br>geometry(0 0 64 64 3)</td></tr>
</table>


---
### [↑](#top) <a name='op_montage_z_core'></a> aktive op montage z-core

Syntax: __aktive op montage z-core__ src0 src1 [[→ definition](/file?ci=trunk&ln=74&name=etc/composer/montage.tcl)]

Returns image with the 2 inputs joined front to back along the z-axis.

The location of the first image becomes the location of the result.

The other location is ignored.

The depth of the result is the sum of the depths of the inputs.

The other dimensions use the maximum of the same over the inputs.

In the result the uncovered parts are zero (black)-filled.

|Input|Description|
|:---|:---|
|src0||
|src1||

---
### [↑](#top) <a name='op_montage_z_rep'></a> aktive op montage z-rep

Syntax: __aktive op montage z-rep__ src (param value)... [[→ definition](/file?ci=trunk&ln=12&name=etc/composer/montage.tcl)]

Returns image with input joined front to back with itself N times along the z-axis.

|Input|Description|
|:---|:---|
|src|Source image|

|Parameter|Type|Default|Description|
|:---|:---|:---|:---|
|by|uint||Replication factor|

#### <a name='op_montage_z_rep__examples'></a> Examples

<a name='op_montage_z_rep__examples__e1'></a><table>
<tr><th>@1
    <br>&nbsp;</th>
    <th>aktive op montage z-rep @1 by 3
    <br>&nbsp;</th></tr>
<tr><td valign='top'><img src='example-00452.gif' alt='@1' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 1)</td>
    <td valign='top'><img src='example-00453.gif' alt='aktive op montage z-rep @1 by 3' style='border:4px solid gold'>
    <br>geometry(0 0 32 32 3)</td></tr>
</table>


